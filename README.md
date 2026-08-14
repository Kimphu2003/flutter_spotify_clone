# 🎵 Flutter Spotify Clone

A cross-platform music streaming app inspired by Spotify's design, built with Flutter. Users can listen to music and upload their own songs, with a full backend for storage, playback, and authentication.

## ✨ Features

- Stream and play audio with background playback support
- Upload personal songs to the platform
- Browse and search music library
- User authentication (JWT-based)
- Persistent local caching for offline-friendly playback

## 🏗️ Architecture

Built with **MVVM (Model-View-ViewModel)** for a maintainable, scalable codebase — keeping UI, business logic, and data layers cleanly separated.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter |
| State Management | Riverpod |
| Audio Playback | `just_audio`, `just_audio_background` |
| Local Storage | Hive |
| Backend | FastAPI (Python) |
| Database | PostgreSQL |
| Auth | JWT |
| Media Storage | Cloudinary |

## 📱 Key Implementation Details

- **Background playback**: `just_audio_background` keeps music playing when the app is minimized or the screen is locked
- **RESTful API**: Backend built with FastAPI, handling song metadata, user data, and authentication endpoints
- **Secure auth**: JWT tokens issued and validated for protected routes
- **Media hosting**: Uploaded songs stored and served via Cloudinary

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.x)
- Python 3.10+ (for backend)
- PostgreSQL instance

### Installation

```bash
# Clone the repo
git clone https://github.com/Kimphu2003/flutter_spotify_clone.git
cd flutter_spotify_clone

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

## 👤 Author

**Tran Kim Phu**
[GitHub](https://github.com/Kimphu2003)
