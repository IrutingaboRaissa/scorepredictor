# Add these code blocks to your EngageMetrics.ipynb notebook

# 1. LOSS CURVE PLOTS FOR TEST AND TRAIN DATA
# Add this after your model training section


# Imports
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, learning_curve
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
import joblib

# Load data (placeholder, replace with your actual loading code)
try:
    df
except NameError:
    df = pd.read_csv('student_performance_cleaned.csv')

# Define selected_features (placeholder, replace with your actual features)
try:
    selected_features
except NameError:
    selected_features = [
        'Parental_Involvement', 'Study_Hours', 'Attendance',
        'Previous_Scores', 'School_Support', 'Health_Status', 'Socioeconomic_Status'
    ]

# Prepare data

X = df[selected_features]
y = df['Exam_Score']


# Convert categorical to numeric if needed
if 'Parental_Involvement' in X.columns and X['Parental_Involvement'].dtype == 'object':
    involvement_map = {'low': 1, 'medium': 2, 'high': 3}
    X['Parental_Involvement'] = X['Parental_Involvement'].map(involvement_map)


# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)


# Standardize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)


# Save scaler for API use
joblib.dump(scaler, 'scaler.joblib')


# Plot learning curves for Linear Regression
def plot_learning_curve(estimator, title, X, y, ylim=None, cv=None,
                        n_jobs=None, train_sizes=np.linspace(.1, 1.0, 5)):
    plt.figure(figsize=(10, 6))
    plt.title(title)
    if ylim is not None:
        plt.ylim(*ylim)
    plt.xlabel("Training examples")
    plt.ylabel("Mean Squared Error")
    train_sizes, train_scores, test_scores = learning_curve(
        estimator, X, y, cv=cv, n_jobs=n_jobs, train_sizes=train_sizes,
        scoring='neg_mean_squared_error')
    train_scores_mean = -np.mean(train_scores, axis=1)
    train_scores_std = np.std(train_scores, axis=1)
    test_scores_mean = -np.mean(test_scores, axis=1)
    test_scores_std = np.std(test_scores, axis=1)
    plt.grid()
    plt.fill_between(train_sizes, train_scores_mean - train_scores_std,
                     train_scores_mean + train_scores_std, alpha=0.1, color="r")
    plt.fill_between(train_sizes, test_scores_mean - test_scores_std,
                     test_scores_mean + test_scores_std, alpha=0.1, color="g")
    plt.plot(train_sizes, train_scores_mean, 'o-', color="r", label="Training score")
    plt.plot(train_sizes, test_scores_mean, 'o-', color="g", label="Cross-validation score")
    plt.legend(loc="best")
    return plt

# Plot learning curve for Linear Regression
lr = LinearRegression()
plot_learning_curve(lr, "Learning Curve (Linear Regression)", 
                   X_train_scaled, y_train, cv=5)
plt.show()


# 2. SCATTER PLOTS BEFORE AND AFTER
# Add this after your model training

# Train Linear Regression model
lr = LinearRegression()
lr.fit(X_train_scaled, y_train)
y_pred_lr = lr.predict(X_test_scaled)

# Create scatter plot of actual vs predicted values
plt.figure(figsize=(10, 6))
plt.scatter(y_test, y_pred_lr, alpha=0.7)

# Add perfect prediction line
min_val = min(min(y_test), min(y_pred_lr))
max_val = max(max(y_test), max(y_pred_lr))
plt.plot([min_val, max_val], [min_val, max_val], 'r--')

plt.xlabel('Actual Exam Scores')
plt.ylabel('Predicted Exam Scores')
plt.title('Linear Regression: Actual vs Predicted Exam Scores')
plt.grid(True)
plt.show()

# Calculate metrics
mse_lr = mean_squared_error(y_test, y_pred_lr)
r2_lr = r2_score(y_test, y_pred_lr)
print(f"Linear Regression - MSE: {mse_lr:.2f}, R²: {r2_lr:.2f}")


# 3. COMPARE LINEAR REGRESSION, DECISION TREES, AND RANDOM FOREST
# Add this after your model training

# Train models
models = {
    'Linear Regression': LinearRegression(),
    'Decision Tree': DecisionTreeRegressor(random_state=42),
    'Random Forest': RandomForestRegressor(random_state=42, n_estimators=100)
}

# Dictionary to store results
results = {}
predictions = {}

# Train and evaluate each model
for name, model in models.items():
    # Train model
    model.fit(X_train_scaled, y_train)
    
    # Make predictions
    y_pred = model.predict(X_test_scaled)
    predictions[name] = y_pred
    
    # Calculate metrics
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    
    # Store results
    results[name] = {'MSE': mse, 'R²': r2}
    
    print(f"{name} - MSE: {mse:.2f}, R²: {r2:.2f}")

# Plot bar chart comparing model performance
plt.figure(figsize=(12, 6))

# Plot MSE
plt.subplot(1, 2, 1)
plt.bar(results.keys(), [results[model]['MSE'] for model in results.keys()])
plt.title('Mean Squared Error (Lower is Better)')
plt.xticks(rotation=45)
plt.tight_layout()

# Plot R²
plt.subplot(1, 2, 2)
plt.bar(results.keys(), [results[model]['R²'] for model in results.keys()])
plt.title('R² Score (Higher is Better)')
plt.xticks(rotation=45)
plt.tight_layout()

plt.show()

# Determine best model based on lowest MSE
best_model_name = min(results, key=lambda x: results[x]['MSE'])
print(f"Best model based on MSE: {best_model_name}")

# Save the best model
best_model = models[best_model_name]
joblib.dump(best_model, 'best_model.joblib')
print(f"Best model ({best_model_name}) saved as 'best_model.joblib'")