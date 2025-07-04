from sqlalchemy import TEXT, VARCHAR, Column, LargeBinary
from sqlalchemy.orm import relationship

from models.base import Base


class User(Base):
    __tablename__ = 'users'

    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)

    favorite = relationship('Favorite', back_populates='user')
    playlists = relationship('Playlist', back_populates='user', cascade="all, delete-orphan")