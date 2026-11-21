# Edo Garden Defense — Base Asset Sheet & Asset Pipeline Spec

> **Reference Sheet:** [base_assetsheet.jpg](references/base_assetsheet.jpg)  
> **Workflow:** Agent tạo asset đặt file vào `inbox/` → Agent tích hợp kiểm tra/cắt/chuẩn hóa vào `assets/sprites/...` → Chuyển file gốc từ `inbox/` sang `archive/`.

---

## 1. Quy Trình Xử Lý Asset (Inbox → Assets → Archive)

1. **`inbox/`**: Nơi nhận toàn bộ file raw / sprite sheet / icon mới do agent tạo asset sinh ra.
2. **`assets/sprites/`**: Nơi lưu các asset đã được chuẩn hóa (xóa nền chuẩn PNG transparent, đúng kích thước ô, cắt/đóng gói sprite sheet đều frame, đặt tên chuẩn `snake_case`) để Godot 4 nạp trực tiếp.
3. **`archive/`**: Sau khi adapt xong từ `inbox/` vào `assets/sprites/`, file gốc trong `inbox/` sẽ được di chuyển sang `archive/` (giữ nguyên hoặc thêm hậu tố ngày) để lưu vết và giữ `inbox/` luôn gọn sạch.

---

## 2. Quy Chuẩn Mỹ Thuật & Kỹ Thuật (Cho Agent Tạo Asset)

- **Phong cách mỹ thuật (Art Style):** Chibi 2D vẽ tay phong cách Nhật Bản thời Edo (ấm áp, nét viền nâu đậm/đen rõ nét `~3–4px`, đổ bóng mềm cel-shaded, khớp 100% với [base_assetsheet.jpg](references/base_assetsheet.jpg)).
- **Định dạng file:** `PNG` nền trong suốt (`transparent background`), không dính viền trắng/viền caro.
- **Hướng nhìn chuẩn (Facing Direction):**
  - **Quân phòng thủ (Defenders):** Quay mặt sang **PHẢI** (hướng về phía Yokai).
  - **Kẻ địch (Yokai):** Quay mặt sang **TRÁI** (tiến về phía nhà cổ Edo).
  - **Đạn & FX:** Hướng bay sang **PHẢI**.
- **Kích thước & Chuẩn số Frame (Base Grid Cell = `128×128 px`, ưu tiên dạng lưới Grid thay vì dải ngang quá dài để giữ đồng nhất hình ảnh & tương thích tốt WebGL 2):**
  - **Idle (Đứng yên):** **6 frames** (lưới `3×2` = `384×256 px` hoặc strip `6×1`), kết hợp nhún thở/đung đưa 60 FPS trong Godot.
  - **Walk / Attack / Produce / Cast / Die (Quân & Yokai thường):** **12 frames** (lưới `4×3` = `512×384 px`, chạy chuẩn `12–15 FPS`).
  - **Boss lớn (`oni_lon`) & Kỹ năng nổ lớn (`phao_hoa`, `fx_explosion`):** **16 frames** (lưới `4×4`, ô `192×192 px` hoặc `256×256 px` cho Boss; `128×128 px` cho VFX).
  - **VFX thông thường (khói độc, tia trúng đòn, gió lốc, đóng băng...):** **12 frames** (lưới `4×3`, ô `128×128 px`), kết hợp `CPUParticles2D` & Tween mờ dần 60 FPS trong Godot.
  - **Ô nền (Tiles):** `128×128 px` (tỉ lệ vuông 1:1, liền mạch cạnh).
  - **Vật cản (Obstacles):** `128×128 px` (căn đáy giữa — bottom-center).
  - **Đạn (Projectiles):** `64×64 px` (tĩnh hoặc 4–6 frames xoay/bay).
  - **UI Icon / Card:** Card `96×112 px`, Icon `64×64 px`.
- **Quy tắc căn tâm (Anchor) cho mọi frame:** Nhân vật và vật cản phải được căn **chính giữa theo chiều ngang, chạm đáy thống nhất (bottom-center)**; VFX căn **chính giữa tâm (center-center)** để triệt tiêu rung/giật (jitter).

