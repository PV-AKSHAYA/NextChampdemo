FROM python:3.10-slim

WORKDIR /app
COPY requirements_serving.txt .
RUN pip install --no-cache-dir -r requirements_serving.txt

COPY . /app

EXPOSE 8000
CMD ["uvicorn", "model_server:app", "--host", "0.0.0.0", "--port", "8000"]
