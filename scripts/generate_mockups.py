import os
from PIL import Image, ImageDraw

def composite_mockup(screenshot_path, frame_path, out_path):
    frame = Image.open(frame_path).convert("RGBA")
    screenshot = Image.open(screenshot_path).convert("RGBA")

    # Screen cutout area in frame: x=58, y=68, w=472, h=1062
    screen_w = 472
    screen_h = 1062

    # Resize screenshot with high quality resampling
    resized_screen = screenshot.resize((screen_w, screen_h), Image.Resampling.LANCZOS)

    # Rounded corners on screen corners to match phone bezel
    mask = Image.new("L", (screen_w, screen_h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (screen_w, screen_h)], radius=42, fill=255)

    # Base canvas
    base = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    base.paste(resized_screen, (58, 68), mask=mask)

    # Paste frame on top
    final_mockup = Image.alpha_composite(base, frame)
    final_mockup.save(out_path, "PNG")
    print(f"Generated mockup: {out_path}")

def generate_grid(mockup_paths, out_grid_path):
    mockups = [Image.open(p).convert("RGBA") for p in mockup_paths]
    
    target_h = 760
    aspect = mockups[0].width / mockups[0].height
    target_w = int(target_h * aspect)

    scaled_mockups = [m.resize((target_w, target_h), Image.Resampling.LANCZOS) for m in mockups]

    gap = 20
    padding_x = 32
    padding_y = 32

    total_w = padding_x * 2 + (target_w * len(scaled_mockups)) + (gap * (len(scaled_mockups) - 1))
    total_h = target_h + padding_y * 2

    grid = Image.new("RGBA", (total_w, total_h), (255, 255, 255, 0))

    cur_x = padding_x
    for m in scaled_mockups:
        grid.paste(m, (cur_x, padding_y), mask=m)
        cur_x += target_w + gap

    grid.save(out_grid_path, "PNG")
    print(f"Generated showcase grid: {out_grid_path}")

def main():
    frame_path = "docs/phone_frame_clean.png"
    out_dir = "docs/mockups"
    os.makedirs(out_dir, exist_ok=True)

    screens = [
        ("docs/raw_screenshots/00_splash.png", "docs/mockups/mockup_splash.png"),
        ("docs/raw_screenshots/01_dashboard.png", "docs/mockups/mockup_dashboard.png"),
        ("docs/raw_screenshots/03_katalog_list.png", "docs/mockups/mockup_katalog.png"),
        ("docs/raw_screenshots/02_form_tambah.png", "docs/mockups/mockup_form.png"),
    ]

    for scr, out in screens:
        if os.path.exists(scr):
            composite_mockup(scr, frame_path, out)

    # Generate Panoramic Grid with 4 mockups
    mockup_files = [out for _, out in screens if os.path.exists(out)]
    if len(mockup_files) >= 3:
        generate_grid(mockup_files, "docs/app_showcase_grid.png")

if __name__ == "__main__":
    main()