---

## 3. Danh Mục Asset Từ Base Asset Sheet (Checklist)

### A. Quân phòng thủ (`assets/sprites/defenders/`)
Quy ước tên file: `<id>_<anim>.png` (VD: `dao_tien_idle.png`, `dao_tien_attack.png`).

| Ưu tiên | ID | Tên Việt | Mô tả hình ảnh & vai trò | Animations cần có | Trạng thái |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **P0** | `dao_tien` | Đào tiên | Cây hoa anh đào chibi — bắn đơn cánh hoa | `idle` (6f), `attack` (12f) | [x] |
| **P0** | `tre_no` | Tre nỏ | Khóm tre xanh tạo hình nỏ — bắn nhanh | `idle` (6f), `attack` (12f) | [x] |
| **P0** | `than_den` | Thần đèn | Đèn đá Tōrō phát sáng vàng — tạo Linh Hỏa | `idle` (6f), `produce` (12f) | [x] |
| **P0** | `bi_ngo` | Bí ngô | Quả bí ngô cam chibi — tường chặn | `idle` (6f), `damaged_1` (6f), `damaged_2` (6f) | [x] |
| **P0** | `nam_doc` | Nấm độc | Nấm tím chấm sáng — phun khói độc lan | `idle` (6f), `attack` (12f) | [x] |
| **P0** | `ho_lo_bang` | Hồ lô băng | Hồ lô xanh băng trong suốt — bắn làm chậm | `idle` (6f), `attack` (12f) | [x] |
| **P1** | `phao_hoa` | Pháo hoa | Bó pháo đỏ dây bện — nổ sát thương lớn | `arm` (12f), `explode` (16f) | [x] |
| **P1** | `phu_chu` | Phù chú | Lá bùa giấy Ofuda chữ 呪 — gây choáng | `idle` (6f), `trigger` (12f) | [x] |
| **P1** | `gio_loc` | Gió lốc | Chong chóng đỏ vàng — đẩy lùi / thổi bay | `idle` (6f), `blow` (12f) | [x] |
| **P1** | `chua_lanh` | Chữa lành | Ống nước tre Shishi-odoshi — hồi máu/hỗ trợ | `idle` (6f), `heal` (12f) | [x] |

### B. Kẻ địch — Yokai (`assets/sprites/enemies/`)
Quy ước tên file: `<id>_<anim>.png` (VD: `tieu_yeu_walk.png`, `oni_lon_attack.png`).

| Ưu tiên | ID | Tên Việt | Mô tả hình ảnh & vai trò | Animations cần có | Trạng thái |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **P0** | `tieu_yeu` | Tiểu yêu | Tanuki đội nón lá đeo tay nải — cơ bản | `walk` (12f), `attack` (12f), `die` (12f) | [x] |
| **P0** | `oni_nho` | Oni nhỏ | Quỷ đỏ nhỏ cầm chùy gỗ — trâu, khỏe hơn | `walk` (12f), `attack` (12f), `die` (12f) | [x] |
| **P0** | `nekomata` | Nekomata | Mèo tam thể hai đuôi — chạy rất nhanh | `walk` (12f), `attack` (12f), `die` (12f) | [x] |
| **P0** | `kappa` | Kappa | Yêu quái rùa xanh mai nâu — kháng sát thương | `walk` (12f), `attack` (12f), `die` (12f) | [x] |
| **P0** | `tengu` | Tengu | Yêu quái quạ đỏ cầm quạt — bay/nhảy qua chặn | `fly` (12f), `attack` (12f), `die` (12f) | [x] |
| **P0** | `oni_lon` | Oni lớn | Đại quỷ đỏ to lớn cầm chùy sắt — Trùm thường | `walk` (16f), `attack` (16f), `die` (16f) | [x] |
| **P1** | `miko_ma` | Miko ma | Vu nữ ma tóc dài áo trắng đỏ — triệu hồi | `walk` (12f), `summon` (12f), `die` (12f) | [x] |
| **P1** | `samurai_ma` | Samurai ma | Võ sĩ giáp đen vàng — giáp dày | `walk` (12f), `attack` (12f), `die` (12f) | [x] |
| **P1** | `yuki_onna` | Yuki-onna | Tuyết nữ kimono xanh trắng — đóng băng | `walk` (12f), `cast` (12f), `die` (12f) | [x] |
| **P1** | `ran_ong` | Rắn ống | Bạch xà mắt đỏ — đa mục tiêu / đổi làn | `walk` (12f), `attack` (12f), `die` (12f) | [x] |

