# 🌶️ Chili Leaf Disease Detection - Model Setup Guide

## Overview

This app uses a **MobileNetV2-based TFLite model** to classify chili leaf diseases into **6 categories**:

| # | Class | Description |
|---|-------|-------------|
| 0 | Bacterial Spot | Dark, water-soaked lesions on leaves |
| 1 | Cercospora Leaf Spot | Circular spots with gray centers |
| 2 | Curl Virus | Curling and distortion of leaves |
| 3 | Healthy Leaf | No disease detected |
| 4 | Nutrition Deficiency | Yellowing, stunted growth |
| 5 | White spot | White powdery patches |

## 🚀 Quick Setup

### Step 1: Prepare Your Dataset

Organize your training images like this:

```
ml_model/
└── dataset/
    ├── Bacterial Spot/
    │   ├── img001.jpg
    │   ├── img002.jpg
    │   └── ...
    ├── Cercospora Leaf Spot/
    │   ├── img001.jpg
    │   └── ...
    ├── Curl Virus/
    │   ├── img001.jpg
    │   └── ...
    ├── Healthy Leaf/
    │   ├── img001.jpg
    │   └── ...
    ├── Nutrition Deficiency/
    │   ├── img001.jpg
    │   └── ...
    └── White spot/
        ├── img001.jpg
        └── ...
```

> **Tip**: Use at least **200+ images per class** for good accuracy.

### Step 2: Install Python Dependencies

```bash
pip install tensorflow numpy pillow
```

### Step 3: Train the Model

```bash
cd ml_model
python train_model.py
```

This will:
- ✅ Train a MobileNetV2 model with transfer learning
- ✅ Apply data augmentation for better accuracy
- ✅ Fine-tune top layers for your specific dataset
- ✅ Save the model as `.h5` and `.tflite`
- ✅ Copy the model to `assets/ml/` automatically

### Step 4 (Alternative): Convert Existing .h5 Model

If you already have a trained `.h5` model:

```bash
cd ml_model
python convert_h5_to_tflite.py path/to/your/model.h5
```

### Step 5: Verify Files

Make sure these files exist:
```
assets/
└── ml/
    ├── chili_disease_model.tflite    ← The model
    └── labels.txt                     ← Class labels
```

### Step 6: Run the App

```bash
flutter pub get
flutter run
```

## 📱 How It Works in the App

1. **Scan Page** → Take a photo or pick from gallery
2. **Preview Page** → See the image and tap "Analyze Leaf"
3. **Result Page** → Shows:
   - 🏷️ Disease name
   - 📊 Confidence percentage
   - 📋 Description & cause
   - ⚠️ Severity level
   - 👁️ Symptoms list
   - 💊 Treatment recommendations
   - 📈 Other possible diseases

## 🔧 Technical Details

- **Model**: MobileNetV2 (transfer learning from ImageNet)
- **Input**: 224×224 RGB image, normalized to [0, 1]
- **Output**: 6-class softmax probabilities
- **Quantization**: Float16 for smaller model size
- **Framework**: TensorFlow Lite via `tflite_flutter` package

## ⚠️ Important Notes

1. **Labels order matters**: The order in `labels.txt` must match the training class order
2. **Model file**: Must be placed in `assets/ml/chili_disease_model.tflite`
3. **Android**: `aaptOptions { noCompress += "tflite" }` is already configured
4. **Image quality**: Better photos = better predictions. Ensure:
   - Good lighting
   - Leaf fills most of the frame
   - Clear, focused image
   - Single leaf per image
