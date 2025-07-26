# Student Performance Score Predictor

## Mission
Predict student exam scores based on multiple behavioral and academic factors to help educators identify at-risk students and optimize learning outcomes.

## Dataset Description and Source
**Dataset:** Student Performance Factors  
**Source:** [Kaggle - Student Performance Factors](https://www.kaggle.com/datasets/lainguyn123/student-performance-factors)

**Richness:**
- **Volume:** 6,607 student records
- **Variety:** 7 diverse features including:
  - Academic factors (Hours_Studied, Previous_Scores, Tutoring_Sessions)
  - Behavioral factors (Attendance, Sleep_Hours, Physical_Activity)
  - Social factors (Parental_Involvement)
  - Target variable: Exam_Score (55-101 range)

## API Deployment
**Live API:** [Your Render URL here]/docs  
**Swagger Documentation:** [Your Render URL here]/docs

## Mobile App
Flutter mobile application with prediction interface connecting to the deployed API.

## Models Implemented
- Linear Regression
- Random Forest Regressor  
- Decision Tree Regressor
- Best model saved based on lowest loss metrics