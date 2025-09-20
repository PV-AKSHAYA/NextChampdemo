# # inference.py
# """
# Usage (examples):
#   # local video
#   python inference.py --video "C:\path\to\video.mp4" --userId user123 --testType vertical_jump --out result.json

#   # remote video (will be downloaded to temp)
#   python inference.py --video "https://storage.googleapis.com/..." --userId user123 --testType pushups

# Notes:
# - Requires OpenCV (opencv-python), torch, torchvision, pandas (already in your env).
# - The script uses the multitask model defined in model_multitask.py and dataset transforms in dataset_video.py
# - score is derived from exercise confidence (0-100). If you need physical metrics (jumpHeight), replace the placeholder in compute_physical_score().
# """

# import os
# import sys
# import argparse
# import tempfile
# import datetime
# import json
# import urllib.request
# import shutil

# import cv2
# import numpy as np
# import torch
# import torch.nn.functional as F

# from model_multitask import MultiTaskModel
# import dataset_video as dv

# # ---------- Config ----------
# T = 4                # number of frames to sample (must match training config)
# DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# TAMPER_THRESHOLD = 0.6   # tamper confidence threshold to flag cheating
# MODEL_PATH = "best_tamp_model.pth"
# # ----------------------------

# def download_to_temp(url):
#     tmp = tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(url)[1] or ".mp4")
#     tmp.close()
#     urllib.request.urlretrieve(url, tmp.name)
#     return tmp.name

# def sample_T_frames_from_video(video_path, T=T):
#     """Return list of PIL-like images (numpy arrays in RGB) sampled evenly from video."""
#     cap = cv2.VideoCapture(video_path)
#     if not cap.isOpened():
#         raise RuntimeError(f"Cannot open video: {video_path}")
#     total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT)) or 0

#     frames = []
#     if total <= 0:
#         # read sequentially until end
#         while True:
#             ret, f = cap.read()
#             if not ret:
#                 break
#             frames.append(f)
#     else:
#         # compute indices (evenly spaced)
#         if total >= T:
#             step = total / float(T)
#             idxs = [int(np.floor(i * step)) for i in range(T)]
#         else:
#             # fewer frames than T: repeat last frame
#             idxs = list(range(total)) + [max(total - 1, 0)] * (T - total)

#         for fi in idxs:
#             cap.set(cv2.CAP_PROP_POS_FRAMES, fi)
#             ret, f = cap.read()
#             if not ret:
#                 # create black frame fallback
#                 h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) or 224)
#                 w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) or 224)
#                 f = np.zeros((h, w, 3), dtype=np.uint8)
#             frames.append(f)

#     cap.release()
#     # convert BGR->RGB and to PIL-like numpy arrays
#     rgb_frames = [cv2.cvtColor(f, cv2.COLOR_BGR2RGB) for f in frames]
#     return rgb_frames

# def frames_to_tensor(frames, transform, device=DEVICE):
#     """frames: list of numpy RGB arrays. transform: dataset_video.val_transform (PIL ops)."""
#     from PIL import Image
#     proc = []
#     for arr in frames:
#         img = Image.fromarray(arr)
#         proc.append(transform(img))   # -> (C,H,W) tensor
#     tensor = torch.stack(proc, dim=0)   # (T, C, H, W)
#     tensor = tensor.unsqueeze(0).to(device)  # (1, T, C, H, W)
#     return tensor

# def load_model(model_path=MODEL_PATH):
#     model = MultiTaskModel(pretrained=False)  # pretrained not needed, we load weights
#     state = torch.load(model_path, map_location=DEVICE)
#     try:
#         model.load_state_dict(state)
#     except Exception:
#         # if state dict keys mismatch, try partial load
#         model.load_state_dict(state, strict=False)
#     model.to(DEVICE)
#     model.eval()
#     return model

# def compute_score_from_ex_conf(ex_conf, testType=None):
#     """
#     Simple mapping from exercise confidence (0..1) to a 0..100 score.
#     If you have task-specific scoring (jump height etc.) replace this function.
#     """
#     base = float(ex_conf)
#     return round(base * 100.0, 2)

