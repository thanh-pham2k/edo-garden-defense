# 14 — Nâng Cấp Công Trình, Cây Thông Tuyết, Đá Bước Theo Mùa & Viền Chương 5 (Landmarks & Winter Polish) — Asset Prompts

- **Danh mục:** Công trình Nhà Chính & Cổng Yokai Chương 5 (thu gọn 3/4), Cây thông tuyết tự nhiên thay bonsai xanh neon, Đá bước sân vườn theo mùa & Viền hàng rào tuyết bản rộng (3 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/environments/`
- **Quy chuẩn chung:** Mỗi prompt tạo 1 ảnh đứng riêng (standalone text-to-image, không dùng Edit Mode) gồm **4 subimages (`2×2`)**, nền trắng phẳng `#FFFFFF`, không đường kẻ lưới, không chữ, không nhân vật.

---

## 1. Bộ Công Trình & Cây Thông Tuyết Chương 5 Thu Gọn (`env_winter_landmarks_pack.png`) — [Ưu tiên cao / P0]
```
Output file: inbox/env_winter_landmarks_pack.png
Asset: Bộ Đền Tuyết 3/4, Cổng Torii Tuyết 3/4, Cây Thông Tuyết Cao & Đèn Đá Tuyết (Chapter 5 Landmarks & Snow Pine Flora Pack) — 4 Props
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game winter shrine sanctuary landmarks and alpine flora pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (4 distinct compact winter props for a tower-defense garden side margin):
- Cell 1 (top-left, -> house_ch5_snow_shrine.png): Compact 3/4 right-facing Japanese snowy mountain shrine sanctuary cottage (slender, narrow horizontal footprint fitting a side garden lane) with dark slate roof buried under sculpted crisp icy-white snow pillows, icicles, warm amber-gold glowing shoji paper doors, braided shimenawa rope, stone stairs, and two cool frosted mini pine sprigs at base. Strictly self-contained building ONLY, NO background mountains, NO distant peaks, NO extra side boulders floating outside the roof silhouette.
- Cell 2 (top-right, -> gate_ch5_snow_torii.png): Compact 3/4 left-angled crimson-vermilion Japanese Shinto Torii spawn gate facing slightly LEFT into the garden so enemies appear from its open archway, slender tall red pillars resting on frosted gray stone plinths with thick sculpted white snow caps, translucent ice icicles, warm amber-red paper lanterns, and compact snow mounds tucked close to the pillars with NO wide side-lantern sprawl.
- Cell 3 (bottom-left, -> flora_snow_pine_tall.png): Tall graceful Japanese alpine snow-covered pine tree (Akamatsu/Kuro-matsu) with rugged dark-brown curving trunk, deep cool dark evergreen blue-pine needle tiers topped with fluffy white-ice-blue snow pillows, and tiny crimson winter nanten berries at the snowy rocky root base (strictly natural deep forest-teal pine greens, ZERO neon green, ZERO lime-yellow foliage).
- Cell 4 (bottom-right, -> flora_snow_lantern_rock.png): Cozy winter corner snow-covered gray granite Japanese stone lantern (Ishidoro) glowing softly warm amber inside its window, paired with a mossy frosted boulder, low deep dark evergreen pine sprigs (ZERO neon/lime green), bright red winter berries, and crisp blue-tinted white snowdrifts.
Composition & Technical Rules: Bottom-center aligned inside each square cell with generous white margins (at least 14% padding on left/right edges so nothing crops at cell boundaries) and crisp readable silhouettes with grounded contact shadow only inside the sprite base.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant yet cool winter cel-shaded watercolor coloring matching snowy Japanese sanctuary scenes.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow cast onto background, strictly NO grid lines, NO borders, NO floating mountain backdrops, NO characters, NO text, NO numbers, NO watermarks.
```

## 2. Bộ Đá Bước Theo Mùa & Viền Hàng Rào Tuyết Bản Rộng (`env_seasonal_paths_and_ch5_border_pack.png`) — [Ưu tiên cao / P0]
```
Output file: inbox/env_seasonal_paths_and_ch5_border_pack.png
Asset: Đá Bước Mùa Đông / Đêm / Hoàng Hôn & Dải Viền Hàng Rào Tuyết Bản Rộng (Seasonal Stepping Stones & Wide Ch5 Snow Border) — 4 Wide Strips
Grid: 2 columns × 2 rows (4 cleanly separated wide horizontal strips in 2×2 cells, 16:9 landscape aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game seasonal stepping-stone path strips and wide snowy fence border pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated wide horizontal elements in 16:9 widescreen layout, read left-to-right, top-to-bottom).
Subimages (4 distinct wide horizontal terrain and fence elements):
- Cell 1 (top-left, -> env_path_stones_winter.png): Wide low-profile Japanese winter garden stepping-stone pathway cluster made of 3 flat dark-slate gray stepping stones partially embedded in crisp white-blue snow and winter frost, frosted pine needles and tiny red berries tucked delicately around stones (strictly NO lush green grass, NO spring pink cherry petals).
- Cell 2 (top-right, -> env_path_stones_night.png): Wide low-profile Japanese twilight & night shrine stepping-stone pathway cluster made of 3 flat slate-gray river stones set into cool dark indigo-violet pebbles and muted dark slate-teal moss with subtle cool moonlight rim highlights.
- Cell 3 (bottom-left, -> env_path_stones_sunset.png): Wide low-profile Golden-Hour Edo garden stepping-stone pathway cluster made of 3 flat warm-lit river stones set into earthy twilight brown soil scattered with fallen golden-amber and autumn maple leaves.
- Cell 4 (bottom-right, -> env_border_top_ch5_wide.png): Wide seamless horizontally-tileable Chapter 5 Snowy Mountain wooden temple fence border strip buried in sculpted icy-white snowdrifts, backed by deep cool evergreen pine boughs with crisp snow caps (strictly natural deep pine greens, ZERO neon/lime green), tiny red winter berries, and a warm-glowing stone lantern post, with symmetrically matching left and right fence ends for seamless horizontal tiling.
Composition & Technical Rules: Center-aligned inside each widescreen cell with generous white margins on all sides so nothing touches cell edges; top-down angled lane-defense perspective matching garden floor tiles.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, crisp cel-shaded watercolor coloring cohesive across seasons.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```

## 3. Bộ Cổng Xuất Hiện Gọn Gàng Dáng 3/4 Chương 1–4 (`env_compact_gates_ch1_4_pack.png`) — [Tùy chọn / P1]
```
Output file: inbox/env_compact_gates_ch1_4_pack.png
Asset: Bộ 4 Cổng Yokai Dáng 3/4 Thu Gọn Chương 1–4 (Compact 3/4 Left-Facing Chapter 1–4 Spawn Gates) — 4 Gates
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game compact Yokai entrance gates pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (4 slender chapter-themed right-margin spawn gates angled 3/4 slightly LEFT toward the garden battlefield):
- Cell 1 (top-left, -> gate_ch1_sakura_torii.png): Chapter 1 Daytime Sakura Village slender vermilion Torii gate angled slightly left with braided gold shimenawa rope, white zigzag shide paper streamers, and delicate blooming pink sakura sprigs hugging the stone base cleanly.
- Cell 2 (top-right, -> gate_ch2_bamboo.png): Chapter 2 Golden Sunset Forest rustic weathered timber and bound bamboo Torii gate angled slightly left, draped with golden moss and warm amber sunset highlights, slender vertical footprint.
- Cell 3 (bottom-left, -> gate_ch3_night_torii.png): Chapter 3 Moonlit Night Shrine glowing vermilion lacquer Torii gate angled slightly left with indigo roof shadow, hanging warm amber paper lanterns, and drifting pale-pink cherry petals kept compact inside the arch silhouette.
- Cell 4 (bottom-right, -> gate_ch4_castle_gate.png): Chapter 4 Misty Castle Stone Guard Gatehouse with weathered dark timber pillars, studded iron straps, white Edo plaster eaves, blue-slate tiled roof, and vibrant crimson autumn maple leaves tucked neatly along the stone base.
Composition & Technical Rules: Tall slender vertical proportions bottom-center aligned inside each square cell with generous left/right white padding (at least 16% side margin) so the entire gate fits cleanly along a narrow right lane-defense margin without clipping at screen edges.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, cohesive cel-shaded watercolor lighting for each time of day.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```
