# Add this code to your notebook after the model validation section

# Linear Regression Scatter Plot with Regression Line (Required by Rubric)
lr_model = LinearRegression()
lr_model.fit(X_train_scaled, y_train)
y_pred_lr = lr_model.predict(X_test_scaled)

plt.figure(figsize=(10, 6))
plt.scatter(y_test, y_pred_lr, alpha=0.6, color='blue', s=50)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2, label='Perfect Prediction')
z = np.polyfit(y_test, y_pred_lr, 1)
p = np.poly1d(z)
plt.plot(y_test.sort_values(), p(y_test.sort_values()), "g-", alpha=0.8, linewidth=2, label='Linear Fit')
plt.xlabel('Actual Exam Scores')
plt.ylabel('Predicted Exam Scores')
plt.title('Linear Regression: Scatter Plot with Regression Line')
plt.legend()
plt.grid(True, alpha=0.3)
plt.savefig('linear_regression_scatter.png', dpi=300, bbox_inches='tight')
plt.show()
print(f"Linear Regression R² Score: {r2_score(y_test, y_pred_lr):.3f}")

# Single Data Point Prediction Test (Required by Rubric)
test_row = X_test.iloc[0:1]
actual_score = y_test.iloc[0]
test_imputed = imputer.transform(test_row)
test_scaled = scaler.transform(test_imputed)
single_prediction = best_model.predict(test_scaled)[0]
print(f"\nSingle Data Point Test:")
print(f"Actual Score: {actual_score:.2f}")
print(f"Predicted Score: {single_prediction:.2f}")
print(f"Prediction Error: {abs(single_prediction - actual_score):.2f}")