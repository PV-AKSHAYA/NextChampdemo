# inference_example.py
import torch, json
from torch.nn import functional as F
from dataset_video import get_frame_paths, sample_T_from_list, val_transform, idx2ex, idx2tamp
from model_multitask import MultiTaskModel
from PIL import Image
import os, torch

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def load_frames_from_folder(folder, T=8):
    paths = get_frame_paths(folder)
    chosen = sample_T_from_list(paths, T=T)
    imgs = [Image.open(p).convert('RGB') for p in chosen]
    proc = [val_transform(im) for im in imgs]
    frames = torch.stack(proc, dim=0)   # (T,C,H,W)
    return frames

def predict(folder):
    frames = load_frames_from_folder(folder, T=8)
    x = frames.unsqueeze(0).to(DEVICE)  # (1,T,C,H,W)
    model = MultiTaskModel(pretrained=False)
    model.load_state_dict(torch.load("best_tamp_model.pth", map_location=DEVICE))
    model.to(DEVICE).eval()
    with torch.no_grad():
        ex_logits, tamp_logits = model(x)
        ex_probs = F.softmax(ex_logits, dim=1).cpu().squeeze().numpy()
        tamp_probs = F.softmax(tamp_logits, dim=1).cpu().squeeze().numpy()
    ex_idx = int(ex_probs.argmax())
    tam_idx = int(tamp_probs.argmax())
    out = {
        "exercise": idx2ex[ex_idx],
        "exercise_confidence": float(ex_probs[ex_idx]),
        "tamper_label": idx2tamp[tam_idx],
        "tamper_confidence": float(tamp_probs[tam_idx]),
        "tamper_scores": {"real": float(tamp_probs[0]), "0rep": float(tamp_probs[1]), "fake": float(tamp_probs[2])}
    }
    print(json.dumps(out, indent=2))
    return out

if __name__ == "__main__":
    # example: change this to a folder path with frames
    folder = input("Enter path to folder with frames (one video): ").strip()
    if not os.path.exists(folder):
        print("Folder not found:", folder)
    else:
        predict(folder)
