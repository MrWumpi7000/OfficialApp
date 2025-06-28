from sqlalchemy import func, Column, Integer, String, ForeignKey, UniqueConstraint, DateTime, Boolean
from app.database import Base
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta

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