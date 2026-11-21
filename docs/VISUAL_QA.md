# Kiểm chứng hình ảnh và bản build

Bản kiểm tra ngày 21/11/2026 dùng Godot 4.7.2, Compatibility Renderer và bản lưu riêng. Ảnh chiến trường đối chiếu commit gốc `1745592` với worktree hiện tại. Hai bên dùng cùng đội hình đặt theo ô, vị trí xuất hiện ban đầu của Yokai, 400 Linh Hỏa, khung 1280×720 và 18 frame mô phỏng ở 5×. Một số hiệu ứng hoặc vị trí sau khi di chuyển có thể khác do thay đổi trong bản hiện tại.

- [Chiến trường trước và sau ở cả 5 chương, cùng kịch bản 5×](references/visual_qa/battlefield_before_after.jpg)
- [Ảnh nền nguồn và texture đã nén của cả 5 chương](references/visual_qa/background_import_comparison.jpg)

## Kiểm chứng tổng thể trong Godot

- [Chiến trường trước và sau ở cả 5 chương](references/visual_qa/art_direction_before_after.jpg). Cùng đội hình, vị trí xuất hiện, nhịp mô phỏng 5× và khung 1280×720. Hai cột đối chiếu bản liền trước và sau lượt làm lại nền và lề sân.
- Đã kiểm tra 319 PNG nguồn và 817 ô trong 78 atlas thân, hiệu ứng, đạn, Linh Hỏa và cá. Các lượt chạy có trả Linh Hỏa cho thẻ bao phủ cả 5 làn ở từng chương, lấy mẫu vị trí quân theo ô và Yokai theo đường chạm đất. Chụp cảnh mở màn, giao chiến, boss và kết quả trực tiếp trong Godot.

## Nhịp mở màn và Linh Hỏa

| Chương | Linh Hỏa khởi đầu | Chuẩn bị ở 1× | Chuẩn bị khi chọn 5× |
|---|---:|---:|---:|
| 1 | 175 | 30 giây | 15 giây |
| 2 | 200 | 28 giây | 14 giây |
| 3 | 200 | 28 giây | 14 giây |
| 4 | 225 | 26 giây | 13 giây |
| 5 | 250 | 26 giây | 13 giây |

- Giai đoạn chuẩn bị dùng một đồng hồ mô phỏng chung, tối đa 2× cho đợt đầu, đèn, Linh Hỏa và hồi thẻ. Tốc độ đã chọn áp dụng khi vào Đợt 1. Sau khoảng 2 giây mô phỏng, Thần Đèn nhả 30 Linh Hỏa đầu. Các lượt sau cách nhau khoảng 9 giây mô phỏng.
- Kịch bản có trả phí thẻ và thu Linh Hỏa qua đầu vào Godot kiểm tra đủ 5 chương ở 1× và 5×, với thẻ Thần Đèn đặt ở giây thực thứ 4. Thu được Linh Hỏa từ đèn trước khi quái vào trong 10/10 lượt. Đã hoàn tất 40 đợt ở mỗi tốc độ với chiến thuật theo chương. Chạy riêng chế độ AUTO 5× cũng hoàn tất cả 40 đợt.
- [Thần Đèn nhả Linh Hỏa trước Đợt 1 ở Hồ Koi](references/visual_qa/opening_lantern_5x.jpg). Lượt này chạy theo đồng hồ thực, đặt đèn ở giây thứ 4 rồi bấm thu Linh Hỏa.

## Nền chiến trường ngày 22/11/2026

- [Ảnh nền trước và sau của cả 5 chương](references/visual_qa/terrain_before_after.jpg). Hai bản chụp ở 1280×720, Compatibility Renderer, 5×, cùng đội hình và vị trí xuất hiện Yokai.
- Nền và lề sân dùng chung vật liệu chuyển tiếp theo tọa độ thế giới. Mỗi chương lấy một cặp texture từ bộ gốc. Các đường làn và vạch ngắn chỉ ô đặt quân bám theo lưới gameplay.
- Hồ Koi có dòng nước và mép bờ nối liền. Ba cụm cá dùng lại atlas 4×3 với lớp nước nền được lọc bằng shader. Tôi giảm mật độ đốm sáng ở Hồ Koi để dễ phân biệt với Linh Hỏa.
- Bộ test gameplay qua, cả 40 đợt AUTO 5× hoàn tất. Trong lượt đo 180 frame ở Hồ Koi, 1280×720 và giới hạn 60 FPS, hai bản đều đạt 60 FPS. Khoảng cách frame p95 là 17,28 ms trước sửa và 17,33 ms sau sửa. Số lệnh vẽ tại frame lấy mẫu giảm từ 261 xuống 167.

