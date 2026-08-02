# APIs

Base Route: `/api/v1`

---

## Auth Endpoints

### 1. Register User
> `POST` `/auth/register` (Public)

#### Request Body
```json
{
  "email": "user@example.com",
  "phone": "98478```00",
  "password": "password123!"
}
```

#### Response Body
```json
{
  "success": true,
  "message": "Registration successfull",
  "data": {
    "uid": "231ceaf6-6c46-4623-8c87-c2acde91df3a",
    "email": "user@example.com",
    "phone": "98478```00",
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
  "password": "SecurePassword123!"
}
```

#### Response Body
```json
{
  "success": true,
  "message": "Login successfull",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```