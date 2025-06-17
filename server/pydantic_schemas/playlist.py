from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CreatePlaylist(BaseModel):
    name: str
    description: Optional[str] = None
    is_public: Optional[bool] = False

class UpdatePlaylist(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    is_public: Optional[bool] = None

class AddSongToPlaylist(BaseModel):
    song_id: str
    position: Optional[int] = None  # If not provided, add to end

class RemoveSongFromPlaylist(BaseModel):
    song_id: str

class ReorderPlaylistSongs(BaseModel):
    song_positions: List[dict]  # [{"song_id": "...", "position": 1}, ...]

class PlaylistSongResponse(BaseModel):
    id: str
    song_name: str
    artist: str
    song_url: str
    thumbnail_url: Optional[str]
    hex_code: Optional[str]
    position: str
    added_at: datetime

    class Config:
        from_attributes = True

class PlaylistResponse(BaseModel):
    id: str
    name: str
    description: Optional[str]
    user_id: str
    is_public: bool
    created_at: datetime
    updated_at: datetime
    songs: Optional[List[PlaylistSongResponse]] = []
    song_count: Optional[int] = 0

    class Config:
        from_attributes = True

# class PlaylistWithSongs(PlaylistResponse):
#     songs: List[dict] = []  # Will contain song details with position