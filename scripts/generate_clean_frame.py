import os
from PIL import Image, ImageDraw, ImageFilter

def create_clean_iphone_frame():
    # Overall frame size: 588 x 1194
    # Screen area: (58, 68) to (530, 1130) -> size (472, 1062)
    width, height = 588, 1194
    screen_rect = (58, 68, 530, 1130)
    screen_radius = 42

    # Outer phone body dimensions
    phone_rect = (38, 48, 550, 1150)
    phone_radius = 58

    frame = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)

    # 1. Outer Titanium Bezel Shadow (Subtle drop shadow)
    shadow_mask = Image.new("L", (width, height), 0)
    sdraw = ImageDraw.Draw(shadow_mask)
    sdraw.rounded_rectangle(phone_rect, radius=phone_radius, fill=100)
    shadow = shadow_mask.filter(ImageFilter.GaussianBlur(16))
    
    shadow_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    shadow_img.paste((0, 0, 0, 90), mask=shadow)

    # 2. Outer Titanium Metal Edge (2-tone brushed titanium)
    metal_draw = ImageDraw.Draw(frame)
    # Dark titanium body
    metal_draw.rounded_rectangle(phone_rect, radius=phone_radius, fill=(28, 30, 34, 255))
    # Subtle metal highlight ring
    metal_draw.rounded_rectangle(phone_rect, radius=phone_radius, outline=(70, 74, 82, 255), width=3)
    
    # Inner black bezel
    bezel_rect = (48, 58, 540, 1140)
    metal_draw.rounded_rectangle(bezel_rect, radius=phone_radius - 8, fill=(10, 11, 13, 255))

    # 3. Transparent Screen Cutout
    # We clear the screen area so it is 100% transparent (alpha = 0)
    cutout_mask = Image.new("L", (width, height), 0)
    cdraw = ImageDraw.Draw(cutout_mask)
    cdraw.rounded_rectangle(screen_rect, radius=screen_radius, fill=255)

    # Subtract screen cutout from frame
    frame_rgba = frame.copy()
    f_pixels = frame_rgba.load()
    c_pixels = cutout_mask.load()
    for y in range(height):
        for x in range(width):
            if c_pixels[x, y] == 255:
                f_pixels[x, y] = (0, 0, 0, 0)

    # 4. Add Dynamic Island & Speaker on top
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)

    # Dynamic Island Pill: centered at x=294, y=86
    di_w, di_h = 106, 28
    di_x1 = 294 - (di_w // 2)
    di_y1 = 80
    di_x2 = di_x1 + di_w
    di_y2 = di_y1 + di_h
    odraw.rounded_rectangle((di_x1, di_y1, di_x2, di_y2), radius=14, fill=(10, 11, 13, 255))

    # Camera sensor subtle reflection
    odraw.ellipse((di_x2 - 22, di_y1 + 6, di_x2 - 8, di_y2 - 6), fill=(18, 22, 30, 255))
    odraw.ellipse((di_x2 - 17, di_y1 + 10, di_x2 - 13, di_y2 - 10), fill=(26, 38, 55, 255))

    # Combine shadow, frame, and dynamic island
    final_frame = Image.alpha_composite(shadow_img, frame_rgba)
    final_frame = Image.alpha_composite(final_frame, overlay)

    final_frame.save("docs/phone_frame_clean.png", "PNG")
    print("Created clean iPhone frame: docs/phone_frame_clean.png")

if __name__ == "__main__":
    create_clean_iphone_frame()
