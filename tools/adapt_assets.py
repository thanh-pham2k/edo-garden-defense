#!/usr/bin/env python3
"""Adapt raw asset sheets from inbox/ into normalized RGBA sprites in assets/sprites/
and move processed raw files to archive/.
"""

import glob
import os
import re
import shutil
import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INBOX_DIR = os.path.join(ROOT, "inbox")
ARCHIVE_DIR = os.path.join(ROOT, "archive")
SPRITES_DIR = os.path.join(ROOT, "assets", "sprites")

HOLE_BY_DARK_OUTLINE = {
    "props_architecture_pack.png",
    "props_nature_pack.png",
    "props_details_pack.png",
    "prop_komainu_dash.png",
    "tre_no_idle.png",
    "tre_no_attack.png",
    "chua_lanh_idle.png",
    "chua_lanh_heal.png",
    "samurai_ma_walk.png",
    "samurai_ma_attack.png",
    "samurai_ma_die.png",
    "dao_tien_idle.png",
    "dao_tien_attack.png",
    "than_den_idle.png",
    "than_den_produce.png",
    "oni_lon_walk.png",
    "oni_lon_attack.png",
    "oni_lon_die.png",
    "kappa_walk.png",
    "kappa_attack.png",
    "kappa_die.png",
    "obs_rock.png",
    "obs_spike_barricade.png",
    "obs_wood_fence.png",
    "obs_crate.png",
    "obs_haystack.png",
    "obs_sake_barrel.png",
    "items_gems_currency.png",
}

UI_PRESERVE_INTERIOR = {
    "ui_hud_cards_pack.png",
    "ui_buttons_pack.png",
    "ui_panels_scrolls_pack.png",
    "ui_level_select_pack.png",
}


def resolve_canonical_name(filename: str) -> str:
    m = re.match(r"^\d+-output-file-inbox-([a-z0-9-]+)-png-asset-", filename)
    if m:
        return m.group(1).replace("-", "_") + ".png"
    return filename


def _best_valley(density: np.ndarray, nom: int, win: int, limit: int) -> int:
    lo = max(1, nom - win)
    hi = min(limit - 1, nom + win)
    sub = density[lo:hi]
    if len(sub) == 0:
        return nom
    min_val = int(sub.min())
    # Prefer the midpoint of the widest contiguous valley at min_val (especially 0)
    indices = np.where(sub <= min_val + 1)[0]
    if len(indices) == 0:
        return nom
    # Split into contiguous runs
    splits = np.where(np.diff(indices) > 1)[0] + 1
    runs = np.split(indices, splits)
    # Score runs by length and proximity to nominal
    best_run = max(runs, key=lambda r: (len(r), -abs((lo + int(r.mean())) - nom)))
    return lo + int(round(best_run.mean()))


def find_grid_cuts(arr: np.ndarray, cols: int, rows: int, per_row_cols: bool = False):
    h, w = arr.shape[:2]
    is_fg = (arr.min(axis=2) < 236) | ((arr.max(axis=2) - arr.min(axis=2)) > 20)
    row_density = is_fg.sum(axis=1)

    ys = [0]
    row_win = max(16, int(h / rows * 0.28))
    for r in range(1, rows):
        nom = int(round(r * h / rows))
        ys.append(_best_valley(row_density, nom, row_win, h))
    ys.append(h)

    col_win = max(16, int(w / cols * 0.28))
    if not per_row_cols:
        col_density = is_fg.sum(axis=0)
        xs = [0]
        for c in range(1, cols):
            nom = int(round(c * w / cols))
            xs.append(_best_valley(col_density, nom, col_win, w))
        xs.append(w)
        return [xs for _ in range(rows)], ys

    row_xs = []
    for r in range(rows):
        row_fg = is_fg[ys[r]:ys[r + 1], :]
        col_density = row_fg.sum(axis=0)
        xs = [0]
        for c in range(1, cols):
            nom = int(round(c * w / cols))
            xs.append(_best_valley(col_density, nom, col_win, w))
        xs.append(w)
        row_xs.append(xs)
    return row_xs, ys


