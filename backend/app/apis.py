from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form, Query # type: ignore
from fastapi.responses import StreamingResponse # type: ignore
from sqlalchemy.orm import Session # type: ignore
from sqlalchemy import or_, func, desc # type: ignore
from app.models import User, VerificationCode, ResetVerificationCode  # Import your models
from app.utils import generate_numeric_code  # Import the utility function for generating numeric codes
from app.utils import hash_password, verify_password, whoami, create_access_token
from app.database import get_db
from app.schemas import RegisterRequest, TokenRequest, LoginRequest, EmailRequest, VerificationRequest, TokenRequest, ChangePasswordRequest  # Import your schemas
from app.emailutils import send_verification_mail, send_password_reset_code  # Assuming you have an email utility module
from uuid import uuid4
from datetime import datetime, timedelta
import os
import shutil
import base64
import random
import string

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
    # Check if email is already registered
    existing_email = db.query(User).filter(User.email == request.email).first()
    if existing_email:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Generate unique 6-digit code
    code = generate_code(db)

    # Parse birthday
    try:
        birthday = datetime.strptime(request.birthday, "%Y-%m-%dT%H:%M:%S.%f").date()
    except ValueError:
        birthday = datetime.strptime(request.birthday, "%Y-%m-%d").date()

    # Hash the password before storing it
    hashed_password = hash_password(request.password)
    profile_image_extension = request.profile_image_extension.lower() if request.profile_image_extension else None

    # Default to no_profile.jpg
    default_image_path = "backend/app/assets/no_profile.jpg"
    profile_image_data = default_image_path

    db_user = User(
        username=request.username,
        email=request.email, 
        birthday=birthday,
        profile_image_data=profile_image_data,
        profile_image_extension=profile_image_extension,
        six_digit_code=code,
        password=hashed_password,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    # Save the image file if provided
    if request.profile_image_data and profile_image_extension:
        try:
            image_data = base64.b64decode(request.profile_image_data)
        except Exception as e:
            db.rollback()  # Rollback the transaction if image decoding fails
            print(f"Base64 decode error: {e}")
            raise HTTPException(status_code=400, detail="Invalid base64 image data")

        upload_dir = "uploads"
        os.makedirs(upload_dir, exist_ok=True)
        filename = f"user_{db_user.id}.{profile_image_extension}"
        file_path = os.path.join(upload_dir, filename)
        with open(file_path, "wb") as f:
            f.write(image_data)

        # Update to use uploaded image path
        db_user.profile_image_data = file_path
        db.commit()

    access_token = create_access_token(data={"email": request.email})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "6-digit_code": code
    }
@router.post("/send-verification-code")
def send_verification_code(request: EmailRequest, db: Session = Depends(get_db)):
    code = generate_numeric_code(6)
    # Upsert: if entry exists, update code; else, create new
    email_exists = db.query(User).filter(User.email == request.email).first()
    if email_exists:
        raise HTTPException(status_code=400, detail="Email already registered")
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
    email = request.email.lower()

    user = db.query(User).filter(
        or_(
            func.lower(User.email) == email
        )
    ).first()

    if not user:
        raise HTTPException(status_code=400, detail="Invalid email or password")

    if not verify_password(request.password, user.password):
        raise HTTPException(status_code=400, detail="Invalid email or password")

    access_token = create_access_token(data={"email": user.email})
    
    six_digit_code = user.six_digit_code if user.six_digit_code else None
    
    return {"access_token": access_token, "token_type": "bearer", "6-digit_code": six_digit_code}

@router.post("/reset-password")
def reset_password(request: EmailRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Generate and save code
    reset_code = generate_numeric_code(6)
    expires_at = datetime.utcnow() + timedelta(minutes=15)  # code valid for 15 mins

    # Remove any existing code for this email
    db.query(ResetVerificationCode).filter(ResetVerificationCode.email == request.email).delete()
    db.add(ResetVerificationCode(
        email=request.email,
        code=reset_code,
        expires_at=expires_at
    ))
    db.commit()

    send_password_reset_code(request.email, reset_code)
    return {"message": "Password reset code sent"}

@router.post("/password-reset/verify")
def verify_password_reset_code(request: VerificationRequest, db: Session = Depends(get_db)):
    entry = db.query(ResetVerificationCode).filter(ResetVerificationCode.email == request.email).first()
    if not entry or entry.code != request.code or entry.is_expired():
        raise HTTPException(status_code=400, detail="Invalid or expired code or email")
    return {"message": "Verification successful"}

@router.post("/password-reset/change")
def change_password(request: ChangePasswordRequest, db: Session = Depends(get_db)):
    # Double check code
    entry = db.query(ResetVerificationCode).filter(
        ResetVerificationCode.email == request.email, 
        ResetVerificationCode.code == request.code
    ).first()
    if not entry or entry.is_expired():
        raise HTTPException(status_code=400, detail="Invalid or expired code or email")

    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password = hash_password(request.new_password)
    db.delete(entry)  # Remove the reset code after successful change
    db.commit()

    return {"message": "Password changed successfully"}