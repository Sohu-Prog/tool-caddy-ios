#!/usr/bin/env python3

import torch
import torch.nn as nn
import torch.optim as optim
import torchvision.models as models
from torch.utils.data import DataLoader, random_split, Dataset
from torchvision import datasets, transforms
import os
from PIL import Image
import matplotlib.pyplot as plt
from enum import Enum

NUM_CLASSES = 3
BATCH_SIZE = 20
NUM_EPOCHS = 10
LEARNING_RATE = 0.001
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
DATA_DIR = "./Data/train"
MODEL_SAVE_PATH = "./models/mobilenet_v3_large.pth"

DataClasses = Enum("DataClasses", ["Fairway", "Rough", "HardPan"], start=0)
# class DataClasses(Enum):
#     Fairway = 0
#     Rough = 1
#     HardPan = 2

# img processing / dataset loading
transform = transforms.Compose(
    [transforms.Resize((244,244)),
     transforms.ToTensor(),
     transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )

])


class CustomDataset(Dataset):
    def __init__(self, data_dir, transform=None):
        self.data_dir = data_dir
        self.transform = transform
        self.images = []
        self.labels = []

        for root, dirs, files in os.walk(data_dir):
            for file in files:
                if file.endswith("jpg"):
                    file_path = os.path.join(root, file)
                    self.images.append(file_path)
                    self.labels.append(os.path.basename(root))

    def __len__(self):
        return len(self.images)

    def __getitem__(self, index):
        image_path = self.images[index]
        label = DataClasses[self.labels[index]].value
        label = torch.tensor(label)
        image = Image.open(image_path).convert("RGB")

        if self.transform:
            image = self.transform(image)
        
        return image, label 
        

dataset = CustomDataset(DATA_DIR, transform)

train_size = int(0.85 * len(dataset))
val_size = len(dataset) - train_size

train_dataset, val_dataset = random_split(dataset, [train_size, val_size])

train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=True)


# model setup
# weights=MobileNet_V3_Large_Weights.DEFAULT

mv3_model = models.mobilenet_v3_large(pretrained=True)
for param in mv3_model.parameters():
    param.requires_grad = False

# mobile_v3_small = models.mobilenet_v3_small(pretrained=True)

# Modify final layer with a new classifier head
mv3_model.classifier[3] = nn.Linear(in_features=1280, out_features=NUM_CLASSES)


# for layer in mobilenet_v3_large

# define loss function and optimizer:


# Training loop
def train_loop(model, num_epochs):
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.classifier.parameters(), lr=0.01)
    model.train()
    for epoch in range(num_epochs):
        running_loss = 0.0
        
        for inputs, labels in train_loader:
            optimizer.zero_grad()

            # Forward pass
            pred = model(inputs)
            loss = criterion(pred, labels)

            # backward pass
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()

        print(f"Epoch {epoch}/{num_epochs}, Loss: {running_loss/len(train_loader):.4f}")
    return model

# model = train_loop(mv3_model, 5)    

# # Evaluate Model
# model.eval()

# correct = 0
# total = 0

# with torch.no_grad():
#     for inputs, labels in val_loader:
#         output = model(inputs)
#         conf , pred = torch.max(output.data, 1) 
#         total += labels.size(0)
#         correct += (pred == labels).sum().item()

# accuracy = correct / total * 100

# print(f"Validation accuracy: {accuracy:.2f} ")

# torch.save(model.state_dict(), "model_weights.pth")

disp_model = models.mobilenet_v3_large(pretrained=False)
disp_model.classifier[3] = nn.Linear(in_features=1280, out_features=NUM_CLASSES)
disp_model.load_state_dict(torch.load("model_weights.pth"))
disp_model.eval()

# Visualisation:
fig, axes = plt.subplots(1, 3, figsize=(20,10))

images, labels = next(iter(val_loader))
mean=torch.tensor([0.485, 0.456, 0.406]).view(3,1,1)
std=torch.tensor([0.229, 0.224, 0.225]).view(3,1,1)


for i in range(3):
    img, label = images[i], labels[i]

    output = disp_model(img.unsqueeze(0))
    _, predicted = torch.max(output, 1)
    img_denorm = img * std + mean
    axes[i].imshow(transforms.functional.to_pil_image(img_denorm))
    axes[i].set_title(f"Pred = {DataClasses(predicted.item()).name}, actual = {DataClasses(label.item()).name}")
    
plt.tight_layout()
plt.show()

# print("Valset_size: ", val_size)