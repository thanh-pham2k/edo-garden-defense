# 06 — Hiệu Ứng (FX) & Đạn (Projectiles) — Asset Prompts

- **Danh mục:** Đạn & Hiệu ứng (P0 cơ bản + P1 nâng cao — 11 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/fx/`
- **Quy chuẩn chung:** Đạn hướng bay sang **PHẢI**, VFX căn chính tâm (`center-center`), chuẩn **12 frames (`4×3`)** cho VFX thường và **16 frames (`4×4`)** cho VFX nổ lớn, nền trắng phẳng `#FFFFFF`, không đường kẻ lưới, không chữ.

---

## 1. Bộ Đạn Bay (`projectiles_pack.png`) — [P0]
```
Output file: inbox/projectiles_pack.png
Asset: Bộ Đạn Bay (Combat Projectiles Pack) — 6 Projectiles
Grid: 3 columns × 2 rows (6 equal-sized square cells, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game projectiles sprite sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (6 projectiles all oriented flying horizontally toward the RIGHT):
- Cell 1 (row 1, col 1): Glowing razor-sharp pink Sakura cherry blossom petal projectile with a delicate luminous pink motion trail.
- Cell 2 (row 1, col 2): Sleek sharpened emerald-green bamboo crossbow dart with crisp white feather fletching and subtle speed streak.
- Cell 3 (row 1, col 3): Radiant translucent glacial-blue ice orb surrounded by 2-3 tiny crystalline frost shards.
- Cell 4 (row 2, col 1): Bubbling violet-magenta poison spore glob trailing tiny toxic droplets.
- Cell 5 (row 2, col 2): Blazing cyan-gold sacred spirit fireball orb with curling spirit flame tail.
- Cell 6 (row 2, col 3): Flaming vermilion-gold Ofuda spark projectile trailing golden embers.
Composition & Technical Rules: Center-aligned in every cell with crisp readable silhouettes at small game sizes. No overlapping between cells.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant luminous cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 2. Khói độc tím (`fx_poison_cloud.png`) — [P0]
```
Output file: inbox/fx_poison_cloud.png
Asset: Khói độc tím (Poison Spore Cloud VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Toxic purple mushroom spore cloud burst expanding from left to right.
Animation sequence (12 frames):
- Frames 1-3: Dense bright violet-magenta initial puff burst popping open.
- Frames 4-6: Billowing toxic purple spore cloud rolling forward with glowing lavender bubbles.
- Frames 7-9: Swirling poison mist spreads wider with tiny floating spore specks.
- Frames 10-12: Cloud breaks into smaller curling purple wisps and fades cleanly until nearly empty on frame 12.
Composition & Technical Rules: Center-aligned in every cell, staying neatly within each cell boundary.
Art Style: Hand-drawn 2D Edo chibi game art, clean dark-purple ink outlines on cloud puffs, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 3. Tia nổ trúng đòn (`fx_hit_spark.png`) — [P0]
```
Output file: inbox/fx_hit_spark.png
Asset: Tia nổ trúng đòn (Projectile Hit Impact Spark VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Crisp energetic cartoon impact hit-spark burst centered in each cell.
Animation sequence (12 frames):
- Frames 1-2: Bright white-gold core impact flash star.
- Frames 3-6: Dynamic spiky golden-orange starburst rays and expanding curved shock ring radiating outward.
- Frames 7-9: Flying cartoon spark flecks and tiny smoke pops dispersing from center.
- Frames 10-12: Remaining tiny golden embers shrink and fade cleanly until empty on frame 12.
Composition & Technical Rules: Center-aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, crisp bold ink outlines, vibrant golden-yellow and orange cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 4. Khói tan biến / Đặt cây (`fx_smoke_puff.png`) — [P0]
```
Output file: inbox/fx_smoke_puff.png
Asset: Khói tan biến / Đặt cây (Ninja Smoke Puff VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Classic cute Japanese cartoon ninja-style white smoke puff (poof effect) for planting defenders or yokai vanishing, centered in each cell.
Animation sequence (12 frames):
- Frames 1-3: Snappy tight cream-white cloud pop with tiny cartoon star sparkles.
- Frames 4-7: Fluffy billowing round smoke cloud expanding smoothly with spiral curls.
- Frames 8-10: Cloud splits into 4-5 smaller floating smoke puffs drifting outward.
- Frames 11-12: Tiny curling wisps shrink and vanish cleanly until empty on frame 12.
Composition & Technical Rules: Center-aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, warm dark-brown ink outlines on fluffy clouds, soft cream-and-gray cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Vụ nổ lớn (`fx_explosion.png`) — [P1]
```
Output file: inbox/fx_explosion.png
Asset: Vụ nổ lớn (Sake Barrel & Firework Massive Explosion VFX) — 16 Frames
Grid: 4 columns × 4 rows (16 equal-sized square cells, 1:1 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 4 rows grid (16 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Dramatic stylized Japanese fire-and-firework explosion centered in each cell.
Animation sequence (16 frames):
- Frames 1-3: Intense blinding white-gold detonation flash.
- Frames 4-7: Rapidly expanding fiery crimson-and-orange fireball with crisp golden shockwave ring and blazing starburst spikes.
- Frames 8-12: Billowing warm gray-orange cartoon smoke plumes rising with swirling red-gold embers.
- Frames 13-16: Soft dissipating smoke curls and tiny twinkling sparks fade cleanly until empty on frame 16.
Composition & Technical Rules: Center-aligned in every cell, staying neatly within cell boundaries.
Art Style: Hand-drawn 2D Edo chibi game art, bold dark-brown ink outlines on flames and smoke, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Luồng gió xoáy (`fx_wind_gust.png`) — [P1]
```
Output file: inbox/fx_wind_gust.png
Asset: Luồng gió xoáy (Knockback Wind Gust VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Dynamic swirling wind gust wave blowing horizontally from left to right.
Animation sequence (12 frames):
- Frames 1-3: Spiraling cyan-and-white wind ribbons forming tightly on the left.
- Frames 4-7: Powerful sweeping curved air currents and curling wind vortexes rushing swiftly to the right with 2-3 tiny flying green leaves.
- Frames 8-10: Wind streaks elongate and thin out gracefully as they surge right.
- Frames 11-12: Delicate translucent aqua wind trails dissolve cleanly until empty on frame 12.
Composition & Technical Rules: Center-aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, crisp teal-blue ink lines, luminous aqua-white cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 7. Hiệu ứng Đóng băng (`fx_freeze_overlay.png`) — [P1]
```
Output file: inbox/fx_freeze_overlay.png
Asset: Hiệu ứng Đóng băng (Ice Crystal Freeze Status VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Translucent icy crystal freeze encasement effect centered in each cell.
Animation sequence (12 frames):
- Frames 1-3: Chilly frost mist bursts at the base as sharp cyan ice spikes begin crystallizing upward.
- Frames 4-7: Faceted translucent glacial-blue ice crystal block forms fully and shimmers with bright white frost sparkles.
- Frames 8-10: Jagged cracks spread across the ice crystal block.
- Frames 11-12: Ice crystal shatters cleanly into glittering flying cyan ice shards and vanishing frost mist.
Composition & Technical Rules: Center-aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, crisp icy-blue ink outlines, luminous cyan and snow-white cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 8. Hiệu ứng Choáng (`fx_stun_stars.png`) — [P1]
```
Output file: inbox/fx_stun_stars.png
Asset: Hiệu ứng Choáng (Orbiting Stun Stars & Talisman Halo VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Seamless looping cartoon stun status halo (placed above stunned enemies' heads), centered in each cell.
Animation sequence (12 frames seamless loop):
- Frames 1-12: Three bright golden 5-pointed cartoon stars, two tiny orange mystic swirls, and glowing vermilion talisman sparks orbiting smoothly along a flat horizontal oval ring (30-degree rotation per frame for a silky 12-frame loop).
Composition & Technical Rules: Center-aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant golden yellow and vermilion cel-shaded coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 9. Hiệu ứng Cháy (`fx_burn_flame.png`) — [P1]
```
Output file: inbox/fx_burn_flame.png
Asset: Hiệu ứng Cháy (Looping Fire Burn Status VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Seamless looping stylized Japanese cartoon fire flame effect (for burning status), centered in each cell.
Animation sequence (12 frames seamless loop):
- Frames 1-12: Lively flickering golden-yellow core flames transitioning into vibrant orange and crimson-red licking fire tongues dancing upward with tiny rising glowing embers.
Composition & Technical Rules: Bottom-center aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, clean dark-crimson ink outlines, luminous gold-to-red cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 10. Hiệu ứng Hồi máu (`fx_heal_aura.png`) — [P1]
```
Output file: inbox/fx_heal_aura.png
Asset: Hiệu ứng Hồi máu (Soothing Emerald Healing Aura VFX) — 12 Frames
Grid: 4 columns × 3 rows (12 equal-sized square cells, 4:3 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game VFX sprite sheet arranged in a strict 4 columns by 3 rows grid (12 equal-sized square cells, read left-to-right, top-to-bottom).
Subject: Soothing emerald-and-aqua healing aura burst effect centered in each cell.
Animation sequence (12 frames):
- Frames 1-3: Soft glowing emerald-aqua circular ripple expands at the base.
- Frames 4-8: Radiant mint-green healing plus-sparkles, shimmering aqua droplets, and tiny fresh green sprout leaves float gently upward.
- Frames 9-12: Rising sparkles and droplets twinkle softly and dissolve cleanly until empty on frame 12.
Composition & Technical Rules: Center-aligned in every cell with clean margins.
Art Style: Hand-drawn 2D Edo chibi game art, clean emerald outlines, luminous mint-green and aqua cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 11. Hạt Cánh hoa & Tuyết rơi nền (`fx_ambient_particles.png`) — [P1]
```
Output file: inbox/fx_ambient_particles.png
Asset: Bộ Hạt Môi Trường (Ambient Particles Pack for CPUParticles2D) — 6 Particles
Grid: 3 columns × 2 rows (6 equal-sized square cells, 3:2 aspect ratio)

Prompt:
Create a 2D Japanese Edo-period chibi game ambient particle sprite sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (6 individual environmental particles centered in each cell):
- Cell 1 (row 1, col 1): Single delicate pastel-pink Sakura cherry blossom petal.
- Cell 2 (row 1, col 2): Gently curved fluttering Sakura petal seen from a side angle.
- Cell 3 (row 1, col 3): Tiny pair of overlapping pink sakura petals.
- Cell 4 (row 2, col 1): Crisp fresh emerald-green pointed Japanese bamboo leaf.
- Cell 5 (row 2, col 2): Delicate glowing white-and-sky-blue six-pointed winter snowflake crystal.
- Cell 6 (row 2, col 3): Small radiant cyan-gold floating spirit wisp spark.
Composition & Technical Rules: Center-aligned in every cell with generous margins.
Art Style: Hand-drawn 2D Edo chibi game art, delicate dark-brown ink outlines, vibrant watercolor cel-shading.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```
