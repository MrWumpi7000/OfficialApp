from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form, Query # type: ignore
from fastapi.responses import StreamingResponse # type: ignore
from sqlalchemy.orm import Session # type: ignore
from sqlalchemy import or_, func, desc # type: ignore
from app.models import User, InboxMessage, VerificationCode, ResetVerificationCode, FriendRequest, FriendRequestStatus # Import your models
from app.utils import hash_password, verify_password, whoami, create_access_token, generate_numeric_code
from app.database import get_db
from app.schemas import RegisterRequest, InboxMessageCreate, InboxMessageOut, InboxListResponse, LoginRequest, FriendRequestOut, FriendRequestStatus, EmailRequest, VerificationRequest, TokenRequest, ChangePasswordRequest  # Import your schemas
from app.emailutils import send_verification_mail, send_password_reset_code  # Assuming you have an email utility module
from uuid import uuid4
from datetime import datetime, timedelta
import os
import shutil
import base64
import random
from typing import Optional
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
    default_image_path = "app/assets/no_profile.jpg"
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
    
    profile_image_base64 = None
    if user.profile_image_data and os.path.exists(user.profile_image_data):
        with open(user.profile_image_data, "rb") as image_file:
            profile_image_base64 = base64.b64encode(image_file.read()).decode('utf-8')
    else:
        profile_image_base64 = base64.b64encode(open("app/assets/no_profile.jpg", "rb").read()).decode('utf-8')

    return {"access_token": access_token, "token_type": "bearer", "6-digit_code": six_digit_code, "name": user.username, "partner_email": user.partner_email, "profile_image_data": profile_image_base64, "profile_image_extension": user.profile_image_extension}

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

inbox_router = APIRouter(prefix="/inbox", tags=["inbox"])