### C. Ô nền — Tiles (`assets/sprites/tiles/`)
| Ưu tiên | ID | Tên Việt | Mô tả | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P0** | `tile_grass` | Cỏ xanh | Cỏ sân vườn sáng/tối (nên có 2 biến thể bàn cờ) | [x] |
| **P0** | `tile_dirt` | Đất | Đất nâu vàng ấm | [x] |
| **P1** | `tile_cobble` | Đá cuội | Đá lát đường xám nâu | [x] |
| **P1** | `tile_moss_stone` | Đá rêu | Đá lát phủ rêu xanh | [x] |
| **P1** | `tile_sakura` | Cánh hoa đào | Nền phủ đầy cánh hoa anh đào hồng | [x] |
| **P1** | `tile_gravel_night` | Sỏi đêm | Đá sỏi xanh xám cho màn sương đêm | [x] |
| **P1** | `tile_koi_water` | Hồ cá Koi | Nước xanh trong có bóng cá Koi bơi | [x] |
| **P2** | `tile_snow` | Tuyết | Nền tuyết trắng xanh nhạt | [x] |

### D. Vật cản — Obstacles (`assets/sprites/obstacles/`)
| Ưu tiên | ID | Tên Việt | Trạng thái |
| :---: | :--- | :--- | :---: |
| **P1** | `obs_rock` | Tảng đá | [x] |
| **P1** | `obs_spike_barricade` | Rào gai | [x] |
| **P1** | `obs_wood_fence` | Hàng rào gỗ | [x] |
| **P1** | `obs_crate` | Thùng gỗ | [x] |
| **P1** | `obs_haystack` | Đống rơm | [x] |
| **P1** | `obs_sake_barrel` | Thùng rượu Sake (nổ 3×3) | [x] |

### E. Trang trí & Bối cảnh — Props (`assets/sprites/props/`)
| Ưu tiên | ID | Tên Việt | Vai trò | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P0** | `prop_edo_house` | Nhà gỗ Edo | Nhà chính cần bảo vệ bên trái | [x] |
| **P0** | `prop_komainu` | Tượng sư tử đá Komainu | Phòng tuyến cuối cùng mỗi hàng | [x] |
| **P0** | `prop_torii` | Cổng Torii đỏ | Điểm xuất hiện Yokai bên phải | [x] |
| **P0** | `prop_sakura_tree` | Cây anh đào lớn | Trang trí rìa sân | [x] |
| **P1** | `prop_lantern` | Đèn đá trang trí | Trang trí lối đi | [x] |
| **P1** | `prop_bamboo_grove` | Rừng tre | Bối cảnh Chương 2 | [x] |
| **P1** | `prop_red_bridge` | Cầu gỗ đỏ | Bối cảnh Chương 3 (Hồ Koi) | [x] |
| **P1** | `prop_market_stall` | Quán hàng Edo | Trang trí rìa làng | [x] |
| **P2** | `prop_pagoda` | Chùa tháp | Bối cảnh nền xa | [x] |
| **P2** | `prop_banner` | Cờ hiệu đỏ | Cờ báo hiệu đợt lớn | [x] |