## Điểm neo và cảnh trí

- [Ảnh cận cảnh trước và sau của cả 5 chương](references/visual_qa/scenery_before_after.jpg). Hai cột dùng cùng khung 1280×720 và cùng tình huống 5×.
- [Dữ liệu điểm chạm đất](../scripts/battle/scenery.gd) ghi tọa độ chân và chiều rộng nhìn thấy theo pixel gốc của mỗi asset. Đền, cổng, cây, đèn và đá dùng dữ liệu này để đặt sprite và bóng tiếp xúc. Cụm đá có kích thước và hướng khác nhau dọc hai lề sân.
- Đền Hồ Koi đứng trên bờ, cầu bắc qua nhánh nước ngoài lưới và Komainu làn nước có bệ đá. Đá sáng màu ở Hồ Koi và đá phủ lá ở Thành Cổ lấy từ bộ asset hiện có. Giảm ánh đèn và đưa đốm sáng ở Thành Cổ về lề.
- Bộ test dự án kiểm tra texture và tọa độ neo của cảnh trí trong cả 5 cấu hình chương. Đã chạy đủ 40 đợt AUTO 5× sau khi bố trí lại cảnh trí.

## Atlas thân nhân vật và vật cản

- Đã đo **55 atlas, 580 ô** đang dùng cho quân, Yokai, Komainu và vật cản. Không có pixel với alpha từ 64/255 chạm mép ô. Hai ô rỗng là khung cuối animation bị hạ của Tiểu Yêu và Kappa.
- [Khung hình Tengu trước và sau trong Godot](references/visual_qa/tengu_contact_before_after.jpg). Bốn trạng thái được dựng ở cùng tọa độ trong trận. Khi bị Gió Lốc kéo xuống, Tengu dùng điểm chạm chân đo riêng cho từng khung đi và tấn công. Huy hiệu bay bám theo độ cao của Tengu; khung bị hạ dùng chung đường chân với khung đầu animation để phần khói tiếp tục tan tự nhiên.
- Các atlas thân dùng chung quy tắc lề chân, với 6 px cho ô 128 px và 8 px cho ô 192 px. Vòng lặp hoạt ảnh xử lý tất cả khung đã trôi qua ở 5×. Bộ test xác nhận một frame dài vẫn đi đúng làn và đòn cận chiến đi qua mốc va chạm chỉ gây sát thương một lần. AUTO 5× hoàn tất cả 40 đợt.

## Atlas hiệu ứng và độ rõ khi giao chiến

- [Cảnh đông hiệu ứng trước và sau ở cả 5 chương](references/visual_qa/combat_effects_before_after.jpg). Hai bản dùng cùng vị trí quân và Yokai, 1280×720, dựng các hiệu ứng cùng lúc ở 5× và so sánh cùng thời điểm mô phỏng.
- Đã kiểm tra 23 atlas hiệu ứng, đạn, Linh Hỏa và cá, tổng cộng 237 ô. 22 atlas có hình với alpha từ 64 trở lên nằm trong lề từng ô. Atlas cá có nền nước phủ kín theo thiết kế; shader lọc lớp nền nước khi ghép.
- Khối băng cố định nằm dưới thân quân và bám chân. Các vụ nổ, khói, độc, hồi phục và sét dùng lớp dưới thân quân. Thanh máu của quân và vật cản được vẽ phía trên, chỉ hiện khi bị thương.
- Bộ test gameplay qua và AUTO 5× hoàn tất 40 đợt. Lượt đo 180 frame ở Hồ Koi với trần 60 FPS cho kết quả p95 17,93 ms trước sửa và 18,18 ms sau sửa.

