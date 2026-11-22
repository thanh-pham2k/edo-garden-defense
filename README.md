# edo-garden-defense

## Triển khai Web lên Vercel

Godot 4.7.2 xuất sẵn HTML, JavaScript, WebAssembly và gói dữ liệu game. Vercel phục vụ trực tiếp bản Web đơn luồng từ `build/web`.

1. Đưa nhánh chứa mã game, asset mới và `vercel.json` lên GitHub.
2. Trên Vercel chọn **Add New → Project**, nhập repo và chọn thư mục gốc chứa `project.godot`.
3. Chọn **Deploy**. Cấu hình repo đặt Framework Preset là **Other**, lệnh build là `bash tools/build_web.sh` và Output Directory là `build/web`.

Build trên Vercel tự tải Godot 4.7.2 cho Linux x86_64 và chỉ tải các template Web đơn luồng. Các tệp build và cache được tạo tự động.

### Thử bản Web trên máy

Cần Python 3 và Godot 4.7.2. Trên macOS, script nhận Godot ở `/Applications/Godot.app` hoặc từ `PATH`. Có thể dùng `GODOT_BIN` nếu Godot nằm ở vị trí khác.

```sh
bash tools/build_web.sh
python3 -m http.server 8000 --directory build/web
```

Mở `http://localhost:8000` bằng trình duyệt có WebGL 2. Có thể dùng `npx vercel` để tạo bản xem trước từ thư mục gốc của repo sau khi đăng nhập Vercel.

[Hướng dẫn xuất Web của Godot](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html) · [Cấu hình build Vercel](https://vercel.com/docs/builds/configure-a-build)
