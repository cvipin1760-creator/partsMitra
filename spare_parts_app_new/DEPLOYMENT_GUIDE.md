# Spares Hub - Deployment Guide

## Summary of Fixes Applied

Your app has been updated to work with the **remote backend** when deployed with `BASE_URL`. Previously, auth and several features used only local SQLite. Now they integrate with your Render backend.

### Key Changes

1. **Authentication (Remote API)**
   - **Login**: Uses `POST /auth/signin` against your backend
   - **Register**: Uses `POST /auth/signup` (location optional when remote)
   - **Google Sign-In**: Uses `POST /auth/google`
   - **OTP**: Uses `POST /auth/send-otp` for registration

2. **Products**
   - Product update: Uses `PUT /products/{id}` (backend endpoint added)
   - Product delete: Uses `DELETE /products/{id}` (backend endpoint added)

3. **Orders**
   - Admin order creation: Sends `sellerId` (required by backend)
   - Admin dashboard: Shows all orders via `/admin/orders`
   - Order parsing: Handles backend response format

4. **User Management**
   - Admin user list: Uses `GET /admin/users`
   - Status/role updates: Use remote API when `BASE_URL` is set

### Run with Remote Backend

```bash
flutter run --dart-define=BASE_URL=https://sparehub-0t47.onrender.com/api
```

### Build APK for Production

```bash
flutter build apk --release --dart-define=BASE_URL=https://sparehub-0t47.onrender.com/api
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

### Backend Deployment (Render)

1. Deploy the backend in `backend/` to Render (or your host)
2. Ensure the base URL matches what you pass to the app
3. Backend seed users (if present):
   - Admin: `admin@example.com` / `password123`
   - Wholesaler: `wholesaler@example.com` / `password123`
   - Retailer: `retailer@example.com` / `password123`
   - Mechanic: `mechanic@example.com` / `password123`

### Features Not in Backend (Local Only When Remote)

- **Order Requests**: Custom text/photo requests – backend has no equivalent; screen shows empty when remote
- **Notifications**: Backend has no notifications API; screen shows empty when remote
- **Product Aliases**: Voice aliases – backend has no support
- **Password Reset**: Uses local OTP flow; no remote reset endpoint

### Testing

1. Run with remote: `flutter run --dart-define=BASE_URL=https://sparehub-0t47.onrender.com/api`
2. Register a new user (location optional when remote)
3. Log in with the new user
4. Browse products, create orders, and test admin flows
