
from fastapi import HTTPException, Header
import jwt


def auth_middleware(x_auth_token = Header()):
    try: 
        # get the user's token from the headers
        if not x_auth_token:
            raise HTTPException(401, 'No auth token, access denied!')
        
        # decode the token
        verified_token = jwt.decode(x_auth_token, 'password_key', ['HS256'])       # the verified_token's type will be a dictionary

        if not verified_token:
            raise HTTPException(401, 'Token verification failed, authorization denied')
        
        # get the id from token
        uid = verified_token.get('id')

        return {'uid': uid, 'token': x_auth_token}
    except jwt.PyJWTError:
        raise HTTPException(401, 'Token is not valid, Authorization failed!')