### F. Hiệu ứng (FX) & Đạn (`assets/sprites/fx/`)
| Ưu tiên | ID | Tên Việt | Chuẩn Frame | Trạng thái |
| :---: | :--- | :--- | :---: | :---: |
| **P0** | `proj_sakura_petal` | Đạn cánh hoa anh đào | 1f / 6f xoay | [x] |
| **P0** | `proj_bamboo_dart` | Đạn mũi tên tre | 1f / 4f | [x] |
| **P0** | `proj_ice_orb` | Đạn cầu băng | 6f | [x] |
| **P0** | `fx_poison_cloud` | Khói độc tím | 12f (`4×3`) | [x] |
| **P0** | `fx_hit_spark` | Tia nổ trúng đòn | 12f (`4×3`) | [x] |
| **P0** | `fx_smoke_puff` | Khói tan biến / đặt cây | 12f (`4×3`) | [x] |
| **P1** | `fx_explosion` | Vụ nổ pháo hoa / thùng Sake | 16f (`4×4`) | [x] |
| **P1** | `fx_wind_gust` | Luồng gió xoáy | 12f (`4×3`) | [x] |
| **P1** | `fx_petal_scatter` | Cánh hoa bay nền | 6f / particle | [x] |
| **P1** | `fx_freeze_overlay` | Hiệu ứng đóng băng | 12f (`4×3`) | [x] |
| **P1** | `fx_stun_stars` | Hiệu ứng choáng | 12f (`4×3`) | [x] |
| **P1** | `fx_heal_aura` | Hiệu ứng hồi máu | 12f (`4×3`) | [x] |

### G. Giao diện — UI (`assets/sprites/ui/`)
| Ưu tiên | ID | Tên Việt | Trạng thái |
| :---: | :--- | :--- | :---: |
| **P0** | `ui_spirit_flame` | Icon & vật phẩm Linh Hỏa (lửa xanh) | [x] |
| **P0** | `ui_card_frame` | Khung thẻ bài quân phòng thủ (active / disabled) | [x] |
| **P0** | `ui_wave_bar` | Thanh tiến độ đợt quái + đầu Oni | [x] |
| **P0** | `ui_btn_speed` | Nút tăng tốc `1x / 2x` (`>>`) | [x] |
| **P0** | `ui_btn_pause` | Nút tạm dừng (`||`) | [x] |
| **P0** | `ui_btn_shovel` | Nút Xẻng (thu hồi cây) | [x] |
| **P1** | `ui_panel_scroll` | Khung cuộn giấy Edo (Menu / Victory / Defeat) | [x] |

### H. Bối cảnh theo màn — Backgrounds (`assets/sprites/backgrounds/`)
| Ưu tiên | ID | Tên Việt | Chi tiết | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P0/P2** | `bg_ch1_sakura_village` | Chương 1: Làng Hoa Ban Ngày | 4 panel 16:9 (`_0`..`_3`) | [x] |
| **P2** | `bg_ch2_bamboo_sunset` | Chương 2: Rừng Tre Hoàng Hôn | 4 panel 16:9 (`_0`..`_3`) | [x] |
| **P2** | `bg_ch3_koi_shrine_night` | Chương 3: Hồ Cá Koi Đêm | 4 panel 16:9 (`_0`..`_3`) | [x] |
| **P2** | `bg_ch4_misty_castle` | Chương 4: Thành Cổ Sương Mù | 4 panel 16:9 (`_0`..`_3`) | [x] |
| **P2** | `bg_ch5_snowy_mountain` | Chương 5: Đỉnh Núi Tuyết Trắng | 4 panel 16:9 (`_0`..`_3`) | [x] |

### I. Vật phẩm & Nâng cấp — Items (`assets/sprites/items/`)
| Ưu tiên | ID | Tên Việt | Chi tiết | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P2** | `items_gems_currency` | Ngọc & Tiền tệ nâng cấp | 6 icon (`item_*`) | [x] |
| **P2** | `items_skills_buffs` | Kỹ năng chủ động & Buff | 6 icon (`skill_*`) | [x] |
| **P2** | `items_garden_upgrades` | Báu vật nâng cấp vườn | 6 icon (`upg_*`) | [x] |

