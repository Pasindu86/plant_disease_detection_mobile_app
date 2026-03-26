"""
Chili Leaf Disease Detection - Model Training Script
=====================================================

This script trains a MobileNetV2-based model to classify chili leaf diseases.

Dataset Structure:
    dataset/
    ├── Bacterial Spot/
    │   ├── image1.jpg
    │   ├── image2.jpg
    │   └── ...
    ├── Cercospora Leaf Spot/
    ├── Curl Virus/
    ├── Healthy Leaf/
    ├── Nutrition Deficiency/
    └── White spot/

Usage:
    1. Place your dataset images in the folder structure above
    2. Run: python train_model.py
    3. The script will produce:
       - chili_disease_model.h5 (Keras model)
       - chili_disease_model.tflite (TFLite model for mobile)
       - labels.txt (class labels)
"""

import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout, BatchNormalization
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint

# ========================= CONFIGURATION =========================
DATASET_DIR = "dataset"          # Path to your dataset folder
IMG_SIZE = 224                    # MobileNetV2 input size
BATCH_SIZE = 32
EPOCHS = 50
VALIDATION_SPLIT = 0.2
SEED = 42

# Disease classes (must match your folder names)
CLASS_NAMES = [
    "Bacterial Spot",
    "Cercospora Leaf Spot",
    "Curl Virus",
    "Healthy Leaf",
    "Nutrition Deficiency",
    "White spot",
]

# ========================= DATA AUGMENTATION =========================
print("📦 Setting up data generators...")

train_datagen = ImageDataGenerator(
    rescale=1.0 / 255.0,
    rotation_range=30,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    vertical_flip=True,
    brightness_range=[0.8, 1.2],
    fill_mode="nearest",
    validation_split=VALIDATION_SPLIT,
)

val_datagen = ImageDataGenerator(
    rescale=1.0 / 255.0,
    validation_split=VALIDATION_SPLIT,
)

train_generator = train_datagen.flow_from_directory(
    DATASET_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="training",
    seed=SEED,
    shuffle=True,
)

val_generator = val_datagen.flow_from_directory(
    DATASET_DIR,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="validation",
    seed=SEED,
    shuffle=False,
)

# Print class mapping
print("\n📋 Class Indices:")
for class_name, index in sorted(train_generator.class_indices.items(), key=lambda x: x[1]):
    print(f"  {index}: {class_name}")

NUM_CLASSES = len(train_generator.class_indices)
print(f"\n✅ Found {train_generator.samples} training images")
print(f"✅ Found {val_generator.samples} validation images")
print(f"✅ Number of classes: {NUM_CLASSES}")

# ========================= BUILD MODEL =========================
print("\n🔧 Building MobileNetV2 model...")

# Load MobileNetV2 with pre-trained ImageNet weights (no top classifier)
base_model = MobileNetV2(
    weights="imagenet",
    include_top=False,
    input_shape=(IMG_SIZE, IMG_SIZE, 3),
)

# Freeze base model layers initially
base_model.trainable = False

# Add custom classification head
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = BatchNormalization()(x)
x = Dense(256, activation="relu")(x)
x = Dropout(0.5)(x)
x = BatchNormalization()(x)
x = Dense(128, activation="relu")(x)
x = Dropout(0.3)(x)
predictions = Dense(NUM_CLASSES, activation="softmax")(x)

model = Model(inputs=base_model.input, outputs=predictions)

model.compile(
    optimizer=Adam(learning_rate=1e-3),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

model.summary()

# ========================= CALLBACKS =========================
callbacks = [
    EarlyStopping(
        monitor="val_accuracy",
        patience=10,
        restore_best_weights=True,
        verbose=1,
    ),
    ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.5,
        patience=5,
        min_lr=1e-7,
        verbose=1,
    ),
    ModelCheckpoint(
        "chili_disease_model_best.h5",
        monitor="val_accuracy",
        save_best_only=True,
        verbose=1,
    ),
]

# ========================= TRAIN (Phase 1: Feature Extraction) =========================
print("\n🚀 Phase 1: Training classifier head (base model frozen)...")

history1 = model.fit(
    train_generator,
    epochs=20,
    validation_data=val_generator,
    callbacks=callbacks,
    verbose=1,
)

# ========================= FINE-TUNING (Phase 2) =========================
print("\n🔓 Phase 2: Fine-tuning top layers of MobileNetV2...")

# Unfreeze last 30 layers of base model for fine-tuning
base_model.trainable = True
for layer in base_model.layers[:-30]:
    layer.trainable = False

# Recompile with lower learning rate
model.compile(
    optimizer=Adam(learning_rate=1e-5),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

history2 = model.fit(
    train_generator,
    epochs=EPOCHS,
    initial_epoch=len(history1.history["loss"]),
    validation_data=val_generator,
    callbacks=callbacks,
    verbose=1,
)

# ========================= EVALUATE =========================
print("\n📊 Evaluating model...")
val_loss, val_accuracy = model.evaluate(val_generator, verbose=1)
print(f"\n✅ Validation Accuracy: {val_accuracy * 100:.2f}%")
print(f"✅ Validation Loss: {val_loss:.4f}")

# ========================= SAVE KERAS MODEL =========================
model.save("chili_disease_model.h5")
print("\n💾 Saved Keras model: chili_disease_model.h5")

# ========================= CONVERT TO TFLITE =========================
print("\n🔄 Converting to TFLite...")

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Quantize for faster inference on mobile
converter.target_spec.supported_types = [tf.float16]

tflite_model = converter.convert()

tflite_path = "chili_disease_model.tflite"
with open(tflite_path, "wb") as f:
    f.write(tflite_model)

print(f"💾 Saved TFLite model: {tflite_path}")
print(f"📏 TFLite model size: {os.path.getsize(tflite_path) / (1024*1024):.2f} MB")

# ========================= SAVE LABELS =========================
# Save labels in the exact order used by the model
sorted_classes = sorted(train_generator.class_indices.items(), key=lambda x: x[1])
labels_path = "labels.txt"
with open(labels_path, "w") as f:
    for class_name, _ in sorted_classes:
        f.write(class_name + "\n")

print(f"💾 Saved labels: {labels_path}")

# ========================= COPY TO FLUTTER ASSETS =========================
import shutil

flutter_assets = os.path.join("..", "assets", "ml")
os.makedirs(flutter_assets, exist_ok=True)

shutil.copy2(tflite_path, os.path.join(flutter_assets, "chili_disease_model.tflite"))
shutil.copy2(labels_path, os.path.join(flutter_assets, "labels.txt"))

print(f"\n✅ Copied model and labels to {flutter_assets}")
print("\n🎉 Training complete! Model is ready for the Flutter app.")
