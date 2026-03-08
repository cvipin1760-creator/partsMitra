# Apply these fixes to fix Flutter build errors

Copy the following 3 files from this folder into your project at `F:\New_folder\apkdev\apkdev\spare_parts_app_new\lib\` (overwrite existing):

1. **lib/services/remote_client.dart**  ← copy from this project's `lib/services/remote_client.dart`
2. **lib/services/order_service.dart**   ← copy from this project's `lib/services/order_service.dart`
3. **lib/screens/admin_dashboard.dart**  ← copy from this project's `lib/screens/admin_dashboard.dart`

If you are already in this project (sparehub-main/spare_parts_app_new), the files here are already fixed. Copy this entire **spare_parts_app_new** folder to `F:\New_folder\apkdev\apkdev\` and replace the existing folder, then run:

```
flutter run --dart-define=BASE_URL=https://sparehub-0t47.onrender.com/api
```