## Bố cục khi đổi kích thước cửa sổ

- [Ảnh trước và sau ở khung 32:9 và 1:1](references/visual_qa/framing_before_after.jpg). Nền và hàng rào phủ theo kích thước vùng nhìn, giữ tọa độ họa tiết khi đổi kích thước. Sân ngoài giảm tương phản dần, giúp khu vực đặt quân nổi lên trong các khung rộng và cao.
- Đã chụp cả 5 chương ở 1280×720, 1920×540, 1024×768 và 900×900. Trong cùng một trận Godot, đổi lần lượt giữa bốn khung và kiểm tra với vùng an toàn bất đối xứng mô phỏng. Các lượt bấm thẻ, đặt cây và dùng Trà Matcha đều trúng vị trí hiển thị.
- Bộ test gameplay qua và AUTO 5× hoàn tất 40 đợt. Ở Hồ Koi 1920×540, lượt đo 180 frame có trần 60 FPS duy trì 60 FPS, p95 17,40 ms.

## Chọn chương, tạm dừng và kết quả trận

- [Ảnh giao diện trước và sau](references/visual_qa/interface_before_after.jpg). Khung chọn chương giữ tỷ lệ tối đa 1280×720 và căn giữa vùng an toàn. Hình thu nhỏ Hồ Koi dùng tile nước; ảnh nền mùa được giữ làm lớp trang trí chính.
- Tiêu đề thắng và thua nằm trong dải banner. Nút về chọn chương dùng cùng bảng màu với giấy cuộn. Chiến thắng Chương 5 hiện một nút chơi lại.
- Đã bấm chọn Chương 3, vào trận, tạm dừng, tiếp tục, thử lại sau khi dựng trạng thái thua, chuyển chương sau khi dựng trạng thái thắng và quay về menu. Luồng qua ở 1280×720, 1920×540 và 900×900. Bộ test gameplay qua, AUTO 5× hoàn tất 40 đợt. Đã kiểm tra 237 đường dẫn tài nguyên được khai báo trực tiếp trong scene và script, tất cả tệp đều tồn tại.

## Vấn đề đã xử lý

