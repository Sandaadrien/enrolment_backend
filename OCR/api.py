from fastapi import FastAPI, File, HTTPException, UploadFile
from cin_ocr import extraire_cin

app = FastAPI(title="CIN OCR")

@app.post("/ocr/cin")
async def ocr_cin(recto: UploadFile = File(...)):
    data = await recto.read()
    try:
        return extraire_cin(data).to_dict()
    except ValueError as e:
        raise HTTPException(400, str(e))