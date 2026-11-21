# 15 — Độ Rõ Chiến Trường (Battlefield Readability) — Asset Prompts

- **Danh mục:** 1 sprite sheet nước Hồ Koi và 5 sprite sheet hiệu ứng thay thế để thử trong Chương 1 và Chương 3.
- **Thư mục nhận raw:** `inbox/`. Tạo mỗi prompt thành một PNG riêng theo tên bên dưới. Hậu tố `_readable` giúp đối chiếu với bản hiện tại khi adapt.
- **Thư mục đích sau adapt:** `assets/sprites/tiles/` và `assets/sprites/fx/`. Agent tạo ảnh chỉ bàn giao raw trong `inbox/`.
- **Quy chuẩn chung:** Lưới 4 cột × 3 hàng, 12 frame đọc trái sang phải rồi trên xuống dưới. Kích thước đích sau chuẩn hóa 512×384 px, mỗi frame 128×128 px. FX ưu tiên PNG alpha thật. Nếu công cụ chỉ xuất nền đặc, dùng trắng phẳng #FFFFFF và tránh chi tiết trắng tinh bên trong FX. Ô nước phủ kín từng frame và không có gutter. Giữ tâm ổn định, không chữ, watermark, vạch lưới, nhân vật hoặc mockup.
- **Tham chiếu:** Dùng sprite hiện tại ghi ở từng prompt để giữ nhận diện màu sắc và hướng nhìn. Xem thêm [ASSET_SPEC.md](../../docs/ASSET_SPEC.md) để bàn giao.

## 1. Mặt Nước Hồ Koi Ban Đêm (`env_koi_water_anim_readable.png`) — [P1]

```
Output file: inbox/env_koi_water_anim_readable.png
Reference: assets/sprites/tiles/env_koi_water_anim.png
Grid: 4 × 3, 12 equal square frames, opaque and edge-to-edge.

Prompt:
Create a hand-painted Japanese Edo chibi game sprite sheet for a tileable night koi pond floor. Use a subdued blue-teal base, soft low-contrast water caustics and two small coral-and-cream koi beneath the surface. Keep the contrast gentle enough for cyan ice projectiles, green defenders and black-outlined yokai to read over it. Avoid white glints and thick, bright caustic webs.
Frames 1–12: a seamless loop of softly drifting caustics and koi movement. Keep large-scale surface brightness stable between frames. Match the four edges in every frame so horizontally adjacent copies at different animation phases show no abrupt edge. No banks, lily pads, borders, gutters or shadows at tile edges.
```

## 2. Vòng Hồi Máu Sát Đất (`fx_heal_aura_readable.png`) — [P0]

```
Output file: inbox/fx_heal_aura_readable.png
Reference: assets/sprites/fx/fx_heal_aura.png
Grid: 4 × 3, 12 equal square frames, transparent FX.

Prompt:
Create a hand-painted Edo chibi healing effect that reads as a shallow mint-green ellipse on the ground. Keep the interior transparent and use a narrow soft rim with two or three tiny leaf motes at its sides. The unit's body above the ring must remain visible even when neighboring units receive healing at the same time.
Frames 1–3: small rim appears. Frames 4–7: one gentle outward pulse. Frames 8–12: rim and leaves dissolve. Center the ellipse consistently in each cell. No vertical beam, opaque disc, broad glow or white center.
```

## 3. Sóng Chuông Băng (`fx_frost_chime_wave_readable.png`) — [P0]

```
Output file: inbox/fx_frost_chime_wave_readable.png
Reference: assets/sprites/fx/fx_frost_chime_wave.png
Grid: 4 × 3, 12 equal square frames, transparent FX.

Prompt:
Create a frost-chime pulse for a hand-painted Edo chibi game. Use two fine broken ice-blue arcs and a few small ice flecks traveling out from the center. Keep the center open so the target's face and pose stay readable. Use cool blue edges with restrained highlights, no solid cyan orb or white flare.
Frames 1–3: arcs form. Frames 4–7: arcs expand from a fixed center. Frames 8–12: arcs and ice flecks disperse. Keep all marks inside the cell with transparent margins.
```

## 4. Vệt Khói Độc (`fx_poison_cloud_readable.png`) — [P1]

```
Output file: inbox/fx_poison_cloud_readable.png
Reference: assets/sprites/fx/fx_poison_cloud.png
Grid: 4 × 3, 12 equal square frames, transparent FX.

Prompt:
Create a compact Edo chibi poison effect for a mushroom defender. Draw two or three separated violet wisps curling toward the RIGHT, with open space between them and a few small dark-plum spores. Keep the puff low and horizontally stretched so it reads as poison as it moves down a lane. Avoid an opaque mass, bright magenta core and wide bloom.
Frames 1–3: wisps gather. Frames 4–7: curl and widen slightly toward the right. Frames 8–12: break apart and fade. Keep the anchor fixed across the sheet since the engine moves the complete sprite.
```

## 5. Tia Trúng Đòn (`fx_hit_spark_readable.png`) — [P1]

```
Output file: inbox/fx_hit_spark_readable.png
Reference: assets/sprites/fx/fx_hit_spark.png
Grid: 4 × 3, 12 equal square frames, transparent FX.

Prompt:
Create a compact hand-drawn Edo chibi impact spark. Use a small warm amber point and three or four short tapered rays. The impact should read at small scale over a dark or bright tile while leaving most of a chibi yokai's face visible. No large solid star, smoke cloud or full-cell glow.
Frames 1–3: quick impact with short rays. Frames 4–7: rays separate and dim. Frames 8–12: tiny embers disappear. Keep the impact point fixed at the center; leave ample transparent padding.
```

## 6. Mảnh Băng Khi Trúng Đòn (`fx_ice_hit_splash_readable.png`) — [P1]

```
Output file: inbox/fx_ice_hit_splash_readable.png
Reference: assets/sprites/fx/fx_ice_hit_splash.png
Grid: 4 × 3, 12 equal square frames, transparent FX.

Prompt:
Create a compact Edo chibi frost impact using three sharp pale-blue shards and a thin broken spray of cyan droplets. Use a defined blue edge so the shards remain readable over a teal koi pond. Leave the center mostly transparent and omit the opaque ice globe, strong white flash and mist veil.
Frames 1–3: shards appear at a fixed impact point. Frames 4–7: shards separate slightly. Frames 8–12: fragments soften and disappear. Keep generous transparent padding and a consistent impact anchor.
```
