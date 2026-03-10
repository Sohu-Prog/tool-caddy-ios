import torch
import torch.nn as nn
import torch.optim as optim
import torchvision.models as models
from torch.utils import DataLoader, random_split
from torchvision import datasets, transforms

NUM_CLASSES = 3
BATCH_SIZE = 20
NUM_EPOCHS = 10
LEARNING_RATE = 0.001
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
DATA_DIR = "./Data/train"
MODEL_SAVE_PATH = "./models/mobilenet_v3_large.pth"


# img processing / dataset loading
transform = transforms.Compose(
    [transforms.Resize((244,244)),
     transforms.ToTensor(),
     transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )

])

dataset = datasets.ImageFolder(root=DATA_DIR, transform=transform)
train_size = int(0.85 * len(dataset))
val_size = len(dataset) - train_size

train_dataset, val_dataset = random_split(dataset, [train_size, val_size])

train_loader = DataLoader(train_dataset, BATCH_SIZE=BATCH_SIZE, shuffle=True)
val_loader = DataLoader(val_dataset, BATCH_SIZE=BATCH_SIZE, shuffle=True)


# model setup

# Load MobileNetV3-Large pretrained on ImageNet
mobilenet_v3_large = models.mobilenet_v3_large(pretrained=True)

# mobile_v3_small = models.mobilenet_v3_small(pretrained=True)

# Modify final layer with a new classifier head
mobilenet_v3_large.classifier[3] = nn.Linear(in_features=1280, out_features=NUM_CLASSES)

# define loss function and optimizer:
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(mobilenet_v3_large.parameters(), lr=0.01)

# Training loop
num_epochs = 5
mobilenet_v3_large.train()
for epoch in range(num_epochs):
    running_loss = 0.0
    
    for inputs, labels in train_loader:
        optimizer.zero_grad()

        # Forward pass
        pred = mobilenet_v3_large(inputs)
        loss = criterion(pred, labels)

        # backward pass
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()

    print(f"Epoch {epoch}/{num_epochs}, Loss: {running_loss/len(train_loader):.4f}")

    

# Evaluate Model
mobilenet_v3_large.eval()

correct = 0
total = 0

with torch.no_grad():
    for inputs, labels in val_loader:
        output = mobilenet_v3_large(inputs)
        conf , pred = torch.max(output.data, 1) 
        total += labels.size(0)
        correct += (pred == labels).sum().item()

accuracy = correct / total * 100

print(f"Validation accuracy: {accuracy:.2f} ")

