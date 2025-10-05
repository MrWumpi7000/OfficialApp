from sqlalchemy import func, Column, Integer, String, ForeignKey, UniqueConstraint, DateTime, Boolean, Text, Enum
from app.database import Base
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta
import enum

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    birthday = Column(DateTime, nullable=True)
    profile_image_data = Column(String, nullable=True)
    profile_image_extension = Column(String, nullable=True)
    six_digit_code = Column(String(6), nullable=True)
    password = Column(String, nullable=False)
    partner_email = Column(String, ForeignKey('users.email'), nullable=True)
    
class VerificationCode(Base):
    __tablename__ = "verification_codes"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    code = Column(String(6), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
class ResetVerificationCode(Base):
    __tablename__ = 'reset_verification_codes'
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, index=True, nullable=False)
    code = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)

    def is_expired(self):
        return datetime.utcnow() > self.expires_at
    
class FriendRequestStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    rejected = "rejected"
    canceled = "canceled"


class FriendRequest(Base):
    __tablename__ = "friend_requests"
    id = Column(Integer, primary_key=True, index=True)
    sender_email = Column(String, ForeignKey("users.email"), nullable=False)
    recipient_email = Column(String, ForeignKey("users.email"), nullable=False)
    status = Column(Enum(FriendRequestStatus), default=FriendRequestStatus.pending, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class InboxMessage(Base):
    __tablename__ = "inbox_messages"

    id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    recipient_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    message_type = Column(String, nullable=False, default="info")
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    friend_request_id = Column(Integer, ForeignKey("friend_requests.id"), nullable=True)
