
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = 'postgresql://postgres:123456@localhost:5432/fluttermusicapp'

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit = False, autoflush = False, bind = engine)           # Tạo ra các phiên làm việc với database, thực hiện các truy vấn, thêm, sửa, xóa trong CSDL

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()