from pydantic import BaseModel

class SongBase(BaseModel):
    song_name: str
    artist: str
    song_url: str
    thumbnail_url: str
    artist: str
    song_name: str
    hex_code: str

class SongResponse(SongBase):
    id: str
    
    class Config:
        orm_mode = True  # This is crucial for ORM model conversion