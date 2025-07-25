import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import joblib

print("Loading dataset...")
try:
    # Try to load the cleaned dataset first
    df = pd.read_csv('student_performance_cleaned.csv')
    print("Loaded student_performance_cleaned.csv")
except FileNotFoundError:
    # If not found, try the original dataset
    df = pd.read_csv('StudentPerformanceFactors.csv')
    print("Loaded StudentPerformanceFactors.csv")

# Select the 7 features used in the model
selected_features = [
    'Attendance',
    'Parental_Involvement',
    'Sleep_Hours',
    'Previous_Scores',
    'Hours_Studied',
    'Tutoring_Sessions',
    'Physical_Activity'
]

# Ensure all selected features exist in the dataframe
available_features = [f for f in selected_features if f in df.columns]
print(f"Using features: {available_features}")

# Convert categorical to numeric if needed
if 'Parental_Involvement' in df.columns and df['Parental_Involvement'].dtype == 'object':
    involvement_map = {'low': 1, 'medium': 2, 'high': 3}
    df['Parental_Involvement'] = df['Parental_Involvement'].map(involvement_map)

# Prepare data
X = df[available_features]
y = df['Exam_Score']

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Standardize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Save scaler for API use
joblib.dump(scaler, 'scaler.joblib')
print("Successfully created scaler.joblib")