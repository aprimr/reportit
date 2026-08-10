# Database Schema

## 1. Users Table (`users`)

The `users` table stores core account details for all registered users in the system.

### Columns
| Column | Type | Constraints / Defaults |
| :--- | :--- | :--- |
| **`uid` (PK)** | UUID | PRIMARY KEY, DEFAULT `gen_random_uuid()` |
| **`fullname`** | TEXT | NOT NULL |
| **`email`** | TEXT | UNIQUE, NOT NULL |
| **`phone`** | TEXT | UNIQUE, NOT NULL |
| **`password_hash`** | TEXT | NOT NULL |
| **`role`** | TEXT | DEFAULT `'user'` |
| **`is_verified`** | BOOLEAN | DEFAULT `true` |
| **`created_at`** | TIMESTAMP WITH TIME ZONE | DEFAULT `now()` |
| **`updated_at`** | TIMESTAMP WITH TIME ZONE | DEFAULT `now()` |

---

## 2. Refresh Tokens Table (`refresh_tokens`)

The `refresh_tokens` table tracks active session tokens to manage user authentication state and token rotation.

### Columns
| Column | Type | Constraints / Defaults |
| :--- | :--- | :--- |
| **`id` (PK)** | UUID | PRIMARY KEY, DEFAULT `gen_random_uuid()` |
| **`uid` (FK)** | UUID | REFERENCES users(uid) ON DELETE CASCADE |
| **`token_hash`** | TEXT | NOT NULL |
| **`expires_at`** | TIMESTAMP WITH TIME ZONE | NOT NULL |
| **`created_at`** | TIMESTAMP WITH TIME ZONE | DEFAULT `now()` |

## 3. Complaints Table (`complaints`)

The `complaints` table stores user-submitted reports, tracking their details, media attachments, geolocation, and status.

### Columns
| Column | Type | Constraints / Defaults |
| :--- | :--- | :--- |
| **`id` (PK)** | UUID | PRIMARY KEY, DEFAULT `gen_random_uuid()` |
| **`uid` (FK)** | UUID | REFERENCES users(uid) ON DELETE CASCADE |
| **`title`** | TEXT | NOT NULL |
| **`description`** | TEXT | NOT NULL |
| **`category`** | TEXT | NOT NULL |
| **`image_urls`** | TEXT[] | NOT NULL |
| **`latitude`** | DOUBLE PRECISION | NOT NULL |
| **`longitude`** | DOUBLE PRECISION | NOT NULL |
| **`is_public`** | BOOLEAN | NOT NULL, DEFAULT `true` |
| **`status`** | TEXT | NOT NULL, DEFAULT `'open'` |
| **`admin_remarks`** | TEXT | — |
| **`verified_at`** | TIMESTAMP WITH TIME ZONE | — |
| **`rejected_at`** | TIMESTAMP WITH TIME ZONE | — |
| **`resolved_at`** | TIMESTAMP WITH TIME ZONE | — |
| **`created_at`** | TIMESTAMP WITH TIME ZONE | DEFAULT `now()` |