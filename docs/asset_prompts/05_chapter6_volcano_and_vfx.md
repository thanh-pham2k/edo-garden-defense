# 05 — Bối Cảnh Chương 6 (Đền Hỏa Sơn Huyết Nguyệt), 3 Vật Cản Mới & VFX Mở Rộng — Asset Prompts

- **Danh mục:** Trọn bộ bối cảnh Chương 6 (Màn 16–18: Đền Hỏa Sơn Huyết Nguyệt), 3 vật cản có cơ chế đặc biệt (`obs_ice_block`, `obs_cursed_lantern`, `obs_incense_burner`) và gói Đạn/VFX mở rộng cho quân & boss mới (7 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/backgrounds/`, `assets/sprites/tiles/`, `assets/sprites/environments/`, `assets/sprites/obstacles/`, `assets/sprites/fx/`
- **Quy chuẩn chung:** Standalone text-to-image (không dùng Edit Mode), nhiều subimages mỗi ảnh, nền trắng `#FFFFFF` (trừ background panels và floor tiles đầy khung), không đường kẻ lưới, không chữ, không watermark.

---

## 1. Nền Trời & Xa Cảnh Chương 6: Đền Hỏa Sơn Huyết Nguyệt (`bg_ch6_blood_moon_shrine.png`) — [P0]
```
Output file: inbox/bg_ch6_blood_moon_shrine.png
Asset: 4 Tấm Nền Bầu Trời & Xa Cảnh Chương 6 (Blood-Moon Volcanic Shrine Vista) — 4 Panels
Grid: 2 columns × 2 rows (4 cleanly separated widescreen panels in a 2×2 layout, 16:9 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period game scenic background vista pack arranged in a strict 2 columns by 2 rows grid (4 distinct panoramic background artwork panels, read left-to-right, top-to-bottom).
Theme: Chapter 6 Blood-Moon Volcanic Shrine Sanctuary (dramatic crimson-violet twilight sky with a huge glowing vermilion-gold harvest blood moon, distant volcanic silhouettes with soft glowing lava veins, layered silhouettes of ancient Edo pagodas and scarlet Torii shrines, drifting glowing golden embers).
Subimages (4 atmospheric widescreen vista panels):
- Cell 1 (top-left, -> bg_ch6_blood_moon_shrine_0.png): Main wide panoramic blood-moon sky over distant misty volcanic mountains and glowing crimson pagoda roofs (clean upper vista for battle scene header).
- Cell 2 (top-right, -> bg_ch6_blood_moon_shrine_1.png): Glowing crimson lantern shrine terrace overlooking twilight volcanic valley with warm amber mist.
- Cell 3 (bottom-left, -> bg_ch6_blood_moon_shrine_2.png): Ancient charred torii pathway winding up rocky volcanic cliffs bathed in dramatic crimson-violet moonlight.
- Cell 4 (bottom-right, -> bg_ch6_blood_moon_shrine_3.png): Grand Mount Fuji-inspired volcanic caldera peak glowing softly beneath a dramatic blood moon and drifting gold ash.
Art Style: Hand-drawn 2D Edo chibi game background illustration, painterly cel-shaded watercolor with rich atmospheric depth, cohesive warm crimson, deep indigo-plum, and glowing gold palette.
Clean Output: Strictly NO characters, NO enemies, NO UI, NO text, NO numbers, NO watermarks, crisp thin separation between the 4 panels.
```

## 2. Bộ 6 Ô Gạch Sàn Đá Núi Lửa Chương 6 (`tiles_ch6_obsidian_ash.png`) — [P0]
```
Output file: inbox/tiles_ch6_obsidian_ash.png
Asset: 6 Ô Gạch Sàn Đá Bazan & Tro Ấm Chương 6 (`tile_volcanic_stone_0..2` & `tile_ember_gravel_0..2`) — 6 Seamless Tiles
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square floor tiles, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game top-down seamless battlefield ground tiles pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square floor tiles filling each cell cleanly, read left-to-right, top-to-bottom).
Subimages (6 readable top-down garden floor tiles for Chapter 6 Volcanic Shrine — kept moderate contrast so units pop clearly):
- Cells 1–3 (row 1, cols 1–3, -> tile_volcanic_stone_0..2.png): 3 subtle variations of smooth weathered dark-plum slate stone flagstones with warm bronze dust in the seams and tiny fallen crimson maple embers.
- Cells 4–6 (row 2, cols 1–3, -> tile_ember_gravel_0..2.png): 3 subtle variations of raked charcoal-ash Edo zen gravel (karesansui swirl pattern) with faint warm amber mineral flecks and smooth volcanic pebbles.
Composition & Technical Rules: Strictly flat top-down orthographic perspective matching tower-defense grid tiles, seamless tileable edges, balanced medium-dark value so bright defenders and enemies remain highly readable.
Art Style: Hand-drawn 2D Edo chibi game art, subtle dark-brown ink stone seams, cel-shaded watercolor textures.
Clean Output: Strictly NO characters, NO plants, NO text, NO numbers, NO watermarks.
```

## 3. Bộ Kiến Trúc, Viền & Cây Cảnh Chương 6 (`env_ch6_border_house_flora_pack.png`) — [P0]
```
Output file: inbox/env_ch6_border_house_flora_pack.png
Asset: Bộ Kiến Trúc & Viền Chương 6 (Top Wall Border, Guardian Fire Shrine House, Ember Maple Flora, Volcanic Curb Edge) — 4 Elements
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Chapter 6 Volcanic Shrine environment architecture and flora pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated cells, read left-to-right, top-to-bottom).
Subimages (4 distinct Chapter 6 environment props):
- Cell 1 (top-left, -> env_border_top_ch6.png): Wide seamless horizontally-tileable dark obsidian stone temple balustrade & vermilion wooden shrine railing accented with glowing amber spirit lanterns and crimson autumn maple branches, symmetrical ends for seamless tiling.
- Cell 2 (top-right, -> house_ch6_fire_shrine.png): Compact 3/4 right-facing Guardian Sacred Fire Shrine sanctuary (slender footprint fitting the left side margin cleanly) with dark charred-timber roof, golden ridge ornaments, glowing warm amber shoji doors, braided gold shimenawa rope, and two warm stone lanterns at the steps (NO floating background mountains).
- Cell 3 (bottom-left, -> flora_ch6_ember_maple.png): Dramatic Edo crimson-and-gold ember maple tree rooted in dark volcanic basalt rock with a tiny warm glowing shrine stone lantern nestled at its base.
- Cell 4 (bottom-right, -> env_edge_volcanic_curb.png): Wide low-profile dark basalt rock garden curbing strip with subtle warm amber glowing moss cracks and fallen crimson leaves for the bottom lawn edge.
Composition & Technical Rules: Centered cleanly inside each cell with generous white margins (at least 14% padding) and zero overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, dramatic crimson-gold and deep slate cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow cast onto background, strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```

## 4. Vật Cản Mới: Tảng Băng Cổ (`obs_new_ice_block.png`) — [P1]
```
Output file: inbox/obs_new_ice_block.png
Asset: Tảng Băng Cổ (`obs_ice_block.png`, Chương 5) — 4 Trạng Thái Máu
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game battlefield obstacle damage-state sprite sheet arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A faceted translucent glacial-cyan Edo shrine ice boulder block with frost crystals and a tiny frozen sakura flower visible inside its icy core, 3/4 top-down angle.
Damage states (4 cells):
- Cell 1 (top-left): 100% intact gleaming crystalline ice block with crisp snow cap at base.
- Cell 2 (top-right): 66% lightly cracked ice block with frosty white fracture lines and chipped corner.
- Cell 3 (bottom-left): 33% heavily shattered jagged ice core missing large chunks.
- Cell 4 (bottom-right): 0% collapsed low pile of glistening ice shards and melted snow slush.
Composition & Technical Rules: Bottom-center aligned consistently across all 4 cells with identical scale and generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-indigo ink outlines, luminous icy cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Vật Cản Mới: Đèn Lồng Nguyền (`obs_new_cursed_lantern.png`) — [P1]
```
Output file: inbox/obs_new_cursed_lantern.png
Asset: Đèn Lồng Nguyền (`obs_cursed_lantern.png`, buff tốc độ Yokai xung quanh) — 4 Trạng Thái Máu
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game battlefield obstacle damage-state sprite sheet arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A weathered dark stone Japanese shrine pedestal lantern (ishidoro) wrapped in dark purple cursed talisman paper seals, glowing eerily with violet-magenta Yokai fire inside its chamber, 3/4 view.
Damage states (4 cells):
- Cell 1 (top-left): 100% intact cursed stone lantern glowing bright eerie purple-magenta.
- Cell 2 (top-right): 66% cracked stone roof with torn paper seal and flickering violet flame.
- Cell 3 (bottom-left): 33% half-crumbled stone pillar leaning sideways with fading sparks.
- Cell 4 (bottom-right): 0% broken pile of mossy stone rubble and extinguished charcoal embers.
Composition & Technical Rules: Bottom-center aligned consistently across all 4 cells with identical scale and generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, moody cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Vật Cản Mới: Lư Hương Thanh Tẩy (`obs_new_incense_burner.png`) — [P1]
```
Output file: inbox/obs_new_incense_burner.png
Asset: Lư Hương Thanh Tẩy (`obs_incense_burner.png`, phá vỡ tỏa khói hồi máu) — 4 Trạng Thái Máu
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game battlefield obstacle damage-state sprite sheet arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A traditional ornate bronze-and-jade Japanese temple incense cauldron (koro) resting on a stone base, curling with delicate fragrant emerald-gold healing smoke wisps, 3/4 view.
Damage states (4 cells):
- Cell 1 (top-left): 100% intact polished bronze incense cauldron emitting gentle emerald-gold smoke.
- Cell 2 (top-right): 66% dented bronze cauldron with glowing cracks leaking brighter fragrant mist.
- Cell 3 (bottom-left): 33% heavily cracked tilting cauldron puffing thick luminous healing steam.
- Cell 4 (bottom-right): 0% overturned broken bronze rim pieces with fading warm golden embers.
Composition & Technical Rules: Bottom-center aligned consistently across all 4 cells with identical scale and generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm bronze-and-jade cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 7. Bộ 6 Đạn & Hiệu Ứng Chiến Đấu Mở Rộng (`fx_expansion_projectiles_pack.png`) — [P0]
```
Output file: inbox/fx_expansion_projectiles_pack.png
Asset: Bộ 6 Đạn & Hiệu Ứng Mới (Phoenix Fireball, Chain Lightning, Daruma Buff Ring, Cat Slash Wave, Kappa Water Orb, Kyubi Foxfire Orb) — 6 Sprites
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game combat projectiles and aura effects pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (6 crisp stylized combat projectile and VFX elements):
- Cell 1 (row 1, col 1, -> proj_phoenix_fireball.png): Blazing golden-crimson phoenix fireball projectile flying horizontally RIGHT with stylized curling flame tail feathers and bright white-gold core.
- Cell 2 (row 1, col 2, -> fx_chain_lightning_arc.png): Crisp jagged horizontal cyan-and-gold Japanese Raijin lightning bolt arc with tiny crackling star sparks.
- Cell 3 (row 1, col 3, -> fx_daruma_buff_ring.png): Glowing circular golden festival aura ring adorned with tiny red-gold sparkles and rhythmic speed-boost chevrons (top-down elliptical ground ring).
- Cell 4 (row 2, col 1, -> fx_katana_slash_wave.png): Dynamic glowing ice-cyan and white crescent samurai sword slash energy wave sweeping RIGHT with crisp ink motion streaks.
- Cell 5 (row 2, col 2, -> proj_kappa_water_orb.png): Swirling translucent turquoise-blue magical water sphere projectile flying LEFT with tiny cresting wave droplets.
- Cell 6 (row 2, col 3, -> proj_kyubi_foxfire.png): Mystical glowing crimson-gold nine-tailed kitsune foxfire spirit orb flying LEFT with curling incandescent flame tails.
Composition & Technical Rules: Center-aligned cleanly inside each square cell with generous white margins and crisp high-contrast silhouettes readable on both light and dark garden tiles.
Art Style: Hand-drawn 2D Edo chibi game art, clean dark ink accents where appropriate, vibrant luminous cel-shaded watercolor effects.
Clean Output: Pure flat solid white background (#FFFFFF), strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```
