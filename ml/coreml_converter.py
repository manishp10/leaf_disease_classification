import argparse
from tensorflow import keras
import numpy as np
import tensorflow as tf
import coremltools as ct
import os

# Parse CLI arguements
parser = argparse.ArgumentParser(description='CoreML Converter')

parser.add_argument('-i', '--input_path', type=str, help='File path to inputs directory', required=True)
parser.add_argument('-o', '--output_path', type=str, help='The path to the output directory', required=True)
parser.add_argument('-n', '--coreml_model_name', type=str, help='Name to give to converted CoreMl model', required=False)

args = parser.parse_args()

INPUTS_DIR = args.input_path
OUTPUT_DIR = args.output_path
CONVERTED_MODEL_NAME = args.coreml_model_name

# List input directory
input_list = os.listdir(INPUTS_DIR)

for input_rel_path in input_list:
    input_path = os.path.join(INPUTS_DIR, input_rel_path)
    # Labels will be in a text file
    if os.path.isfile(input_path):
        labels_path = input_path
    # Saved model will be in a folder
    else:
        saved_model_dir = input_path

print("Loading original model...")
# Load saved model
model = keras.models.load_model(saved_model_dir)

# Load labels
f = open(labels_path, "r")
class_labels = [class_.strip() for class_ in f.readlines()]

print("Model successfully loaded!")

print("Converting to CoreML...")

# Convert model to CoreML
classifier_config = ct.ClassifierConfig(class_labels)
ct_model = ct.convert(model, inputs=[ct.ImageType(color_layout='RGB')], classifier_config= classifier_config)

# Save model to disk
if CONVERTED_MODEL_NAME:
    ct_model_name = f"{CONVERTED_MODEL_NAME}.mlmodel"
else:
    ct_model_name = f"{saved_model_dir}.mlmodel"

ct_model_path = os.path.join(OUTPUT_DIR, ct_model_name)
ct_model.save(ct_model_path)

print("Successfully written converted model to:")
print(f"{ct_model_path}")