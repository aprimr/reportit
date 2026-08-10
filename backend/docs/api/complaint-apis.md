# APIs

**Base Route:** `/api/v1`

---

## Complaint Endpoints


### 1. Create New Complaint

> Header: `Authorization: Bearer <access_token>`
>
> `POST /api/v1/complaint/`

#### Request Body (Multipart Form-Data)

| Key | Type | Description |
| --- | --- | --- |
| `title` | String | Title of the complaint |
| `description` | String | Description of the issue |
| `category` | String | Category |
| `latitude` | Number | Location latitude |
| `longitude` | Number | Location longitude |
| `is_public` | Boolean | Visibility flag (`true` / `false`) |
| `images` | Files | Image files to upload |

#### Response Body

```
{
  "success": true,
  "message": "complaint create successful",
  "data": {
    "id": "f29dae63-8201-4040-8d5c-2...",
    "uid": "b1d6a311-92cc-48c6-923a-f...",
    "title": "Large Pothole on...",
    "description": "There is a massive pothole in the middle of the...",
    "category": "road",
    "image_urls": [
      "https://res.cloudinary.com/dpzi1uyn6/image/upload/v178..."
    ],
    "longitude": 0.0,
    "latitude": 0.0,
    "is_public": true,
    "status": "open",
    "admin_remarks": null,
    "verified_at": null,
    "rejected_at": null,
    "resolved_at": null,
    "created_at": "2026-08-10T12:07:47.642206Z"
  }
}
```

---

### 2. Delete Complaint
> Header: `Authorization: Bearer <access_token>`
>
> `DELETE /api/v1/complaint/{id}`

#### Request Body

`null`

#### Response Body

```
{
  "success": true,
  "message": "complaint delete successful"
}
```

---

### 3. Get Complaint by ID

`GET /api/v1/complaint/{id}`

#### Request Body

`null`

#### Response Body

```
{
  "success": true,
  "message": "complaint create successful",
  "data": {
    "id": "f29dae63-8201-4040-8d5c-2...",
    "uid": "b1d6a311-92cc-48c6-923a-f...",
    "title": "Large Pothole on...",
    "description": "There is a massive pothole in the middle of the...",
    "category": "road",
    "image_urls": [
      "https://res.cloudinary.com/dpzi1uyn6/image/upload/v178..."
    ],
    "longitude": 0.0,
    "latitude": 0.0,
    "is_public": true,
    "status": "open",
    "admin_remarks": null,
    "verified_at": null,
    "rejected_at": null,
    "resolved_at": null,
    "created_at": "2026-08-10T12:07:47.642206Z"
  }
}
```

---

### 4. Get My Complaints

> Header: `Authorization: Bearer <access_token>`
>
> `GET /api/v1/complaint/me`

#### Query Parameters

* `search`
* `status`
* `sort`
* `limit`

#### Request Body

`null`

#### Response Body

```
{
  "success": true,
  "message": "complaints fetch successful",
  "data": [
    {
      "success": true,
      "message": "complaint create successful",
      "data": {
        "id": "f29dae63-8201-4040-8d5c-2...",
        "uid": "b1d6a311-92cc-48c6-923a-f...",
        "title": "Large Pothole on...",
        "description": "There is a massive pothole in the middle of the...",
        "category": "road",
        "image_urls": [
          "https://res.cloudinary.com/dpzi1uyn6/image/upload/v178..."
        ],
        "longitude": 0.0,
        "latitude": 0.0,
        "is_public": true,
        "status": "open",
        "admin_remarks": null,
        "verified_at": null,
        "rejected_at": null,
        "resolved_at": null,
        "created_at": "2026-08-10T12:07:47.642206Z"
      }
    },
    {
      ...
    }
  ]
}
```

---

### 5. Get All Complaints

> Header: `Authorization: Bearer <access_token>`
>
> `GET /api/v1/complaint/all`

#### Query Parameters

* `search`
* `status`
* `sort`
* `limit`

#### Request Body

`null`

#### Response Body

```
{
  "success": true,
  "message": "complaints fetch successful",
  "data": [
    {
      "success": true,
      "message": "complaint create successful",
      "data": {
        "id": "f29dae63-8201-4040-8d5c-2...",
        "uid": "b1d6a311-92cc-48c6-923a-f...",
        "title": "Large Pothole on...",
        "description": "There is a massive pothole in the middle of the...",
        "category": "road",
        "image_urls": [
          "https://res.cloudinary.com/dpzi1uyn6/image/upload/v178..."
        ],
        "longitude": 0.0,
        "latitude": 0.0,
        "is_public": true,
        "status": "open",
        "admin_remarks": null,
        "verified_at": null,
        "rejected_at": null,
        "resolved_at": null,
        "created_at": "2026-08-10T12:07:47.642206Z"
      }
    },
    {
      ...
    }
  ]
}
```