def remove_background(cell_rgb: np.ndarray, canonical_name: str) -> np.ndarray:
    h, w = cell_rgb.shape[:2]
    r = cell_rgb[:, :, 0].astype(np.int16)
    g = cell_rgb[:, :, 1].astype(np.int16)
    b = cell_rgb[:, :, 2].astype(np.int16)
    mx = np.maximum(np.maximum(r, g), b)
    mn = np.minimum(np.minimum(r, g), b)
    chroma = mx - mn

    if canonical_name in UI_PRESERVE_INTERIOR:
        bg_cand = (mn >= 240) & (chroma <= 16)
    else:
        bg_cand = (mn >= 237) & (chroma <= 18)

    struct4 = np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]], dtype=np.int32)
    lbl, n = ndimage.label(bg_cand, structure=struct4)

    border_mask = np.zeros_like(bg_cand)
    border_mask[:2, :] = True
    border_mask[-2:, :] = True
    border_mask[:, :2] = True
    border_mask[:, -2:] = True
    border_labels = set(np.unique(lbl[border_mask])) - {0}
    bg = np.isin(lbl, list(border_labels))

    if canonical_name == "fx_stun_stars.png":
        pure = (mn >= 248) & (chroma <= 7)
        plbl, pn = ndimage.label(pure, structure=struct4)
        pborder = set(np.unique(plbl[border_mask])) - {0}
        counts = np.bincount(plbl.ravel())
        for i in range(1, pn + 1):
            if i not in pborder and counts[i] >= 500:
                bg |= (plbl == i)
    elif canonical_name in HOLE_BY_DARK_OUTLINE:
        pure = (mn >= 247) & (chroma <= 8)
        plbl, pn = ndimage.label(pure, structure=struct4)
        pborder = set(np.unique(plbl[border_mask])) - {0}
        counts = np.bincount(plbl.ravel())
        dark = mx < 145
        for i in range(1, pn + 1):
            if i not in pborder and counts[i] >= 80:
                comp = plbl == i
                ring = ndimage.binary_dilation(comp, iterations=2) & (~comp)
                if ring.sum() > 0 and (dark[ring].sum() / ring.sum()) >= 0.45:
                    bg |= comp

    # Soften 1px anti-aliased fringe adjacent to transparent background
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    edge = ndimage.binary_dilation(bg, iterations=1) & (~bg)
    neutral_edge = edge & (chroma <= 22) & (mn >= 205)
    if np.any(neutral_edge):
        mean_val = (r + g + b) / 3.0
        soft_a = np.clip((248.0 - mean_val) / 43.0 * 255.0, 0, 255).astype(np.uint8)
        alpha = np.where(neutral_edge, np.minimum(alpha, soft_a), alpha)

    # Also reduce white halo color bleed on semi-transparent fringe pixels
    rgba = np.dstack([cell_rgb, alpha])
    return rgba


def trim_alpha_bbox(rgba: np.ndarray, alpha_thresh: int = 12):
    ys, xs = np.where(rgba[:, :, 3] > alpha_thresh)
    if len(xs) == 0 or len(ys) == 0:
        return None
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def normalize_sheet(
    cells_rgba,
    cols: int,
    rows: int,
    cell_size: int,
    anchor: str = "bottom-center",
    max_content_ratio: float = 0.88,
    margin_bottom: int = 6,
    uniform_scale: bool = True,
):
    bboxes = [trim_alpha_bbox(c) for c in cells_rgba]
    valid = [(i, b) for i, b in enumerate(bboxes) if b is not None]

    target = int(round(cell_size * max_content_ratio))
    global_scale = 1.0
    if valid and uniform_scale:
        max_w = max(b[2] - b[0] for _, b in valid)
        max_h = max(b[3] - b[1] for _, b in valid)
        global_scale = min(target / max(1, max_w), target / max(1, max_h))

    sheet = Image.new("RGBA", (cols * cell_size, rows * cell_size), (0, 0, 0, 0))
    frames = []
    for idx, cell in enumerate(cells_rgba):
        canvas = Image.new("RGBA", (cell_size, cell_size), (0, 0, 0, 0))
        b = bboxes[idx]
        if b is not None:
            crop = Image.fromarray(cell[b[1]:b[3], b[0]:b[2]])
            cw, ch = crop.size
            if uniform_scale:
                sc = global_scale
            else:
                sc = min(target / max(1, cw), target / max(1, ch))
            nw = max(1, int(round(cw * sc)))
            nh = max(1, int(round(ch * sc)))
            resized = crop.resize((nw, nh), Image.Resampling.LANCZOS)
            if anchor == "bottom-center":
                px = (cell_size - nw) // 2
                py = cell_size - margin_bottom - nh
            else:
                px = (cell_size - nw) // 2
                py = (cell_size - nh) // 2
            canvas.paste(resized, (px, py), resized)
        frames.append(canvas)
        col = idx % cols
        row = idx // cols
        sheet.paste(canvas, (col * cell_size, row * cell_size), canvas)
    return sheet, frames


