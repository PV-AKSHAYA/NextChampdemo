# model_server.py
"""
FastAPI server wrapper for your existing inference.py

Endpoints:
- POST /predict       -> JSON body: {"video": "<url_or_local_path>", "userId": "u1", "testType": "pushups", "T": 8}
- POST /predict_upload -> multipart form upload: field "file" = video file. Optional form fields: userId, testType, T

Notes:
- This server uses the load_model() and run_inference() functions already present in inference.py.
- Ensure MODEL_PATH in inference.py points to the checkpoint you want, or pass `model` in the JSON body.
"""
import os
import shutil
import tempfile
import traceback
from fastapi import FastAPI, HTTPException, File, UploadFile, Form
from pydantic import BaseModel
from typing import Optional
import uvicorn

# import your functions from inference.py
from inference import load_model, run_inference, MODEL_PATH  # MODEL_PATH optional

app = FastAPI(title="Exercise Tamper Detection - Model Server")

# Global model object (loaded on startup)
MODEL = None
MODEL_PATH_USED = None

class PredictRequest(BaseModel):
    video: str             # local path or HTTP(S) URL
    userId: Optional[str] = "unknown"
    testType: Optional[str] = None
    model: Optional[str] = None    # optional override model path
    T: Optional[int] = None        # optional frame count

@app.on_event("startup")
def startup_event():
    global MODEL, MODEL_PATH_USED
    try:
        # choose model path: use provided MODEL_PATH from inference.py by default
        model_path = getattr(__import__("inference"), "MODEL_PATH", None) or MODEL_PATH
        MODEL = load_model(model_path=model_path)
        MODEL_PATH_USED = model_path
        print(f"Model loaded from {model_path}")
    except Exception as e:
        MODEL = None
        print("Failed to load model on startup. Error:")
        traceback.print_exc()

@app.get("/", status_code=200)
def root():
    return {"status": "ok", "model_loaded": MODEL is not None, "model_path": MODEL_PATH_USED}

@app.post("/predict")
async def predict(req: PredictRequest):
    """
    Accepts JSON with video path/URL and returns inference JSON.
    """
    if MODEL is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")

    # decide model path to pass through to run_inference
    model_path = req.model or MODEL_PATH_USED

    # If video is an HTTP URL, run_inference can handle it (your inference.py already downloads URLs).
    try:
        res = run_inference(
            video_path=req.video,
            userId=req.userId,
            testType=req.testType,
            timestamp=None,
            model_path=model_path,
            T_frames=(req.T if req.T is not None else None),
            device=("cuda" if hasattr(MODEL, "to") and str(next(MODEL.parameters()).device).startswith("cuda") else "cpu")
        )
        return {"success": True, "result": res}
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Inference failed: {str(e)}")

@app.post("/predict_upload")
async def predict_upload(file: UploadFile = File(...), userId: str = Form("unknown"), testType: Optional[str] = Form(None), T: Optional[int] = Form(None), model: Optional[str] = Form(None)):
    """
    Accept a video file upload in multipart/form-data and run inference.
    Returns the inference JSON.
    """
    if MODEL is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")

    # save uploaded file to a temporary file
    tmp_dir = tempfile.mkdtemp(prefix="upload_")
    try:
        suffix = os.path.splitext(file.filename)[1] or ".mp4"
        tmp_path = os.path.join(tmp_dir, "upload" + suffix)
        with open(tmp_path, "wb") as f:
            shutil.copyfileobj(file.file, f)

        model_path = model or MODEL_PATH_USED

        res = run_inference(
            video_path=tmp_path,
            userId=userId,
            testType=testType,
            timestamp=None,
            model_path=model_path,
            T_frames=(int(T) if T is not None else None),
            device=("cuda" if hasattr(MODEL, "to") and str(next(MODEL.parameters()).device).startswith("cuda") else "cpu")
        )

        return {"success": True, "result": res}
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Upload inference failed: {str(e)}")
    finally:
        # cleanup the temp dir
        try:
            shutil.rmtree(tmp_dir)
        except Exception:
            pass

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("model_server:app", host="0.0.0.0", port=port, reload=True)