def send_inbox_message_internal(
    db: Session,
    recipient_id: int,
    message: str,
    title: Optional[str] = None,
    sender_id: Optional[int] = None,
    message_type: Optional[str] = None
) -> InboxMessage:
    """Helper: create a message for recipient_id. Use this from other modules when you need to notify a user."""
    msg = InboxMessage(
        recipient_id=recipient_id,
        sender_id=sender_id,
        message=message,
        title=title,
        message_type=message_type,
        is_read=False
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg


@inbox_router.post("/send", response_model=InboxMessageOut)
def send_inbox_message(payload: InboxMessageCreate, db: Session = Depends(get_db)):
    sender = db.query(User).filter(User.email == payload.sender_email).first()
    recipient = db.query(User).filter(User.email == payload.recipient_email).first()

    if not sender or not recipient:
        raise HTTPException(status_code=404, detail="Sender or recipient not found")

    msg = InboxMessage(
        sender_id=sender.id,
        recipient_id=recipient.id,
        title=payload.title,
        message=payload.message,
        message_type=payload.message_type,
        is_read=False,
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)

    return InboxMessageOut(
        id=msg.id,
        sender_email=sender.email,
        recipient_email=recipient.email,
        title=msg.title,
        message=msg.message,
        message_type=msg.message_type,
        is_read=msg.is_read,
        created_at=msg.created_at
    )
@inbox_router.get("/", response_model=InboxListResponse)
def list_inbox_items(db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid user")

    q = db.query(InboxMessage).filter(InboxMessage.recipient_id == user.id)
    items = q.order_by(desc(InboxMessage.created_at)).all()
    total = q.count()

    unread_count = db.query(InboxMessage).filter(
        InboxMessage.recipient_id == user.id,
        InboxMessage.is_read == False
    ).count()

    results: List[InboxMessageOut] = []
    for msg in items:
        sender_email = db.query(User.email).filter(User.id == msg.sender_id).scalar() if msg.sender_id else None
        recipient_email = db.query(User.email).filter(User.id == msg.recipient_id).scalar()
        results.append(
            InboxMessageOut(
                id=msg.id,
                sender_email=sender_email,
                recipient_email=recipient_email,
                title=msg.title,
                message=msg.message,
                message_type=msg.message_type,
                is_read=msg.is_read,
                created_at=msg.created_at,
            )
        )

    return {"items": results, "total": total, "unread_count": unread_count}


@inbox_router.get("/{message_id}", response_model=InboxMessageOut)
def get_inbox_message(message_id: int, db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    msg = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not msg or msg.recipient_id != user.id:
        raise HTTPException(status_code=404, detail="Message not found")

    sender_email = db.query(User.email).filter(User.id == msg.sender_id).scalar() if msg.sender_id else None
    recipient_email = db.query(User.email).filter(User.id == msg.recipient_id).scalar()

    return InboxMessageOut(
        id=msg.id,
        sender_email=sender_email,
        recipient_email=recipient_email,
        title=msg.title,
        message=msg.message,
        message_type=msg.message_type,
        is_read=msg.is_read,
        created_at=msg.created_at,
    )


@inbox_router.post("/{message_id}/mark-read", response_model=InboxMessageOut)
def mark_message_read(message_id: int, db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    msg = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not msg or msg.recipient_id != user.id:
        raise HTTPException(status_code=404, detail="Message not found")

    if not msg.is_read:
        msg.is_read = True
        db.commit()
        db.refresh(msg)

    sender_email = db.query(User.email).filter(User.id == msg.sender_id).scalar() if msg.sender_id else None
    recipient_email = db.query(User.email).filter(User.id == msg.recipient_id).scalar()

    return InboxMessageOut(
        id=msg.id,
        sender_email=sender_email,
        recipient_email=recipient_email,
        title=msg.title,
        message=msg.message,
        message_type=msg.message_type,
        is_read=msg.is_read,
        created_at=msg.created_at,
    )


@inbox_router.post("/{message_id}/mark-unread", response_model=InboxMessageOut)
def mark_message_unread(message_id: int, db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    msg = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not msg or msg.recipient_id != user.id:
        raise HTTPException(status_code=404, detail="Message not found")

    if msg.is_read:
        msg.is_read = False
        db.commit()
        db.refresh(msg)

    sender_email = db.query(User.email).filter(User.id == msg.sender_id).scalar() if msg.sender_id else None
    recipient_email = db.query(User.email).filter(User.id == msg.recipient_id).scalar()

    return InboxMessageOut(
        id=msg.id,
        sender_email=sender_email,
        recipient_email=recipient_email,
        title=msg.title,
        message=msg.message,
        message_type=msg.message_type,
        is_read=msg.is_read,
        created_at=msg.created_at,
    )


@inbox_router.delete("/{message_id}", response_model=dict)
def delete_inbox_message(message_id: int, db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    msg = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not msg or msg.recipient_id != user.id:
        raise HTTPException(status_code=404, detail="Message not found")

    db.delete(msg)
    db.commit()
    return {"message": "deleted"}


@inbox_router.get("/unread/count", response_model=dict)
def unread_count(db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    cnt = db.query(InboxMessage).filter(
        InboxMessage.recipient_id == user.id,
        InboxMessage.is_read == False
    ).count()
    return {"unread_count": cnt}







friend_router = APIRouter(prefix="/friends", tags=["friends"])


@friend_router.post("/add/{six_digit_code}", response_model=dict)
def send_friend_request(
    six_digit_code: str,
    db: Session = Depends(get_db),
    current_user_email: str = Depends(whoami)
):
    current_user = db.query(User).filter(User.email == current_user_email).first()
    if not current_user:
        raise HTTPException(status_code=404, detail="User not found")

    recipient = db.query(User).filter(User.six_digit_code == six_digit_code).first()
    if not recipient:
        raise HTTPException(status_code=404, detail="User not found")

    if recipient.email == current_user.email:
        raise HTTPException(status_code=400, detail="You cannot add yourself")

    existing_request = db.query(FriendRequest).filter(
        ((FriendRequest.sender_email == current_user.email) | (FriendRequest.recipient_email == current_user.email)),
        (FriendRequest.status == FriendRequestStatus.pending)
    ).first()

    if existing_request:
        raise HTTPException(status_code=400, detail="You already have a pending request")

    # CREATE FRIEND REQUEST
    request = FriendRequest(sender_email=current_user.email, recipient_email=recipient.email)
    db.add(request)
    db.commit()
    db.refresh(request)

    # CREATE INBOX MESSAGE FOR RECIPIENT
    db.add(InboxMessage(
        recipient_id=recipient.id,
        sender_id=current_user.id,
        title="Friend request",
        message=f"{current_user.username} added you. Enter their six-digit code to accept.",
        message_type="friend_request_incoming",
        friend_request_id=request.id
    ))

    # CREATE INBOX MESSAGE FOR SENDER
    db.add(InboxMessage(
        recipient_id=current_user.id,
        sender_id=recipient.id,
        title="Friend request sent",
        message=f"You added {recipient.username}. Waiting for acceptance.",
        message_type="friend_request_outgoing",
        friend_request_id=request.id
    ))

    db.commit()
    return {"detail": "Friend request sent"}


@friend_router.post("/accept/{message_id}", response_model=dict)
def accept_request(
    message_id: int,
    db: Session = Depends(get_db),
    current_user_email: str = Depends(whoami)
):
    inbox_message = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not inbox_message:
        raise HTTPException(status_code=404, detail="Message not found")

    current_user = db.query(User).filter(User.id == inbox_message.recipient_id).first()
    if not current_user or current_user.email != current_user_email:
        raise HTTPException(status_code=403, detail="Unauthorized")

    if inbox_message.message_type != "friend_request_incoming":
        raise HTTPException(status_code=400, detail="Invalid message type")

    request = db.query(FriendRequest).filter(FriendRequest.id == inbox_message.friend_request_id).first()
    if not request or request.status != FriendRequestStatus.pending:
        raise HTTPException(status_code=404, detail="Friend request not found")

    sender_user = db.query(User).filter(User.email == request.sender_email).first()
    if not sender_user:
        raise HTTPException(status_code=404, detail="Sender not found")

    # Store partner relationship
    current_user.partner_email = sender_user.email
    sender_user.partner_email = current_user.email
    request.status = FriendRequestStatus.accepted
    db.commit()

    # Delete both friend request messages
    db.query(InboxMessage).filter(InboxMessage.friend_request_id == request.id).delete()

    # Send info messages to both users
    db.add(InboxMessage(
        recipient_id=sender_user.id,
        sender_id=current_user.id,
        title="Friend request accepted",
        message=f"{current_user.username} accepted your friend request.",
        message_type="info"
    ))
    db.add(InboxMessage(
        recipient_id=current_user.id,
        sender_id=sender_user.id,
        title="Friend request accepted",
        message=f"You accepted {sender_user.username}'s friend request.",
        message_type="info"
    ))
    db.commit()

    return {"detail": "Friend request accepted"}


@friend_router.post("/reject/{message_id}", response_model=dict)
def reject_request(
    message_id: int,
    db: Session = Depends(get_db),
    current_user_email: str = Depends(whoami)
):
    inbox_message = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not inbox_message:
        raise HTTPException(status_code=404, detail="Message not found")

    current_user = db.query(User).filter(User.id == inbox_message.recipient_id).first()
    if not current_user or current_user.email != current_user_email:
        raise HTTPException(status_code=403, detail="Unauthorized")

    if inbox_message.message_type != "friend_request_incoming":
        raise HTTPException(status_code=400, detail="Invalid message type")

    request = db.query(FriendRequest).filter(FriendRequest.id == inbox_message.friend_request_id).first()
    if not request or request.status != FriendRequestStatus.pending:
        raise HTTPException(status_code=404, detail="Friend request not found")

    sender_user = db.query(User).filter(User.email == request.sender_email).first()
    if not sender_user:
        raise HTTPException(status_code=404, detail="Sender not found")

    db.query(InboxMessage).filter(InboxMessage.friend_request_id == request.id).delete()
    db.delete(request)
    db.commit()

    db.add(InboxMessage(
        recipient_id=sender_user.id,
        sender_id=current_user.id,
        title="Friend request rejected",
        message=f"{current_user.username} rejected your friend request.",
        message_type="info"
    ))
    db.add(InboxMessage(
        recipient_id=current_user.id,
        sender_id=sender_user.id,
        title="Friend request rejected",
        message=f"You rejected {sender_user.username}'s friend request.",
        message_type="info"
    ))
    db.commit()

    return {"detail": "Friend request rejected"}


@friend_router.post("/cancel/{message_id}", response_model=dict)
def cancel_request(
    message_id: int,
    db: Session = Depends(get_db),
    current_user_email: str = Depends(whoami)
):
    inbox_message = db.query(InboxMessage).filter(InboxMessage.id == message_id).first()
    if not inbox_message:
        raise HTTPException(status_code=404, detail="Message not found")

    current_user = db.query(User).filter(User.id == inbox_message.sender_id).first()
    if not current_user or current_user.email != current_user_email:
        raise HTTPException(status_code=403, detail="Unauthorized")

    if inbox_message.message_type != "friend_request_outgoing":
        raise HTTPException(status_code=400, detail="Invalid message type")

    request = db.query(FriendRequest).filter(FriendRequest.id == inbox_message.friend_request_id).first()
    if not request or request.status != FriendRequestStatus.pending:
        raise HTTPException(status_code=404, detail="Friend request not found")

    recipient_user = db.query(User).filter(User.email == request.recipient_email).first()
    if not recipient_user:
        raise HTTPException(status_code=404, detail="Recipient not found")

    db.query(InboxMessage).filter(InboxMessage.friend_request_id == request.id).delete()
    db.delete(request)
    db.commit()

    db.add(InboxMessage(
        recipient_id=recipient_user.id,
        sender_id=current_user.id,
        title="Friend request canceled",
        message=f"{current_user.username} canceled the friend request.",
        message_type="info"
    ))
    db.add(InboxMessage(
        recipient_id=current_user.id,
        sender_id=recipient_user.id,
        title="Friend request canceled",
        message=f"You canceled the friend request to {recipient_user.username}.",
        message_type="info"
    ))
    db.commit()

    return {"detail": "Friend request canceled"}

partner_router = APIRouter(prefix="/partner", tags=["partner"])


@partner_router.get("/email", response_model=dict)
def get_partner_email(
    db: Session = Depends(get_db),
    current_user_email: str = Depends(whoami)
):
    user = db.query(User).filter(User.email == current_user_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"partner_email": user.partner_email}


@partner_router.get("/info")
def get_partner_info(db: Session = Depends(get_db), current_user_email: str = Depends(whoami)):
    user = db.query(User).filter(User.email == current_user_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not user.partner_email:
        return {"partner_email": None, "profile_image_data": None, "profile_image_extension": None}

    partner = db.query(User).filter(User.email == user.partner_email).first()
    if not partner:
        return {"partner_email": None, "profile_image_data": None, "profile_image_extension": None}

    profile_image_data = None
    if partner.profile_image_data:
        try:
            image_path = partner.profile_image_data
            with open(image_path, "rb") as image_file:
                profile_image_data = base64.b64encode(image_file.read()).decode("utf-8")
        except Exception as e:
            print(f"Error reading image: {e}")

    return {
        "partner_email": partner.email,
        "profile_image_data": profile_image_data,
        "profile_image_extension": partner.profile_image_extension
    }