# def decide_cheat(tamp_label, tamp_conf, threshold=TAMPER_THRESHOLD):
#     # flag cheat if tamper label is not 'real' and confidence exceeds threshold
#     is_cheat = (tamp_label != 'real') and (float(tamp_conf) >= threshold)
#     return bool(is_cheat)

# def make_output_json(userId, testType, videoUrl, ex_label, ex_conf, tamp_label, tamp_conf, tamp_scores, score=None, timestamp=None):
#     if timestamp is None:
#         timestamp = datetime.datetime.utcnow().isoformat() + "Z"
#     if score is None:
#         score = compute_score_from_ex_conf(ex_conf, testType=testType)
#     cheatFlag = decide_cheat(tamp_label, tamp_conf)
#     analysis = {
#         # include both tasks and the raw scores so frontend can display / compute further metrics
#         "exercise": ex_label,
#         "exercise_confidence": round(float(ex_conf), 4),
#         "tamper_label": tamp_label,
#         "tamper_confidence": round(float(tamp_conf), 4),
#         "tamper_scores": {k: round(float(v), 4) for k, v in tamp_scores.items()}
#     }
#     out = {
#         "userId": userId,
#         "testType": testType,
#         "score": float(score),
#         "timestamp": timestamp,
#         "videoUrl": videoUrl,
#         "cheatDetected": cheatFlag,
#         "analysisResults": analysis
#     }
#     return out

# def run_inference(video_path, userId="unknown", testType=None, timestamp=None,
#                   model_path="best_tamp_model.pth", T_frames=8, device="cpu"):
#     import torch
#     import torch.nn.functional as F
#     from torchvision import transforms
#     import os
#     from datetime import datetime

#     # mappings (must match your training setup)
#     idx2exercise = {0: "curls", 1: "pushups", 2: "jumps", 3: "situps", 4: "squats"}
#     idx2tamper = {0: "real", 1: "0rep", 2: "fake"}

#     # --- load model ---
#     from model_multitask import MultiTaskModel
#     model = MultiTaskModel()
#     model.load_state_dict(torch.load(model_path, map_location=device))
#     model.eval()
#     model.to(device)

#     # --- sample frames ---
#     frames_tensor = sample_T_frames_from_video(video_path, T=T_frames)  # (T,C,H,W)
#     frames_tensor = frames_tensor.unsqueeze(0).to(device)  # (1,T,C,H,W)

#     # --- forward pass ---
#     with torch.no_grad():
#         ex_logits, tamp_logits = model(frames_tensor)
#         ex_probs = F.softmax(ex_logits, dim=1)
#         tamp_probs = F.softmax(tamp_logits, dim=1)

#     # --- predictions ---
#     ex_pred_idx = int(torch.argmax(ex_probs))
#     tamp_pred_idx = int(torch.argmax(tamp_probs))

#     pred_exercise = idx2exercise[ex_pred_idx]
#     pred_ex_conf = float(ex_probs[0, ex_pred_idx])
#     pred_tamp = idx2tamper[tamp_pred_idx]
#     pred_tamp_conf = float(tamp_probs[0, tamp_pred_idx])

#     # --- cheating logic ---
#     cheat_detected = False
#     # Rule 1: testType mismatch with low confidence
#     if testType is not None:
#         if testType != pred_exercise and pred_ex_conf < 0.6:
#             cheat_detected = True
#     # Rule 2: low tamper confidence (optional safeguard)
#     if pred_tamp != "real" and pred_tamp_conf < 0.5:
#         cheat_detected = True

#     # --- build result JSON ---
#     if timestamp is None:
#         timestamp = datetime.utcnow().isoformat() + "Z"