| Mức độ | Vấn đề quan sát được | Thay đổi và bằng chứng |
|---|---|---|
| P0 | Vòng hồi máu, băng và khói che hình quân; chỉ báo trạng thái có thể lẫn vào hiệu ứng | Tách lớp thanh máu và trạng thái, thu gọn VFX và giảm độ che của thời tiết. Render Chương 3 ở 1× và 5× cho thấy vẫn đọc được quân và thanh máu khi hiệu ứng xuất hiện. |
| P0 | Đạn có thể vượt qua mục tiêu ở frame dài | Kiểm tra giao đoạn di chuyển của đạn, ưu tiên mục tiêu đầu tiên. Bộ test có ca chạy đạn qua hai Yokai trong cùng một frame. |
| P0 | Cụm đá, cây và cổng chồng lên lối vào | Dời cảnh trí ra lề, căn bóng và điểm tiếp đất theo hàng. Kiểm tra Yokai đi ngang và về đúng trục khi đổi hàng. |
| P1 | Nền đá Chương 2 và nền hoa Chương 3 cạnh tranh với quân | Dùng chung shader giảm độ bão hòa và tương phản của ô đất, với tham số riêng từng chương. Giữ làn nước tách rõ với đất. |
| P1 | Thiếu bản sắc theo mùa ở công trình và cảnh trí | Tích hợp Torii theo từng chương, nhà và cây tuyết, đèn mùa đông, đường đá đêm, hoàng hôn và tuyết. |
| P1 | Dải xám phía trên HUD và mép nền bị hở ở màn cao hoặc siêu rộng | Bỏ hai lớp phủ tối, cho bầu trời phủ mép trên và kéo dài phần lát sân. Quan sát ở 16:9, 4:3, 1280×800 và khung siêu rộng. |
| P1 | Có thể bỏ sót Linh Hỏa khi người chơi vuốt nhanh | Thu theo đoạn đường con trỏ đi qua. Kiểm tra một sự kiện vuốt thu hai vật phẩm trên đường và bỏ qua vật phẩm ngoài đường. |
| P1 | Kéo thẻ gần mép trên của một làn có thể xem trước và đặt nhầm sang làn phía trên | Tính ô trực tiếp từ vị trí con trỏ, cập nhật xem trước ngay khi bắt đầu kéo và dùng cùng tọa độ lúc thả. Bộ test gameplay và lượt kiểm tra cảm ứng mô phỏng ở 5× xác nhận đặt đúng làn. |
| P1 | Giá Linh Hỏa trên thẻ chọn đội hình lệch khỏi phù hiệu | Căn label theo kích thước ảnh thực tế và điểm neo riêng của thẻ đang chọn và chưa chọn. Đã xem ảnh menu ở 1280×720. |
| P1 | HUD có thể chạm mép màn hình có vùng khuyết | Menu và HUD dùng vùng an toàn do nền tảng native báo. Ảnh mô phỏng với inset bất đối xứng xác nhận hàng HUD và cụm kỹ năng nằm trong giới hạn. |
| P1 | Sai đích bay Linh Hỏa sau đổi kích thước; trận vẫn tiến sau lời nhắc xoay màn hình | Lấy vị trí thật của biểu tượng HUD, ngừng mô phỏng chiến trường trong khung dọc và giữ trạng thái tạm dừng khi quay lại. |
| P1 | Game tự bật AUTO 5× khi mở giao diện và ghi thiết lập thử vào bản lưu | Game mở menu chọn chương. Bật AUTO 5× qua nút trong game hoặc cờ `--autoplay-5x-10m`. Đã xác nhận bản Web mở menu và bản macOS giữ nguyên checksum bản lưu khi mở menu rồi thoát. |
| P1 | Cửa sổ chuẩn bị 8 giây ở 5× gây áp lực lên thao tác đặt đèn và thu Linh Hỏa | Tăng lên 13–15 giây ở 5× và 26–30 giây ở 1×, cộng 25 Linh Hỏa khởi đầu mỗi chương và cho đèn nhả Linh Hỏa đầu sau khoảng 2 giây mô phỏng. |
| P2 | Chớp sao choáng dùng đồng hồ thật, lệch nhịp ở 5× | Chuyển sang delta mô phỏng và thêm ca kiểm thử tiến frame. Rà cấu trúc 50 sprite sheet, xem hai animation chết có frame cuối trong suốt trong trận. |
| P2 | VFX cấp phát node và nạp texture lặp lại khi combat đông | Dùng lại tối đa 32 VFX đã phát xong và cache texture theo trận. Stress test ở 5× dùng 24 node qua 480 lượt phát; test xác nhận reset frame, texture, tốc độ và giới hạn pool. |
| P2 | Cảnh báo tài nguyên âm thanh khi đóng cửa sổ lúc đang phát | Trên desktop, dừng âm thanh và dành 100 ms theo đồng hồ thực để bộ trộn giải phóng các lượt phát trước khi thoát. Với CoreAudio và 5×, cảnh báo giảm từ 11/12 lượt trước sửa xuống 0/12 lượt sau sửa. |

## Kết quả và giới hạn

