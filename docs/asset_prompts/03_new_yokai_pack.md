# 03 — 4 Yokai Thường Mới Có Cơ Chế Đặc Biệt (New Enemies) — Asset Prompts

- **Danh mục:** 4 Yokai mới cho Màn 7 → 18 (`karakasa`, `chochin_ma`, `tanuki`, `kappa_phap_su`) gồm `walk`/`attack`/`die` (`4×3` = 12 frames) và bộ 4 Icon (`2×2`) (13 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/enemies/`
- **Quy chuẩn chung:** Tất cả Yokai đều quay mặt **SANG TRÁI (facing LEFT)** để tiến vào khu vườn; nền trắng phẳng `#FFFFFF`, không dùng Edit Mode, không đường kẻ lưới, không chữ.

---

## 1. Ma Ô Karakasa — Walk/Hop (`karakasa_walk.png`) — [P0]
```
Output file: inbox/karakasa_walk.png
Asset: Ma Ô Karakasa (Umbrella Hopping Yokai) — Walk/Hop Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy walk/hop animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Mischievous cute chibi Karakasa-obake (one-eyed traditional red-and-cream oiled-paper Japanese umbrella monster with a playful sticking-out tongue, hopping on a single wooden geta sandal foot), facing LEFT. Role: leaps over the first obstacle or frontline defender.
Animation (12 bouncy one-legged hopping cycle frames moving LEFT):
- Frames 1–3: Compresses umbrella canopy slightly before hopping off its single geta foot.
- Frames 4–7: Springs playfully into the air leaning LEFT, umbrella rim flaring open, tongue flopping happily.
- Frames 8–12: Lands smoothly on geta sandal with squash-and-stretch recoil returning seamlessly to Frame 1.
Composition & Technical Rules: Bottom-center aligned consistently across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, lively cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 2. Ma Ô Karakasa — Attack (`karakasa_attack.png`) — [P0]
```
Output file: inbox/karakasa_attack.png
Asset: Ma Ô Karakasa — Attack Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy attack animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Mischievous cute chibi Karakasa-obake (one-eyed red-and-cream paper umbrella Yokai on a single wooden geta sandal), facing LEFT.
Animation (12 playful smack/lick attack frames facing LEFT):
- Frames 1–4: Tilts umbrella top back preparing to strike.
- Frames 5–8: Lunges forward LEFT smacking with its heavy umbrella tip and big playful tongue whip.
- Frames 9–12: Bounces smoothly back upright to ready stance.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 3. Ma Ô Karakasa — Die (`karakasa_die.png`) — [P0]
```
Output file: inbox/karakasa_die.png
Asset: Ma Ô Karakasa — Die Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy defeat animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Cute chibi Karakasa-obake (one-eyed red-and-cream paper umbrella Yokai on a geta sandal), facing LEFT.
Animation (12 comical defeat frames):
- Frames 1–4: Startled spiral-dizzy eye, umbrella flips inside-out upward with comical pop.
- Frames 5–8: Spins and collapses downward folding shut with little dust stars.
- Frames 9–12: Dissolves cleanly into cute white spirit smoke puffs and fading paper petals.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, soft cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 4. Đèn Lồng Ma Chochin — Float/Fly (`chochin_ma_walk.png`) — [P0]
```
Output file: inbox/chochin_ma_walk.png
Asset: Đèn Lồng Ma Chochin-obake (Flying Spirit-Drain Yokai) — Float Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy flying animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Spooky-cute chibi Chochin-obake (torn purple-and-cream glowing Japanese paper lantern Yokai with wide yellow eyes, jagged grin mouth slit in its belly, tiny spectral blue flame trailing behind), floating in mid-air facing LEFT. Role: flying enemy that drains player Spirit Flame if left alive.
Animation (12 eerie floating bob frames):
- Frames 1–6: Bobs gently upward and forward LEFT, lantern accordion ribs expanding slightly while ghostly cyan flame flickers.
- Frames 7–12: Drifts downward and forward smoothly looping back into Frame 1 with mischievous grin chomp.
Composition & Technical Rules: Center-aligned consistently across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, moody purple-and-cyan cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Đèn Lồng Ma Chochin — Attack (`chochin_ma_attack.png`) — [P0]
```
Output file: inbox/chochin_ma_attack.png
Asset: Đèn Lồng Ma Chochin-obake — Bite/Drain Attack Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy attack animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Spooky-cute chibi Chochin-obake (floating purple-and-cream glowing paper lantern Yokai with wide mouth slit and blue spirit wisps), facing LEFT.
Animation (12 spirit-drain & chomp frames facing LEFT):
- Frames 1–4: Opens wide glowing lantern mouth pulling in tiny purple-cyan energy swirls from the LEFT.
- Frames 5–8: Snaps forward LEFT with a glowing spectral chomp flash.
- Frames 9–12: Floats smoothly back into poised hovering stance.
Composition & Technical Rules: Center-aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Đèn Lồng Ma Chochin — Die (`chochin_ma_die.png`) — [P0]
```
Output file: inbox/chochin_ma_die.png
Asset: Đèn Lồng Ma Chochin-obake — Die Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy defeat animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Spooky-cute chibi Chochin-obake (floating purple-and-cream paper lantern Yokai), facing LEFT.
Animation (12 defeat frames):
- Frames 1–4: Inner flame flickers out with dizzy spiral eyes, paper body crumples like an accordion.
- Frames 5–8: Drops downward spinning into a collapsed lantern ring.
- Frames 9–12: Fades into cute lavender-cyan smoke wisps and tiny sparks.
Composition & Technical Rules: Center-aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 7. Tanuki Biến Hình — Walk (`tanuki_walk.png`) — [P1]
```
Output file: inbox/tanuki_walk.png
Asset: Tanuki Biến Hình (Raccoon-Dog Trickster Yokai) — Walk Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy walk animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Plump cheeky chibi Japanese Tanuki Yokai with warm brown fur, dark raccoon eye-mask, straw rain hat, a magic green transformation leaf perched on its head, and a small sake gourd tied at its waist, waddling briskly LEFT. Role: speeds up and gains temporary shield when below 50% HP.
Animation (12 brisk waddle cycle frames moving LEFT):
- Frames 1–6: Left foot step forward with belly bounce, bushy striped tail bobbing, straw hat tipping playfully.
- Frames 7–12: Right foot step forward mirroring stride cleanly back into Frame 1.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm earthy cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 8. Tanuki Biến Hình — Attack (`tanuki_attack.png`) — [P1]
```
Output file: inbox/tanuki_attack.png
Asset: Tanuki Biến Hình — Belly-Drum / Leaf Slam Attack Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy attack animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Plump cheeky chibi Japanese Tanuki Yokai wearing a straw hat, magic green leaf on head, and waist sake gourd, facing LEFT.
Animation (12 comedic belly-bump & club slam frames facing LEFT):
- Frames 1–4: Puffs out round belly drumming twice with paws while magic leaf glows green.
- Frames 5–8: Bounces forward LEFT delivering a stout belly-slam impact with leaf-spark burst.
- Frames 9–12: Recovers smoothly back into waddle stance.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, warm cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 9. Tanuki Biến Hình — Die (`tanuki_die.png`) — [P1]
```
Output file: inbox/tanuki_die.png
Asset: Tanuki Biến Hình — Die Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy defeat animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Plump cheeky chibi Japanese Tanuki Yokai with straw hat and magic green leaf, facing LEFT.
Animation (12 classic trickster-poof defeat frames):
- Frames 1–4: Surprised dizzy eyes, straw hat pops upward off its head.
- Frames 5–8: Spins into a classic cartoon white transformation smoke cloud ("POOF!") as green leaves scatter.
- Frames 9–12: Smoke cloud gently dissipates leaving only two tiny floating green leaves fading out.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 10. Kappa Pháp Sư — Walk (`kappa_phap_su_walk.png`) — [P1]
```
Output file: inbox/kappa_phap_su_walk.png
Asset: Kappa Pháp Sư (Ranged Water-Mage Kappa) — Walk Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy walk animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Clever chibi emerald-green Kappa Water Mage wearing a tiny indigo shrine-sorcerer vest, glowing water dish on head, turtle shell on back, carrying a gnarled bamboo water-orb staff, marching LEFT. Role: stops at mid-range to lob water orbs at defenders.
Animation (12 steady march frames moving LEFT):
- Frames 1–6: Left webbed foot forward, staff tapping rhythmically, water orb at staff tip shimmering cyan.
- Frames 7–12: Right webbed foot forward looping seamlessly into Frame 1.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, crisp aqua-and-emerald cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 11. Kappa Pháp Sư — Cast Attack (`kappa_phap_su_attack.png`) — [P1]
```
Output file: inbox/kappa_phap_su_attack.png
Asset: Kappa Pháp Sư — Water Orb Cast Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy spell-cast animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Clever chibi emerald-green Kappa Water Mage in indigo sorcerer vest holding a bamboo water-orb staff, facing LEFT.
Animation (12 ranged water-spell cast frames facing LEFT):
- Frames 1–4: Raises bamboo staff high as swirling aqua water gathers around its tip.
- Frames 5–8: Thrusts staff forward LEFT launching a splashing magical water orb with droplet sparks.
- Frames 9–12: Lowers staff cleanly back to walking stance.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 12. Kappa Pháp Sư — Die (`kappa_phap_su_die.png`) — [P1]
```
Output file: inbox/kappa_phap_su_die.png
Asset: Kappa Pháp Sư — Die Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy defeat animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Chibi emerald-green Kappa Water Mage in indigo vest with bamboo staff, facing LEFT.
Animation (12 defeat frames):
- Frames 1–4: Water dish on head splashes out comically, eyes turn spiral dizzy.
- Frames 5–8: Tumbles backward onto turtle shell dropping bamboo staff with water droplets flying.
- Frames 9–12: Dissolves cleanly into aqua mist bubbles and white spirit smoke.
Composition & Technical Rules: Bottom-center aligned across all 12 cells, facing LEFT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 13. Bộ 4 Icon Yokai Mới (`enemies_new_icons_pack.png`) — [P0]
```
Output file: inbox/enemies_new_icons_pack.png
Asset: Bộ 4 Icon Yokai Mới (Karakasa, Chochin Ma, Tanuki, Kappa Phap Su) — 4 Icons
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game Yokai enemy portrait icons pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (4 crisp Yokai portrait icons facing LEFT):
- Cell 1 (top-left, -> karakasa_icon.png): Mischievous one-eyed red-and-cream Karakasa paper umbrella Yokai hopping on one geta sandal.
- Cell 2 (top-right, -> chochin_ma_icon.png): Spooky-cute floating purple-and-cream Chochin paper lantern Yokai with glowing grin and blue spirit wisps.
- Cell 3 (bottom-left, -> tanuki_icon.png): Cheeky brown chibi Tanuki Yokai in straw hat with magic green leaf on head.
- Cell 4 (bottom-right, -> kappa_phap_su_icon.png): Clever emerald-green Kappa Water Mage in indigo vest holding a glowing water-orb bamboo staff.
Composition & Technical Rules: Center-aligned cleanly inside each square cell with generous white margins and strong silhouettes.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no frames, no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```
