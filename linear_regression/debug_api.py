import requests
import json

# Test both local and deployed API
urls = [
    "http://127.0.0.1:8000/predict",
    "https://scorepredictor-b45k.onrender.com/predict"
]

# Test data matching Flutter app format
test_data = {
    "attendance": 95.0,
    "parental_involvement": 2,
    "sleep_hours": 7.0,
    "previous_scores": 88.0,
    "hours_studied": 10.0,
    "tutoring_sessions": 1,
    "physical_activity": 3.0
}

print("Testing API endpoints...")
print("=" * 50)

for url in urls:
    print(f"\nTesting: {url}")
    try:
        response = requests.post(url, json=test_data, timeout=10)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Prediction: {result['prediction']}")
        else:
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"Connection error: {e}")

# Test with manual calculation
print("\n" + "=" * 50)
print("Manual model test...")
try:
    import joblib
    import numpy as np
    
    model = joblib.load('best_model.joblib')
    scaler = joblib.load('scaler.joblib')
    imputer = joblib.load('imputer.joblib')
    
    features = np.array([[95.0, 2, 7.0, 88.0, 10.0, 1, 3.0]])
    features_imputed = imputer.transform(features)
    features_scaled = scaler.transform(features_imputed)
    prediction = model.predict(features_scaled)[0]
    prediction = max(55, min(101, prediction))
    
    print(f"Direct model prediction: {prediction:.2f}")
    print("Model loaded successfully!")
    
except Exception as e:
    print(f"Model loading error: {e}")