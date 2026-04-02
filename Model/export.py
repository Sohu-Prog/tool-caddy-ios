import coremltools as ct
import torch
import torchvision.models as models
import torch.nn as nn
from train_pipeline import ModelWithNorm
NUM_CLASSES = 3


model = models.mobilenet_v3_large(weights=models.MobileNet_V3_Large_Weights.DEFAULT)
model.classifier[3] = nn.Linear(in_features=1280, out_features=NUM_CLASSES)

model = ModelWithNorm(model)


model.load_state_dict(torch.load("normalised_model_weights.pth"))

model.eval()

sample_input = torch.rand(1, 3, 224, 224)
traced = torch.jit.trace(model, sample_input)

coreml_model = ct.convert(traced, 
                          inputs=[ct.ImageType(
                            name="input",
                            shape=(1, 3, 224, 224),
                        )],
                        classifier_config=ct.ClassifierConfig(
                        class_labels=["Fairway", "Rough", "HardPan"]
                        )
                    )

coreml_model.save("MobileNetV3Classifier.mlpackage")


