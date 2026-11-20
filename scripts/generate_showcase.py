import os
from PIL import Image, ImageDraw, ImageFilter, ImageOps

def create_phone_frame(screen_path, frame_w=370, frame_h=770, corner_r=48, bezel=14):
    screen = Image.open(screen_path).convert("RGBA")
    
    # Target screen size inside frame
    inner_w = frame_w - (bezel * 2)
    inner_h = frame_h - (bezel * 2)
    
    # Resize and crop screen
    screen_fitted = ImageOps.fit(screen, (inner_w, inner_h), Image.Resampling.LANCZOS)
    
    # Mask for inner screen rounded corners
    screen_mask = Image.new("L", (inner_w, inner_h), 0)
    draw_screen = ImageDraw.Draw(screen_mask)
    draw_screen.rounded_rectangle([0, 0, inner_w, inner_h], radius=corner_r - bezel, fill=255)
    
    screen_fitted.putalpha(screen_mask)
    
    # Create outer frame (Titanium dark border)
    phone = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(phone)
    
    # Outer dark chassis
    draw.rounded_rectangle([0, 0, frame_w, frame_h], radius=corner_r, fill=(18, 20, 24, 255), outline=(50, 54, 62, 255), width=3)
    
    # Inner bezel
    draw.rounded_rectangle([bezel-2, bezel-2, frame_w - bezel + 2, frame_h - bezel + 2], radius=corner_r - bezel + 2, fill=(10, 11, 14, 255))
    
    # Paste screen
    phone.paste(screen_fitted, (bezel, bezel), screen_fitted)
    
    # Dynamic Island / Notch
    island_w, island_h = 96, 22
    island_x = (frame_w - island_w) // 2
    island_y = bezel + 10
    draw.rounded_rectangle([island_x, island_y, island_x + island_w, island_y + island_h], radius=11, fill=(0, 0, 0, 255))
    
    # Camera dot reflection
    draw.ellipse([island_x + island_w - 20, island_y + 6, island_x + island_w - 10, island_y + 16], fill=(15, 20, 35, 255))
    
    return phone

print("Generating smartphone mockups with current real screenshots...")
screens = [
    ("docs/mockups/real_splash.png", "docs/mockups/mockup_splash.png"),
    ("docs/mockups/real_katalog.png", "docs/mockups/mockup_dashboard.png"),
    ("docs/mockups/real_form.png", "docs/mockups/mockup_form.png"),
    ("docs/mockups/real_analitik.png", "docs/mockups/mockup_katalog.png"),
]

framed_images = []
for src, dst in screens:
    phone = create_phone_frame(src)
    phone.save(dst, "PNG")
    framed_images.append(phone)
    print(f"Saved {dst}")

# Generate app_showcase_grid.png (Panoramic 4 phones)
grid_w = 1620
grid_h = 824
grid = Image.new("RGBA", (grid_w, grid_h), (255, 255, 255, 0))

# Spacing
phone_w, phone_h = framed_images[0].size
gap = (grid_w - (phone_w * 4)) // 5
y_offset = (grid_h - phone_h) // 2

for i, p in enumerate(framed_images):
    x = gap + i * (phone_w + gap)
    grid.paste(p, (x, y_offset), p)

grid.save("docs/app_showcase_grid.png", "PNG")
print("Saved docs/app_showcase_grid.png successfully!")
