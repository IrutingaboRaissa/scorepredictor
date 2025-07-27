import requests
import json

# Test deployed API with both formats
url = "https://scorepredictor-b45k.onrender.com/predict"

# Format 1: Features array (what deployed API expects)
test_data_1 = {
    "features": [95.0, 2, 7.0, 88.0, 10.0, 1, 3.0]
}

# Format 2: Individual fields (what local API expects)
test_data_2 = {
    "attendance": 95.0,
    "parental_involvement": 2,
    "sleep_hours": 7.0,
    "previous_scores": 88.0,
    "hours_studied": 10.0,
    "tutoring_sessions": 1,
    "physical_activity": 3.0
}

print("Testing deployed API with different formats...")
print("=" * 60)

for i, test_data in enumerate([test_data_1, test_data_2], 1):
    print(f"\nFormat {i}: {list(test_data.keys())}")
    try:
        response = requests.post(url, json=test_data, timeout=15)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Prediction: {result['prediction']}")
        else:
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"Connection error: {e}")

print("\nExpected prediction range: 55-101")
print("Manual calculation shows: ~67.63")