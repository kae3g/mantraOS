# Guardian Dragon — Logo & Mascot Prompt Guide
_(internal assets note; misc helpers for contributors)_

---

## Purpose

This guide helps contributors generate high-fidelity **Guardian Dragon** logo/mascot explorations using **any image generator** (chat-based, local diffusion, or API-style).  
We avoid naming specific products or websites; adapt the steps to your favorite tools.

The design intent: **East-Asian-inspired, serpentine guardian**, asymmetrical brush-stroke motion, **calm eyes**, **closed mouth**, gentle **bamboo/hemp armor**, warm **furnace glow** under natural **brown scales**, protecting a **small sapling or open book**.

Use the provided **SVG line-art skeleton** (`assets/logo/guardian-dragon-lineart.svg`) as an `img2img` starting point when possible.

---

## Visual Goals (recap)

- **Asymmetric, flowing coil** (not a perfect circle).  
- **Face shield helmet**, **dark calm eyes**, **whiskers**, **ear fins**.  
- **Closed mouth**, no teeth; dignified, protective.  
- **Armor**: stylized dark-stained bamboo/hemp plates; natural, not militaristic.  
- **Warm brown body**, **soft orange/gold inner glow**, **green sapling**.  
- **Not scary**; carries gravitas and serenity.

---

## Color Swatches (hex)

- **Guardian Brown (body/armor)**: `#7C4A33`  
- **Furnace Orange (inner glow)**: `#FFA94D`  
- **Daylight Gold (accents)**: `#EBCB8B`  
- **Deep Black-Blue (helmet/eyes)**: `#002B36`  
- **Paper White (background)**: `#FDF6E3`  
- **Guardian Green (sapling/book motif)**: `#859900`

---

## Master Prompt (copy-paste, then adapt)

> A serene guardian dragon rendered as a flowing, asymmetric East-Asian serpentine form, coiling protectively around a tiny sapling (or an open book). Closed mouth, no teeth, calm dark eyes beneath a face-shield helmet with natural bamboo/hemp textures. Elegant whiskers and ear fins drawn like ink calligraphy. Body covered with warm brown scales and gentle layered armor plates; a soft furnace-orange inner glow pulses under the scales and along the tail edges, blending into daylight-gold highlights. Composition reads as a mascot emblem suitable for a software project: iconic silhouette, strong negative space, not a perfect circle, balanced swirl motion. High readability at small sizes. Soft paper-white background. Non-aggressive, dignified, protective.

**Styling modifiers to try:**  
- sumi-e brush textures, ink-wash edges, subtle grain  
- layered vector-painterly hybrid, clean emblem silhouette  
- cinematic keylight from upper left, subtle rimlight on armor plates  
- soft depth shading, no harsh speculars  

**What to avoid (negative cues):**  
- open mouth, fangs, gore, smoke, sparks, aggressive fire  
- childish cartoon style, emoji style, chibi proportions  
- perfect circles or symmetrical coils  
- metallic sci-fi armor or mecha panels  
- cluttered backgrounds

---

## Generator A (chat-style UI)

1. **Upload** `assets/logo/guardian-dragon-lineart.svg` as reference (if uploads are supported).  
2. Paste the **Master Prompt**.  
3. Add **parameters** (if available):  
   - Aspect: `1:1` (icons) or `3:2` (hero art)  
   - Stylization: moderate  
   - Quality: high  
   - Seed: fixed number for repeatability (e.g., `12345`)  
4. Request **4–8 variations**.  
5. Choose the best silhouette → **upscale** → **remove background** (transparent).  
6. Export **PNG (transparent)** and **SVG (vectorized)** if the tool supports vector export.

---

## Generator B (local diffusion or on-prem)

