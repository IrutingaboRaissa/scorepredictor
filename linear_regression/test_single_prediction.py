# Test prediction on one data point from test dataset
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
import joblib

# Load data and recreate test set
df = pd.read_csv('StudentPerformanceFactors.csv')
df_processed = df.copy()
parental_mapping = {'Low': 1, 'Medium': 2, 'High': 3}
df_processed['Parental_Involvement'] = df_processed['Parental_Involvement'].map(parental_mapping)

features = ['Attendance', 'Parental_Involvement', 'Sleep_Hours', 'Previous_Scores', 
           'Hours_Studied', 'Tutoring_Sessions', 'Physical_Activity']
target = 'Exam_Score'

X = df_processed[features]
y = df_processed[target]

# Split data (same random state as training)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Load saved models
model = joblib.load('best_model.joblib')
scaler = joblib.load('scaler.joblib')
imputer = joblib.load('imputer.joblib')

# Select first row from test set
test_row = X_test.iloc[0:1]  # Keep as DataFrame for consistency
actual_score = y_test.iloc[0]

print("Test Data Point (First row from test set):")
print("=" * 50)
for i, feature in enumerate(features):
    print(f"{feature}: {test_row.iloc[0, i]}")
print(f"Actual Exam Score: {actual_score}")

# Preprocess the single data point
test_imputed = imputer.transform(test_row)
test_scaled = scaler.transform(test_imputed)

# Make prediction
prediction = model.predict(test_scaled)[0]
prediction = max(55, min(101, prediction))  # Ensure realistic range

print("\nPrediction Results:")
print("=" * 50)
print(f"Predicted Exam Score: {prediction:.2f}")
print(f"Actual Exam Score: {actual_score:.2f}")
print(f"Prediction Error: {abs(prediction - actual_score):.2f}")
print(f"Relative Error: {abs(prediction - actual_score) / actual_score * 100:.1f}%")

print("\nSingle data point prediction test completed successfully!")