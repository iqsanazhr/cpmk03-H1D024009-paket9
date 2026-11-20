import os
import time
import subprocess

adb = os.path.expandvars(r"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe")
ffmpeg = r"C:\Users\zbook\AppData\Local\CapCut\Apps\9.5.0.4050\ffmpeg.exe"
clips_dir = r"docs\video_assets\raw_clips"
os.makedirs(clips_dir, exist_ok=True)

def tap(x, y):
    subprocess.run([adb, "-s", "emulator-5554", "shell", "input", "tap", str(x), str(y)])

def swipe(x1, y1, x2, y2, duration_ms=400):
    subprocess.run([adb, "-s", "emulator-5554", "shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration_ms)])

def type_text(text):
    # Escape spaces as %s for adb shell input text
    formatted = text.replace(" ", "%s")
    subprocess.run([adb, "-s", "emulator-5554", "shell", "input", "text", formatted])

def keyevent(code):
    subprocess.run([adb, "-s", "emulator-5554", "shell", "input", "keyevent", str(code)])

def record_clip(name, duration_sec, action_fn):
    print(f"\n=== RECORDING {name} (Duration: {duration_sec}s) ===")
    sdcard_path = f"/sdcard/{name}.mp4"
    local_raw = os.path.join(clips_dir, f"{name}_raw.mp4")
    local_final = os.path.join(clips_dir, f"{name}.mp4")

    # Start adb screenrecord
    rec_proc = subprocess.Popen([
        adb, "-s", "emulator-5554", "shell", "screenrecord",
        "--size", "1080x2400",
        "--bit-rate", "6000000",
        "--time-limit", str(duration_sec),
        sdcard_path
    ])

    time.sleep(1.0)
    start_t = time.time()
    try:
        action_fn()
    except Exception as e:
        print(f"Error during action: {e}")

    # Wait for screenrecord to finish
    elapsed = time.time() - start_t
    remaining = duration_sec - elapsed
    if remaining > 0:
        time.sleep(remaining + 0.5)
    rec_proc.wait()

    # Pull from emulator
    print("Pulling video from emulator...")
    subprocess.run([adb, "-s", "emulator-5554", "pull", sdcard_path, local_raw], stdout=subprocess.DEVNULL)
    subprocess.run([adb, "-s", "emulator-5554", "shell", "rm", sdcard_path], stdout=subprocess.DEVNULL)

    # Re-encode with FFmpeg (h264_mf for standard 1080p MP4)
    print("Re-encoding video with FFmpeg...")
    subprocess.run([
        ffmpeg, "-y", "-i", local_raw,
        "-c:v", "h264_mf",
        "-pix_fmt", "yuv420p",
        local_final
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if os.path.exists(local_raw):
        os.remove(local_raw)

    print(f"SUCCESS: {local_final} ({os.path.getsize(local_final):,} bytes)")

# ==============================================================================
# CLIP 1: Overview Katalog & Tab Switching
# ==============================================================================
def clip_01_actions():
    # Ensure on katalog page
    subprocess.run([adb, "-s", "emulator-5554", "shell", "am", "start", "-n", "com.example.cpmk3_paket9/.MainActivity"])
    time.sleep(2)

    # Scroll down smoothly
    swipe(540, 1800, 540, 900, 600)
    time.sleep(1.5)
    swipe(540, 1800, 540, 900, 600)
    time.sleep(1.5)

    # Scroll back up to Bento Card
    swipe(540, 900, 540, 1900, 600)
    time.sleep(1.5)
    swipe(540, 900, 540, 1900, 600)
    time.sleep(1.5)

    # Filter Kategori chips:
    # 'Makanan & Minuman' around x=420, y=1230
    tap(420, 1230)
    time.sleep(1.5)
    # 'Pakaian & Tekstil' around x=800, y=1230
    tap(800, 1230)
    time.sleep(1.5)
    # 'Semua' around x=120, y=1230
    tap(120, 1230)
    time.sleep(1.5)

    # Switch to Analitik Tab (Bottom Nav: x=540, y=2270)
    tap(540, 2270)
    time.sleep(2.0)
    swipe(540, 1600, 540, 1100, 500)
    time.sleep(1.5)
    swipe(540, 1100, 540, 1600, 500)
    time.sleep(1.0)

    # Switch to Riwayat Tab (Bottom Nav: x=880, y=2270)
    tap(880, 2270)
    time.sleep(2.0)

    # Back to Katalog Tab (Bottom Nav: x=200, y=2270)
    tap(200, 2270)
    time.sleep(1.5)

# ==============================================================================
# CLIP 2: Demo CRUD & Validasi Form Gagal
# ==============================================================================
def clip_02_actions():
    # Start on katalog page
    subprocess.run([adb, "-s", "emulator-5554", "shell", "am", "start", "-n", "com.example.cpmk3_paket9/.MainActivity"])
    time.sleep(1.5)

    # 1. Tap FAB Tambah Produk (x=850, y=2050)
    tap(850, 2050)
    time.sleep(1.5)

    # 2. Tap Simpan langsung -> Muncul validasi merah kosong!
    tap(540, 2300)
    time.sleep(2.0)

    # 3. Tap SKU field (x=400, y=490) -> ketik PRD-005
    tap(400, 490)
    time.sleep(0.5)
    type_text("PRD-005")
    time.sleep(1.0)

    # 4. Tap Nama field (x=400, y=715) -> ketik Kopi Robusta Banyumas 250g
    tap(400, 715)
    time.sleep(0.5)
    type_text("Kopi Robusta Banyumas 250g")
    time.sleep(1.0)

    # Hide keyboard
    keyevent(4) # BACK key
    time.sleep(0.8)

    # Scroll down to Harga section
    swipe(540, 1700, 540, 950, 500)
    time.sleep(1.0)

    # 5. Tap Harga Beli (x=280, y=1050) -> ketik 30000
    tap(280, 1050)
    time.sleep(0.5)
    type_text("30000")
    time.sleep(1.0)

    # 6. Tap Harga Jual (x=710, y=1050) -> ketik 20000 (Gagal validasi: Jual <= Beli)
    tap(710, 1050)
    time.sleep(0.5)
    type_text("20000")
    time.sleep(1.0)

    # Hide keyboard
    keyevent(4)
    time.sleep(0.5)

    # Tap Simpan -> Muncul error: "Harga jual harus > harga beli (modal)!"
    tap(540, 2300)
    time.sleep(2.0)

    # 7. Perbaiki Harga Jual -> 45000 (Valid!)
    tap(710, 1050)
    time.sleep(0.5)
    # Clear and type 45000
    for _ in range(6):
        keyevent(67) # KEYCODE_DEL
    time.sleep(0.3)
    type_text("45000")
    time.sleep(1.0)

    # Hide keyboard
    keyevent(4)
    time.sleep(0.5)

    # Scroll down to Stok section
    swipe(540, 1800, 540, 1200, 500)
    time.sleep(0.8)

    # 8. Tap Stok (x=240, y=1680) -> ketik 25
    tap(240, 1680)
    time.sleep(0.5)
    type_text("25")
    time.sleep(1.0)

    # Hide keyboard
    keyevent(4)
    time.sleep(0.5)

    # 9. Tap Simpan ke Katalog Produk
    tap(540, 2300)
    time.sleep(2.5)

    # 10. Search: Tap search bar (x=350, y=1100) -> ketik Robusta
    tap(350, 1100)
    time.sleep(0.5)
    type_text("Robusta")
    time.sleep(2.0)

    # Clear search
    for _ in range(8):
        keyevent(67)
    time.sleep(0.5)
    keyevent(4) # Hide keyboard
    time.sleep(1.5)

    # 11. Hapus Produk: Scroll ke bawah
    swipe(540, 1800, 540, 1200, 500)
    time.sleep(1.0)
    # Tap titik tiga menu pada produk Kopi Robusta (around x=980, y=1900)
    tap(980, 1900)
    time.sleep(1.2)
    # Tap 'Hapus Produk' pada bottom sheet (around x=540, y=2250)
    tap(540, 2250)
    time.sleep(1.2)
    # Konfirmasi Hapus pada Get.dialog (Tombol 'Hapus' merah di kanan: x=750, y=1340)
    tap(750, 1340)
    time.sleep(2.0)

# ==============================================================================
# CLIP 3: Demo Fitur Khusus Paket 9
# ==============================================================================
def clip_03_actions():
    subprocess.run([adb, "-s", "emulator-5554", "shell", "am", "start", "-n", "com.example.cpmk3_paket9/.MainActivity"])
    time.sleep(2.0)

    # 1. Sorot Fitur Khusus 3: Bento Card Valuasi Total Stok (Rp 3.160.000)
    time.sleep(2.5)

    # 2. Sorot Fitur Khusus 2: Toggle Sort Harga Jual (x=900, y=1100)
    # Tap 'Termurah' -> berubah jadi 'Termahal'
    tap(900, 1100)
    time.sleep(2.5)
    # Tap lagi 'Termahal' -> kembali 'Termurah'
    tap(900, 1100)
    time.sleep(2.5)

    # 3. Sorot Fitur Khusus 1: Margin Keuntungan (%) Otomatis
    swipe(540, 1800, 540, 1200, 500)
    time.sleep(2.5)
    swipe(540, 1800, 540, 1200, 500)
    time.sleep(2.5)
    swipe(540, 1200, 540, 1800, 500)
    time.sleep(1.5)

# ==============================================================================
# CLIP 4: Bukti Persistensi Data (Cold Restart)
# ==============================================================================
def clip_04_actions():
    # Ensure app is running
    subprocess.run([adb, "-s", "emulator-5554", "shell", "am", "start", "-n", "com.example.cpmk3_paket9/.MainActivity"])
    time.sleep(2.0)

    # Force Stop (Cold Close)
    print("Force stopping app (Simulating Cold Close)...")
    subprocess.run([adb, "-s", "emulator-5554", "shell", "am", "force-stop", "com.example.cpmk3_paket9"])
    time.sleep(2.0)

    # Relaunch from cold start
    print("Relaunching app from cold start...")
    subprocess.run([adb, "-s", "emulator-5554", "shell", "am", "start", "-n", "com.example.cpmk3_paket9/.MainActivity"])
    # Splash screen will display for ~1.3s then fade into Katalog
    time.sleep(3.5)

    # Scroll down to prove all Hive data is intact
    swipe(540, 1800, 540, 1100, 500)
    time.sleep(2.0)
    swipe(540, 1100, 540, 1800, 500)
    time.sleep(1.5)

if __name__ == "__main__":
    record_clip("clip_01_overview_katalog", 22, clip_01_actions)
    record_clip("clip_02_demo_crud_dan_validasi", 35, clip_02_actions)
    record_clip("clip_03_demo_fitur_khusus_paket9", 20, clip_03_actions)
    record_clip("clip_04_bukti_persistensi", 16, clip_04_actions)
    print("\nALL 4 EMULATOR CLIPS RECORDED AND CONVERTED TO NATIVE MP4!")