**img2img workflow (recommended):**
1. Open your diffusion UI (local).  
2. Load `assets/logo/guardian-dragon-lineart.svg` as the **init image** (rasterize to 1536×1536 or 2048×2048).  
3. Set **denoise** around `0.35–0.55` to respect line art but allow detail.  
4. Use the **Master Prompt**; add **negative prompts** from "What to avoid."  
5. Choose a **photoreal→illustrative** capable model or **vector-friendly illustration** model.  
6. Sampler: 30–40 steps; CFG: 5–7; Seed: fixed.  
7. Generate 8–12 images; pick the cleanest silhouette.  
8. If edges look fuzzy, run a **vectorization** pass (e.g., Potrace/Illustrator/Inkscape).  
9. Export: **SVG** for logo, **PNG** for previews.

**Control & consistency tips:**  
- Use **ControlNet or similar** with "scribble/lineart" to adhere to the SVG skeleton.  
- Inpaint eyes/helmet if needed to keep **calm expression** and **closed mouth**.  
- Add a soft **paper-white background** (`#FDF6E3`) layer for preview; keep the final transparent.

---

## Generator C (API-driven)

1. Convert the **Master Prompt** into your API's JSON payload.  
2. Include a **reference image URL or base64** of the line-art if supported.  
3. Parameters:  
   - size: `1024×1024` or `1536×1536`  
   - style: "illustrative, emblem, ink-brush"  
   - background: "transparent preferred"  
   - seed: integer  
4. Request **N=6–12 variations**.  
5. Programmatically **threshold for silhouette clarity** (optional) and keep top 2–3.  
6. Store results under `assets/logo/drafts/` with a naming convention:

```
assets/logo/drafts/
guardian_v001_seed12345_a01.png
guardian_v001_seed12345_a02.png
...
```

---

## Post-Processing Checklist

- [ ] Background transparent; **export PNG + SVG**.  
- [ ] Silhouette legible at **32 px, 64 px, 128 px**.  
- [ ] Color balance: warm brown dominant, subtle orange/gold glow; no harsh neon.  
- [ ] Eyes remain **calm and dark**; mouth closed.  
- [ ] Armor reads as **natural material** (bamboo/hemp), not metal.  
- [ ] Sapling/book remains visible but secondary.  
- [ ] Works on light and dark UI (prepare light/dark variants if needed).

---

## Wordmark Lockup (optional)

Set the symbol left, wordmark right:

- Symbol: Guardian Dragon emblem (SVG).  
- Wordmark:  
- Project name set in **Noto Serif** for headings or **Noto Sans** for UI, tracking slightly tightened.  
- Don't kern the "OS" apart from "Mantra" unless exploring a stylistic lockup.  
- Spacing: clear-space equal to dragon head height around the emblem.

---

## File Hygiene

Place drafts and finals here:

```
assets/
logo/
guardian-dragon-lineart.svg
guardian-dragon-mascot.svg         # final or near-final
guardian-dragon-mascot-icon.svg    # small icon variant
drafts/                             # generated explorations
guardian_v001_seed12345_a01.png
guardian_v001_seed12345_a02.png
...
```

---

## Ethical & Licensing Notes

- Keep outputs **non-violent, family-safe, and culturally respectful**.  
- Avoid copying any specific commercial or franchise designs.  
- Prefer **original silhouettes**; use references only for general style guidance.  
- When contributors generate images, request a note confirming they hold rights to contribute them under the project's norms.

---

## Quick Commands (local tooling examples)

> Example rasterization + vectorization (adjust for your environment):

```bash
# Rasterize the SVG lineart for img2img (2048x2048)
rsvg-convert -w 2048 -h 2048 assets/logo/guardian-dragon-lineart.svg \
  -o assets/logo/drafts/lineart_2048.png

# Vectorize a selected PNG result back to SVG (threshold tune as needed)
potrace assets/logo/drafts/guardian_pick.png --svg -o assets/logo/drafts/guardian_pick.svg
```

---

## Review Criteria (internal)

* **Guardian, not predator** (emotion check).
* **Asymmetric grace** (no geometric ring).
* **Readable silhouette** at small sizes.
* **Materials feel natural** (bamboo/hemp), not sci-fi metal.
* **Color warmth** consistent with our palette.
* **Pairs well with wordmark** in UI mockups.

---

*This file is intentionally generic and avoids naming any third-party tools or websites. Adapt freely.*
