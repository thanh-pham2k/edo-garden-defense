# 11 — Nhân Vật Thủ Vườn, Biểu Tượng Thương Hiệu & Giao Diện Mở Rộng (Characters & Extended UI) — Asset Prompts

- **Danh mục:** Chân dung Thủ Vườn Nhí, Biểu tượng thương hiệu / App / Xoay màn hình / Auto-Play và HUD mở rộng (nút kỹ năng, sổ Bách Quỷ, khung thoại, tắt âm, hút Hỏa) — 3 prompts
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/ui/`
- **Quy chuẩn chung:** Mỗi prompt tạo 1 ảnh đứng riêng (standalone text-to-image, không dùng Edit Mode) gồm **4 hoặc 6 subimages (`2×2` hoặc `3×2`)**, phong cách giấy Washi, gỗ sơn mài ấm và nét vẽ Edo chibi, **KHÔNG chữ / KHÔNG số**, nền trắng phẳng `#FFFFFF`.

---

## 1. Bộ Biểu Cảm Thủ Vườn Nhí (`char_gardener_portraits.png`) — [P2]
```
Output file: inbox/char_gardener_portraits.png
Asset: Thủ Vườn Nhí (Young Edo Gardener Protagonist) — 6 Expression Portraits
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi character portrait sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character Design (consistent across all 6 portraits): Cute young chibi Edo Japanese garden guardian keeper wearing an emerald-green and warm gold happi gardener coat tied with a red cord sash, pink sakura petal hairpins in tousled warm brown hair, rosy cheeks, and holding a small glowing cyan spirit lantern.
Subimages (6 waist-up character bust portraits facing slightly toward the right):
- Cell 1 (row 1, col 1): Cheerful smiling welcome expression holding up the glowing cyan spirit lantern warmly.
- Cell 2 (row 1, col 2): Determined focused battle-ready expression pointing forward heroically with confident brows.
- Cell 3 (row 1, col 3): Dramatic surprised alert expression with wide eyes, tiny sweat drop, and warning hand raised (Huge Wave alert).
- Cell 4 (row 2, col 1): Joyful celebratory victory expression with sparkling eyes, big laugh, and both fists raised in triumph among floating sakura petals.
- Cell 5 (row 2, col 2): Gentle worried yet encouraging expression cradling the spirit lantern softly (Defeat / try-again encouragement).
- Cell 6 (row 2, col 3): Playful winking tutorial guide expression resting one finger thoughtfully near chin with bright sparkle.
Composition & Technical Rules: Consistent head scale and chest crop centered in every square cell with generous white margins. Zero overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant warm watercolor cel-shading, expressive anime-chibi eyes.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO speech bubbles, NO text, NO numbers, NO watermarks.
```

## 2. Bộ Biểu Tượng Thương Hiệu & Tính Năng Đặc Biệt (`ui_branding_icons_pack.png`) — [P2]
```
Output file: inbox/ui_branding_icons_pack.png
Asset: Biểu Tượng Tiêu Đề, App Icon, Xoay Màn Hình & Auto-Play (Branding & Special Badges Pack) — 4 Emblems
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game UI branding emblems and app badges sheet arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom), completely BLANK interior frames with ZERO text or letters.
Subimages (4 ornate Japanese branding and feature badges):
- Cell 1 (top-left): Ornate horizontal blank cream-washi wooden-and-gold title signboard plaque framed by blooming sakura boughs, knotted crimson cords, and tiny cyan spirit flame crest (no text).
- Cell 2 (top-right): Square rounded-corner Japanese Edo lacquer-and-gold game app icon crest showcasing a radiant cyan-blue Spirit Flame orb framed by five pink cherry blossoms.
- Cell 3 (bottom-left): Cute rounded mobile landscape-rotation badge depicting a tilted golden Edo wooden tablet rotating from vertical to horizontal with crisp curved arrow and tiny sakura petal.
- Cell 4 (bottom-right): Cute spirited chibi white Kitsune fox mask emblem ringed by spinning golden speed lines and glowing emerald spirit sparks (auto-play turbo badge).
Composition & Technical Rules: Center-aligned in every square cell with generous white margins and crisp readable emblem silhouettes.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, glossy lacquered wood, gold, and cyan-pink cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders around cells, NO text, NO letters, NO numbers, NO watermarks.
```

## 3. Bộ HUD Kỹ Năng, Sổ Tay & Nút Tiện Ích Mở Rộng (`ui_extended_hud_pack.png`) — [P2]
```
Output file: inbox/ui_extended_hud_pack.png
Asset: Bộ Khung Kỹ Năng, Hộp Thoại, Sổ Yêu Quái & Nút Muted/Auto (Extended HUD Pack) — 6 UI Elements
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game extended UI widgets pack arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized cells, read left-to-right, top-to-bottom), completely BLANK with ZERO text or numbers.
Subimages (6 parchment-wood and lacquer UI components):
- Cell 1 (row 1, col 1): Chunky square rounded Edo lacquered-gold and cedar-wood active skill button socket ready state with warm amber corner glow (blank interior).
- Cell 2 (row 1, col 2): Muted dark-slate cool stone square button socket disabled/cooldown state matching Cell 1 dimensions (blank interior).
- Cell 3 (row 1, col 3): Wide horizontal cream Japanese washi parchment story dialogue panel framed with warm bamboo-wood molding and golden corner brackets (blank interior).
- Cell 4 (row 2, col 1): Cute bound traditional Edo Japanese Yokai Almanac encyclopedia book open flat with blank warm cream paper pages and red silk bookmark ribbon.
- Cell 5 (row 2, col 2): Chunky rounded-square warm amber-gold HUD button featuring an audio speaker icon crossed out by a bold crimson diagonal slash (sound muted toggle).
- Cell 6 (row 2, col 3): Chunky rounded-square warm amber-gold HUD button featuring a glowing cyan Spirit Flame swirl icon inside a shimmering pickup ring (auto-collect Spirit Flame toggle).
Composition & Technical Rules: Center-aligned cleanly inside each cell with generous white margins and crisp UI icon readability.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, glossy lacquered wood, gold, and warm washi paper cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders around cells, NO text, NO letters, NO numbers, NO watermarks.
```
