# dataset_video.py
import os
from PIL import Image
from torch.utils.data import Dataset
from torchvision import transforms
import torch

# Label mappings (must match train script)
ex2idx = {'curls':0,'pushups':1,'jumps':2,'situps':3,'squats':4}
tamp2idx = {'real':0,'0rep':1,'fake':2}
idx2ex = {v:k for k,v in ex2idx.items()}
idx2tamp = {v:k for k,v in tamp2idx.items()}

def get_frame_paths(folder):
    exts = ('.jpg','.jpeg','.png')
    files = [os.path.join(folder,f) for f in sorted(os.listdir(folder)) if f.lower().endswith(exts)]
    return files

def sample_T_from_list(paths, T=8):
    n = len(paths)
    if n == 0:
        raise RuntimeError(f"No frames found in folder: {paths}")
    if n >= T:
        step = n / T
        idxs = [int(i*step) for i in range(T)]
    else:
        # repeat last frame if too few
        idxs = list(range(n)) + [n-1] * (T - n)
    return [paths[i] for i in idxs]

train_transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.RandomResizedCrop(224, scale=(0.8,1.0)),
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(0.2,0.2,0.2,0.05),
    transforms.ToTensor(),
    transforms.RandomRotation(10),
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2),
    transforms.RandomResizedCrop(224, scale=(0.8, 1.0)),
    transforms.Normalize(mean=[0.485,0.456,0.406], std=[0.229,0.224,0.225])
])

val_transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485,0.456,0.406], std=[0.229,0.224,0.225])
])

class VideoFramesDataset(Dataset):
    """
    Expects dataframe with columns: filepath (path to folder of frames), exercise (string), tamper_label (string)
    Returns frames: tensor (T, C, H, W), ex_label (long), tamp_label (long)
    """
    def __init__(self, df, T=8, transform=None):
        self.df = df.reset_index(drop=True)
        self.T = T
        self.transform = transform
    def __len__(self):
        return len(self.df)
    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        folder = row['filepath']
        frames_paths = [os.path.join(folder, f) for f in sorted(os.listdir(folder)) if f.endswith(".jpg")]
        chosen = frames_paths[:self.T]
        imgs = [Image.open(f).convert("RGB") for f in chosen]
        if self.transform:
            imgs = [self.transform(img) for img in imgs]

        frames_tensor = torch.stack(imgs)  # (T, C, H, W)
        ex_label = row['exercise']
        tamp_label = row['tamper_label']
        return frames_tensor, ex_label, tamp_label