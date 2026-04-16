# News App - Quản lý tin tức cá nhân

Ứng dụng Flutter dùng **Firebase Firestore** + **Firebase Auth** làm database.
Sinh viên: **Từ Huy Hoàng**.

---

## ⚠️ QUAN TRỌNG - Cài đặt Firebase trước khi chạy

App này dùng Firebase nên **bắt buộc** phải có file `google-services.json` trước khi chạy.

### Bước 1: Tạo Firebase project
1. Truy cập https://console.firebase.google.com
2. **Add project** → nhập tên (VD: "news-app-tu-huy-hoang") → Continue
3. Tắt Google Analytics (không cần) → Create project

### Bước 2: Add Android app
1. Trong project, bấm icon Android
2. **Android package name**: `com.example.hhhhhhhhhh` ⚠️ phải đúng tên này
3. App nickname: tùy ý
4. SHA-1: bỏ trống
5. Bấm **Register app**
6. **Download `google-services.json`**
7. Đặt file vào: `android/app/google-services.json`
8. Skip 2 bước cuối (đã config trong gradle)

### Bước 3: Bật Authentication
1. Build → **Authentication** → Get started
2. Sign-in method → **Email/Password** → Enable → Save

### Bước 4: Tạo Firestore Database
1. Build → **Firestore Database** → Create database
2. Chọn location (asia-southeast1 cho VN) → Next
3. Chọn **Start in test mode** → Create

### Bước 5: Cập nhật Security Rules (test mode)
Vào tab **Rules**, dán:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /articles/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Bước 6: Chạy app
```bash
flutter pub get
flutter run
```

---

## 1. Database (Firestore) - 4 collections

| Collection | Mô tả |
|-----------|-------|
| `users/{uid}` | Profile user (uid, name, email, createdAt) |
| `users/{uid}/favorites/{articleId}` | Bài yêu thích của user |
| `users/{uid}/search_history/{auto}` | Lịch sử tìm kiếm (query, createdAt) |
| `articles/{id}` | Cache bài viết để xem offline |

**Authentication**: dùng Firebase Auth (email + password) - Google tự hash mật khẩu, không cần lưu trong Firestore.

---

## 2. Tính năng

### Đăng ký / Đăng nhập (Firebase Auth)
- Tạo account với email + password.
- Session tự động duy trì (Firebase Auth lưu token).
- Đăng xuất → quay về Login.

### Tab Tin tức
- Tải bài từ JSONPlaceholder API.
- Tự **cache vào Firestore** mỗi lần load thành công.
- **Mất mạng** → tự đọc từ cache → vẫn xem được.
- Pull-to-refresh.
- Search theo title + body, lưu **lịch sử tìm kiếm** vào Firestore.

### Tab Yêu thích
- Toggle favorite → ghi/xóa trên Firestore.
- **Realtime stream** - vote ở thiết bị này, thiết bị kia thấy ngay.
- Search trong yêu thích (title + body), debounce 300ms.
- Hiển thị số kết quả tìm thấy.

### Tab Tài khoản
- Avatar (chữ cái đầu tên).
- Hiển thị tên + email từ Firestore.
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
             │ gọi
┌────────────▼───────────────┐
│      Data Source           │
│   - Firebase Auth          │
│   - Cloud Firestore        │
│   - HTTP (JSONPlaceholder) │
└────────────────────────────┘
```

---

## 4. Cấu trúc thư mục

```
lib/
├── main.dart                           # Init Firebase + AuthGate + bind providers
├── models/
│   ├── article.dart                    # toMap/fromMap cho Firestore
│   └── user.dart
├── services/
│   └── news_api.dart                   # HTTP gọi JSONPlaceholder
├── repositories/                       # Tầng truy cập dữ liệu
│   ├── auth_repository.dart            # Firebase Auth + users collection
│   ├── favorites_repository.dart       # users/{uid}/favorites
│   ├── article_repository.dart         # Wrap NewsApi
│   ├── article_cache_repository.dart   # Collection articles (cache)
│   └── search_history_repository.dart  # users/{uid}/search_history
├── providers/                          # ViewModel (ChangeNotifier)
│   ├── auth_provider.dart
│   ├── news_provider.dart
│   ├── favorites_provider.dart
│   └── search_history_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_shell.dart                 # Bottom nav 3 tab
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
| `firebase_core` | Khởi tạo Firebase |
| `firebase_auth` | Đăng ký, đăng nhập, session |
| `cloud_firestore` | Database NoSQL realtime |
| `http` | Gọi JSONPlaceholder |
| `provider` | State management |
| `intl` | Format ngày tháng |
| `shared_preferences` | (legacy - vẫn giữ) |

---

## 6. Cách chạy

```bash
# 1. Cài dependencies
flutter pub get

# 2. Đảm bảo google-services.json đã có ở android/app/

# 3. Chạy trên Android (mở emulator trong Android Studio)
flutter run

# Test
flutter test

# Analyze
flutter analyze
```

---

## 7. Troubleshooting

### "Default FirebaseApp is not initialized"
→ Chưa có `google-services.json`, làm lại Bước 2.

### "PERMISSION_DENIED: Missing or insufficient permissions"
→ Chưa cập nhật Firestore Rules, làm Bước 5.

### Không build được trên Android
→ Kiểm tra `minSdk = 23` trong `android/app/build.gradle.kts`.
→ Chạy `flutter clean && flutter pub get`.

---

**Bài tập kiểm tra giữa kỳ - Mobile Development**