| Hạng mục | Bằng chứng hiện có | Phần còn cần kiểm chứng |
|---|---|---|
| Gameplay | Bộ test dự án qua. Bản hiện tại thắng cả 5 chương qua 40 đợt ở Auto 5× trong mô phỏng Godot. | Chơi thủ công đủ cả 5 chương trên thiết bị đích. |
| Web | Bản đơn luồng chạy và đặt cây được qua HTTP cục bộ. Safari trên macOS đã vào trận 5×, đặt cây, tạm dừng và bật/tắt ambience. Bản hiện tại trên Chrome nhận HTML, JS, WASM và PCK qua Brotli, tổng cộng 14,94 MB. Lượt mở menu với cache tắt mất 7,94 giây ở 16 Mbit/s, độ trễ mô phỏng 100 ms. | Xác nhận máy chủ triển khai phục vụ Brotli và thử Safari iOS, Chrome Android trên thiết bị thật. |
| Âm thanh | CoreAudio cho tín hiệu thực. Khi kích hoạt dồn cùng frame, số tiếng phát ở nhóm tấn công/va chạm/phép là 3/1/2 ở 1× và 1/1/1 ở 5×. Đã xác minh phát tiếp sau khoảng nghỉ thực, tốc độ nhạc và ambience, ưu tiên tiếng thắng, công tắc từng lớp và tắt toàn bộ. Đoạn ghi Auto 5× Chương 5 có đỉnh âm −14,2 dBFS. [Nguồn âm thanh](AUDIO_CREDITS.md) | Nghe A/B trong cả 5 chương trên loa điện thoại và trình duyệt mục tiêu. |
| macOS | Xuất app độc lập với template chính thức, kiểm tra chữ ký cục bộ và khởi động headless. Trên bản app độc lập có âm thanh mới, đã vào trận, tắt Auto, đặt Thần Đèn bằng chuột và tạm dừng trực tiếp trong cửa sổ. | Kiểm tra bản phân phối có notarization nếu chọn phát hành macOS. |
| Cảm ứng | Sự kiện Godot mô phỏng chạm chọn thẻ, chạm đặt cây, kéo thả thẻ vào đúng ô preview và vuốt một lần qua hai Linh Hỏa ở 5×. | Độ nhạy và thao tác cảm ứng trên phần cứng thật. |
| Android | Đã xuất APK QA ARM64 từ template Godot 4.7.2, kiểm chữ ký v2/v3 và xác nhận APK chứa hai mẫu âm thanh mới. Dùng Android SDK và Java tạm thời. | Cài và chạy trên thiết bị thật. Máy QA chưa có thiết bị Android kết nối. |
| iOS | Máy QA chỉ có Xcode Command Line Tools. | Xuất bản native với Xcode đầy đủ, ký và chạy trên thiết bị thật. |
| Hiệu năng | Mac Apple M5 Pro, OpenGL Compatibility, 1280×720, giới hạn 60 FPS, Chương 3 với đội hình showcase. Mỗi lượt đo 3,2 giây: 1× trung bình 60,02 FPS, p95 17,56 ms; 5× trung bình 60,05 FPS, p95 17,17 ms. Đây là số đo khoảng cách giữa process frame. | Số liệu frame time và bộ nhớ trên trình duyệt và thiết bị đích. |

## Chạy lại kiểm tra

Chạy bộ test gameplay bằng Godot 4.7.2 từ thư mục dự án, ưu tiên một bản sao có tên project riêng vì suite có ghi tiến trình.

```sh
godot --headless --editor --import
godot --headless --script res://tests/test_gameplay.gd
```

Kiểm tra đóng cửa sổ khi cả hai lớp nền và SFX đang phát ở 5× bằng audio driver desktop. Đọc log để xác nhận tài nguyên được giải phóng.

```sh
godot --verbose --script res://tests/test_audio_shutdown.gd
```

Dùng template export cùng phiên bản và các preset trong [export_presets.cfg](../export_presets.cfg). Giữ cả thư mục xuất Web khi thử qua HTTP. App macOS dành cho kiểm tra cục bộ. Bản Web chỉ đạt mốc 15 MB khi máy chủ chọn tệp nén cho trình duyệt hỗ trợ Brotli.

```sh
godot --headless --export-release Web /absolute/output/web/index.html
godot --headless --export-release "macOS QA" "/absolute/output/Edo Garden Defense.app"
godot --headless --export-release "Android QA" "/absolute/output/Edo-Garden-Defense-Android-QA.apk"
```

Preset Android QA cần Java SDK, Android SDK, template Android chính thức và khóa ký QA được cấp qua `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER` và `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`.

Để chuẩn bị tệp nén từ Web export có tên `index.html`:

```sh
node tools/compress_web_export.mjs /absolute/output/web
```

Máy chủ trả tệp `.br` qua URL gốc khi trình duyệt chấp nhận Brotli. Nếu trình duyệt chỉ chấp nhận gzip, dùng tệp `.gz`. Gửi đúng `Content-Encoding`, `Vary: Accept-Encoding` và kiểu nội dung gốc. Giữ tệp gốc làm dự phòng. Đo lại kích thước tải trên máy chủ HTTPS khi triển khai.
