import os
import time
import shutil
import subprocess
from playwright.sync_api import sync_playwright

ffmpeg_exe = r"C:\Users\zbook\AppData\Local\CapCut\Apps\9.5.0.4050\ffmpeg.exe"
clips_dir = r"docs\video_assets\raw_clips"
os.makedirs(clips_dir, exist_ok=True)

def convert_webm_to_mp4(webm_path, mp4_path):
    print(f"Converting {webm_path} -> {mp4_path}...")
    subprocess.run([
        ffmpeg_exe, "-y", "-i", webm_path,
        "-c:v", "h264_mf",
        "-pix_fmt", "yuv420p",
        mp4_path
    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Done: {mp4_path} ({os.path.getsize(mp4_path):,} bytes)")

def record_clip(name, actions_func):
    temp_dir = os.path.join(clips_dir, f"temp_{name}")
    os.makedirs(temp_dir, exist_ok=True)

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            record_video_dir=temp_dir,
            record_video_size={"width": 412, "height": 892},
            viewport={"width": 412, "height": 892},
            device_scale_factor=2,
        )
        page = context.new_page()
        
        try:
            actions_func(page)
        finally:
            page.close()
            context.close()
            browser.close()

    # Find recorded webm
    webms = [f for f in os.listdir(temp_dir) if f.endswith(".webm")]
    if webms:
        src = os.path.join(temp_dir, webms[0])
        dst = os.path.join(clips_dir, f"{name}.mp4")
        convert_webm_to_mp4(src, dst)
    
    shutil.rmtree(temp_dir)

# ==============================================================================
# CLIP 1: Overview & Navigasi Katalog
# ==============================================================================
def clip_01_actions(page):
    print("Recording Clip 1: Overview Katalog...")
    page.goto("http://localhost:8089/#/daftar")
    page.wait_for_timeout(2500)

    # Scroll down to see products
    page.mouse.wheel(0, 300)
    page.wait_for_timeout(1500)
    page.mouse.wheel(0, 400)
    page.wait_for_timeout(1500)
    page.mouse.wheel(0, -700)
    page.wait_for_timeout(1500)

    # Click categories
    # Category chips are horizontal
    # Click 'Makanan & Minuman'
    page.mouse.click(140, 260)
    page.wait_for_timeout(1500)

    # Click 'Pakaian & Tekstil'
    page.mouse.click(260, 260)
    page.wait_for_timeout(1500)

    # Click 'Semua'
    page.mouse.click(50, 260)
    page.wait_for_timeout(1500)

    # Click Tab Analitik (Bottom Nav middle)
    page.mouse.click(206, 860)
    page.wait_for_timeout(2500)

    # Click Tab Riwayat (Bottom Nav right)
    page.mouse.click(340, 860)
    page.wait_for_timeout(2500)

    # Return to Tab Katalog
    page.mouse.click(70, 860)
    page.wait_for_timeout(2000)

# ==============================================================================
# CLIP 2: Demo CRUD & Validasi Form Gagal
# ==============================================================================
def clip_02_actions(page):
    print("Recording Clip 2: Demo CRUD & Validasi...")
    page.goto("http://localhost:8089/#/daftar")
    page.wait_for_timeout(2000)

    # 1. Click FAB Tambah Produk (Bottom Right)
    page.mouse.click(340, 810)
    page.wait_for_timeout(2000)

    # 2. Click Simpan langsung saat form kosong -> Validasi Gagal!
    page.mouse.click(206, 860)
    page.wait_for_timeout(2500)

    # 3. Fill SKU valid
    page.mouse.click(150, 180)
    page.keyboard.type("PRD-005")
    page.wait_for_timeout(1000)

    # 4. Fill Nama
    page.mouse.click(150, 260)
    page.keyboard.type("Kopi Robusta Banyumas 250g")
    page.wait_for_timeout(1000)

    # 5. Scroll down to price section
    page.mouse.wheel(0, 300)
    page.wait_for_timeout(1000)

    # 6. Fill Harga Beli = 30000
    page.mouse.click(100, 480)
    page.keyboard.type("30000")
    page.wait_for_timeout(1000)

    # 7. Fill Harga Jual = 20000 (Gagal validasi: Jual <= Beli)
    page.mouse.click(280, 480)
    page.keyboard.type("20000")
    page.wait_for_timeout(1500)

    # Trigger validation by clicking save
    page.mouse.click(206, 860)
    page.wait_for_timeout(2000)

    # 8. Fix Harga Jual = 45000 (Valid! Margin +50.0%)
    page.mouse.click(280, 480)
    page.keyboard.press("Control+A")
    page.keyboard.press("Backspace")
    page.keyboard.type("45000")
    page.wait_for_timeout(1500)

    # 9. Fill Stok = 25
    page.mouse.wheel(0, 250)
    page.wait_for_timeout(800)
    page.mouse.click(100, 710)
    page.keyboard.type("25")
    page.wait_for_timeout(1200)

    # 10. Click Simpan ke Katalog Produk
    page.mouse.click(206, 860)
    page.wait_for_timeout(3000)

    # 11. Search: Cari 'Robusta'
    page.mouse.click(150, 215)
    page.keyboard.type("Robusta")
    page.wait_for_timeout(2500)

    # Clear search
    page.keyboard.press("Control+A")
    page.keyboard.press("Backspace")
    page.wait_for_timeout(2000)

# ==============================================================================
# CLIP 3: Demo Fitur Khusus Paket 9
# ==============================================================================
def clip_03_actions(page):
    print("Recording Clip 3: Fitur Khusus Paket 9...")
    page.goto("http://localhost:8089/#/daftar")
    page.wait_for_timeout(2500)

    # Highlight Bento Card (Fitur Khusus 3: Total Nilai Stok)
    page.mouse.move(206, 140)
    page.wait_for_timeout(2500)

    # Highlight Fitur Khusus 2: Toggle Sort Harga Jual (Termurah <-> Termahal)
    # Click Sort Button around x=350, y=215
    page.mouse.click(350, 215)
    page.wait_for_timeout(2500)
    # Click again to toggle back
    page.mouse.click(350, 215)
    page.wait_for_timeout(2500)

    # Highlight Fitur Khusus 1: Margin Keuntungan (%) Otomatis
    page.mouse.wheel(0, 280)
    page.wait_for_timeout(2500)
    page.mouse.wheel(0, 200)
    page.wait_for_timeout(2500)
    page.mouse.wheel(0, -480)
    page.wait_for_timeout(1500)

# ==============================================================================
# CLIP 4: Bukti Persistensi Data (Cold Restart)
# ==============================================================================
def clip_04_actions(page):
    print("Recording Clip 4: Bukti Persistensi...")
    page.goto("http://localhost:8089/#/daftar")
    page.wait_for_timeout(2500)

    # Simulate Full Refresh / Re-open App
    print("Reloading page completely (Simulating App Re-open)...")
    page.reload()
    page.wait_for_timeout(3500)

    # Show data is still intact from Hive
    page.mouse.wheel(0, 300)
    page.wait_for_timeout(2000)
    page.mouse.wheel(0, -300)
    page.wait_for_timeout(1500)

if __name__ == "__main__":
    record_clip("clip_01_overview_katalog", clip_01_actions)
    record_clip("clip_02_demo_crud_dan_validasi", clip_02_actions)
    record_clip("clip_03_demo_fitur_khusus_paket9", clip_03_actions)
    record_clip("clip_04_bukti_persistensi", clip_04_actions)
    print("All demo clips recorded and converted successfully!")