#     res = {
#         "userId": userId,
#         "testType": testType,
#         "score": round(float(pred_ex_conf * 100), 2),   # score = % confidence
#         "timestamp": timestamp,
#         "videoUrl": os.path.abspath(video_path),
#         "cheatDetected": cheat_detected,
#         "analysisResults": {
#             "exercise": pred_exercise,
#             "exercise_confidence": round(pred_ex_conf, 4),
#             "tamper_label": pred_tamp,
#             "tamper_confidence": round(pred_tamp_conf, 4),
#             "tamper_scores": {
#                 "real": round(float(tamp_probs[0,0]), 4),
#                 "0rep": round(float(tamp_probs[0,1]), 4),
#                 "fake": round(float(tamp_probs[0,2]), 4),
#             }
#         }
#     }

#     return res


# def main():
#     p = argparse.ArgumentParser()
#     p.add_argument("--video", required=True, help="Path to local video file, or HTTP URL")
#     p.add_argument("--userId", default="userId", help="user identifier to include in output JSON")
#     p.add_argument("--testType", default="vertical_jump", help="test type identifier (e.g., vertical_jump)")
#     p.add_argument("--timestamp", default=None, help="ISO timestamp to include (default=now)")
#     p.add_argument("--model", default=MODEL_PATH, help="path to model checkpoint (best_tamp_model.pth)")
#     p.add_argument("--out", default=None, help="if provided, writes JSON to this file in addition to printing")
#     p.add_argument("--T", type=int, default=T, help="number of frames to sample")
#     args = p.parse_args()

#     res = run_inference(args.video, userId=args.userId, testType=args.testType, timestamp=args.timestamp, model_path=args.model, T_frames=args.T)
#     json_out = json.dumps(res, indent=2)
#     print(json_out)
#     if args.out:
#         with open(args.out, "w", encoding="utf8") as f:
#             f.write(json_out)
#         print("Wrote output to", args.out)

# # if __name__ == "__main__":
#     # main()




# inference.py (UPDATED)
"""
This updated version fixes frame preprocessing bug and adds optional model caching.
"""
import os
import sys
import argparse
import tempfile
import datetime
import json
import urllib.request
import shutil

import cv2
import numpy as np
import torch
import torch.nn.functional as F

from model_multitask import MultiTaskModel
import dataset_video as dv

# ---------- Config ----------
T = 4                # number of frames to sample (must match training config)
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
TAMPER_THRESHOLD = 0.6   # tamper confidence threshold to flag cheating
MODEL_PATH = "best_tamp_model.pth"
# ----------------------------

def download_to_temp(url):
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(url)[1] or ".mp4")
    tmp.close()
    urllib.request.urlretrieve(url, tmp.name)
    return tmp.name

def sample_T_frames_from_video(video_path, T=T):
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise RuntimeError(f"Cannot open video: {video_path}")
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT)) or 0
    frames = []
    if total <= 0:
        while True:
            ret, f = cap.read()
            if not ret:
                break
            frames.append(f)
    else:
        if total >= T:
            step = total / float(T)
            idxs = [int(np.floor(i * step)) for i in range(T)]
        else:
            idxs = list(range(total)) + [max(total - 1, 0)] * (T - total)
        for fi in idxs:
            cap.set(cv2.CAP_PROP_POS_FRAMES, fi)
            ret, f = cap.read()
            if not ret:
                h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) or 224)
                w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) or 224)
                f = np.zeros((h, w, 3), dtype=np.uint8)
            frames.append(f)
    cap.release()
    rgb_frames = [cv2.cvtColor(f, cv2.COLOR_BGR2RGB) for f in frames]
    return rgb_frames

def frames_to_tensor(frames, transform, device=DEVICE):
    from PIL import Image
    proc = [transform(Image.fromarray(arr)) for arr in frames]
    tensor = torch.stack(proc, dim=0)
    tensor = tensor.unsqueeze(0).to(device)
    return tensor

_cached_model = None
def load_model(model_path=MODEL_PATH):
    global _cached_model
    if _cached_model is None:
        model = MultiTaskModel(pretrained=False)
        state = torch.load(model_path, map_location=DEVICE)
        try:
            model.load_state_dict(state)
        except Exception:
            model.load_state_dict(state, strict=False)
        model.to(DEVICE)
        model.eval()
        _cached_model = model
    return _cached_model

def compute_score_from_ex_conf(ex_conf, testType=None):
    base = float(ex_conf)
    return round(base * 100.0, 2)

