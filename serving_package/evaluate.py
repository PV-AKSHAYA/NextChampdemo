# evaluate.py
import os
import json
import torch
import pandas as pd
from sklearn.metrics import classification_report, f1_score, accuracy_score
from torch.utils.data import DataLoader

# import dataset and model
from dataset_video import VideoFramesDataset, train_transform, val_transform
from model_multitask import MultiTaskModel

# If dataset_video defines ex2idx / tamp2idx, import them; otherwise define here:
try:
    from dataset_video import ex2idx, tamp2idx
except Exception:
    ex2idx = {'curls':0,'pushups':1,'jumps':2,'situps':3,'squats':4}
    tamp2idx = {'real':0,'0rep':1,'fake':2}

# Reverse maps for reporting
idx2ex = {v:k for k,v in ex2idx.items()}
idx2tamp = {v:k for k,v in tamp2idx.items()}

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
BATCH_SIZE = 8   # eval batch size (increase if you have RAM)
T = 8            # must match inference/training T

def load_weights_safe(path, model, device):
    ckpt = torch.load(path, map_location=device)
    if isinstance(ckpt, dict) and "model_state" in ckpt:
        state = ckpt["model_state"]
    else:
        state = ckpt
    model.load_state_dict(state, strict=False)
    return model

def collate_fn(batch):
    """
    batch: list of tuples (frames_tensor (T,C,H,W), ex_label (str), tamp_label (str))
    Convert labels to tensors of indices.
    """
    frames = [b[0] for b in batch]
    ex_labels = [b[1] for b in batch]
    tamp_labels = [b[2] for b in batch]

    frames = torch.stack(frames, dim=0)  # (B, T, C, H, W)

    # map strings to indices (if already numeric, handle that)
    ex_indices = []
    tamp_indices = []
    for e, t in zip(ex_labels, tamp_labels):
        if isinstance(e, str):
            ex_indices.append(ex2idx[e])
        else:
            ex_indices.append(int(e))
        if isinstance(t, str):
            tamp_indices.append(tamp2idx[t])
        else:
            tamp_indices.append(int(t))
    ex_tensor = torch.tensor(ex_indices, dtype=torch.long)
    tamp_tensor = torch.tensor(tamp_indices, dtype=torch.long)

    return frames, ex_tensor, tamp_tensor

def main():
    # load validation CSV
    val_csv = "dataset/val.csv"
    if not os.path.exists(val_csv):
        raise FileNotFoundError(f"{val_csv} not found")

    val_df = pd.read_csv(val_csv)

    # dataset
    val_ds = VideoFramesDataset(val_df, T=T, transform=val_transform)
    val_loader = DataLoader(val_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=0, collate_fn=collate_fn)

    # load model (weights-only preferred)
    model = MultiTaskModel(pretrained=False).to(DEVICE)
    weights_path_candidates = ["best_model_only.pth", "checkpoint.pth", "best_tamp_model.pth"]
    loaded = False
    for p in weights_path_candidates:
        if os.path.exists(p):
            try:
                model = load_weights_safe(p, model, DEVICE)
                print(f"Loaded weights from {p}")
                loaded = True
                break
            except Exception as e:
                print(f"Failed loading {p}: {e}")
    if not loaded:
        raise FileNotFoundError("No model weights found. Please ensure best_model_only.pth or checkpoint.pth exists.")

    model.eval()

    all_ex_true = []
    all_ex_pred = []
    all_tamp_true = []
    all_tamp_pred = []

    with torch.no_grad():
        for frames, ex_labels, tamp_labels in val_loader:
            # frames: (B, T, C, H, W)
            frames = frames.to(DEVICE).float()
            ex_labels = ex_labels.to(DEVICE)
            tamp_labels = tamp_labels.to(DEVICE)

            ex_logits, tamp_logits = model(frames)
            ex_preds = ex_logits.argmax(dim=1)
            tamp_preds = tamp_logits.argmax(dim=1)

            all_ex_true.extend(ex_labels.cpu().tolist())
            all_ex_pred.extend(ex_preds.cpu().tolist())
            all_tamp_true.extend(tamp_labels.cpu().tolist())
            all_tamp_pred.extend(tamp_preds.cpu().tolist())

    # metrics
    ex_acc = accuracy_score(all_ex_true, all_ex_pred)
    tamp_macro_f1 = f1_score(all_tamp_true, all_tamp_pred, average="macro")

    print("Exercise accuracy:", ex_acc)
    print("Tamper macro-F1:", tamp_macro_f1)
    print("\nExercise classification report:")
    print(classification_report(all_ex_true, all_ex_pred, target_names=[idx2ex[i] for i in range(len(idx2ex))]))
    print("\nTamper classification report:")
    print(classification_report(all_tamp_true, all_tamp_pred, target_names=[idx2tamp[i] for i in range(len(idx2tamp))]))

    # Save compact JSON summary
    summary = {
        "exercise_accuracy": float(ex_acc),
        "tamper_macro_f1": float(tamp_macro_f1),
        "num_val_samples": len(val_ds),
        "exercise_report": classification_report(all_ex_true, all_ex_pred, target_names=[idx2ex[i] for i in range(len(idx2ex))], output_dict=True),
        "tamper_report": classification_report(all_tamp_true, all_tamp_pred, target_names=[idx2tamp[i] for i in range(len(idx2tamp))], output_dict=True)
    }
    with open("eval_report.json", "w", encoding="utf8") as f:
        json.dump(summary, f, indent=2)
    print("Wrote eval_report.json")

if __name__ == "__main__":
    main()
