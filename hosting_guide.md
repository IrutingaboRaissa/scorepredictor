# Hosting the EngageMetrics API on Render

This guide will walk you through the process of hosting your FastAPI application on Render, which will provide a public URL with Swagger UI documentation.

## Prerequisites

1. Create a free account on [Render](https://render.com/)
2. Make sure your project is in a Git repository (GitHub, GitLab, or Bitbucket)

## Steps to Deploy on Render

### 1. Prepare Your Project

Ensure your project has the following files:

- `requirements.txt` - Contains all the Python dependencies
- `api.py` - Your FastAPI application
- `best_model.joblib` - Your trained model
- `scaler.joblib` - Your data scaler

### 2. Create a New Web Service on Render

1. Log in to your Render account
2. Click on the "New +" button and select "Web Service"
3. Connect your Git repository
4. Configure your web service:
   - **Name**: `engagemetrics-api` (or any name you prefer)
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn api:app --host 0.0.0.0 --port $PORT`
   - **Plan**: Free

5. Click "Create Web Service"

### 3. Wait for Deployment

Render will automatically build and deploy your application. This may take a few minutes.

### 4. Access Your API

Once deployed, you can access your API at the URL provided by Render:
- Main API: `https://your-service-name.onrender.com`
- Swagger UI Documentation: `https://your-service-name.onrender.com/docs`

### 5. Update Your Flutter App

Update the API endpoint in your Flutter app to point to your new public URL:

```dart
// In api_service.dart
Future<double?> getPrediction(List<double> features) async {
  // Replace with your Render URL
  final url = Uri.parse('https://your-service-name.onrender.com/predict');
  
  // Rest of the code remains the same
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'features': features}),
  );
  // ...
}
```

## Troubleshooting

- If your deployment fails, check the logs in the Render dashboard for error messages
- Make sure all required files are included in your repository
- Ensure your `requirements.txt` includes all necessary dependencies
- If your model files are too large for Git, you may need to use Render's persistent disk feature

## Additional Resources

- [Render Documentation](https://render.com/docs)
- [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/)