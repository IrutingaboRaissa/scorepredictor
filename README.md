# EngageMetrics: Student Performance Predictor

EngageMetrics is a comprehensive student performance prediction system that uses machine learning to predict exam scores based on various student metrics. The project consists of three main components:

1. **Machine Learning Model**: A regression model trained on student performance data
2. **FastAPI Backend**: A REST API that serves the trained model
3. **Flutter Mobile App**: A cross-platform mobile application for users to input metrics and get predictions

## Project Structure

```
scorepredictor/
├── EngageMetrics.ipynb        # Jupyter notebook with data analysis and model training
├── api.py                     # FastAPI backend
├── best_model.joblib          # Trained machine learning model
├── scaler.joblib              # Feature scaler for preprocessing
├── requirements.txt           # Python dependencies
├── hosting_guide.md           # Guide for hosting the API on Render
├── engage_metrics_app/        # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart          # Main Flutter app code
│   │   ├── api_service.dart   # Service for API communication
│   │   ├── welcome_page.dart  # Welcome/home page
│   │   └── history_page.dart  # Prediction history page
│   └── ...                    # Other Flutter app files
└── ...
```

## Features

- **Data Analysis**: Correlation analysis to identify key factors affecting student performance
- **Model Comparison**: Evaluation of Linear Regression, Decision Trees, and Random Forest models
- **API Endpoints**: RESTful endpoints for prediction and health checks
- **Mobile App**: User-friendly interface for entering student metrics and viewing predictions
- **Prediction History**: Storage and display of past predictions
- **Input Validation**: Client and server-side validation of input data

## Machine Learning Model

The model is trained on a dataset of student performance factors, focusing on these key metrics:

1. Attendance (%)
2. Parental Engagement (Low=1, Medium=2, High=3)
3. Sleep Hours/week
4. Previous Grades (0-100)
5. Hours Studied/week
6. Tutoring Sessions/week
7. Physical Activity (hours/week)

The notebook includes:
- Data visualization and correlation analysis
- Feature selection and engineering
- Model training and hyperparameter tuning
- Performance comparison between different algorithms
- Learning curves and prediction scatter plots

## API Backend

The FastAPI backend provides:

- `/predict` endpoint for making predictions
- Input validation using Pydantic models
- CORS middleware for cross-origin requests
- Health check and feature information endpoints
- Swagger UI documentation at `/docs`

## Mobile Application

The Flutter app includes:

- Welcome page with app information
- Prediction screen with input fields for all required metrics
- Results display with clear formatting
- History page to view past predictions
- Error handling and loading indicators
- Client-side input validation

## Getting Started

### Prerequisites

- Python 3.8+
- Flutter SDK
- Git

### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd scorepredictor
   ```

2. Install Python dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Install Flutter dependencies:
   ```
   cd engage_metrics_app
   flutter pub get
   ```

### Running the API Locally

```
uvicorn api:app --reload
```

The API will be available at `http://127.0.0.1:8000`.

### Running the Flutter App

```
cd engage_metrics_app
flutter run
```

## Step-by-Step: How to Check API and Run the Flutter App

### 1. Start the FastAPI Server

Open a terminal in the project root and run:
```
uvicorn api:app --reload
```
The API will be available at `http://127.0.0.1:8000`.

### 2. Check if the API is Working

- Open your browser and go to:
  - `http://127.0.0.1:8000/health` (should return `{ "status": "ok" }`)
  - `http://127.0.0.1:8000/docs` (Swagger UI for interactive API testing)
- You can test endpoints like `/predict` directly in Swagger UI.

### 3. Test the Prediction Endpoint

Send a POST request to `/predict` with a JSON body. The features **must be provided in the following order**:

1. Attendance (%)
2. Parental Engagement (Low=1, Medium=2, High=3)
3. Sleep Hours/week
4. Previous Grades (0-100)
5. Hours Studied/week
6. Tutoring Sessions/week
7. Physical Activity (hours/week)

**Example JSON payload:**
```
{
  "features": [
    95,    // Attendance (%)
    2,     // Parental Engagement (Low=1, Medium=2, High=3)
    56,    // Sleep Hours/week
    88,    // Previous Grades (0-100)
    10,    // Hours Studied/week
    1,     // Tutoring Sessions/week
    3      // Physical Activity (hours/week)
  ]
}
```
Replace each value with your input. You can use Swagger UI or a tool like Postman. Make sure the order matches the list above.

### 4. Run the Flutter App

Open a terminal and run:
```
cd engage_metrics_app
flutter pub get
flutter run
```
This will launch the mobile app. Make sure your API is running so the app can connect for predictions.

### 5. Troubleshooting
- If the API does not start, check for missing model files (`best_model.joblib`, `scaler.joblib`).
- If you see errors about missing features, ensure your request matches the required order and number of features.
- For Flutter issues, ensure you have the Flutter SDK installed and dependencies fetched.

## Deployment

See the [hosting guide](hosting_guide.md) for instructions on deploying the API to Render.

## Future Improvements

- Add user authentication
- Implement more advanced models
- Add data visualization in the mobile app
- Create a web interface
- Add support for different educational contexts
- Implement real-time updates and notifications

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Dataset from Kaggle: "Student Performance Factors" by lainguyn123
- Flutter and FastAPI communities for excellent documentation