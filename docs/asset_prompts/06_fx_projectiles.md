# 06 — Hiệu Ứng (FX) & Đạn (Projectiles) — Asset Prompts

- **Danh mục:** Đạn & Hiệu ứng (P0 cơ bản + P1 nâng cao: cháy, choáng, băng, hồi máu, đẩy lùi, nổ lớn)
- **Thư mục nhận raw:** `inbox/`
- **Thư mục đích sau adapt:** `assets/sprites/fx/`
- **Quy chuẩn chung:** Đạn hướng bay sang **PHẢI**, VFX căn chính tâm (`center-center`), chuẩn **12 frames (`4×3`)** cho VFX thường và **16 frames (`4×4`)** cho VFX nổ lớn, nền trắng phẳng `#FFFFFF`, không đường kẻ lưới, không chữ.

---

## 1. Bộ Đạn Bay (`projectiles_pack.png`) — [P0]
*Gồm 6 subimages (`3×2`): Cánh hoa đào bay, Mũi tên tre, Cầu băng, Hạt phấn độc tím, Tia linh lực Komainu, Đạn bùa lửa.*
```
2D Japanese Edo-period chibi game projectiles sprite sheet, 3 columns by 2 rows (6 equal-sized square cells), game projectiles all oriented flying horizontally to the right with clean silhouettes. Cell 1: glowing sharp pink Sakura cherry blossom petal projectile with soft pink trail. Cell 2: sleek green bamboo crossbow dart with feather fletching and speed line. Cell 3: radiant translucent frost-blue ice orb with tiny orbiting ice crystals. Cell 4: bubbling violet poison spore glob with toxic droplets. Cell 5: blazing cyan-gold sacred spirit fireball orb. Cell 6: flaming vermilion-gold Ofuda spark projectile. Center-aligned in every cell. Hand-drawn 2D game art style, thick clean dark-brown ink outlines, vibrant luminous cel-shaded watercolor coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 2. Khói độc tím (`fx_poison_cloud.png`) — [P0]
*12 frames (`4×3`): Làn khói độc phun ra từ Nấm độc, cuộn xoáy và tan mượt.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), toxic purple mushroom spore cloud effect expanding from left to right. Frame progression from top-left to bottom-right: frames 1-3 dense bright violet puff burst; frames 4-8 billowing toxic purple-magenta cloud swirling with glowing bubbles and tiny spore dots; frames 9-12 cloud breaks into smaller floating purple wisps and softly fades away cleanly. Center-aligned in every cell. Hand-drawn 2D game art style, clean dark-purple outlines on puffs, vibrant cel-shaded watercolor coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 3. Tia nổ trúng đòn (`fx_hit_spark.png`) — [P0]
*12 frames (`4×3`): Hiệu ứng trúng đòn sắc nét khi đạn chạm Yokai.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), crisp cartoon impact hit-spark burst centered in each cell. Frame progression from top-left to bottom-right: frames 1-2 bright white-yellow impact flash star; frames 3-6 dynamic spiky golden-orange starburst rays and curved impact ring expanding outward; frames 7-10 flying cartoon spark flecks and tiny smoke dots; frames 11-12 remaining tiny sparks fade cleanly away. Center-aligned in every cell. Hand-drawn 2D game art style, crisp bold ink outlines, vibrant yellow-orange cel-shaded coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 4. Khói tan biến / Đặt cây (`fx_smoke_puff.png`) — [P0]
*12 frames (`4×3`): Đám khói trắng dễ thương kiểu Ninja/Yokai khi trồng quân hoặc Yokai biến mất.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), classic cute Japanese cartoon ninja-style white smoke puff (poof effect) centered in each cell. Frame progression from top-left to bottom-right: frames 1-3 quick tight white cloud pop with tiny star bursts; frames 4-7 fluffy billowing cream-white smoke cloud expanding in a round silhouette; frames 8-12 cloud separates into smaller curling smoke swirls that shrink and vanish cleanly. Center-aligned in every cell. Hand-drawn 2D game art style, warm dark-brown ink outlines on fluffy clouds, soft cream-gray cel-shading. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 5. Vụ nổ lớn (`fx_explosion.png`) — [P1]
*16 frames (`4×4`): Vụ nổ Pháo hoa / Thùng rượu Sake uy lực cao.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 4 rows (16 equal-sized square cells), dramatic stylized Japanese firework-and-fire explosion centered in each cell. Frame progression from top-left to bottom-right: frames 1-3 intense white-gold core flash; frames 4-7 fiery orange-crimson fireball expanding rapidly with sharp shockwave ring and golden sparks; frames 8-12 billowing warm gray-orange smoke plumes rising with swirling red embers; frames 13-16 soft dissipating smoke curls and fading sparks until empty. Center-aligned in every cell. Hand-drawn 2D game art style, bold ink outlines on flames and smoke, vibrant cel-shaded watercolor coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 6. Luồng gió xoáy (`fx_wind_gust.png`) — [P1]
*12 frames (`4×3`): Luồng gió đẩy lùi từ Gió lốc, thổi sang PHẢI.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), dynamic swirling wind gust wave blowing from left to right. Frame progression from top-left to bottom-right: frames 1-3 spiraling cyan-white wind ribbons forming on the left; frames 4-8 strong sweeping curved air currents and curling wind swirls rushing right with tiny flying green leaves; frames 9-12 wind streaks elongate, thin out, and dissolve cleanly. Center-aligned in every cell. Hand-drawn 2D game art style, crisp teal-blue ink lines, translucent aqua-white cel-shaded coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 7. Hiệu ứng Đóng băng (`fx_freeze_overlay.png`) — [P1]
*12 frames (`4×3`): Tinh thể băng phủ lên mục tiêu khi bị Hồ lô băng làm chậm hoặc Yuki-onna đóng băng.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), icy crystal freeze encasement effect centered in each cell. Frame progression from top-left to bottom-right: frames 1-4 frosty mist bursts and sharp translucent cyan ice spikes grow upward from the base; frames 5-8 solid faceted crystalline ice block shimmers with bright white frost sparkles; frames 9-12 ice crystal cracks and shatters cleanly into flying glittering ice shards. Center-aligned in every cell. Hand-drawn 2D game art style, crisp icy-blue ink outlines, luminous cyan and white cel-shaded watercolor coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 8. Hiệu ứng Choáng (`fx_stun_stars.png`) — [P1]
*12 frames (`4×3`): Vòng sao và bùa chú xoay tròn trên đầu Yokai khi bị Phù chú làm choáng.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), seamless looping cartoon stun status effect centered in each cell. Frame progression from top-left to bottom-right: golden cartoon stars, tiny swirling mystic orange spirals, and two miniature glowing red-gold talisman sparks orbiting smoothly in a horizontal oval halo. Center-aligned in every cell. Hand-drawn 2D game art style, thick clean dark-brown ink outlines, bright golden yellow and vermilion cel-shaded coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 9. Hiệu ứng Cháy (`fx_burn_flame.png`) — [P1]
*12 frames (`4×3`): Ngọn lửa cháy liếm liên tục (hiệu ứng thiêu đốt / thùng Sake).*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), seamless looping stylized Japanese cartoon fire flame effect centered in each cell. Frame progression from top-left to bottom-right: lively flickering orange, yellow, and crimson fire tongues dancing upward with rising glowing embers. Center-aligned in every cell. Hand-drawn 2D game art style, clean dark-red ink outlines, vibrant fiery gold-to-crimson cel-shaded watercolor coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 10. Hiệu ứng Hồi máu (`fx_heal_aura.png`) — [P1]
*12 frames (`4×3`): Luồng ánh sáng xanh ngọc & giọt nước/lá non bay lên từ Chữa lành.*
```
2D Japanese Edo-period chibi game VFX sprite sheet, 4 columns by 3 rows (12 equal-sized square cells), soothing healing aura burst effect centered in each cell. Frame progression from top-left to bottom-right: frames 1-4 glowing emerald-green and aqua circular ripple expands at the base; frames 5-9 sparkling green healing plus-sparkles, glowing water droplets, and tiny fresh green leaves float gently upward; frames 10-12 sparkles softly fade away cleanly. Center-aligned in every cell. Hand-drawn 2D game art style, soft emerald outlines, luminous mint-green and aqua cel-shaded watercolor coloring. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```

## 11. Hạt Cánh hoa & Tuyết rơi nền (`fx_ambient_particles.png`) — [P1]
*Gồm 6 subimages (`3×2`): 3 kiểu cánh hoa anh đào, lá tre rơi, bông tuyết, đốm linh hỏa lơ lửng (dùng cho `CPUParticles2D` trong Godot).*
```
2D Japanese Edo-period chibi game ambient particle sprite sheet, 3 columns by 2 rows (6 equal-sized square cells), individual floating environmental particles centered in each cell. Cell 1: single soft pink cherry blossom sakura petal. Cell 2: curved fluttering sakura petal angled differently. Cell 3: tiny cluster of two pink petals. Cell 4: fresh green pointed bamboo leaf. Cell 5: delicate crisp white-blue six-pointed snowflake crystal. Cell 6: small glowing cyan-gold floating spirit wisp spark. Hand-drawn 2D game art style, clean delicate dark-brown outlines, vibrant watercolor cel-shading. Pure flat solid white background (#FFFFFF), no grid lines, no borders, no text, no drop shadow on the background.
```