### J. Lớp Bối Cảnh Sống Động & Công Trình Theo Chương (`assets/sprites/environments/`)
| Ưu tiên | ID | Tên Việt | Chi tiết | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P1/P2** | `env_top_borders_pack` | Viền trung cảnh trên Ch1–Ch4 | 4 dải lặp ngang (`env_border_top_ch1..ch4.png`) | [x] |
| **P1/P2** | `env_lawn_borders_pack` | Viền chuyển tiếp sân & hàng rào tuyết Ch5 | `env_border_top_ch5`, `env_edge_*`, `env_path_stepping_stones` | [x] |
| **P1/P2** | `env_chapter_houses_pack` | Nhà chính Edo theo Chương 2–5 | `house_ch2_teahouse` .. `house_ch5_snow_shrine` | [x] |
| **P1/P2** | `env_chapter_gates_pack` | Cổng xuất hiện Yokai Chương 2–5 | `gate_ch2_bamboo` .. `gate_ch5_snow_torii` | [x] |
| **P1/P2** | `env_biome_flora_pack` | Cây cối & tiểu cảnh theo mùa | 6 cụm thực vật 5 mùa (`flora_*`) | [x] |
| **P2** | `env_atmosphere_pack` | Lớp khí quyển, sương mù & ánh sáng | Mây, sương tím, quầng đèn, tia nắng, đom đóm, gió tuyết (`env_atmo_*`) | [x] |

### K. Nhân Vật Thủ Vườn, Biểu Tượng & HUD Mở Rộng (`assets/sprites/ui/`)
| Ưu tiên | ID | Tên Việt | Chi tiết | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P2** | `char_gardener_portraits` | Chân dung biểu cảm Thủ Vườn Nhí | 6 biểu cảm (`gardener_*`) | [x] |
| **P2** | `ui_branding_icons_pack` | Biểu tượng tiêu đề, App, xoay ngang, Kitsune | `ui_title_plaque`, `ui_app_icon`, `ui_rotate_landscape`, `ui_kitsune_auto` | [x] |
| **P2** | `ui_extended_hud_pack` | Khung kỹ năng, hộp thoại, sổ tay & nút mở rộng | `ui_skill_frame_*`, `ui_dialogue_box`, `ui_almanac_book`, `ui_btn_sound_muted`, `ui_btn_auto_collect` | [x] |

### L. Hiệu Ứng Chiến Đấu Bổ Sung (`assets/sprites/fx/`)
| Ưu tiên | ID | Tên Việt | Chi tiết | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P1/P2** | `fx_thunder_strike` | Tia sét Cuộn Sấm Sét | 12 frames (`4×3`) | [x] |
| **P1/P2** | `fx_frost_chime_wave` | Sóng âm Chuông Băng | 12 frames (`4×3`) | [x] |
| **P0/P1** | `fx_ice_hit_splash` | Vỡ băng trúng đòn Cầu Băng | 12 frames (`4×3`) | [x] |
| **P1** | `fx_miko_summon_circle` | Vòng tròn triệu hồi Miko Ma | 12 frames (`4×3`) | [x] |
| **P1** | `fx_yuki_ice_breath` | Luồng hơi lạnh Yuki-onna | 12 frames (`4×3`) | [x] |
| **P1** | `fx_armor_break` | Hiệu ứng vỡ giáp Samurai/Kappa | 12 frames (`4×3`) | [x] |

### M. Hồ Cá Koi Động, Đạn Animation & Icon Trạng Thái (`tiles/`, `fx/`, `ui/`)
| Ưu tiên | ID | Tên Việt | Chi tiết | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **P1** | `water_platforms_pack` | Lá sen, bè tre & vòng nước Hồ Koi | 6 sprites (`water_*`) | [x] |
| **P1/P2** | `env_koi_water_anim` | Mặt nước Hồ Cá Koi chuyển động | 12 frames (`4×3`) | [x] |
| **P0/P2** | `proj_sakura_petal_anim` | Đạn cánh hoa anh đào xoay | 6 frames (`3×2`) | [x] |
| **P0/P2** | `proj_ice_orb_anim` | Đạn cầu băng nhấp nháy | 6 frames (`3×2`) | [x] |
| **P0/P2** | `proj_dart_poison_anim` | Đạn tên tre & bọt độc animation | `proj_bamboo_dart_anim` (`3×1`) & `proj_poison_glob_anim` (`3×1`) | [x] |
| **P1/P2** | `gameplay_status_badges` | Badge trạng thái & khung đặt ô | 6 icons (`badge_*`) | [x] |
