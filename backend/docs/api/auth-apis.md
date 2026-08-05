# APIs

Base Route: `/api/v1`

---

## Auth Endpoints

### 1. Register User
> `POST` `/auth/register` (Public)

#### Request Body
```json
{
  "fullname": "user user",
  "email": "user@example.com",
  "phone": "9847800000",
  "password": "Password123!"
}
```

#### Response Body
```json
{
  "success": true,
  "message": "Registration successfull",
  "data": {
    "uid": "231ceaf6-6c46-4623-8...",
    "fullname": "user user",
    "email": "user@example.com",
    "phone": "9847800000",
    "role": "user",
    "is_verified": true,
    "created_at": "2026-08-02T12:00:04.330385Z",
    "updated_at": "2026-08-02T12:00:04.330385Z"
  }
}
```

---

### 2. Login User
> `POST` `/auth/login` (Public)

#### Request Body
```json
{
  "emailOrPhone": "user@example.com",
  "password": "Password123!"
}
```

#### Response Body
```json
{
  "success": true,
  "message": "Login successfull",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJl2giL...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJl1MTE..."
  }
}
```

### 3. Rotate Access and Refresh Tokens
> `POST` `/auth/refresh` (Public)

#### Request Body
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJl3ODg..."
}
```

#### Response Body
```json
{
  "success": true,
  "message": "tokens refreshed successfully",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFp...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAi..."
  }
}
```

---

### 4. Logout User
> Header: `Authorization` `bearer <access_token>`
>
> `POST` `/auth/logout` (Protected)

#### Request Body
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Response Body
```json
{
  "success": true,
  "message": "logout successful"
}
```

---

### 5. Logout From All Devices
> Header: `Authorization` `bearer <access_token>`
>
> `POST` `/auth/logout-all` (Protected)

#### Request Body
```
null
```

#### Response Body
```json
{
  "success": true,
  "message": "logged out from all devices"
}
```