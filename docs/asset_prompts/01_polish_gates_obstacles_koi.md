# 01 — Nâng Cấp Hoàn Thiện 5 Chương Hiện Có (Cổng 3/4, Vật Cản Edo & Cá Koi 360°) — Asset Prompts

- **Danh mục:** Bộ 6 Cổng Yokai dáng 3/4 hướng trái (Ch1–Ch6), 2 Vật cản Edo (`2×2`), và Sprite sheet Cá Koi bơi đơn 8 khung hình để xoay 360° mượt khắp hồ (5 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/environments/`, `assets/sprites/obstacles/`, `assets/sprites/tiles/`
- **Quy chuẩn chung:** Mỗi prompt tạo 1 ảnh đứng riêng (standalone text-to-image, không dùng Edit Mode) gồm nhiều subimages trên nền trắng phẳng `#FFFFFF`, không đường kẻ lưới, không chữ, không watermark.

---

## 1. Bộ 6 Cổng Xuất Hiện Yokai Dáng 3/4 Hướng Trái Chương 1–6 (`env_compact_gates_6ch_pack.png`) — [P0]
```
Output file: inbox/env_compact_gates_6ch_pack.png
Asset: Bộ 6 Cổng Yokai Dáng 3/4 Nghiêng Trái Chương 1–6 (Compact 3/4 Left-Angled Spawn Gates) — 6 Gates
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game enemy spawn gates pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Every gate MUST be drawn in a consistent 3/4 angled perspective facing slightly LEFT into the garden battlefield (the right pillar closer and slightly larger/lower, the left pillar slightly further back and higher) with a slender vertical footprint so it fits cleanly inside a narrow right screen margin without clipping.
Subimages (6 chapter-themed 3/4 left-angled Yokai entrance gates):
- Cell 1 (row 1, col 1, -> gate_ch1_sakura_torii.png): Chapter 1 Daytime Sakura Village slender vermilion Torii gate with dark slate top beam, gold crest plaque, braided shimenawa rope with white shide streamers, and blooming pink cherry blossoms hugging the stone bases.
- Cell 2 (row 1, col 2, -> gate_ch2_bamboo.png): Chapter 2 Sunset Bamboo Forest weathered timber and bound bamboo Torii gate bathed in warm golden-amber sunset light, draped with mossy vines and golden bamboo leaves.
- Cell 3 (row 1, col 3, -> gate_ch3_night_torii.png): Chapter 3 Moonlit Koi Shrine glowing vermilion Torii gate with deep indigo night shading, two hanging warm amber paper lanterns, and tiny pale-cyan spirit wisps tucked neatly inside the arch.
- Cell 4 (row 2, col 1, -> gate_ch4_castle_gate.png): Chapter 4 Misty Castle Edo fortress timber-and-stone gatehouse angled 3/4 left with iron-studded wooden posts, white plaster eaves, indigo tiled roof, and crimson autumn maple leaves.
- Cell 5 (row 2, col 2, -> gate_ch5_snow_torii.png): Chapter 5 Snowy Mountain Peak vermilion Torii gate angled 3/4 left, topped with sculpted crisp blue-white snowdrifts, translucent icicles, warm glowing red lanterns, and compact snowy stone pedestals.
- Cell 6 (row 2, col 3, -> gate_ch6_volcano_torii.png): Chapter 6 Blood-Moon Volcanic Shrine charred obsidian-black and crimson-gold Torii gate angled 3/4 left with glowing ember cracks, fiery gold shimenawa rope, and twin floating crimson-orange spirit lanterns.
Composition & Technical Rules: Bottom-center aligned inside each square cell with at least 16% generous white margin on left and right edges, clean open archway interior, zero overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring matching each chapter lighting.
Clean Output: Pure flat solid white background (#FFFFFF), no ground patch, no drop shadow cast onto background, strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```

## 2. Hàng Rào Gỗ Chắn Đường Edo Góc 3/4 (`obs_edo_fence_34.png`) — [P0]
```
Output file: inbox/obs_edo_fence_34.png
Asset: Hàng Rào Chắn Tre/Gỗ Edo Nghiêng 3/4 (`obs_wood_fence.png`) — 4 Trạng Thái Máu
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game battlefield obstacle damage-state sprite sheet arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A traditional Edo Japanese wooden and bound-bamboo lane barricade (uma-yarai style low defensive hurdle) positioned in a 3/4 diagonal perspective blocking a horizontal lane, angled slightly toward the RIGHT to confront oncoming Yokai (NOT flat front-facing). Warm honey-cedar wood posts lashed with thick hemp rope and small river pebbles/grass tufts at the base.
Damage states (4 cells):
- Cell 1 (top-left): 100% intact sturdy 3/4 angled Edo wooden bamboo barricade with crisp rope bindings.
- Cell 2 (top-right): 66% lightly damaged barricade with cracked wood planks, chipped beams, and frayed loose rope ends.
- Cell 3 (bottom-left): 33% heavily damaged collapsing barricade with snapped posts leaning sideways and splintered bamboo slats.
- Cell 4 (bottom-right): 0% destroyed low pile of broken wood splinters, snapped bamboo segments, and untied rope on the ground.
Composition & Technical Rules: Bottom-center aligned consistently across all 4 cells with identical scale and perspective anchor, generous white margins around every cell.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 3. Hòm Gỗ Tuyết Tùng Edo (`obs_edo_crate_kibako.png`) — [P0]
```
Output file: inbox/obs_edo_crate_kibako.png
Asset: Hòm Gỗ Tuyết Tùng Edo Buộc Thừng Rơm (`obs_crate.png`) — 4 Trạng Thái Máu
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game battlefield obstacle damage-state sprite sheet arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A traditional Japanese Edo merchant wooden supply crate (kibako) in crisp 3/4 isometric perspective, crafted from warm cedar planks bound tightly with crossed golden straw ropes and decorated with a small red vermilion circular wax/ink seal (NO Western iron corner brackets, NO medieval metal rivets).
Damage states (4 cells):
- Cell 1 (top-left): 100% intact Edo cedar wooden crate neatly tied with straw rope and bright red seal emblem.
- Cell 2 (top-right): 66% lightly damaged crate with split lid plank, cracked wood grain, and loosening straw rope.
- Cell 3 (bottom-left): 33% heavily broken crate with caved-in side boards, snapped ropes, and straw stuffing poking out.
- Cell 4 (bottom-right): 0% shattered low pile of broken cedar slats, loose straw rope coils, and wood chips.
Composition & Technical Rules: Bottom-center aligned consistently across all 4 cells with identical scale and perspective anchor, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 4. Cá Koi Đơn Bơi Uốn Đuôi — Kohaku Trắng Đỏ (`koi_kohaku_swim.png`) — [P0]
```
Output file: inbox/koi_kohaku_swim.png
Asset: Cá Koi Kohaku Nhìn Từ Trên Xuống Bơi Uốn Đuôi — 8 Frames Vòng Lặp Kín
Grid: 4 columns × 2 rows (8 cleanly separated equal-sized square cells, 2:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game top-down swimming animation sprite sheet arranged in a strict 4 columns by 2 rows grid (8 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A single graceful Japanese Kohaku Koi fish (pearly white body with vibrant vermilion-orange dorsal markings and translucent flowing pectoral & tail fins) viewed strictly from straight TOP-DOWN, facing RIGHT (nose pointing horizontally right at 0 degrees in every frame) so the game engine can smoothly rotate it 360 degrees along curved pond paths.
Animation cycle (8 seamless S-curve swimming frames):
- Frame 1 (r1c1): Straight neutral glide, tail centered, pectoral fins out.
- Frame 2 (r1c2): Subtle head turn slightly up, mid-body curving up, tail sweeping down.
- Frame 3 (r1c3): Peak upward body curve, tail swept fully down-left pushing water.
- Frame 4 (r1c4): Recovery passing back toward center, tail trailing gracefully.
- Frame 5 (r2c1): Straight neutral glide mirroring frame 1, fins fluttering softly.
- Frame 6 (r2c2): Subtle head turn slightly down, mid-body curving down, tail sweeping up.
- Frame 7 (r2c3): Peak downward body curve, tail swept fully up-left pushing water.
- Frame 8 (r2c4): Smooth recovery returning seamlessly into Frame 1.
Composition & Technical Rules: Center-aligned at identical scale and exact horizontal orientation across all 8 cells, zero water background, zero ripples attached.
Art Style: Hand-drawn 2D Edo chibi game art, clean dark-brown outlines, glossy watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF), strictly NO water texture, NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Cá Koi Đơn Bơi Uốn Đuôi — Yamabuki Vàng Ánh Kim (`koi_yamabuki_swim.png`) — [P1]
```
Output file: inbox/koi_yamabuki_swim.png
Asset: Cá Koi Yamabuki Vàng Nhìn Từ Trên Xuống Bơi Uốn Đuôi — 8 Frames Vòng Lặp Kín
Grid: 4 columns × 2 rows (8 cleanly separated equal-sized square cells, 2:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game top-down swimming animation sprite sheet arranged in a strict 4 columns by 2 rows grid (8 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A single luminous Japanese Yamabuki Ogon Koi fish (shimmering golden-amber scales with delicate pale-gold translucent pectoral & tail fins) viewed strictly from straight TOP-DOWN, facing RIGHT (nose pointing horizontally right at 0 degrees in every frame) for smooth 360-degree curved path swimming in code.
Animation cycle (8 seamless S-curve swimming frames):
- Frame 1 (r1c1): Neutral horizontal glide, tail centered.
- Frame 2 (r1c2): Body begins gentle upward S-curve, tail sweeps down.
- Frame 3 (r1c3): Peak upward curve, tail fully flexed down-left.
- Frame 4 (r1c4): Smooth return toward neutral centerline.
- Frame 5 (r2c1): Neutral horizontal glide, pectoral fins gently fanned.
- Frame 6 (r2c2): Body begins gentle downward S-curve, tail sweeps up.
- Frame 7 (r2c3): Peak downward curve, tail fully flexed up-left.
- Frame 8 (r2c4): Smooth return seamlessly looping back into Frame 1.
Composition & Technical Rules: Center-aligned at identical scale and exact horizontal orientation across all 8 cells, zero water background.
Art Style: Hand-drawn 2D Edo chibi game art, clean dark-brown outlines, warm luminous watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF), strictly NO water texture, NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```
