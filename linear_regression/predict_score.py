import joblib
import numpy as np

def predict_student_score(attendance, parental_involvement, sleep_hours, 
                         previous_scores, hours_studied, tutoring_sessions, 
                         physical_activity):
    """
    Predict student exam score using the best trained model.
    
    Parameters:
    - attendance: float (0-100) - Attendance percentage
    - parental_involvement: int (1-3) - 1=Low, 2=Medium, 3=High
    - sleep_hours: float (4-10) - Daily sleep hours
    - previous_scores: float (0-100) - Previous academic scores
    - hours_studied: float (0-50) - Weekly study hours
    - tutoring_sessions: int (0-8) - Weekly tutoring sessions
    - physical_activity: float (0-6) - Weekly physical activity hours
    
    Returns:
    - predicted_score: float - Predicted exam score
    """
    
    # Load saved models
    model = joblib.load('best_model.joblib')
    scaler = joblib.load('scaler.joblib')
    imputer = joblib.load('imputer.joblib')
    
    # Prepare input features
    features = np.array([[attendance, parental_involvement, sleep_hours, 
                         previous_scores, hours_studied, tutoring_sessions, 
                         physical_activity]])
    
    # Apply preprocessing
    features_imputed = imputer.transform(features)
    features_scaled = scaler.transform(features_imputed)
    
    # Make prediction
    prediction = model.predict(features_scaled)[0]
    
    # Ensure realistic range
    prediction = max(55, min(101, prediction))
    
    return round(prediction, 2)

if __name__ == "__main__":
    # Test the prediction function
    test_prediction = predict_student_score(
        attendance=95.0,
        parental_involvement=2,
        sleep_hours=7.0,
        previous_scores=88.0,
        hours_studied=10.0,
        tutoring_sessions=1,
        physical_activity=3.0
    )
    
    print(f"Test prediction: {test_prediction}")
    print("Prediction function ready for API integration!")