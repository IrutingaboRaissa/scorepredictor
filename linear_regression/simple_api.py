from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import numpy as np

app = FastAPI(title="Student Score Predictor", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class InputData(BaseModel):
    attendance: float
    parental_involvement: int
    sleep_hours: float
    previous_grades: float
    hours_studied: float
    tutoring_sessions: int
    physical_activity: float

@app.get("/")
def root():
    return {"message": "Student Score Predictor API"}

@app.post("/predict")
def predict(data: InputData):
    # Simple linear formula based on your data analysis
    score = (
        data.attendance * 0.3 +
        data.parental_involvement * 5 +
        data.sleep_hours * 2 +
        data.previous_grades * 0.4 +
        data.hours_studied * 0.8 +
        data.tutoring_sessions * 3 +
        data.physical_activity * 1.5
    ) / 10
    
    return {"prediction": max(55, min(101, score))}