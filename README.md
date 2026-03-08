# Tapto

A Flutter mobile application (client) that communicates with a REST API backend. This repository contains the Flutter app source, platform folders, and shared assets.

**Key features (inferred from codebase)**
- Authentication (login/register, profile, password reset)
- Product browsing and categories
- Cart sync and management
- Orders (user and admin flows), tracking and status updates
- Address management and image upload for profiles

**Repository layout (top-level)**
- `lib/` — Flutter app source (entry: `lib/main.dart`)
- `android/`, `ios/`, `macos/`, `linux/`, `web/`, `windows/` — platform projects
- `assets/` — fonts, images, translations
- `test/` — unit and widget tests

**API configuration**
The API endpoints and runtime base URL logic live in `lib/core/api/api_endpoint.dart`.

Important runtime controls:
- `API_BASE_URL` environment override: set at runtime via Dart define, e.g.

  ```bash
  flutter run --dart-define=API_BASE_URL=http://192.168.1.92:4000
  ```

- If `API_BASE_URL` is not provided, the app computes a base URL using `Platform` and these constants defined in the file:
  - `compIpAddress` — your computer LAN IP (default in file: `192.168.1.92`). Update this if your IP changes.
  - `isPhysicalDevice` — set to `true` when running on a physical device so the app will use `http://<compIpAddress>:4000`.
  - Android emulator uses `10.0.2.2` when `isPhysicalDevice` is `false`.
  - iOS simulator uses `localhost` when `isPhysicalDevice` is `false`.

Timeouts (from the same file):
- `connectionTimeout` = 20s
- `receiveTimeout` = 20s

**Main API endpoints (from `lib/core/api/api_endpoint.dart`)**
- Auth
  - POST `/api/auth/login`
  - POST `/api/auth/register`
  - GET `/api/auth/me`
  - GET/PUT `/api/auth/{id}`
  - POST `/api/auth/upload-profile-picture`
  - POST `/api/auth/request-password-reset`
  - POST `/api/auth/reset-password`

- Products
  - GET `/api/products`
  - GET `/api/products/{id}`
  - GET `/api/products/categories`
  - GET `/api/products/category/{category}`
  - GET `/api/products?category={fashionType}`

- Admin Products
  - `/api/admin/products`
  - `/api/admin/products/{id}`

- Categories
  - `/api/categories`
  - `/api/categories/{id}`

- Orders
  - `/api/orders`
  - `/api/orders/my-orders`
  - `/api/orders/{id}`
  - `/api/orders/{id}/status`
  - `/api/orders/{id}/track`
  - `/api/orders/{id}/location`
  - `/api/orders/{id}/cancel`

- Addresses
  - `/api/addresses`
  - `/api/addresses/{id}`
  - `/api/addresses/{id}/default`

- Cart
  - `/api/cart`
  - `/api/cart/sync`
  - `/api/cart/{id}`

**Quick start (dev)**
1. Install Flutter (stable) and set up platform tooling.
2. From project root:

```bash
flutter pub get
# Run on default device (with optional API override):
flutter run --dart-define=API_BASE_URL=http://192.168.1.92:4000
```

If running on an emulator and not using `API_BASE_URL`, ensure `compIpAddress` matches your machine IP or set `isPhysicalDevice` accordingly.

**Example: override base URL for development**
- Android emulator (recommended):
  ```bash
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
  ```
- iOS simulator:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://localhost:4000
  ```

**Testing**
- Run unit/widget tests:

```bash
flutter test
```

**Development notes**
- Keep `compIpAddress` updated when your development machine IP changes and you rely on that constant.
- Use `--dart-define=API_BASE_URL=...` for quick switching between local, staging, and production APIs.

**Where to look in code**
- API endpoint definitions and base URL logic: [lib/core/api/api_endpoint.dart](lib/core/api/api_endpoint.dart)
- App entrypoint: `lib/main.dart`

**Next steps / recommendations**
- Add a small `.env` or help script to set `API_BASE_URL` per environment.
- Add CI job to run `flutter test` and static analysis.
- Add short CONTRIBUTING.md with branch and PR process.

**License & contact**
Include project license and contributor contact info here.

---
Generated from code inspection of `lib/core/api/api_endpoint.dart` to capture runtime configuration and endpoints.