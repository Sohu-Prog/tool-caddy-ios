import coremltools as ct
import torch
import torchvision.models as models
import torch.nn as nn

NUM_CLASSES = 3

# pretrain=False may be deprecated in future, so use below
# mv3_model = models.mobilenet_v3_large(weights=models.MobileNet_V3_Large_Weights.DEFAULT)

model = models.mobilenet_v3_large(pretrained=False)
model.classifier[3] = nn.Linear(in_features=1280, out_features=NUM_CLASSES)
model.load_state_dict(torch.load("toy_model_weights.pth"))
model.eval()

sample_input = torch.rand(1, 3, 244, 244)
traced = torch.jit.trace(model, sample_input)

coreml_model = ct.convert(traced, 
                          inputs=[ct.ImageType(name="Input", shape = (1,3,244,244))]
                          )

coreml_model.save("MobileNetV3Classifier.mlpackage")


