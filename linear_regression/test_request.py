import requests
import json

# Test the API
url = "http://127.0.0.1:8000/predict"
data = {"features": [95, 2, 7, 88, 10, 1, 3]}

try:
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Request failed: {e}")