# Âm thanh Edo Garden Defense

Tám bản dưới đây lấy từ bản nghe thử công khai của Freesound. Trang nguồn của từng bản ghi giấy phép CC0. Các tệp trong game là bản cắt và chuyển mã Ogg Vorbis; bản nghe thử gốc nằm ngoài repository.

| Âm thanh | Tác giả và nguồn | Cách dùng trong game |
|---|---|---|
| The Koto | [zacate](https://freesound.org/people/zacate/sounds/714936/) | Cắt đoạn 25 giây từ giây thứ 3, chuyển mono và nối chồng 1,2 giây để lặp. |
| Birds, wind through bamboo and a little waterstream | [tomasloos](https://freesound.org/people/tomasloos/sounds/843520/) | Cắt đoạn stereo 16 giây từ giây thứ 24 và nối chồng 1,2 giây để lặp dưới nhạc. |
| Basic Click Wooden | [GameAudio](https://freesound.org/s/220200/) | Cắt tiếng click còn khoảng 0,22 giây. |
| Soft Magic Spell Cast Whoosh | [Assetsmith](https://freesound.org/people/Assetsmith/sounds/876167/) | Cắt đoạn ngắn cho cánh hoa, băng và Nấm Độc. |
| Soft Impact – Pillow Hit | [KoimeMatsuchiya](https://freesound.org/people/KoimeMatsuchiya/sounds/872227/) | Cắt đuôi cho tín hiệu trúng đòn. |
| Soft explosion puff | [ihitokage](https://freesound.org/people/ihitokage/sounds/656066/) | Cắt đuôi cho tiếng nổ và Yokai bị tiêu diệt. |
| Stick – Whoosh 7 (Soft) | [Sadiquecat](https://freesound.org/people/Sadiquecat/sounds/802465/) | Cắt còn 0,27 giây, chuyển mono và làm mờ hai đầu cho tiếng Tre Nỏ bắn. |
| Bell at Daitokuji temple, Kyoto | [nahmandub](https://freesound.org/people/nahmandub/sounds/131348/) | Lấy 1,6 giây đầu, lọc dải trầm và giảm dần đuôi. Phát khi báo đợt Yokai lớn. |

Ở menu chọn chương, nút loa mở tùy chọn nhạc nền, âm thanh thiên nhiên, SFX và tắt toàn bộ. Nút loa trong trận vẫn dùng để tắt hoặc bật toàn bộ. Chuyển màn giữ các vòng lặp đang chạy, với gain ambience chuyển dần trong 1,4 giây theo chương.

SFX được giới hạn bằng đồng hồ thực. Các sự kiện dùng chung một mẫu âm thanh chia sẻ khoảng nghỉ. Ở 5×, thời gian tối thiểu giữa hai lượt phát bất kỳ trong cùng nhóm là 125 ms cho tấn công, 140 ms cho va chạm và 150 ms cho phép. Số tiếng đồng thời tối đa theo nhóm lần lượt là 3 tấn công, 1 va chạm, 2 phép, 2 giao diện và 2 tín hiệu quan trọng.

Bus Master dùng HardLimiter với trần −1 dB trên nền tảng có hỗ trợ hiệu ứng mixer. Bản Web dùng phát mẫu mặc định của Godot; khoảng nghỉ, trần số tiếng và gain vẫn được áp dụng tại AudioManager.

Bản [koto and shamisen loop.wav của zagi2](https://freesound.org/people/zagi2/sounds/222655/) có giấy phép CC BY-NC 4.0 nên không nằm trong bộ asset của game. Chuông gió, intro và sáo là các phương án bổ sung cho vòng thử âm thanh sau.
