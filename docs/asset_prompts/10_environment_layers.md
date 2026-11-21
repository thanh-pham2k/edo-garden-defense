# 10 — Lớp Bối Cảnh Sống Động, Viền Bàn Cờ & Công Trình Theo Chương (Environment Layers) — Asset Prompts

- **Danh mục:** Lớp bối cảnh trung cảnh không lộ vết ghép, viền chuyển tiếp bàn cờ, nhà/cổng Torii riêng từng chương, cây cối theo mùa và hiệu ứng ánh sáng/khí quyển (6 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/environments/` (và `assets/sprites/props/`, `assets/sprites/backgrounds/`)
- **Quy chuẩn chung:** Mỗi prompt tạo 1 ảnh đứng riêng (standalone text-to-image, không dùng Edit Mode) gồm **4 hoặc 6 subimages (`2×2` hoặc `3×2`)**, nền trắng phẳng `#FFFFFF`, không đường kẻ lưới, không chữ, không nhân vật.

---

## 1. Bộ Viền Trung Cảnh Phía Trên (`env_top_borders_pack.png`) — [P1/P2]
```
Output file: inbox/env_top_borders_pack.png
Asset: Bộ Viền Hàng Rào & Trung Cảnh Trên Theo Chương (Seamless Chapter Top Borders) — 4 Wide Strips
Grid: 2 columns × 2 rows (4 cleanly separated wide horizontal border strips in 2×2 cells, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game wide environment border strips pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated wide horizontal strips, read left-to-right, top-to-bottom).
Subimages (4 seamless horizontally-tileable mid-ground garden fence and wall strips):
- Cell 1 (row 1, col 1): Daytime Sakura Village wooden bamboo garden fence with lush blooming pink cherry blossom bushes, mossy stepping rocks, and symmetrically repeatable left and right ends.
- Cell 2 (row 1, col 2): Golden-Hour Bamboo Sunset rustic woven bamboo fence lined with glowing golden-amber grass tufts and falling bamboo leaves, seamlessly repeatable left-to-right.
- Cell 3 (row 2, col 1): Moonlit Koi Shrine Night vermilion-lacquered wooden temple railing with soft weeping pink sakura branches and tiny warm glowing paper lanterns along a symmetrical horizontal strip.
- Cell 4 (row 2, col 2): Misty Edo Castle Twilight weathered stone fortress wall (ishigaki) with tiled eaves and vibrant crimson autumn maple foliage draped along the top edge.
Composition & Technical Rules: Wide horizontal strip centered inside each cell with balanced symmetrical edge heights so tiles repeat horizontally without mirror seams. Generous white space between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring matching traditional Japanese garden scenes.
Clean Output: Pure flat solid white background (#FFFFFF) outside each strip, strictly NO characters, NO UI, NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 2. Bộ Viền Chuyển Tiếp Sân & Bàn Cờ (`env_lawn_borders_pack.png`) — [P1/P2]
```
Output file: inbox/env_lawn_borders_pack.png
Asset: Bộ Viền Sân Vườn, Bờ Hồ & Tuyết (Garden Edge & Yard Transition Tiles Pack) — 6 Border Elements
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized cells, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game lawn border and terrain transition props pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized cells, read left-to-right, top-to-bottom).
Subimages (6 top-down angled landscape border segments):
- Cell 1 (row 1, col 1): Snowy Mountain Peak weathered wooden garden fence piled thick with crisp white-cyan snow and tiny red winter berries.
- Cell 2 (row 1, col 2): Lush mossy cobblestone garden curbing strip with clover sprouts and smooth rounded river stones for blending the battlefield lawn edges.
- Cell 3 (row 1, col 3): Traditional Koi pond rocky shoreline bank with pale emerald-green water reeds and smooth gray pond pebbles.
- Cell 4 (row 2, col 1): Fluffy scalloped crisp white winter snowdrift mound with gentle icy blue cel-shaded shadows for snowy garden edges.
- Cell 5 (row 2, col 2): Neat flat Japanese stepping-stone pathway segment set into dark mossy soil with fallen pink cherry blossom petals.
- Cell 6 (row 2, col 3): Low rustic split-bamboo garden edging with tiny golden dandelions and wild grass tufts.
Composition & Technical Rules: Center-aligned in every cell with top-down lane-defense perspective matching lawn tiles, clean silhouettes, and generous margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 3. Bộ Nhà Chính Theo Từng Chương (`env_chapter_houses_pack.png`) — [P1/P2]
```
Output file: inbox/env_chapter_houses_pack.png
Asset: Bộ Nhà Chính Edo Theo Chương 2–5 (Chapter-Themed Left Guardian Buildings Pack) — 4 Buildings
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game guardian sanctuary buildings pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (4 chapter-themed left-side home base buildings facing slightly RIGHT):
- Cell 1 (top-left): Chapter 2 Sunset Bamboo Teahouse sanctuary with warm amber glowing shoji sliding doors, thatched wooden roof, and bamboo veranda bathed in golden sunset light.
- Cell 2 (top-right): Chapter 3 Moonlit Koi Shinto Shrine Hall at night with deep indigo roof tiles, crimson wooden pillars, golden hanging lanterns, and sacred braided shimenawa rope.
- Cell 3 (bottom-left): Chapter 4 Misty Castle Guardhouse Bastion with gray stone rampart base, white Edo plaster walls, tiled watchtower roof, and glowing warm paper lantern by the entrance.
- Cell 4 (bottom-right): Chapter 5 Snowy Mountain Peak Shrine Sanctuary topped with thick sparkling white snow, icicles under dark slate eaves, and radiant warm crimson-gold glowing paper doors.
Composition & Technical Rules: Bottom-center aligned inside each square cell with generous white margins and zero overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, rich atmospheric cel-shaded watercolor coloring tailored to each chapter lighting.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```