def extract_cells(img_arr: np.ndarray, cols: int, rows: int, canonical_name: str):
    per_row = canonical_name.endswith("_pack.png") or canonical_name.startswith("items_")
    row_xs, ys = find_grid_cuts(img_arr, cols, rows, per_row_cols=per_row)
    cells = []
    for r in range(rows):
        xs = row_xs[r]
        for c in range(cols):
            sub = img_arr[ys[r]:ys[r + 1], xs[c]:xs[c + 1]]
            cells.append(remove_background(sub, canonical_name))
    return cells


def adapt_tile_sheet(img_arr: np.ndarray, canonical_name: str):
    cols, rows = 3, 2
    row_xs, ys = find_grid_cuts(img_arr, cols, rows, per_row_cols=True)
    tile_size = 128
    sheet = Image.new("RGBA", (cols * tile_size, rows * tile_size), (0, 0, 0, 0))
    tiles = []

    for r in range(rows):
        xs = row_xs[r]
        for c in range(cols):
            idx = r * cols + c
            sub = img_arr[ys[r]:ys[r + 1], xs[c]:xs[c + 1]]
            rgba = remove_background(sub, canonical_name)
            b = trim_alpha_bbox(rgba, alpha_thresh=40)
            if b is None:
                tile = Image.new("RGBA", (tile_size, tile_size), (120, 160, 80, 255))
            else:
                x0, y0, x1, y1 = b
                pw, ph = x1 - x0, y1 - y0
                # Inset 5.5% from tile bbox to trim scalloped dark outer border
                ix = max(2, int(round(pw * 0.055)))
                iy = max(2, int(round(ph * 0.055)))
                core = rgba[y0 + iy:y1 - iy, x0 + ix:x1 - ix]
                # Fill any remaining transparent pixels with nearest solid neighbor
                alpha_ok = core[:, :, 3] > 200
                if not np.all(alpha_ok) and np.any(alpha_ok):
                    _, indices = ndimage.distance_transform_edt(~alpha_ok, return_indices=True)
                    core_rgb = core[:, :, :3][indices[0], indices[1]]
                    core = np.dstack([core_rgb, np.full(core_rgb.shape[:2], 255, dtype=np.uint8)])
                else:
                    core[:, :, 3] = 255
                tile = Image.fromarray(core).resize(
                    (tile_size, tile_size), Image.Resampling.LANCZOS
                )
            tiles.append(tile)
            sheet.paste(tile, (c * tile_size, r * tile_size))

    out_dir = os.path.join(SPRITES_DIR, "tiles")
    sheet.save(os.path.join(out_dir, canonical_name))
    stem = canonical_name[:-4]
    for i, t in enumerate(tiles):
        t.save(os.path.join(out_dir, f"{stem}_{i}.png"))


def save_single_trimmed(rgba: np.ndarray, out_path: str, size: int = 0, anchor: str = "center"):
    b = trim_alpha_bbox(rgba)
    if b is None:
        Image.new("RGBA", (size or 64, size or 64), (0, 0, 0, 0)).save(out_path)
        return
    crop = Image.fromarray(rgba[b[1]:b[3], b[0]:b[2]])
    if size > 0:
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        target = int(round(size * 0.90))
        sc = min(target / max(1, crop.width), target / max(1, crop.height))
        nw, nh = max(1, int(round(crop.width * sc))), max(1, int(round(crop.height * sc)))
        resized = crop.resize((nw, nh), Image.Resampling.LANCZOS)
        px = (size - nw) // 2
        py = (size - nh - int(size * 0.04)) if anchor == "bottom-center" else (size - nh) // 2
        canvas.paste(resized, (px, py), resized)
        canvas.save(out_path)
    else:
        crop.save(out_path)


