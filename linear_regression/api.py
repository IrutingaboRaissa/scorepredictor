
# --- FastAPI Imports ---
from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import List
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np
import os
import logging

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
    features: List[float] = Field(
        ...,
        description=(
            "List of features in the following order: "
            "1. Attendance (%), "
            "2. Parental Engagement (Low=1, Medium=2, High=3), "
            "3. Sleep Hours/week, "
            "4. Previous Grades (0-100), "
            "5. Hours Studied/week, "
            "6. Tutoring Sessions/week, "
            "7. Physical Activity (hours/week)"
        ),
        example=[95, 2, 56, 88, 10, 1, 3]
    )

    def validate_length(self):
        if len(self.features) != N_FEATURES:
            raise ValueError(f'Exactly {N_FEATURES} features are required.')

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
        data.validate_length()
        arr = np.array(data.features).reshape(1, -1)
        arr_imputed = imputer.transform(arr)
        arr_scaled = scaler.transform(arr_imputed)
        pred = model.predict(arr_scaled)
        logging.info(f"Prediction result: {pred[0]}")
        return {"prediction": float(pred[0])}
    except Exception as e:
        logging.error(f"Prediction error: {str(e)}")
        return {"error": str(e)}
