
from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import List
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np
import os
import logging
app = FastAPI()

# --- Load Model, Scaler, Imputer ---
MODEL_PATH = 'best_model.joblib'
SCALER_PATH = 'scaler.joblib'
IMPUTER_PATH = 'imputer.joblib'

if not os.path.exists(MODEL_PATH) or not os.path.exists(SCALER_PATH) or not os.path.exists(IMPUTER_PATH):
    raise FileNotFoundError("Required model/scaler/imputer files not found. Please run your notebook and save them using joblib.dump().")
model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)
imputer = joblib.load(IMPUTER_PATH)

# --- Feature Names ---
FEATURE_NAMES = [
    "Attendance",
    "Parental_Involvement",
    "Sleep_Hours",
    "Previous_Scores",
    "Hours_Studied",
    "Tutoring_Sessions",
    "Physical_Activity"
]
N_FEATURES = len(FEATURE_NAMES)

# --- Input Model ---
class InputData(BaseModel):
    attendance: float = Field(..., description="Attendance (%)", example=95)
    parental_involvement: int = Field(..., description="Parental Engagement (Low=1, Medium=2, High=3)", example=2)
    sleep_hours: float = Field(..., description="Sleep Hours/week", example=56)
    previous_grades: float = Field(..., description="Previous Grades (0-100)", example=88)
    hours_studied: float = Field(..., description="Hours Studied/week", example=10)
    tutoring_sessions: int = Field(..., description="Tutoring Sessions/week", example=1)
    physical_activity: float = Field(..., description="Physical Activity (hours/week)", example=3)

    def validate_values(self):
        errors = []
        # Attendance: 0-100
        if not (0 <= self.attendance <= 100):
            errors.append(f"Attendance must be between 0 and 100. Got {self.attendance}")
        # Parental Involvement: 1, 2, or 3
        if self.parental_involvement not in [1, 2, 3]:
            errors.append(f"Parental Involvement must be 1 (Low), 2 (Medium), or 3 (High). Got {self.parental_involvement}")
        # Sleep Hours: 30-65
        if not (30 <= self.sleep_hours <= 65):
            errors.append(f"Sleep Hours must be between 30 and 65. Got {self.sleep_hours}")
        # Previous Grades: 0-100
        if not (0 <= self.previous_grades <= 100):
            errors.append(f"Previous Grades must be between 0 and 100. Got {self.previous_grades}")
        # Hours Studied: 0-50
        if not (0 <= self.hours_studied <= 50):
            errors.append(f"Hours Studied must be between 0 and 50. Got {self.hours_studied}")
        # Tutoring Sessions: 0-7
        if not (0 <= self.tutoring_sessions <= 7):
            errors.append(f"Tutoring Sessions must be between 0 and 7. Got {self.tutoring_sessions}")
        # Physical Activity: 0-14
        if not (0 <= self.physical_activity <= 14):
            errors.append(f"Physical Activity must be between 0 and 14. Got {self.physical_activity}")
        if errors:
            raise ValueError("Input validation errors:\n" + "\n".join(errors))

# --- FastAPI App ---
app = FastAPI()

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Health Check ---
@app.get("/health")
def health():
    return {"status": "ok"}

# --- Feature Count Endpoint ---
@app.get("/n_features")
def n_features():
    return {"n_features": N_FEATURES}

# --- Root Endpoint ---
@app.get("/")
def root():
    return {"message": "Welcome to the EngageMetrics Prediction API. Use the /predict endpoint to get predictions."}

# --- Prediction Endpoint ---
@app.post("/predict")
def predict(data: InputData):
    try:
        data.validate_values()
    except ValueError as ve:
        logging.warning(f"Validation error: {str(ve)}")
        return {"error": str(ve), "type": "validation"}
    except Exception as e:
        logging.error(f"Unexpected error: {str(e)}")
        return {"error": "Unexpected error during validation.", "details": str(e), "type": "internal"}

    try:
        features = [
            data.attendance,
            data.parental_involvement,
            data.sleep_hours,
            data.previous_grades,
            data.hours_studied,
            data.tutoring_sessions,
            data.physical_activity
        ]
        arr = np.array(features).reshape(1, -1)
        arr_imputed = imputer.transform(arr)
        arr_scaled = scaler.transform(arr_imputed)
        pred = model.predict(arr_scaled)
        logging.info(f"Prediction result: {pred[0]}")
        return {"prediction": float(pred[0])}
    except Exception as e:
        logging.error(f"Prediction error: {str(e)}")
        return {"error": "Prediction failed due to server error.", "details": str(e), "type": "internal"}
