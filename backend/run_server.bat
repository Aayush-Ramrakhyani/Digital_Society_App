@echo off
echo Installing dependencies...
pip install -r requirements.txt
echo.
echo Starting Digital Society API server...
echo Server will run at http://localhost:8000
echo API docs at http://localhost:8000/docs
echo.
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
