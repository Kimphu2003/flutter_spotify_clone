from sqlalchemy import TEXT, Column, ForeignKey, DateTime, Boolean
from models.base import Base
from sqlalchemy.orm import relationship
from datetime import datetime

class Playlist(Base):
    __tablename__ = "playlists"

    id = Column(TEXT, primary_key=True)
    name = Column(TEXT, nullable=False)
    description = Column(TEXT, nullable=True)
    user_id = Column(TEXT, ForeignKey("users.id"), nullable=False)
    is_public = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship('User', back_populates='playlists')
    playlist_songs = relationship('PlaylistSong', back_populates='playlist', cascade="all, delete-orphan")

class PlaylistSong(Base):
    __tablename__ = "playlist_songs"

    id = Column(TEXT, primary_key=True)
    playlist_id = Column(TEXT, ForeignKey("playlists.id"), nullable=False)
    song_id = Column(TEXT, ForeignKey("songs.id"), nullable=False)
    position = Column(TEXT, nullable=False)  # For ordering songs in playlist
    added_at = Column(DateTime, default=datetime.utcnow)

    playlist = relationship('Playlist', back_populates='playlist_songs')
    song = relationship('Song')