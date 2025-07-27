from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import numpy as np
import logging

# Load models
try:
    model = joblib.load('best_model.joblib')
    scaler = joblib.load('scaler.joblib')
    imputer = joblib.load('imputer.joblib')
except Exception as e:
    raise RuntimeError(f"Failed to load models: {e}")

app = FastAPI(title="Student Score Predictor API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PredictionRequest(BaseModel):
    attendance: float = 95.0  # Attendance percentage (0-100)
    parental_involvement: int = 2  # Parental engagement (1=Low, 2=Medium, 3=High)
    sleep_hours: float = 7.0  # Sleep hours per day (4-10)
    previous_scores: float = 88.0  # Previous academic scores (0-100)
    hours_studied: float = 10.0  # Study hours per week (0-50)
    tutoring_sessions: int = 1  # Tutoring sessions per week (0-8)
    physical_activity: float = 3.0  # Physical activity hours per week (0-6)
    
    class Config:
        schema_extra = {
            "example": {
                "attendance": 95.0,
                "parental_involvement": 2,
                "sleep_hours": 7.0,
                "previous_scores": 88.0,
                "hours_studied": 10.0,
                "tutoring_sessions": 1,
                "physical_activity": 3.0
            }
        }

@app.get("/")
def root():
    return {"message": "Student Score Predictor API is running"}

@app.post("/predict")
def predict(request: PredictionRequest):
    """
    Predict student exam score based on performance factors
    """
    try:
        # Extract features from request
        features = [
            request.attendance,
            request.parental_involvement,
            request.sleep_hours,
            request.previous_scores,
            request.hours_studied,
            request.tutoring_sessions,
            request.physical_activity
        ]
        
        # Convert to numpy array
        features_array = np.array([features])
        
        # Process through pipeline
        features_imputed = imputer.transform(features_array)
        features_scaled = scaler.transform(features_imputed)
        
        # Make prediction
        prediction = model.predict(features_scaled)[0]
        
        # Ensure realistic range
        prediction = max(55, min(101, prediction))
        prediction = round(prediction, 1)
        
        return {"prediction": float(prediction)}
        
    except Exception as e:
        logging.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")