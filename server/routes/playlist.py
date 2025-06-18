from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from models.playlist_model import Playlist, PlaylistSong
from pydantic_schemas.playlist import (
    CreatePlaylist, UpdatePlaylist, AddSongToPlaylist, 
    RemoveSongFromPlaylist, PlaylistResponse, PlaylistSongResponse
)
from database import get_db 
from middleware.auth_middleware import auth_middleware 
import uuid

router = APIRouter()

def format_playlist_with_songs(playlist, db: Session):
    """Helper function to format playlist with songs"""
    # Get songs with their positions
    playlist_songs = db.query(PlaylistSong).filter(
        PlaylistSong.playlist_id == playlist.id
    ).options(
        joinedload(PlaylistSong.song)
    ).order_by(PlaylistSong.position).all()
    
    songs = []
    for ps in playlist_songs:
        song_data = PlaylistSongResponse(
            id=ps.song.id,
            song_name=ps.song.song_name,
            artist=ps.song.artist,
            song_url=ps.song.song_url,
            thumbnail_url=ps.song.thumbnail_url,
            hex_code=ps.song.hex_code,
            position=ps.position,
            added_at=ps.added_at
        )
        songs.append(song_data)
    
    return PlaylistResponse(
        id=playlist.id,
        name=playlist.name,
        description=playlist.description,
        user_id=playlist.user_id,
        is_public=playlist.is_public,
        created_at=playlist.created_at,
        updated_at=playlist.updated_at,
        song_count=len(songs),
        songs=songs
    )

@router.post('/', response_model=PlaylistResponse)
def create_playlist(
    playlist_data: CreatePlaylist,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    try:
        user_id = auth_details['uid']
        
        new_playlist = Playlist(
            id=str(uuid.uuid4()),
            name=playlist_data.name,
            description=playlist_data.description,
            user_id=user_id,
            is_public=playlist_data.is_public
        )
        
        db.add(new_playlist)
        db.commit()
        db.refresh(new_playlist)
        
        # Return playlist with empty songs list
        return format_playlist_with_songs(new_playlist, db)
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get('/', response_model=List[PlaylistResponse])
def get_user_playlists(
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    user_id = auth_details['uid']
    
    playlists = db.query(Playlist).filter(
        Playlist.user_id == user_id
    ).all()
    
    # Format each playlist with songs
    formatted_playlists = []
    for playlist in playlists:
        formatted_playlist = format_playlist_with_songs(playlist, db)
        formatted_playlists.append(formatted_playlist)
    
    return formatted_playlists

@router.post('/{playlist_id}/song')
def add_song_to_playlist(
    playlist_id: str,
    song_data: AddSongToPlaylist,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    user_id = auth_details['uid']
    
    # Check if playlist exists and belongs to user
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_id
    ).first()
    
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
    
    # Check if song is already in playlist
    existing_song = db.query(PlaylistSong).filter(
        PlaylistSong.playlist_id == playlist_id,
        PlaylistSong.song_id == song_data.song_id
    ).first()
    
    if existing_song:
        raise HTTPException(status_code=400, detail="Song already in playlist")
    
    try:
        # Determine position
        if song_data.position is None:
            # Add to end
            max_position = db.query(PlaylistSong).filter(
                PlaylistSong.playlist_id == playlist_id
            ).count()
            position = max_position + 1
        else:
            position = song_data.position
        
        new_playlist_song = PlaylistSong(
            id=str(uuid.uuid4()),
            playlist_id=playlist_id,
            song_id=song_data.song_id,
            position=str(position)
        )
        
        db.add(new_playlist_song)
        db.commit()
        
        return {"message": "Song added to playlist successfully"}
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.put('/{playlist_id}', response_model=PlaylistResponse)
def update_playlist(
    playlist_id: str,
    playlist_data: UpdatePlaylist,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    user_id = auth_details['uid']
    
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_id
    ).first()
    
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
    
    try:
        if playlist_data.name is not None:
            playlist.name = playlist_data.name
        if playlist_data.description is not None:
            playlist.description = playlist_data.description
        if playlist_data.is_public is not None:
            playlist.is_public = playlist_data.is_public
        
        db.commit()
        db.refresh(playlist)
        
        return format_playlist_with_songs(playlist, db)
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.delete('/{playlist_id}')
def delete_playlist(
    playlist_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    user_id = auth_details['uid']
    
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_id
    ).first()
    
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
    
    try:
        db.delete(playlist)
        db.commit()
        return {"message": "Playlist deleted successfully"}
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.delete('/{playlist_id}/song/{song_id}')
def remove_song_from_playlist(
    playlist_id: str,
    song_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    user_id = auth_details['uid']
    
    # Check if playlist exists and belongs to user
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_id
    ).first()
    
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
    
    # Find the song in playlist
    playlist_song = db.query(PlaylistSong).filter(
        PlaylistSong.playlist_id == playlist_id,
        PlaylistSong.song_id == song_id
    ).first()
    
    if not playlist_song:
        raise HTTPException(status_code=404, detail="Song not found in playlist")
    
    try:
        db.delete(playlist_song)
        db.commit()
        return {"message": "Song removed from playlist successfully"}
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get('/public', response_model=List[PlaylistResponse])
def get_public_playlists(db: Session = Depends(get_db)):
    playlists = db.query(Playlist).filter(
        Playlist.is_public == True
    ).all()

    print("playlists: ", playlists)
    
    # Format each playlist with songs
    formatted_playlists = []
    for playlist in playlists:
        formatted_playlist = format_playlist_with_songs(playlist, db)
        formatted_playlists.append(formatted_playlist)
    
    return formatted_playlists

@router.get('/{playlist_id}', response_model=PlaylistResponse)
def get_playlist_with_songs(
    playlist_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    user_id = auth_details['uid']
    
    playlist = db.query(Playlist).filter(
        Playlist.id == playlist_id,
        Playlist.user_id == user_id
    ).first()
    
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
    
    return format_playlist_with_songs(playlist, db)