from pydantic import BaseModel
from typing import List, Optional

class RegisterRequest(BaseModel):
    username: str
    email: str
    birthday: str
    profile_image_data: str
    profile_image_extension: Optional[str] = None
    password: str
    
class TokenRequest(BaseModel):
    token: str

class LoginRequest(BaseModel):
    email: str
    password: str
    
class EmailRequest(BaseModel):
    email: str

class VerificationRequest(BaseModel):
    email: str
    code: str

class ChangePasswordRequest(BaseModel):
    email: str
    code: str
    new_password: str