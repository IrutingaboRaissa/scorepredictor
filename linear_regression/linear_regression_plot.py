# Linear Regression Scatter Plot with Regression Line
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
import joblib

# Load and preprocess data
df = pd.read_csv('StudentPerformanceFactors.csv')
df_processed = df.copy()
parental_mapping = {'Low': 1, 'Medium': 2, 'High': 3}
df_processed['Parental_Involvement'] = df_processed['Parental_Involvement'].map(parental_mapping)

features = ['Attendance', 'Parental_Involvement', 'Sleep_Hours', 'Previous_Scores', 
           'Hours_Studied', 'Tutoring_Sessions', 'Physical_Activity']
target = 'Exam_Score'

X = df_processed[features]
y = df_processed[target]

# Split and preprocess
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
imputer = SimpleImputer(strategy='mean')
X_train_imputed = imputer.fit_transform(X_train)
X_test_imputed = imputer.transform(X_test)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train_imputed)
X_test_scaled = scaler.transform(X_test_imputed)

# Train Linear Regression
lr_model = LinearRegression()
lr_model.fit(X_train_scaled, y_train)
y_pred_lr = lr_model.predict(X_test_scaled)

# Create scatter plot with regression line
plt.figure(figsize=(12, 8))

# Main scatter plot
plt.scatter(y_test, y_pred_lr, alpha=0.6, color='blue', s=50, label='Predictions')
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2, label='Perfect Prediction Line')

# Add regression line for the scatter
z = np.polyfit(y_test, y_pred_lr, 1)
p = np.poly1d(z)
plt.plot(y_test.sort_values(), p(y_test.sort_values()), "g-", alpha=0.8, linewidth=2, label='Linear Regression Fit')

plt.xlabel('Actual Exam Scores', fontsize=14)
plt.ylabel('Predicted Exam Scores', fontsize=14)
plt.title('Linear Regression: Actual vs Predicted Scores\nwith Regression Line', fontsize=16, fontweight='bold')
plt.grid(True, alpha=0.3)
plt.legend(fontsize=12)

# Add R² score
r2 = r2_score(y_test, y_pred_lr)
plt.text(0.05, 0.95, f'R² = {r2:.3f}', transform=plt.gca().transAxes, 
         fontsize=14, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('linear_regression_scatter.png', dpi=300, bbox_inches='tight')
plt.show()

print(f"Linear Regression R² Score: {r2:.3f}")
print("Linear regression scatter plot with regression line saved!")