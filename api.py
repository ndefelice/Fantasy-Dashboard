from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Annotated

import models.user as user_model

import platforms.sleeper as sleeper

from database.database import SessionLocal, engine
from sqlalchemy.orm import Session

tags = [
    {
        "name": "User",
        "description": "Basic information for a user",
    },
    {
        "name": "Sleeper",
        "description": "Information from the Sleeper platform",
    },
]


app = FastAPI(
    title="Fantasy Dashboard",
    summary="API for unifying fantasy football applications!",
    version="0.0.1",
    openapi_tags=tags
)

user_model.Base.metadata.create_all(bind=engine)

origins = [
    "http://localhost:53969",  # Replace with the origin of your Flutter app
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["OPTIONS", "GET", "PUT", "POST", "DELETE"],
    allow_headers=["/users/"],
)

class User(BaseModel):
    username: str
    email: str
    password: str
    sleeper_id: str | None = None


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session, Depends(get_db)]

app.include_router(sleeper.router)


# Create user
@app.post("/users/", tags=["User"])
async def create_user(user: User, db: db_dependency):
    db_user = user_model.User(
        username=user.username,
        email=user.email,
        password=user.password,
        sleeper_id=user.sleeper_id,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return {"message": "User created successfully!"}


# Get user
@app.get("/users/{username}", tags=["User"])
async def get_user(username: str, db: db_dependency):
    db_user = db.query(user_model.User).filter(user_model.User.username == username).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


# Update user
@app.put("/users/{username}", tags=["User"])
async def update_user(username: str, user: User, db: db_dependency):
    db_user = db.query(user_model.User).filter(user_model.User.username == username).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    db_user.username = user.username
    db_user.email = user.email
    db_user.password = user.password
    db_user.sleeper_id = user.sleeper_id
    db.commit()
    db.refresh(db_user)

    return {"message": "User updated successfully!"}


# Delete user
@app.delete("/users/{username}", tags=["User"])
async def delete_user(username: str, db: db_dependency):
    db_user = db.query(user_model.User).filter(user_model.User.username == username).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(db_user)
    db.commit()

    return {"message": "User deleted successfully!"}