## 4. Bộ Cổng Xuất Hiện Yokai Theo Chương (`env_chapter_gates_pack.png`) — [P1/P2]
```
Output file: inbox/env_chapter_gates_pack.png
Asset: Bộ Cổng Yokai Theo Chương 2–5 (Chapter-Themed Right Spawn Gates Pack) — 4 Gates
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game enemy spawn gates pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (4 chapter-themed right-side Yokai entrance gates):
- Cell 1 (top-left): Chapter 2 Weathered Bamboo Forest Wooden Torii Gate wrapped in moss and twisted vines with two tiny glowing chartreuse fireflies near the top beam.
- Cell 2 (top-right): Chapter 3 Moonlit Night Shrine Vermilion Torii Gate with hanging red paper lanterns, cool indigo night shading, and swirling mystical cyan spirit wisps.
- Cell 3 (bottom-left): Chapter 4 Ancient Edo Castle Heavy Iron-Studded Timber Gatehouse flanked by mossy stone pillars and clinging red autumn ivy.
- Cell 4 (bottom-right): Chapter 5 Blizzard Snowbound Vermilion Torii Gate covered in deep snowdrifts and hanging crystal icicles, lit by glowing warm red festival lanterns.
Composition & Technical Rules: Bottom-center aligned inside each square cell with generous white margins and clear open archway silhouettes.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, crisp atmospheric cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```

## 5. Bộ Cây Cối & Bụi Cảnh Theo Mùa (`env_biome_flora_pack.png`) — [P1/P2]
```
Output file: inbox/env_biome_flora_pack.png
Asset: Bộ Cây Cối & Tiểu Cảnh 5 Mùa (Seasonal Biome Trees & Flora Pack) — 6 Flora Props
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game seasonal flora props pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (6 distinct Edo garden trees and foliage clusters):
- Cell 1 (row 1, col 1): Lush snow-laden Japanese evergreen pine tree topped with thick rounded pillows of white snow and tiny red winter plum blossoms (Chapter 5 snow biome).
- Cell 2 (row 1, col 2): Vibrant Japanese maple tree (Momiji) bursting with fiery crimson and vermilion autumn leaves over dark-violet bark (Chapter 4 castle biome).
- Cell 3 (row 1, col 3): Graceful night-blooming weeping cherry blossom tree glowing softly in pastel moonlight pink with tiny cyan fireflies (Chapter 3 night biome).
- Cell 4 (row 2, col 1): Tall golden-green sunset bamboo cluster backlit by warm amber rim highlights and curling golden leaves (Chapter 2 sunset biome).
- Cell 5 (row 2, col 2): Rounded manicured Japanese azalea flower hedge bursting with warm pink and coral spring blossoms (Chapter 1 village biome).
- Cell 6 (row 2, col 3): Cozy garden corner cluster combining a mossy boulder, green fern fronds, and a tiny warm-glowing stone lantern.
Composition & Technical Rules: Bottom-center aligned inside each square cell with generous margins and no overlapping.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, lush layered cel-shaded watercolor foliage.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Bộ Lớp Khí Quyển, Sương Mù & Ánh Sáng (`env_atmosphere_pack.png`) — [P2]
```
Output file: inbox/env_atmosphere_pack.png
Asset: Bộ Mây, Sương Mù, Tia Nắng & Quầng Sáng (Atmospheric Lighting & Mist Pack) — 6 Atmospheric Elements
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game atmospheric overlays and lighting elements pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized cells, read left-to-right, top-to-bottom).
Subimages (6 clean stylized environment atmosphere effects):
- Cell 1 (row 1, col 1): Cute rounded fluffy cream-white and soft sky-blue stylized Edo daytime cloud cluster.
- Cell 2 (row 1, col 2): Layered stylized pale-lavender and slate-silver curling Japanese twilight mist cloud bank (for misty castle drifting fog).
- Cell 3 (row 1, col 3): Warm glowing amber-gold radiant lantern halo blossom orb for subtle additive night glow highlights.
- Cell 4 (row 2, col 1): Soft diagonal golden sunlight / moonlight shaft beam ribbon with delicate floating dust motes.
- Cell 5 (row 2, col 2): Magical cluster of 6 luminous cyan-gold firefly wisps with soft glowing trails.
- Cell 6 (row 2, col 3): Stylized sweeping icy-white and glacial-cyan winter blizzard wind swirl ribbon with crisp snowflakes.
Composition & Technical Rules: Center-aligned cleanly inside each cell with generous white margins and clear readable silhouettes without muddy dark boxes.
Art Style: Hand-drawn 2D Edo chibi game art, soft luminous watercolor cel-shading and stylized curling Japanese cloud ink accents where appropriate.
Clean Output: Pure flat solid white background (#FFFFFF), strictly NO grid lines, NO borders, NO characters, NO text, NO numbers, NO watermarks.
```
