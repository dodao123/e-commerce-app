# delivery_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
RUN FE
# Tự detect IP, không cần biết IP là gì
.\scripts\run_dev.ps1

# Hoặc chỉ định device
.\scripts\run_dev.ps1 -Device "emulator"

#down sv
netstat -ano | findstr :8081
taskkill /PID 5868 /F

