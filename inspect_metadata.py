import json
import zipfile
import sys
try:
    with zipfile.ZipFile('assets/ml/chili_disease_model.tflite', 'r') as z:
        print(z.namelist())
        if 'TFLITE_METADATA/metadata.json' in z.namelist():
            print(z.read('TFLITE_METADATA/metadata.json').decode('utf-8'))
        elif 'metadata.json' in z.namelist():
            print(z.read('metadata.json').decode('utf-8'))
except zipfile.BadZipFile:
    print('Not a zip file (no metadata packed as zip).')
except Exception as e:
    print(f'Error: {e}')
