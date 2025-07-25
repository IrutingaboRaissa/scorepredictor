from fastapi import FastAPI
from pydantic import BaseModel, field_validator
from pydantic import Field
from typing import List
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np
import os


# Load model and scaler, require that they exist
if not os.path.exists('best_model.joblib') or not os.path.exists('scaler.joblib'):
    raise FileNotFoundError("best_model.joblib and/or scaler.joblib not found. Please run your notebook and save both files in this folder using joblib.dump().")
model = joblib.load('best_model.joblib')
scaler = joblib.load('scaler.joblib')

# The required order of features for prediction:
FEATURE_NAMES = [
    "Attendance",
    "Parental_Involvement",
    "Sleep_Hours",
    "Previous_Scores",
    "Hours_Studied",
    "Tutoring_Sessions",
    "Physical_Activity"
]
# Set the number of features (update if needed)
N_FEATURES = scaler.mean_.shape[0]

class InputData(BaseModel):
from pydantic import Field

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

    @field_validator('features')
    @classmethod
    def check_ranges_and_length(cls, v):
        if len(v) != N_FEATURES:
            raise ValueError(f'Exactly {N_FEATURES} features are required.')
        for value in v:
            if not (0 <= value <= 100):
                raise ValueError('Each feature must be between 0 and 100')
        return v



import logging


app = FastAPI()

# Health check endpoint
@app.get("/health")
def health():
    return {"status": "ok"}

# Endpoint to get the number of features expected by the model
@app.get("/n_features")
def n_features():
class InputData(BaseModel):

# Root endpoint for friendly message
@app.get("/")
def root():
    return {"message": "Welcome to the EngageMetrics Prediction API. Use the /predict endpoint to get predictions."}

# Allow CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/predict")
def predict(data: InputData):
    logging.info(f"Received prediction request: {data.features}")
    arr = np.array(data.features).reshape(1, -1)
    arr_scaled = scaler.transform(arr)
    pred = model.predict(arr_scaled)
    logging.info(f"Prediction result: {pred[0]}")
    return {"prediction": float(pred[0])}
