import requests
import json

# Test the API with sample data
url = "http://127.0.0.1:8000/predict"

# Sample student data
test_data = {
    "attendance": 95.0,
    "parental_involvement": 2,
    "sleep_hours": 7.0,
    "previous_scores": 88.0,
    "hours_studied": 10.0,
    "tutoring_sessions": 1,
    "physical_activity": 3.0
}

try:
    response = requests.post(url, json=test_data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Error: {e}")