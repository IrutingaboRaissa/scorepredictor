from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
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
    attendance: float = Field(95.0, ge=0, le=100, description="Attendance percentage (0-100)")
    parental_involvement: int = Field(2, ge=1, le=3, description="Parental engagement (1=Low, 2=Medium, 3=High)")
    sleep_hours: float = Field(7.0, ge=4, le=10, description="Sleep hours per day (4-10)")
    previous_scores: float = Field(88.0, ge=0, le=100, description="Previous academic scores (0-100)")
    hours_studied: float = Field(10.0, ge=0, le=50, description="Study hours per week (0-50)")
    tutoring_sessions: int = Field(1, ge=0, le=8, description="Tutoring sessions per week (0-8)")
    physical_activity: float = Field(3.0, ge=0, le=6, description="Physical activity hours per week (0-6)")
    
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

class FeaturesRequest(BaseModel):
    features: list[float]  # List of 7 features in order

@app.get("/")
def root():
    return {"message": "Student Score Predictor API is running"}

@app.post("/predict")
def predict(request: dict):
    """
    Predict student exam score based on performance factors
    Accepts both individual fields and features array
    """
    try:
        # Handle both formats for compatibility
        if 'features' in request and isinstance(request['features'], list):
            # Features array format
            features = request['features']
            if len(features) != 7:
                raise ValueError("Features array must contain exactly 7 values")
        else:
            # Individual fields format
            features = [
                request.get('attendance', 95.0),
                request.get('parental_involvement', 2),
                request.get('sleep_hours', 7.0),
                request.get('previous_scores', 88.0),
                request.get('hours_studied', 10.0),
                request.get('tutoring_sessions', 1),
                request.get('physical_activity', 3.0)
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