# News App - Quản lý tin tức cá nhân

Ứng dụng Flutter dùng **SQLite (sqflite)** làm database local — không cần internet, không cần backend.
Sinh viên: **Từ Huy Hoàng**.

---

## ✨ Cài đặt và chạy (rất đơn giản)

```bash
flutter pub get
flutter run
```

**Không cần** Firebase, không cần download file config nào, không cần internet.

---

## 1. Database SQLite — 4 bảng

File DB tự tạo lần đầu chạy app, lưu tại:
- Android: `/data/data/com.example.hhhhhhhhhh/databases/news_app.db`

### Schema

```sql
-- Tài khoản
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,    -- SHA-256 (không lưu plaintext)
  created_at INTEGER NOT NULL
);

-- Bài yêu thích (theo user)
CREATE TABLE favorites (
  user_id INTEGER NOT NULL,
  article_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  image_url TEXT NOT NULL,
  published_at TEXT NOT NULL,
  added_at INTEGER NOT NULL,
  PRIMARY KEY (user_id, article_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Cache bài đã tải (xem offline)
CREATE TABLE articles_cache (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  image_url TEXT NOT NULL,
  published_at TEXT NOT NULL,
  cached_at INTEGER NOT NULL
);

-- Lịch sử tìm kiếm (theo user)
CREATE TABLE search_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  query TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 2. Tính năng

### Đăng ký / Đăng nhập
- Email + password (hash SHA-256 trước khi lưu DB).
- Session lưu `current_user_id` trong SharedPreferences.
- Đăng xuất → quay về Login.

### Tab Tin tức
- Tải bài từ JSONPlaceholder API.
- Tự cache vào bảng `articles_cache` mỗi lần load thành công.
- Mất mạng → tự đọc cache → vẫn xem được.
- Pull-to-refresh.
- Search title + body, debounce 300ms, lưu lịch sử vào `search_history`.

### Tab Yêu thích
- Toggle favorite → INSERT/DELETE bảng `favorites`.
- Search trong yêu thích (title + body).
- Hiển thị số kết quả + chip filter.

### Tab Tài khoản
- Avatar (chữ cái đầu tên).
- Tên + email từ DB.
- Số bài yêu thích.
- Nút **Đăng xuất** với dialog confirm.

---

## 3. Kiến trúc Clean Architecture

```
┌────────────────────────────┐
│         View (UI)          │
│   screens/, widgets/       │
└────────────┬───────────────┘
             │ watch / read
┌────────────▼───────────────┐
│   Provider (ViewModel)     │
│   - AuthProvider           │
│   - NewsProvider           │
│   - FavoritesProvider      │
│   - SearchHistoryProvider  │
└────────────┬───────────────┘
             │ dùng
┌────────────▼───────────────┐
│       Repository           │
│   - AuthRepository         │
│   - FavoritesRepository    │
│   - ArticleRepository      │
│   - ArticleCacheRepository │
│   - SearchHistoryRepository│
└────────────┬───────────────┘
             │ truy cập
┌────────────▼───────────────┐
│      Data Source           │
│   - SQLite (sqflite)       │
│   - SharedPreferences      │
│   - HTTP (JSONPlaceholder) │
└────────────────────────────┘
```

---

## 4. Cấu trúc thư mục

```
lib/
├── main.dart                           # MultiProvider + AuthGate
├── models/
│   ├── article.dart
│   └── user.dart
├── services/
│   ├── news_api.dart                   # HTTP gọi JSONPlaceholder
│   └── database_helper.dart            # SQLite singleton + create tables
├── repositories/
│   ├── auth_repository.dart            # SQLite users + SHA-256 hash
│   ├── favorites_repository.dart       # SQLite favorites
│   ├── article_repository.dart         # Wrap NewsApi
│   ├── article_cache_repository.dart   # SQLite articles_cache
│   └── search_history_repository.dart  # SQLite search_history
├── providers/
│   ├── auth_provider.dart
│   ├── news_provider.dart
│   ├── favorites_provider.dart
│   └── search_history_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_shell.dart
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   ├── detail_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── article_card.dart
    ├── search_field.dart
    ├── error_view.dart
    ├── empty_state.dart
    └── favorites_icon_button.dart
```

---

## 5. Thư viện sử dụng

| Package | Mục đích |
|--------|----------|
| `sqflite` | Database SQLite local |
| `path` | Build path tới file DB |
| `crypto` | Hash password SHA-256 |
| `shared_preferences` | Lưu session (current_user_id) |
| `http` | Gọi JSONPlaceholder API |
| `provider` | State management |
| `intl` | Format ngày tháng |

---

## 6. Cách xem dữ liệu trong DB

### Cách 1: Android Studio Database Inspector
1. Run app trên emulator.
2. Mở **View → Tool Windows → App Inspection → Database Inspector**.
3. Chọn process → thấy `news_app.db` → browse 4 bảng.

### Cách 2: Pull file DB từ emulator
```bash
adb pull /data/data/com.example.hhhhhhhhhh/databases/news_app.db
```
Mở file `news_app.db` bằng [DB Browser for SQLite](https://sqlitebrowser.org/).

---

## 7. Test

```bash
flutter test     # 3 tests về Article model
flutter analyze  # 0 errors
```

---

**Bài tập kiểm tra giữa kỳ - Mobile Development**
