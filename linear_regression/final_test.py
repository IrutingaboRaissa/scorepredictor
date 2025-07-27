import requests
import json

url = "https://scorepredictor-b45k.onrender.com/predict"
flutter_data = {"features": [95.0, 2, 7.0, 88.0, 10.0, 1, 3.0]}

try:
    response = requests.post(url, json=flutter_data, timeout=15)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"SUCCESS: Prediction = {result['prediction']}")
    else:
        print(f"Error: {response.text}")
except Exception as e:
    print(f"Connection error: {e}")