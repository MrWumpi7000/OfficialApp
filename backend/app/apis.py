from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form, Query # type: ignore
from fastapi.responses import StreamingResponse # type: ignore
from sqlalchemy.orm import Session # type: ignore
from sqlalchemy import or_, func, desc # type: ignore
from app.models import User, VerificationCode  # Import your models
from app.utils import generate_numeric_code  # Import the utility function for generating numeric codes
from app.utils import hash_password, verify_password, whoami, create_access_token
from app.database import get_db
from app.schemas import RegisterRequest, TokenRequest, LoginRequest, EmailRequest, VerificationRequest
from app.emailutils import send_verification_mail  # Assuming you have an email utility module
from uuid import uuid4
import datetime
import os
import shutil
import random
import string
from datetime import datetime

UPLOAD_DIR = "uploads"

router = APIRouter()

def generate_code(db, length=6):
    while True:
        characters = string.ascii_letters + string.digits
        code = ''.join(random.choices(characters, k=length))
        existing_code = db.query(User).filter(User.six_digit_code == code).first()
        if not existing_code:
            return code

@router.post("/register")
def register_user(request: RegisterRequest, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.username == request.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already taken")
    
    existing_email = db.query(User).filter(User.email == request.email).first()
    if existing_email:
        raise HTTPException(status_code=400, detail="Email already registered")

    code = generate_code(db)

    # Fix: parse birthday string to date or datetime
    try:
        birthday = datetime.strptime(request.birthday, "%Y-%m-%dT%H:%M:%S.%f").date()  # or just .date() if your model uses Date
    except ValueError:
        birthday = datetime.strptime(request.birthday, "%Y-%m-%d").date()  # fallback if no time is sent

    db_user = User(
        username=request.username,
        email=request.email, 
        birthday=birthday,
        profile_image_data=request.profile_image_data,
        six_digit_code=code
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    access_token = create_access_token(data={"email": request.email})

    return {"access_token": access_token, "token_type": "bearer", '6-digit_code': code}

@router.post("/send-verification-code")
def send_verification_code(request: EmailRequest, db: Session = Depends(get_db)):
    code = generate_numeric_code(6)
    # Upsert: if entry exists, update code; else, create new
    entry = db.query(VerificationCode).filter(VerificationCode.email == request.email).first()
    if entry:
        entry.code = code
    else:
        entry = VerificationCode(email=request.email, code=code)
        db.add(entry)
    db.commit()

    send_verification_mail(request.email, code)
    return {"message": "Verification code sent"}

@router.post("/verify-code")
def verify_code(request: VerificationRequest, db: Session = Depends(get_db)):
    entry = db.query(VerificationCode).filter(VerificationCode.email == request.email).first()
    if not entry or entry.code != request.code:
        raise HTTPException(status_code=400, detail="Invalid code or email")

    # Optionally: Delete the code after successful verification
    db.delete(entry)
    db.commit()
    return {"message": "Verification successful"}

@router.post("/login")
def login_user(request: LoginRequest, db: Session = Depends(get_db)):
    username_or_email_lower = request.username_or_email.lower()

    user = db.query(User).filter(
        or_(
            func.lower(User.username) == username_or_email_lower,
            func.lower(User.email) == username_or_email_lower
        )
    ).first()

    if not user:
        raise HTTPException(status_code=400, detail="Invalid username or password")

    if not verify_password(request.password, user.password):
        raise HTTPException(status_code=400, detail="Invalid username or password")

    access_token = create_access_token(data={"email": user.email})

    return {"access_token": access_token, "token_type": "bearer"}
