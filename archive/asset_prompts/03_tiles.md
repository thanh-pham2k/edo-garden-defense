# 03 — Ô Nền / Tiles — Asset Prompts

- **Danh mục:** Ô nền (8 loại địa hình — 8 prompts, mỗi prompt tạo 1 bộ 6 ô biến thể `3×2`)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/tiles/`
- **Quy chuẩn chung:** Góc nhìn top-down hơi nghiêng chuẩn game *Plants vs. Zombies*, mỗi ô vuông đều nhau, phong cách vẽ tay Edo chibi.

---

## 1. Cỏ xanh (`tile_grass`) — [P0]
```
Output file: inbox/tile_grass.png
Asset: Ô nền Cỏ xanh (Sakura Village Grass Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 seamless garden grass variants):
- Cell 1 (row 1, col 1): Bright sunlit fresh spring-green Edo garden grass tile (light checkerboard base).
- Cell 2 (row 1, col 2): Slightly deeper lush emerald-green grass tile (dark checkerboard base for clear grid contrast).
- Cell 3 (row 1, col 3): Green garden grass tile dotted with tiny white and yellow clovers.
- Cell 4 (row 2, col 1): Green grass tile with a few smooth mossy garden pebbles.
- Cell 5 (row 2, col 2): Green grass tile sprinkled with 3-4 delicate fallen pink sakura petals.
- Cell 6 (row 2, col 3): Soft shaded garden grass tile with subtle stylized grass blade tufts.
Composition & Technical Rules: Flat top-down lane-defense perspective matching Plants vs. Zombies lawn readability. Clean square tile edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, warm natural watercolor cel-shaded texture, cozy inviting daylight palette.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 2. Đất (`tile_dirt`) — [P0]
```
Output file: inbox/tile_dirt.png
Asset: Ô nền Đất (Edo Garden Dirt Path Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 warm earthy dirt variants):
- Cell 1 (row 1, col 1): Warm golden-ochre Edo garden dirt path tile (light checkerboard base).
- Cell 2 (row 1, col 2): Slightly richer toasted-brown dirt tile (dark checkerboard base).
- Cell 3 (row 1, col 3): Warm dirt tile with tiny smooth river pebbles scattered naturally.
- Cell 4 (row 2, col 1): Neat Japanese garden dirt tile with subtle gentle raked soil texture.
- Cell 5 (row 2, col 2): Dirt tile with tiny green grass tufts peeking at two corners.
- Cell 6 (row 2, col 3): Packed footpath dirt tile with a couple of tiny fallen dry leaves.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, warm earthy watercolor cel-shaded texture.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 3. Đá cuội (`tile_cobble`) — [P1]
```
Output file: inbox/tile_cobble.png
Asset: Ô nền Đá cuội (Edo Cobblestone Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 cobblestone variants):
- Cell 1 (row 1, col 1): Warm light gray-brown Japanese rounded cobblestone tile (light checkerboard base).
- Cell 2 (row 1, col 2): Slightly darker weathered slate cobblestone tile (dark checkerboard base).
- Cell 3 (row 1, col 3): Cobblestone tile with subtle earthy dirt peeking between stone joints.
- Cell 4 (row 2, col 1): Traditional flat stepping-stone flagstone garden tile.
- Cell 5 (row 2, col 2): Cobblestone tile with 2-3 fallen green-gold bamboo leaves resting on top.
- Cell 6 (row 2, col 3): Worn ancient temple courtyard stone tile with gentle hairline cracks.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, crisp warm dark-brown ink linework on stones, soft watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 4. Đá rêu (`tile_moss_stone`) — [P1]
```
Output file: inbox/tile_moss_stone.png
Asset: Ô nền Đá rêu (Mossy Temple Stone Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 mossy stone variants):
- Cell 1 (row 1, col 1): Ancient gray temple stone tile with soft green moss growing along the crevices.
- Cell 2 (row 1, col 2): Slightly darker forest-shaded mossy stone tile for checkerboard grid readability.
- Cell 3 (row 1, col 3): Heavily moss-carpeted stone tile with tiny fresh fern buds.
- Cell 4 (row 2, col 1): Cracked mossy flagstone tile with lush emerald moss seams.
- Cell 5 (row 2, col 2): Mossy stone tile with small fallen bamboo leaves.
- Cell 6 (row 2, col 3): Damp bamboo-forest shrine stone tile with rich velvety moss patches.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, warm dark-brown ink linework, rich moss green and stone gray watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 5. Cánh hoa đào (`tile_sakura`) — [P1]
```
Output file: inbox/tile_sakura.png
Asset: Ô nền Cánh hoa đào (Sakura Petal Carpet Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 sakura petal ground variants):
- Cell 1 (row 1, col 1): Soft garden ground densely carpeted in pastel pink cherry blossom petals.
- Cell 2 (row 1, col 2): Slightly deeper rose-pink petal carpet tile for checkerboard contrast.
- Cell 3 (row 1, col 3): Light stone-and-earth tile with swirling wind-blown drifts of pink petals.
- Cell 4 (row 2, col 1): Lush mossy ground sprinkled with bright pink and white sakura blossoms.
- Cell 5 (row 2, col 2): Temple stone tile half-covered in soft fallen sakura petals.
- Cell 6 (row 2, col 3): Festive glowing sakura petal ground tile with tiny magical pink sparkles.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, warm pastel pink and fresh green watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 6. Sỏi đêm (`tile_gravel_night`) — [P1]
```
Output file: inbox/tile_gravel_night.png
Asset: Ô nền Sỏi đêm (Nighttime Zen Gravel Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 nighttime Zen gravel variants):
- Cell 1 (row 1, col 1): Cool moonlit blue-gray raked Zen gravel tile (light checkerboard base).
- Cell 2 (row 1, col 2): Slightly darker twilight indigo-slate gravel tile (dark checkerboard base).
- Cell 3 (row 1, col 3): Misty castle courtyard gravel tile dotted with small dark river stones.
- Cell 4 (row 2, col 1): Moonlit gravel tile with subtle curved Zen sand-rake wave lines.
- Cell 5 (row 2, col 2): Twilight stone-and-gravel tile with a faint ghostly blue mist sheen.
- Cell 6 (row 2, col 3): Ancient dark courtyard gravel tile with one small crimson autumn maple leaf.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, moody yet readable twilight indigo and cool gray watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 7. Hồ cá Koi (`tile_koi_water`) — [P1]
```
Output file: inbox/tile_koi_water.png
Asset: Ô nền Hồ cá Koi (Koi Pond Water Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 Koi pond water variants):
- Cell 1 (row 1, col 1): Crystal-clear azure Japanese Koi pond water tile with soft white-blue surface ripples.
- Cell 2 (row 1, col 2): Slightly deeper turquoise-cobalt pond water tile for grid readability.
- Cell 3 (row 1, col 3): Clear pond water tile featuring a cute orange-and-white Koi fish swimming gracefully beneath the surface.
- Cell 4 (row 2, col 1): Pond water tile with a large sturdy green floating lotus lily pad centered (plantable spot).
- Cell 5 (row 2, col 2): Pond water tile with a blooming pink lotus flower and gentle ripples.
- Cell 6 (row 2, col 3): Pond water tile with a golden Koi fish and 2-3 floating pink sakura petals.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, luminous turquoise and azure watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```

## 8. Tuyết trắng (`tile_snow`) — [P2]
```
Output file: inbox/tile_snow.png
Asset: Ô nền Tuyết trắng (Snowy Mountain Tileset) — 6 Tile Variants
Grid: 3 columns × 2 rows (6 equal-sized square top-down tiles, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ground tileset sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square top-down tiles, read left-to-right, top-to-bottom).
Subimages (6 snowy ground variants):
- Cell 1 (row 1, col 1): Crisp bright white fresh snow ground tile with soft pale-blue shading (light base).
- Cell 2 (row 1, col 2): Slightly cooler glacial sky-blue tinted snow tile for checkerboard grid contrast.
- Cell 3 (row 1, col 3): Soft snow tile with cute tiny animal paw prints and subtle wind ripples.
- Cell 4 (row 2, col 1): Frosty packed snow tile with tiny glittering ice crystals.
- Cell 5 (row 2, col 2): Snow-dusted ancient temple stone peeking through white snow drifts.
- Cell 6 (row 2, col 3): Deep fluffy mountain snow tile with a couple of tiny fallen green pine needles.
Composition & Technical Rules: Flat top-down lane-defense perspective, clean square edges with narrow uniform white space between tiles.
Art Style: Hand-drawn 2D Edo chibi game art, clean crisp snow white and pastel sky-blue watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF) outside the tiles, strictly NO text, NO numbers, NO harsh black border boxes.
```
