# Serving package — Exercise Tamper Detection

## Run locally (venv)
python -m venv venv
# Linux/macOS: source venv/bin/activate
# Windows (powershell/cmd): venv\Scripts\activate
pip install -r requirements_serving.txt
python model_server.py

Server runs at http://localhost:8000

## Docker
docker build -t exercise-server .
docker run -p 8000:8000 exercise-server

## API endpoints

1) GET /
- Returns health + model load status.
- Example:
  GET http://localhost:8000/
  Response: {"status":"ok","model_loaded": true, "model_path": "best_tamp_model.pth"}

2) POST /predict
- Request JSON:
  {
    "video": "<http-url-or-local-path-to-video>",
    "userId": "user123",
    "testType": "pushups",
    "T": 8,
    "model": "<optional model path override>"
  }
- Example curl:
  curl -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{"video":"https://.../vid.mp4","userId":"u1","testType":"pushups"}'

3) POST /predict_upload
- Multipart form upload: field name `file` (video). Optional form fields: userId, testType, T, model.
- Example curl:
  curl -X POST "http://localhost:8000/predict_upload" -F "file=@/path/video.mp4" -F "userId=user1" -F "testType=pushups"

## Notes
- If model file is large, share weights via cloud (Google Drive/S3) and set MODEL_PATH in model_server.py or pass `"model"` field in requests.
- For testing from mobile device, either host server on public IP, use ngrok, or run backend on a cloud VM.
