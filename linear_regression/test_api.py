import joblib
import numpy as np

# Test model loading
try:
    model = joblib.load('best_model.joblib')
    scaler = joblib.load('scaler.joblib')
    imputer = joblib.load('imputer.joblib')
    print("[OK] Models loaded successfully")
    print(f"Model type: {type(model)}")
    print(f"Scaler type: {type(scaler)}")
    print(f"Imputer type: {type(imputer)}")
except Exception as e:
    print(f"[ERROR] Model loading failed: {e}")
    exit(1)

# Test prediction
try:
    # Sample features: [attendance, parental_involvement, sleep_hours, previous_grades, hours_studied, tutoring_sessions, physical_activity]
    features = np.array([[95, 2, 7, 88, 10, 1, 3]])
    print(f"Input features shape: {features.shape}")
    
    # Handle missing values
    features_imputed = imputer.transform(features)
    print(f"After imputation: {features_imputed}")
    
    # Scale features
    features_scaled = scaler.transform(features_imputed)
    print(f"After scaling: {features_scaled}")
    
    # Make prediction
    prediction = model.predict(features_scaled)[0]
    print(f"Raw prediction: {prediction}")
    
    # Apply range constraints
    prediction = max(55, min(101, prediction))
    prediction = round(prediction, 1)
    print(f"[OK] Final prediction: {prediction}")
    
except Exception as e:
    print(f"[ERROR] Prediction failed: {e}")
    import traceback
    traceback.print_exc()