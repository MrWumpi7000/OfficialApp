from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import enum

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
    
class InboxMessageCreate(BaseModel):
    sender_email: str
    recipient_email: str
    title: Optional[str] = None
    message: str
    message_type: Optional[str] = None

    class Config:
        from_attributes = True  # instead of orm_mode
        
class InboxMessageBase(BaseModel):
    title: Optional[str] = None
    message: str
    message_type: Optional[str] = None
    
class InboxMessageOut(BaseModel):
    id: int
    sender_email: Optional[str] = None
    recipient_email: str
    title: str
    message: str
    message_type: str
    is_read: bool
    created_at: datetime

    class Config:
        orm_mode = True


class InboxListResponse(BaseModel):
    items: List[InboxMessageOut]
    total: int
    unread_count: int
    
class FriendRequestStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    rejected = "rejected"
    canceled = "canceled"

class FriendRequestOut(BaseModel):
    id: int
    sender_email: str
    recipient_email: str
    status: FriendRequestStatus
    created_at: datetime

    class Config:
        orm_mode = True
