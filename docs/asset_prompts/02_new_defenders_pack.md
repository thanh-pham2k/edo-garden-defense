# 02 — 4 Quân Phòng Thủ Mới Cho Mở Rộng 18 Màn (New Defenders) — Asset Prompts

- **Danh mục:** 4 quân phòng thủ chiến thuật mới mở khóa từ Màn 7 → Màn 18 (`hoa_phuong`, `daruma_buff`, `meo_kiem`, `cung_sam`) gồm hoạt ảnh Idle (`3×2`), Action (`4×3`) và bộ 4 Icon thẻ bài (`2×2`) (9 prompts)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/defenders/`
- **Quy chuẩn chung:** Tất cả quân phòng thủ đều quay mặt **SANG PHẢI (facing RIGHT)** để đón Yokai; nền trắng phẳng `#FFFFFF`, không dùng Edit Mode, không đường kẻ lưới, không chữ.

---

## 1. Đèn Lồng Hỏa Phượng — Idle (`hoa_phuong_idle.png`) — [P0]
```
Output file: inbox/hoa_phuong_idle.png
Asset: Đèn Lồng Hỏa Phượng (Phoenix Brazier Lantern) — Idle Animation (6 Frames)
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character idle animation sprite sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Cute living Edo crimson-and-gold phoenix paper lantern spirit (Hoa Phuong) mounted on a sturdy bronze tripod stand with fiery golden tail-feather crests, warm glowing amber-orange inner flame, cute determined eyes facing RIGHT. Role: launches splashing phoenix fireballs and melts frost.
Animation (6 seamless breathing idle frames):
- Frames 1–3: Gentle buoyant squash-and-stretch bobbing upward as the phoenix flame crest flickers warmly and tiny golden sparks rise.
- Frames 4–6: Smooth settle downward with bright eye blink on frame 5 and softly swaying golden tassels returning cleanly to Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale and foot anchor across all 6 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, rich warm cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 2. Đèn Lồng Hỏa Phượng — Attack (`hoa_phuong_attack.png`) — [P0]
```
Output file: inbox/hoa_phuong_attack.png
Asset: Đèn Lồng Hỏa Phượng (Phoenix Brazier Lantern) — Attack Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character attack animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Cute living Edo crimson-and-gold phoenix paper lantern spirit (Hoa Phuong) on a bronze tripod stand with fiery feather crests, facing RIGHT.
Animation (12 crisp fireball-launch frames):
- Frames 1–4: Inhales and swells slightly backward, glowing bright golden-orange as flame plumes flare around its crest.
- Frames 5–7: Snaps forward to the RIGHT releasing a brilliant fiery burst from its front lantern opening with recoil sparks.
- Frames 8–12: Smooth elastic bounce-back and settle into calm glowing stance matching Idle Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale and anchor across all 12 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 3. Búp Bê Daruma Trống Cổ Vũ — Idle (`daruma_buff_idle.png`) — [P0]
```
Output file: inbox/daruma_buff_idle.png
Asset: Búp Bê Daruma Cổ Vũ (Aura Haste Buffer) — Idle Animation (6 Frames)
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character idle animation sprite sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Plump adorable crimson-red Japanese Daruma doll guardian with bold golden eyebrow strokes, cheerful determined chibi face facing RIGHT, wearing a tiny golden festival hachimaki headband and holding two mini wooden taiko drumsticks. Role: boosts attack speed of nearby allies in a 3×3 area.
Animation (6 seamless roly-poly idle frames):
- Frames 1–3: Cute rhythmic roly-poly tilt slightly right and bounce up with drumsticks tapping lightly.
- Frames 4–6: Cute roly-poly rock slightly left and settle upright seamlessly back to Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale and anchor across all 6 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant red-and-gold cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 4. Búp Bê Daruma Trống Cổ Vũ — Buff Action (`daruma_buff_action.png`) — [P0]
```
Output file: inbox/daruma_buff_action.png
Asset: Búp Bê Daruma Cổ Vũ — Buff Pulse Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character skill-cast animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Plump adorable crimson-red Japanese Daruma doll guardian with golden eyebrows, festival headband, and twin mini taiko drumsticks, facing RIGHT.
Animation (12 energetic buff-cheer frames):
- Frames 1–4: Raises both drumsticks high and squashes down charging golden spirit energy.
- Frames 5–8: Leaps joyously slightly off ground striking a celebratory beat as shimmering golden ring sparkles radiate outward from its body.
- Frames 9–12: Lands with cute roly-poly wobble and settles smoothly back into Idle Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale across all 12 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, luminous cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 5. Mèo Kiếm Sĩ — Idle (`meo_kiem_idle.png`) — [P1]
```
Output file: inbox/meo_kiem_idle.png
Asset: Mèo Kiếm Sĩ Edo (Samurai Cat Melee Striker) — Idle Animation (6 Frames)
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character idle animation sprite sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Brave adorable white-and-calico chibi Samurai Cat (Meo Kiem) wearing miniature indigo-and-gold Edo samurai shoulder armor, red scarf, and gripping a tiny gleaming wooden/bamboo-hilted katana in a ready stance facing RIGHT. Role: fast 2-tile piercing melee slasher behind frontline walls.
Animation (6 seamless ready-stance frames):
- Frames 1–3: Focused breathing bob, red scarf fluttering gently, katana tip bobbing steadily, curled tail swaying.
- Frames 4–6: Smooth return with sharp determined eye blink on frame 5 looping cleanly to Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale and anchor across all 6 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, crisp cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 6. Mèo Kiếm Sĩ — Attack (`meo_kiem_attack.png`) — [P1]
```
Output file: inbox/meo_kiem_attack.png
Asset: Mèo Kiếm Sĩ Edo (Samurai Cat) — Katana Slash Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character attack animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Brave adorable white-and-calico chibi Samurai Cat in indigo-and-gold armor with red scarf and gleaming katana, facing RIGHT.
Animation (12 crisp iaijutsu slash frames):
- Frames 1–3: Crouches low pulling katana back to hip in coiled samurai draw pose.
- Frames 4–7: Explosive forward lunge to the RIGHT unleashing a wide glowing cyan-white crescent sword arc slash.
- Frames 8–12: Crisp follow-through flourish, scarf trailing, stepping smoothly back into Idle Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale across all 12 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 7. Cung Thủ Sấm — Idle (`cung_sam_idle.png`) — [P1]
```
Output file: inbox/cung_sam_idle.png
Asset: Cung Thủ Sấm (Raijin Thunder Archer Spirit) — Idle Animation (6 Frames)
Grid: 3 columns × 2 rows (6 cleanly separated equal-sized square cells, 3:2 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character idle animation sprite sheet arranged in a strict 3 columns by 2 rows grid (6 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Cute miniature Edo shrine thunder-spirit archer (Cung Sam) wearing a white-and-violet miko/kyudo tunic, a tiny halo of 3 miniature golden Raijin thunder drums behind its back, holding an ornate Japanese yumi bow crackling with tiny cyan-gold lightning sparks, facing RIGHT. Role: fires chain lightning jumping across 3 Yokai.
Animation (6 seamless idle frames):
- Frames 1–3: Gentle breathing sway, golden mini-drums floating subtly, faint electric sparks dancing along bowstring.
- Frames 4–6: Smooth settle back to Frame 1 with confident smile.
Composition & Technical Rules: Bottom-center aligned at identical scale across all 6 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 8. Cung Thủ Sấm — Attack (`cung_sam_attack.png`) — [P1]
```
Output file: inbox/cung_sam_attack.png
Asset: Cung Thủ Sấm (Raijin Thunder Archer Spirit) — Lightning Shot Animation (12 Frames)
Grid: 4 columns × 3 rows (12 cleanly separated equal-sized square cells, 4:3 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game character attack animation sprite sheet arranged in a strict 4 columns by 3 rows grid (12 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Character: Cute miniature Edo shrine thunder-spirit archer with white-violet kyudo outfit, 3 mini golden Raijin drums behind its back, and Japanese yumi bow, facing RIGHT.
Animation (12 crisp thunder-arrow frames):
- Frames 1–4: Draws bowstring back tightly as a glowing cyan-gold lightning arrow crackles into form on the bow.
- Frames 5–7: Releases bowstring with bright electric flash burst shooting straight RIGHT, mini-drums glowing brightly.
- Frames 8–12: Smooth bow recoil and return to poised Idle Frame 1.
Composition & Technical Rules: Bottom-center aligned at identical scale across all 12 cells, facing RIGHT, generous white margins.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```

## 9. Bộ 4 Icon Thẻ Quân Phòng Thủ Mới (`defenders_new_icons_pack.png`) — [P0]
```
Output file: inbox/defenders_new_icons_pack.png
Asset: Bộ 4 Icon Thẻ Quân Mới (Hoa Phuong, Daruma, Meo Kiem, Cung Sam) — 4 Icons
Grid: 2 columns × 2 rows (4 cleanly separated equal-sized square cells, 1:1 aspect ratio, read left-to-right, top-to-bottom)

Prompt:
Create a 2D Japanese Edo-period chibi game unit portrait icons pack arranged in a strict 2 columns by 2 rows grid (4 cleanly separated equal-sized square cells, read left-to-right, top-to-bottom).
Subimages (4 clean full-body/bust unit icons facing RIGHT for deck cards):
- Cell 1 (top-left, -> hoa_phuong_icon.png): Cute crimson-and-gold phoenix brazier lantern spirit glowing warmly with fiery tail crests.
- Cell 2 (top-right, -> daruma_buff_icon.png): Plump cheerful red Japanese Daruma doll with golden eyebrows, headband, and twin mini taiko drumsticks.
- Cell 3 (bottom-left, -> meo_kiem_icon.png): Brave chibi white-and-calico Samurai Cat wearing indigo-gold armor, red scarf, holding a gleaming katana.
- Cell 4 (bottom-right, -> cung_sam_icon.png): Cute chibi Edo thunder-spirit archer in white-violet kyudo attire with golden Raijin mini-drums and lightning bow.
Composition & Technical Rules: Center-aligned cleanly inside each square cell with generous white margins and crisp readable silhouettes at small card sizes.
Art Style: Hand-drawn 2D Edo chibi game art, thick clean dark-brown ink outlines, vibrant cel-shaded watercolor coloring.
Clean Output: Pure flat solid white background (#FFFFFF), no card frames, no drop shadow on background, strictly NO grid lines, NO borders, NO text, NO numbers, NO watermarks.
```
