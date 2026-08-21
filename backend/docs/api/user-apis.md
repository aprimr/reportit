# APIs

Base Route: `/api/v1`

---

## User Endpoints

### 1. Fetch User Profile

> Header: `Authorization` `bearer <access_token>`
>
> `GET` `/user/` (Protected)

#### Request Body

```
null
```

#### Response Body

```json
{
  "success": true,
  "message": "user fetched successfully",
  "data": {
    "user":{
      "uid": "231ceaf6-6c46-4623-8...",
      "fullname": "user user",
      "email": "user@example.com",
      "phone": "9847800000",
      "role": "user",
      "is_verified": true,
      "created_at": "2026-08-02T12:00:04.330385Z",
      "updated_at": "2026-08-02T12:00:04.330385Z",
    },
    "complaint_stats": {
      "open": 1,
      "verified": 2,
      "resolved": 2,
      "rejected": 1,
      "total": 6
    }
  }
}
```

---

### 2. Update Full Name

> Header: `Authorization` `bearer <access_token>`
>
> `PATCH` `/user/fullname` (Protected)

#### Request Body

```json
{
  "fullname": "New name"
}
```

#### Response Body

```json
{
  "success": true,
  "message": "fullname updated successfully"
}
```

---

### 3. Change Password

> Header: `Authorization` `bearer <access_token>`
>
> `PATCH` `/user/password` (Protected)

#### Request Body

```json
{
  "current_password": "Password123!",
  "new_password": "NewPassword123@"
}
```

#### Response Body

```json
{
  "success": true,
  "message": "password updated successfully"
}
```