"""
Convert existing .h5 Keras model to TFLite format for Flutter
==============================================================

If you already have a trained chili_model.h5 file, run this script
to convert it to TFLite format.

Usage:
    python convert_h5_to_tflite.py
"""

import os
import sys
import tensorflow as tf
import shutil


def convert_model(h5_path: str, output_dir: str = "."):
    """Convert a Keras .h5 model to TFLite format."""
    
    print(f"📦 Loading model from: {h5_path}")
    model = tf.keras.models.load_model(h5_path)
    
    # Print model info
    print(f"\n📋 Model Summary:")
    model.summary()
    
    input_shape = model.input_shape
    output_shape = model.output_shape
    num_classes = output_shape[-1]
    
    print(f"\n📐 Input shape: {input_shape}")
    print(f"📐 Output shape: {output_shape}")
    print(f"📐 Number of classes: {num_classes}")
    
    # Convert to TFLite with float16 quantization
    print("\n🔄 Converting to TFLite (float16 quantization)...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    
    tflite_model = converter.convert()
    
    tflite_path = os.path.join(output_dir, "chili_disease_model.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
    
    file_size = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"💾 Saved TFLite model: {tflite_path} ({file_size:.2f} MB)")
    
    # Create labels file
    labels = [
        "Bacterial Spot",
        "Cercospora Leaf Spot", 
        "Curl Virus",
        "Healthy Leaf",
        "Nutrition Deficiency",
        "White spot",
    ]
    
    labels_path = os.path.join(output_dir, "labels.txt")
    with open(labels_path, "w") as f:
        for label in labels:
            f.write(label + "\n")
    print(f"💾 Saved labels: {labels_path}")
    
    # Copy to Flutter assets
    flutter_assets = os.path.join(output_dir, "..", "assets", "ml")
    os.makedirs(flutter_assets, exist_ok=True)
    
    shutil.copy2(tflite_path, os.path.join(flutter_assets, "chili_disease_model.tflite"))
    shutil.copy2(labels_path, os.path.join(flutter_assets, "labels.txt"))
    
    print(f"\n✅ Copied to Flutter assets: {flutter_assets}")
    print("🎉 Conversion complete!")
    
    return tflite_path


if __name__ == "__main__":
    # Default: look for model in lib/models/ or current directory
    possible_paths = [
        os.path.join("..", "lib", "models", "chili_model.h5"),
        "chili_model.h5",
        "chili_disease_model.h5",
    ]
    
    h5_path = None
    if len(sys.argv) > 1:
        h5_path = sys.argv[1]
    else:
        for path in possible_paths:
            if os.path.exists(path):
                h5_path = path
                break
    
    if h5_path is None or not os.path.exists(h5_path):
        print("❌ No .h5 model file found!")
        print("Usage: python convert_h5_to_tflite.py [path_to_model.h5]")
        print(f"Searched: {possible_paths}")
        sys.exit(1)
    
    convert_model(h5_path)
