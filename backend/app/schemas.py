from pydantic import BaseModel
from typing import List, Optional

class RegisterRequest(BaseModel):
    username: str
    email: str
    birthday: str
    profile_image_data: str

class TokenRequest(BaseModel):
    token: str

class LoginRequest(BaseModel):
    username_or_email: str
    password: str
    
class EmailRequest(BaseModel):
    email: str

class VerificationRequest(BaseModel):
    email: str
    code: str