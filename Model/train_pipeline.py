import torch
import torch.nn as nn
import torchvision.models as models


NUM_CLASSES = 3

# Load MobileNetV3-Large pretrained on ImageNet
mobilenet_v3_large = models.mobilenet_v3_large(pretrained=True)

# mobile_v3_small = models.mobilenet_v3_small(pretrained=True)

mobilenet_v3_large.classifier[3] = nn.Linear(in_features=1280, out_features=NUM_CLASSES)

# Set up data loaders


# Training loop


# Evaluate Model


