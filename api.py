from fastapi import FastAPI
from pydantic import BaseModel, field_validator
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

# Set the number of features (update if needed)
N_FEATURES = scaler.mean_.shape[0]

class InputData(BaseModel):
    features: List[float]

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
    return {"n_features": N_FEATURES}

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