def adapt_background_sheet(img_arr: np.ndarray, canonical_name: str):
    cols, rows = 2, 2
    row_xs, ys = find_grid_cuts(img_arr, cols, rows, per_row_cols=True)
    panel_w, panel_h = 640, 360
    sheet = Image.new("RGBA", (cols * panel_w, rows * panel_h), (0, 0, 0, 255))
    panels = []

    for r in range(rows):
        xs = row_xs[r]
        for c in range(cols):
            sub = img_arr[ys[r]:ys[r + 1], xs[c]:xs[c + 1]]
            mx = sub.max(axis=2)
            mn = sub.min(axis=2)
            white_mask = (mn >= 242) & ((mx - mn) <= 14)

            sh, sw = sub.shape[:2]
            top = 0
            while top < sh - 10 and white_mask[top, :].mean() >= 0.78:
                top += 1
            bottom = sh
            while bottom > top + 10 and white_mask[bottom - 1, :].mean() >= 0.78:
                bottom -= 1
            left = 0
            while left < sw - 10 and white_mask[:, left].mean() >= 0.78:
                left += 1
            right = sw
            while right > left + 10 and white_mask[:, right - 1].mean() >= 0.78:
                right -= 1

            # Shave 2px anti-aliased edge margin if panel had white gutters
            pad_x = 2 if (right - left) > 40 else 0
            pad_y = 2 if (bottom - top) > 40 else 0
            core = sub[top + pad_y:bottom - pad_y, left + pad_x:right - pad_x]
            rgba_core = np.dstack([core, np.full(core.shape[:2], 255, dtype=np.uint8)])
            panel_img = Image.fromarray(rgba_core).resize(
                (panel_w, panel_h), Image.Resampling.LANCZOS
            )
            panels.append(panel_img)
            sheet.paste(panel_img, (c * panel_w, r * panel_h))

    out_dir = os.path.join(SPRITES_DIR, "backgrounds")
    os.makedirs(out_dir, exist_ok=True)
    sheet.save(os.path.join(out_dir, canonical_name))
    stem = canonical_name[:-4]
    for idx, p_img in enumerate(panels):
        p_img.save(os.path.join(out_dir, f"{stem}_{idx}.png"))


