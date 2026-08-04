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
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```