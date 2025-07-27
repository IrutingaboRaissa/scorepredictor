import requests
import json

# Test exactly what Flutter app will send
url = "https://scorepredictor-b45k.onrender.com/predict"

# Sample data from Flutter app (7 features in order)
flutter_data = {
    "features": [
        95.0,  # attendance
        2,     # parental_involvement (1=Low, 2=Medium, 3=High)
        7.0,   # sleep_hours
        88.0,  # previous_scores
        10.0,  # hours_studied
        1,     # tutoring_sessions
        3.0    # physical_activity
    ]
}

print("Testing Flutter app format with deployed API...")
print("=" * 50)
print(f"Sending: {flutter_data}")

try:
    response = requests.post(url, json=flutter_data, timeout=15)
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        prediction = result['prediction']
        print(f"✅ SUCCESS: Prediction = {prediction}")
        print(f"Prediction is within expected range (55-101): {55 <= prediction <= 101}")
    else:
        print(f"❌ ERROR: {response.text}")
        
except Exception as e:
    print(f"❌ CONNECTION ERROR: {e}")

print("\nFlutter app should now work correctly with the deployed API!")