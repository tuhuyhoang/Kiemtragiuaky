# News App - Quản lý tin tức cá nhân

Ứng dụng Flutter - **Bài tập lớn môn Mobile Development**.
Sinh viên: **Từ Huy Hoàng**.

---

## 1. Chức năng

### Màn hình 1 — Danh sách tin tức (Home)
- Tải danh sách bài báo từ API `https://jsonplaceholder.typicode.com/posts`.
- Mỗi item: ảnh minh họa (`Image.network`), tiêu đề, tóm tắt, ngày đăng.
- **Pull-to-refresh** kéo xuống để reload.
- **Tìm kiếm theo tiêu đề** với debounce 300ms.
- Nút trái tim ở AppBar mở màn hình Yêu thích (kèm **badge số lượng**).

### Màn hình 2 — Chi tiết tin tức (Detail)
- Hiển thị đầy đủ nội dung bài viết, ảnh, thời gian đăng.
- Nút **Back** (AppBar + button dưới bài).
- Nút **Favorite** ở AppBar — toggle yêu thích, có SnackBar xác nhận.

### Màn hình 3 — Yêu thích & Tìm kiếm
- Danh sách các bài đã được đánh dấu yêu thích.
- **Tìm kiếm riêng** trong danh sách yêu thích.
- Dữ liệu được **persist qua SharedPreferences** — không mất khi tắt app.

### Xử lý lỗi & UX
- `CircularProgressIndicator` khi tải dữ liệu lần đầu.
- `SnackBar` hiển thị lỗi (SocketException, timeout...) với action **Thử lại**.
- `ErrorView` cho trạng thái lỗi khi chưa có data.
- `EmptyState` khi tìm kiếm không có kết quả.

---

## 2. Kiến trúc (Clean Architecture)

```
┌──────────────────────────┐
│        View (UI)         │   screens/, widgets/
│   - HomeScreen           │
│   - DetailScreen         │
│   - FavoritesScreen      │
└───────────┬──────────────┘
            │ watch / read
┌───────────▼──────────────┐
│   Controller / ViewModel │   providers/
│   - NewsProvider         │   (ChangeNotifier + Provider)
│   - FavoritesProvider    │
└───────────┬──────────────┘
            │ dùng
┌───────────▼──────────────┐
│       Repository         │   repositories/
│   - ArticleRepository    │   (lớp trung gian, tiện mock khi test)
│   - FavoritesRepository  │
└───────────┬──────────────┘
            │ gọi
┌───────────▼──────────────┐
│     Data Source          │   services/
│   - NewsApi (HTTP)       │   + SharedPreferences
└──────────────────────────┘
```

### Ánh xạ Clean Architecture
- **Model**: `lib/models/article.dart`
- **View**: `lib/screens/*.dart`, `lib/widgets/*.dart`
- **ViewModel / Controller**: `lib/providers/*.dart`
- **Repository**: `lib/repositories/*.dart`
- **Data source**: `lib/services/news_api.dart` + SharedPreferences

---

## 3. Cấu trúc thư mục

```
lib/
├── main.dart                        # Dependency injection + MaterialApp
├── models/
│   └── article.dart                 # Data model + fromJson
├── services/
│   └── news_api.dart                # HTTP client gọi JSONPlaceholder
├── repositories/
│   ├── article_repository.dart      # Wrap NewsApi
│   └── favorites_repository.dart    # SharedPreferences (JSON)
├── providers/                       # ChangeNotifier (ViewModel)
│   ├── news_provider.dart           # Load, search (debounce)
│   └── favorites_provider.dart      # Toggle, persist, search
├── screens/                         # View - các màn hình
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   └── favorites_screen.dart
└── widgets/                         # Widget tái sử dụng
    ├── article_card.dart
    ├── search_field.dart
    ├── error_view.dart
    ├── empty_state.dart
    └── favorites_icon_button.dart   # Icon trái tim + Badge
```

---

## 4. Thư viện sử dụng

| Package | Mục đích |
|--------|----------|
| `http` | Gọi REST API JSONPlaceholder |
| `provider` | Quản lý trạng thái (ChangeNotifier) |
| `intl` | Format ngày tháng tiếng Việt |
| `shared_preferences` | Persist danh sách yêu thích |
| `cupertino_icons` | Icon mặc định |

---

## 5. Cách chạy

### Cài dependencies
```bash
flutter pub get
```

### Chạy trên Android (trong Android Studio)
1. Mở Android Studio → **Open** folder `D:\tu_huy_hoag`.
2. Bật một AVD (Android Virtual Device) hoặc cắm máy Android thật.
3. Nhấn **Run** ▶ hoặc gõ trong terminal:
```bash
flutter run
```

### Chạy thử trên web / desktop (nếu cần)
```bash
flutter run -d chrome
flutter run -d windows
```

### Chạy test
```bash
flutter test
```

---

## 6. Checklist yêu cầu đề bài

| Hạng mục | Điểm | Trạng thái |
|---------|------|:---:|
| Home: API + Image + Title + Desc + Date | 3.0 | ✅ |
| Home: Pull-to-refresh | — | ✅ |
| Detail: Đầy đủ nội dung + Back | 2.0 | ✅ |
| Detail: Nút Favorite | — | ✅ |
| Favorites list + Provider | 2.0 | ✅ |
| Search theo tiêu đề | — | ✅ (cả Home + Favorites) |
| CircularProgressIndicator | 1.0 | ✅ |
| SnackBar báo lỗi | — | ✅ |
| Clean Architecture (Model/View/VM/Repo) | 2.0 | ✅ |
| Material Design | — | ✅ (Material 3) |
| Widget tách nhỏ tái sử dụng | — | ✅ (5 widget riêng) |
| Provider quản lý trạng thái | — | ✅ |

**Ngoài yêu cầu — điểm cộng:**
- Favorites **persist** khi tắt app (SharedPreferences).
- Search có **debounce 300ms**.
- **Badge** số lượng favorites trên AppBar.
- **ErrorView** + **EmptyState** tách widget tái sử dụng.
- **Repository pattern** — dễ mock khi viết unit test.