def decide_cheat(tamp_label, tamp_conf, threshold=TAMPER_THRESHOLD):
    return (tamp_label != 'real') and (float(tamp_conf) >= threshold)

def make_output_json(userId, testType, videoUrl, ex_label, ex_conf, tamp_label, tamp_conf, tamp_scores, score=None, timestamp=None):
    if timestamp is None:
        timestamp = datetime.datetime.utcnow().isoformat() + "Z"
    if score is None:
        score = compute_score_from_ex_conf(ex_conf, testType=testType)
    cheatFlag = decide_cheat(tamp_label, tamp_conf)
    analysis = {
        "exercise": ex_label,
        "exercise_confidence": round(float(ex_conf), 4),
        "tamper_label": tamp_label,
        "tamper_confidence": round(float(tamp_conf), 4),
        "tamper_scores": {k: round(float(v), 4) for k, v in tamp_scores.items()}
    }
    return {
        "userId": userId,
        "testType": testType,
        "score": float(score),
        "timestamp": timestamp,
        "videoUrl": videoUrl,
        "cheatDetected": cheatFlag,
        "analysisResults": analysis
    }

def run_inference(video_path, userId="unknown", testType=None, timestamp=None,
                  model_path=MODEL_PATH, T_frames=8, device=str(DEVICE)):
    import torch
    import torch.nn.functional as F
    from torchvision import transforms
    from datetime import datetime

    device = torch.device(device)
    idx2exercise = {0: "curls", 1: "pushups", 2: "jumps", 3: "situps", 4: "squats"}
    idx2tamper = {0: "real", 1: "0rep", 2: "fake"}

    model = load_model(model_path)
    model.to(device)
    model.eval()

    frames = sample_T_frames_from_video(video_path, T=T_frames)
    try:
        transform = dv.val_transform if not callable(dv.val_transform) else dv.val_transform()
    except Exception:
        from torchvision import transforms
        transform = transforms.Compose([
            transforms.ToPILImage(),
            transforms.Resize((224, 224)),
            transforms.ToTensor()
        ])

    frames_tensor = frames_to_tensor(frames, transform, device=device)

    with torch.no_grad():
        ex_logits, tamp_logits = model(frames_tensor)
        ex_probs = F.softmax(ex_logits, dim=1)
        tamp_probs = F.softmax(tamp_logits, dim=1)

    ex_pred_idx = int(torch.argmax(ex_probs))
    tamp_pred_idx = int(torch.argmax(tamp_probs))

    pred_exercise = idx2exercise[ex_pred_idx]
    pred_ex_conf = float(ex_probs[0, ex_pred_idx])
    pred_tamp = idx2tamper[tamp_pred_idx]
    pred_tamp_conf = float(tamp_probs[0, tamp_pred_idx])

    if timestamp is None:
        timestamp = datetime.utcnow().isoformat() + "Z"

    tamp_scores = {
        "real": float(tamp_probs[0,0]),
        "0rep": float(tamp_probs[0,1]),
        "fake": float(tamp_probs[0,2])
    }

    return make_output_json(userId, testType, os.path.abspath(video_path),
                            pred_exercise, pred_ex_conf, pred_tamp, pred_tamp_conf, tamp_scores,
                            timestamp=timestamp)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--video", required=True)
    p.add_argument("--userId", default="userId")
    p.add_argument("--testType", default="vertical_jump")
    p.add_argument("--timestamp", default=None)
    p.add_argument("--model", default=MODEL_PATH)
    p.add_argument("--out", default=None)
    p.add_argument("--T", type=int, default=T)
    args = p.parse_args()

    res = run_inference(args.video, userId=args.userId, testType=args.testType,
                        timestamp=args.timestamp, model_path=args.model, T_frames=args.T)
    json_out = json.dumps(res, indent=2)
    print(json_out)
    if args.out:
        with open(args.out, "w", encoding="utf8") as f:
            f.write(json_out)
        print("Wrote output to", args.out)

# if __name__ == "__main__":
#     main()
