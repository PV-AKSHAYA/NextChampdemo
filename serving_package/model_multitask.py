import torch
import torch.nn as nn
from torchvision import models

class MultiTaskModel(nn.Module):
    def __init__(self, backbone_name='resnet18', pretrained=True, feat_dim=512, n_exercises=5, n_tamper=3):
        super().__init__()
        self.backbone = models.resnet18(pretrained=pretrained)
        self.backbone.fc = nn.Identity()   # 512-d feature
        self.feat_dim = feat_dim

        # freeze all layers except last block
        for name, param in self.backbone.named_parameters():
            param.requires_grad = False

        for name, param in self.backbone.layer4.named_parameters():
            param.requires_grad = True
        for name, param in self.backbone.fc.named_parameters():
            param.requires_grad = True
            
        # exercise head
        self.ex_head = nn.Sequential(
            nn.Linear(feat_dim, 128),
            nn.ReLU(),
            nn.Dropout(0.4),
            nn.Linear(128, n_exercises)
        )
        # tamper head
        self.tamp_head = nn.Sequential(
            nn.Linear(feat_dim, 128),
            nn.ReLU(),
            nn.Dropout(0.4),
            nn.Linear(128, n_tamper)
        )

    def forward(self, frames):  # frames: (B, T, C, H, W)
        B, T, C, H, W = frames.shape
        frames = frames.view(B*T, C, H, W)
        feats = self.backbone(frames)          # (B*T, feat_dim)
        feats = feats.view(B, T, -1)           # (B, T, feat_dim)
        pooled = feats.mean(dim=1)             # (B, feat_dim) - temporal avg pooling
        ex_logits = self.ex_head(pooled)       # (B, n_exercises)
        tamp_logits = self.tamp_head(pooled)   # (B, n_tamper)
        return ex_logits, tamp_logits
