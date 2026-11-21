# 04 — Vật Cản / Chướng Ngại (Obstacles) — Asset Prompts

- **Danh mục:** Vật cản trên sân đấu (6 loại — 6 prompts, mỗi prompt tạo 1 ảnh `2×2` gồm 4 trạng thái hư hại)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/obstacles/`
- **Quy chuẩn chung:** Căn đáy giữa (`bottom-center`), nền trắng phẳng `#FFFFFF`, không đường kẻ lưới, không chữ.

---

## 1. Tảng đá (`obs_rock`) — [P1]
```
Output file: inbox/obs_rock.png
Asset: Tảng đá (Mossy Garden Boulder Obstacle) — 4 Damage States
Grid: 2 columns × 2 rows (4 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game obstacle sprite sheet arranged in a strict 2 columns by 2 rows grid (4 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A sturdy mossy Japanese garden boulder obstacle showing 4 progressive destruction states:
- Cell 1 (top-left): Intact rounded gray garden boulder with soft green moss patches on top.
- Cell 2 (top-right): Lightly damaged boulder with jagged hairline cracks and small chipped stone edge.
- Cell 3 (bottom-left): Heavily fractured boulder splitting down the middle with loose pebbles at its base.
- Cell 4 (bottom-right): Destroyed crumbled pile of broken stone rubble and small dust puffs on the ground.
Composition & Technical Rules: Consistent object scale and bottom-center ground alignment in every cell. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm stone gray and moss green cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 2. Rào gai (`obs_spike_barricade`) — [P1]
```
Output file: inbox/obs_spike_barricade.png
Asset: Rào gai (Edo Spike Barricade Obstacle) — 4 Damage States
Grid: 2 columns × 2 rows (4 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game obstacle sprite sheet arranged in a strict 2 columns by 2 rows grid (4 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A traditional Edo wooden and sharpened-bamboo defensive spike barricade (Umabo stakes bound with straw rope), angled defensively toward the right, showing 4 progressive damage states:
- Cell 1 (top-left): Intact sturdy wooden barricade with sharp pointed bamboo stakes tightly bound by rope.
- Cell 2 (top-right): Lightly damaged barricade with slightly chipped spike tips and loosened rope knots.
- Cell 3 (bottom-left): Heavily splintered half-broken barricade leaning crookedly with snapped stakes.
- Cell 4 (bottom-right): Collapsed pile of broken wooden stakes and frayed rope on the ground.
Composition & Technical Rules: Consistent object scale and bottom-center ground alignment in every cell. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm cedar wood and straw rope cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 3. Hàng rào gỗ (`obs_wood_fence`) — [P1]
```
Output file: inbox/obs_wood_fence.png
Asset: Hàng rào gỗ (Wooden Garden Fence Obstacle) — 4 Damage States
Grid: 2 columns × 2 rows (4 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game obstacle sprite sheet arranged in a strict 2 columns by 2 rows grid (4 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A rustic traditional Edo Japanese wooden-and-bamboo garden fence section tied with dark hemp cord, showing 4 progressive damage states:
- Cell 1 (top-left): Neat intact wooden garden fence section with tied hemp knots.
- Cell 2 (top-right): Lightly damaged fence with cracked wooden slats and one slightly tilted post.
- Cell 3 (bottom-left): Heavily splintered fence with missing slats and hanging cords.
- Cell 4 (bottom-right): Shattered flat pile of broken wooden boards and splinters on the ground.
Composition & Technical Rules: Consistent object scale and bottom-center ground alignment in every cell. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm honey-cedar wood cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 4. Thùng gỗ (`obs_crate`) — [P1]
```
Output file: inbox/obs_crate.png
Asset: Thùng gỗ (Edo Wooden Supply Crate Obstacle) — 4 Damage States
Grid: 2 columns × 2 rows (4 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game obstacle sprite sheet arranged in a strict 2 columns by 2 rows grid (4 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A sturdy square Edo merchant wooden supply crate reinforced with dark iron corner brackets, showing 4 progressive damage states:
- Cell 1 (top-left): Intact sturdy wooden supply crate.
- Cell 2 (top-right): Scratched and dented crate with one cracked side plank.
- Cell 3 (bottom-left): Bursting splintered wooden crate with loose planks ready to fall apart.
- Cell 4 (bottom-right): Smashed wooden planks, iron brackets, and splinters scattered on the ground.
Composition & Technical Rules: Consistent object scale and bottom-center ground alignment in every cell. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm oak wood and iron gray cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Đống rơm (`obs_haystack`) — [P1]
```
Output file: inbox/obs_haystack.png
Asset: Đống rơm (Golden Rice-Straw Haystack Obstacle) — 4 Damage States
Grid: 2 columns × 2 rows (4 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game obstacle sprite sheet arranged in a strict 2 columns by 2 rows grid (4 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: A cute plump golden Japanese rice-straw haystack bundled with hemp rope, showing 4 progressive damage states:
- Cell 1 (top-left): Neat plump intact golden rice-straw haystack.
- Cell 2 (top-right): Ruffled haystack with loose golden straw stalks poking out wildly.
- Cell 3 (bottom-left): Untied sagging haystack spilling straw in all directions.
- Cell 4 (bottom-right): Flattened scattered golden straw pile lying low on the ground.
Composition & Technical Rules: Consistent object scale and bottom-center ground alignment in every cell. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm golden straw yellow cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Thùng rượu Sake (`obs_sake_barrel`) — [P1]
```
Output file: inbox/obs_sake_barrel.png
Asset: Thùng rượu Sake (Explosive Sake Barrel Obstacle) — 4 States
Grid: 2 columns × 2 rows (4 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game obstacle sprite sheet arranged in a strict 2 columns by 2 rows grid (4 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: An explosive Edo wooden Sake barrel (Komodaru wrapped with straw-rope bands and red-gold seal emblem), showing 4 progressive states:
- Cell 1 (top-left): Intact plump wooden Sake barrel with straw-rope bands and red seal.
- Cell 2 (top-right): Cracked barrel leaking shimmering amber sake droplets with faint warm orange glow.
- Cell 3 (bottom-left): Critical glowing red-hot swelling barrel with fiery sparks bursting from its seams right before exploding.
- Cell 4 (bottom-right): Charred splintered barrel staves and splashing amber ring after detonation.
Composition & Technical Rules: Consistent object scale and bottom-center ground alignment in every cell. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm oak brown, straw gold, and crimson seal cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```
