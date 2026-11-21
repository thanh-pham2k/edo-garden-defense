# 13 — Bệ Nổi Hồ Cá Koi, Nước Động, Đạn Bay Animation & Icon Trạng Thái (Water Platforms, Animated Projectiles & Status Badges) — Asset Prompts

- **Danh mục:** Lá sen / bè tre / bọt nước cho làn Hồ Cá Koi (Chương 3), mặt nước Hồ Cá Koi chuyển động 12 frames, đạn bay animation xoay/nhấp nháy (`6 frames` mỗi loại) và bộ icon trạng thái chiến đấu — 6 prompts
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/tiles/`, `assets/sprites/fx/`, `assets/sprites/ui/`
- **Quy chuẩn chung:** Mỗi prompt tạo 1 ảnh đứng riêng (standalone text-to-image, không dùng Edit Mode) gồm **6 hoặc 12 subimages (`3×2` hoặc `4×3`)**, nền trắng phẳng `#FFFFFF` (riêng `env_koi_water_anim.png` là 12 ô mặt nước liền mạch có viền hẹp giữa các ô), không đường kẻ lưới, không chữ.

---

## 1. Bộ Lá Sen, Bè Tre & Vòng Nước Hồ Cá Koi (`water_platforms_pack.png`) — [P1]
```
Output file: inbox/water_platforms_pack.png
Asset: Bộ Bệ Nổi Hồ Cá Koi (Lotus Lily Pads, Bamboo Raft & Water Ripples Pack) — 6 Subimages
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game water platform props pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (6 top-down angled Koi pond water placement platforms and water effects):
- Cell 1 (row 1, col 1): Lush bright emerald-green floating lotus lily pad with crisp curved leaf veins and gentle aqua water ripple around its rim (for planting ground defenders on Koi water lanes).
- Cell 2 (row 1, col 2): Floating green lotus lily pad decorated with a cute blooming pastel-pink lotus flower bud on the side edge.
- Cell 3 (row 1, col 3): Traditional Edo tied-bamboo floating wooden garden raft bound cleanly with cream hemp cords.
- Cell 4 (row 2, col 1): Bright stylized cartoon splash ring of sparkling aqua-white water droplets bursting upward (water entry splash).
- Cell 5 (row 2, col 2): Flat mossy gray temple stepping stone rising slightly above a delicate white water ripple ring.
- Cell 6 (row 2, col 3): Nibbled/chipped floating green lily pad showing slight bite notches on its outer rim (damaged lily pad state).
Composition & Technical Rules: Center-aligned inside every cell in slight top-down perspective matching PvZ lawn tiles, with generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant emerald, pink, bamboo-gold, and aqua watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 2. Mặt Nước Hồ Cá Koi Chuyển Động (`env_koi_water_anim.png`) — [P1/P2]
```
Output file: inbox/env_koi_water_anim.png
Asset: Ô Nước Hồ Cá Koi Chuyển Động (Animated Koi Pond Water Tile Loop) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square top-down tiles, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game animated water tile sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subject: Shimmering crystal-clear turquoise Japanese temple Koi pond tile with bright sunlit surface water ripples and two small orange-and-white Koi fish swimming gracefully underneath.
Animation sequence (12-frame seamless swimming loop):
- Frames 1-12: Continuous smooth undulating water caustics and surface ripple highlights shimmering across the square tile while the two cute orange-white Koi fish glide smoothly in a gentle curved figure-eight loop inside the pond tile.
Composition & Technical Rules: Consistent top-down square tile geometry across all 12 frames, keeping clear narrow white separation gaps between frames.
Art Style: Hand-drawn 2D Edo chibi game art, crisp turquoise watercolor cel-shading with soft luminous surface highlights and clean koi fish silhouettes.
Clean Output: Pure flat solid white background (#FFFFFF) in narrow gutters outside the square water tiles, strictly NO text, NO numbers, NO dark black border boxes.
```

## 3. Đạn Cánh Hoa Anh Đào Xoay (`proj_sakura_petal_anim.png`) — [P0/P2]
```
Output file: inbox/proj_sakura_petal_anim.png
Asset: Đạn Cánh Hoa Anh Đào Xoay (Animated Spinning Sakura Petal Projectile) — 6 Frames
Grid: 3 columns × 2 rows (6 equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game projectile sprite sheet arranged in a strict 3 columns by 2 rows grid (6 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Glowing razor-sharp pastel pink Japanese Sakura cherry blossom petal projectile flying rapidly horizontally toward the RIGHT with a luminous pink ribbon trail.
Animation sequence (6-frame seamless spinning loop):
- Frames 1-6: The sakura petal spins cleanly along its horizontal flight axis toward the right with fluttering pink sparkle glints and dynamic curved motion streaks.
Composition & Technical Rules: Centered in every cell, consistent flight direction strictly facing RIGHT, generous margins.
Art Style: Hand-drawn 2D Edo chibi game art, crisp dark-rose ink outlines, luminous pastel pink and white-gold cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 4. Đạn Cầu Băng Nhấp Nháy (`proj_ice_orb_anim.png`) — [P0/P2]
```
Output file: inbox/proj_ice_orb_anim.png
Asset: Đạn Cầu Băng Nhấp Nháy (Animated Spinning Ice Orb Projectile) — 6 Frames
Grid: 3 columns × 2 rows (6 equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game projectile sprite sheet arranged in a strict 3 columns by 2 rows grid (6 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Radiant translucent glacial-blue frozen spirit ice orb flying horizontally toward the RIGHT, orbited by 3 crisp crystalline frost shards and chilly cyan trail.
Animation sequence (6-frame seamless pulsing & orbiting loop):
- Frames 1-6: The glowing icy-blue core pulses softly while the 3 diamond ice shards orbit clockwise smoothly and icy mist trails behind to the left.
Composition & Technical Rules: Centered in every cell, facing RIGHT, crisp silhouette readability at small gameplay scale.
Art Style: Hand-drawn 2D Edo chibi game art, crisp deep-cyan ink outlines, glowing frost-blue and white cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Đạn Tên Tre & Độc Dược Animation (`proj_dart_poison_anim.png`) — [P0/P2]
```
Output file: inbox/proj_dart_poison_anim.png
Asset: Đạn Tên Tre & Bọt Độc Animation (Bamboo Dart & Poison Glob Motion Pack) — 6 Frames (2×3)
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game projectile animation sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (two 3-frame animated combat projectiles both flying horizontally toward the RIGHT):
- Row 1 (Cells 1-3): 3-frame high-speed emerald-green sharpened bamboo crossbow dart flying RIGHT with alternating white speed wind streaks and crisp white feather fletching.
- Row 2 (Cells 4-6): 3-frame bubbling violet-magenta toxic mushroom poison glob flying RIGHT with wobbling liquid jelly shape and dripping purple spore droplets.
Composition & Technical Rules: Center-aligned in every cell, oriented horizontally toward the RIGHT with generous margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant emerald-green and violet-magenta cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Bộ Biểu Tượng Trạng Thái & Khung Chỉ Dẫn (`gameplay_status_badges.png`) — [P1/P2]
```
Output file: inbox/gameplay_status_badges.png
Asset: Bộ Icon Trạng Thái Chiến Đấu & Khung Đặt Ô (Overhead Status Badges & Grid Indicator Pack) — 6 Icons
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game combat status badges pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom), completely BLANK with ZERO letters or numbers.
Subimages (6 bold crisp HUD/entity overhead combat status symbols):
- Cell 1 (row 1, col 1): Glossy golden and charcoal-black Japanese Samurai armor crest shield icon (armored enemy indicator).
- Cell 2 (row 1, col 2): Glowing bright violet-purple skull-free toxic bubble droplet icon (poison DoT active indicator).
- Cell 3 (row 1, col 3): Crisp radiant glacial-blue crystalline six-point snowflake badge (chilled/slowed status indicator).
- Cell 4 (row 2, col 1): Sleek crimson-and-black Tengu feathered wing emblem (airborne/flying unit indicator).
- Cell 5 (row 2, col 2): Fierce crimson-and-gold Oni horned crown badge (wave Boss unit indicator).
- Cell 6 (row 2, col 3): Luminous glowing emerald-green dashed square planting corner reticle bracket frame (valid tile target indicator).
Composition & Technical Rules: Center-aligned strictly inside each square cell with bold readable silhouettes even when scaled down to 24x24px.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant high-contrast cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO letters, NO numbers, NO watermarks.
```