def adapt_all(from_archive: bool = False):
    for sub in ["defenders", "enemies", "tiles", "obstacles", "props", "fx", "ui", "backgrounds", "items"]:
        os.makedirs(os.path.join(SPRITES_DIR, sub), exist_ok=True)
    os.makedirs(ARCHIVE_DIR, exist_ok=True)

    src_dir = ARCHIVE_DIR if from_archive else INBOX_DIR
    raw_files = sorted(glob.glob(os.path.join(src_dir, "*.png")))
    print(f"Found {len(raw_files)} PNG files in {'archive/' if from_archive else 'inbox/'}")

    defenders_icon_sources = {
        "dao_tien_idle.png": "dao_tien",
        "tre_no_idle.png": "tre_no",
        "than_den_idle.png": "than_den",
        "bi_ngo_states.png": "bi_ngo",
        "nam_doc_idle.png": "nam_doc",
        "ho_lo_bang_idle.png": "ho_lo_bang",
        "phao_hoa_arm.png": "phao_hoa",
        "phu_chu_idle_trigger.png": "phu_chu",
        "gio_loc_idle.png": "gio_loc",
        "chua_lanh_idle.png": "chua_lanh",
    }

    enemies_icon_sources = {
        "tieu_yeu_walk.png": "tieu_yeu",
        "oni_nho_walk.png": "oni_nho",
        "nekomata_walk.png": "nekomata",
        "kappa_walk.png": "kappa",
        "tengu_fly.png": "tengu",
        "oni_lon_walk.png": "oni_lon",
        "miko_ma_walk.png": "miko_ma",
        "samurai_ma_walk.png": "samurai_ma",
        "yuki_onna_walk.png": "yuki_onna",
        "ran_ong_walk.png": "ran_ong",
    }

    adapted_count = 0
    for raw_path in raw_files:
        raw_name = os.path.basename(raw_path)
        cname = resolve_canonical_name(raw_name)
        img_arr = np.array(Image.open(raw_path).convert("RGB"))

        # 1. Tiles (8 files)
        if cname.startswith("tile_"):
            adapt_tile_sheet(img_arr, cname)

        # 1b. Obstacles (6 files, 2x2 damage states)
        elif cname.startswith("obs_"):
            out_dir = os.path.join(SPRITES_DIR, "obstacles")
            cells = extract_cells(img_arr, 2, 2, cname)
            sheet, _ = normalize_sheet(cells, 2, 2, 128, anchor="bottom-center", max_content_ratio=0.88)
            sheet.save(os.path.join(out_dir, cname))

        # 1c. Backgrounds (5 files, 2x2 16:9 panels)
        elif cname.startswith("bg_"):
            adapt_background_sheet(img_arr, cname)

        # 2. Defenders (18 files)
        elif cname in {
            "dao_tien_idle.png", "dao_tien_attack.png",
            "tre_no_idle.png", "tre_no_attack.png",
            "than_den_idle.png", "than_den_produce.png",
            "bi_ngo_states.png",
            "nam_doc_idle.png", "nam_doc_attack.png",
            "ho_lo_bang_idle.png", "ho_lo_bang_attack.png",
            "phao_hoa_arm.png", "phao_hoa_explode.png",
            "phu_chu_idle_trigger.png",
            "gio_loc_idle.png", "gio_loc_blow.png",
            "chua_lanh_idle.png", "chua_lanh_heal.png",
        }:
            out_dir = os.path.join(SPRITES_DIR, "defenders")
            if cname == "phao_hoa_explode.png":
                cells = extract_cells(img_arr, 4, 4, cname)
                sheet, frames = normalize_sheet(cells, 4, 4, 192, anchor="center", max_content_ratio=0.92)
            elif cname.endswith("_idle.png") or cname == "bi_ngo_states.png":
                cells = extract_cells(img_arr, 3, 2, cname)
                sheet, frames = normalize_sheet(cells, 3, 2, 128, anchor="bottom-center", max_content_ratio=0.86)
            else:
                cells = extract_cells(img_arr, 4, 3, cname)
                sheet, frames = normalize_sheet(cells, 4, 3, 128, anchor="bottom-center", max_content_ratio=0.88)
            sheet.save(os.path.join(out_dir, cname))
            if cname in defenders_icon_sources:
                did = defenders_icon_sources[cname]
                frames[0].save(os.path.join(out_dir, f"{did}_icon.png"))

        # 3. Enemies (30 files)
        elif cname.endswith(("_walk.png", "_attack.png", "_die.png", "_fly.png", "_summon.png", "_cast.png")):
            out_dir = os.path.join(SPRITES_DIR, "enemies")
            if cname.startswith("oni_lon_"):
                cells = extract_cells(img_arr, 4, 4, cname)
                sheet, frames = normalize_sheet(cells, 4, 4, 192, anchor="bottom-center", max_content_ratio=0.90, margin_bottom=8)
            elif cname.startswith("tengu_"):
                cells = extract_cells(img_arr, 4, 3, cname)
                sheet, frames = normalize_sheet(cells, 4, 3, 128, anchor="center", max_content_ratio=0.88)
            else:
                cells = extract_cells(img_arr, 4, 3, cname)
                sheet, frames = normalize_sheet(cells, 4, 3, 128, anchor="bottom-center", max_content_ratio=0.88)
            sheet.save(os.path.join(out_dir, cname))
            if cname in enemies_icon_sources:
                eid = enemies_icon_sources[cname]
                frames[0].save(os.path.join(out_dir, f"{eid}_icon.png"))

        # 4. Props (4 files)
        elif cname == "props_architecture_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "props")
            cells = extract_cells(img_arr, 2, 2, cname)
            sheet, _ = normalize_sheet(cells, 2, 2, 256, anchor="bottom-center", max_content_ratio=0.92, uniform_scale=False)
            sheet.save(os.path.join(out_dir, cname))
            names = ["prop_edo_house.png", "prop_market_stall.png", "prop_torii.png", "prop_pagoda.png"]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=256, anchor="bottom-center")

        elif cname == "props_nature_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "props")
            cells = extract_cells(img_arr, 2, 2, cname)
            sheet, _ = normalize_sheet(cells, 2, 2, 256, anchor="bottom-center", max_content_ratio=0.92, uniform_scale=False)
            sheet.save(os.path.join(out_dir, cname))
            names = ["prop_sakura_tree.png", "prop_bamboo_grove.png", "prop_red_bridge.png", "prop_lantern.png"]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=256, anchor="bottom-center")

        elif cname == "prop_komainu_dash.png":
            out_dir = os.path.join(SPRITES_DIR, "props")
            cells = extract_cells(img_arr, 4, 3, cname)
            sheet, frames = normalize_sheet(cells, 4, 3, 128, anchor="bottom-center", max_content_ratio=0.88)
            sheet.save(os.path.join(out_dir, cname))
            frames[0].save(os.path.join(out_dir, "prop_komainu.png"))

        elif cname == "props_details_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "props")
            cells = extract_cells(img_arr, 3, 2, cname)
            sheet, _ = normalize_sheet(cells, 3, 2, 128, anchor="bottom-center", max_content_ratio=0.90, uniform_scale=False)
            sheet.save(os.path.join(out_dir, cname))
            names = [
                "prop_banner.png", "prop_hanging_lantern.png", "prop_flower_bush.png",
                "prop_tsukubai.png", "prop_signpost.png", "prop_snow_bonsai.png",
            ]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=128, anchor="bottom-center")

        # 5. FX & Projectiles (11 files)
        elif cname == "projectiles_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "fx")
            cells = extract_cells(img_arr, 3, 2, cname)
            sheet, _ = normalize_sheet(cells, 3, 2, 96, anchor="center", max_content_ratio=0.90, uniform_scale=False)
            sheet.save(os.path.join(out_dir, cname))
            names = [
                "proj_sakura_petal.png", "proj_bamboo_dart.png", "proj_ice_orb.png",
                "proj_poison_glob.png", "proj_spirit_fireball.png", "proj_ofuda_spark.png",
            ]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=96, anchor="center")

        elif cname == "fx_ambient_particles.png":
            out_dir = os.path.join(SPRITES_DIR, "fx")
            cells = extract_cells(img_arr, 3, 2, cname)
            sheet, _ = normalize_sheet(cells, 3, 2, 64, anchor="center", max_content_ratio=0.88, uniform_scale=False)
            sheet.save(os.path.join(out_dir, cname))
            names = [
                "part_sakura_1.png", "part_sakura_2.png", "part_sakura_pair.png",
                "part_bamboo_leaf.png", "part_snowflake.png", "part_spirit_wisp.png",
            ]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=64, anchor="center")

        elif cname == "fx_explosion.png":
            out_dir = os.path.join(SPRITES_DIR, "fx")
            cells = extract_cells(img_arr, 4, 4, cname)
            sheet, _ = normalize_sheet(cells, 4, 4, 192, anchor="center", max_content_ratio=0.92)
            sheet.save(os.path.join(out_dir, cname))

        elif cname.startswith("fx_"):
            out_dir = os.path.join(SPRITES_DIR, "fx")
            cells = extract_cells(img_arr, 4, 3, cname)
            anchor = "bottom-center" if cname == "fx_burn_flame.png" else "center"
            sheet, _ = normalize_sheet(cells, 4, 3, 128, anchor=anchor, max_content_ratio=0.90)
            sheet.save(os.path.join(out_dir, cname))

        # 6. UI (5 files)
        elif cname == "ui_spirit_flame_anim.png":
            out_dir = os.path.join(SPRITES_DIR, "ui")
            cells = extract_cells(img_arr, 3, 2, cname)
            sheet, frames = normalize_sheet(cells, 3, 2, 128, anchor="center", max_content_ratio=0.88)
            sheet.save(os.path.join(out_dir, cname))
            frames[0].save(os.path.join(out_dir, "ui_spirit_flame.png"))

        elif cname == "ui_hud_cards_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "ui")
            cells = extract_cells(img_arr, 3, 2, cname)
            names = [
                "ui_card_ready.png", "ui_card_selected.png", "ui_card_disabled.png",
                "ui_resource_pill.png", "ui_wave_bar.png", "ui_oni_head.png",
            ]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=0)

        elif cname == "ui_buttons_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "ui")
            cells = extract_cells(img_arr, 3, 2, cname)
            names = [
                "ui_btn_speed.png", "ui_btn_pause.png", "ui_btn_play.png",
                "ui_btn_shovel.png", "ui_btn_sound.png", "ui_btn_settings.png",
            ]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=128, anchor="center")

        elif cname == "ui_panels_scrolls_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "ui")
            cells = extract_cells(img_arr, 2, 2, cname)
            save_single_trimmed(cells[0], os.path.join(out_dir, "ui_panel_scroll.png"), size=0)
            save_single_trimmed(cells[1], os.path.join(out_dir, "ui_banner_victory.png"), size=0)
            save_single_trimmed(cells[2], os.path.join(out_dir, "ui_banner_defeat.png"), size=0)
            # Split cell 3 (bottom-right) vertically into green (top) and orange (bottom) buttons
            btn_pair = cells[3]
            mid_y = btn_pair.shape[0] // 2
            save_single_trimmed(btn_pair[:mid_y, :], os.path.join(out_dir, "ui_btn_action_green.png"), size=0)
            save_single_trimmed(btn_pair[mid_y:, :], os.path.join(out_dir, "ui_btn_action_orange.png"), size=0)

        elif cname == "ui_level_select_pack.png":
            out_dir = os.path.join(SPRITES_DIR, "ui")
            cells = extract_cells(img_arr, 3, 2, cname)
            names = [
                "ui_node_unlocked.png", "ui_node_current.png", "ui_node_locked.png",
                "ui_star_earned.png", "ui_star_empty.png", "ui_node_boss.png",
            ]
            for c_rgba, pname in zip(cells, names):
                save_single_trimmed(c_rgba, os.path.join(out_dir, pname), size=128, anchor="center")

        # 7. Items & Upgrades (3 files, 3x2 icons)
        elif cname in {
            "items_gems_currency.png",
            "items_skills_buffs.png",
            "items_garden_upgrades.png",
        }:
            out_dir = os.path.join(SPRITES_DIR, "items")
            cells = extract_cells(img_arr, 3, 2, cname)
            sheet, _ = normalize_sheet(cells, 3, 2, 128, anchor="center", max_content_ratio=0.88, uniform_scale=False)
            sheet.save(os.path.join(out_dir, cname))
            item_map = {
                "items_gems_currency.png": [
                    "item_magatama_jade.png", "item_magatama_ruby.png", "item_koban_coins.png",
                    "item_omamori_charm.png", "item_golden_seed.png", "item_treasure_chest.png",
                ],
                "items_skills_buffs.png": [
                    "skill_fire_fan.png", "skill_taiko_drum.png", "skill_matcha_tea.png",
                    "skill_edo_shield.png", "skill_frost_chime.png", "skill_thunder_scroll.png",
                ],
                "items_garden_upgrades.png": [
                    "upg_watering_can.png", "upg_golden_trowel.png", "upg_festival_lantern.png",
                    "upg_maneki_neko.png", "upg_blessing_mallet.png", "upg_bento_box.png",
                ],
            }
            for c_rgba, iname in zip(cells, item_map[cname]):
                save_single_trimmed(c_rgba, os.path.join(out_dir, iname), size=128, anchor="center")
        else:
            print(f"WARNING: Unhandled file {raw_name} -> {cname}")
            continue

        # Archive processed raw file
        if not from_archive:
            shutil.move(raw_path, os.path.join(ARCHIVE_DIR, raw_name))
        adapted_count += 1
        print(f"Adapted [{adapted_count}/{len(raw_files)}]: {cname}")

    print(f"Done! Adapted {adapted_count} sheets.")


if __name__ == "__main__":
    import sys
    adapt_all(from_archive=("--from-archive" in sys.argv))
