import subprocess
import os
import sys
import shutil

DRAFT_NAME = "CPMK 03 - Paket 9 - Iqsan Azhar - H1D024009"
DRAFT_DIR = rf"C:\Users\zbook\AppData\Local\CapCut\User Data\Projects\com.lveditor.draft\{DRAFT_NAME}"
VOICE_DIR = r"C:\Users\zbook\Downloads\ss an cpmk 3 vs code\voice"

print(f"=== REBUILDING CAPCUT PROJECT WITH SYNCED AUDIO & VIDEO: {DRAFT_NAME} ===")

# 1. Bersihkan draft lama jika ada, lalu inisialisasi ulang 16:9
if os.path.exists(DRAFT_DIR):
    shutil.rmtree(DRAFT_DIR, ignore_errors=True)

init_cmd = "capcut init \"" + DRAFT_NAME + "\" --ratio 16:9"
res = subprocess.run(init_cmd, shell=True, capture_output=True, text=True)
if res.returncode != 0:
    print("Init error:", res.stderr or res.stdout)
    sys.exit(1)
print("Draft initialized cleanly.")

# 2. Definisikan durasi persis tiap bagian suara ElevenLabs
# Total = 308.19 detik (~5 menit 8 detik - Memenuhi syarat >= 5 menit)
voice_parts = [
    {"num": 1, "start": 0.0,    "dur": 34.28, "title": "CPMK 03 - Paket 9: Katalog UMKM | Iqsan Azhar - H1D024009"},
    {"num": 2, "start": 34.28,  "dur": 41.10, "title": "Bagian 2: Struktur Arsitektur 6 Lapisan MVC"},
    {"num": 3, "start": 75.38,  "dur": 43.55, "title": "Bagian 3: Model, TypeAdapter Hive & Service"},
    {"num": 4, "start": 118.93, "dur": 45.41, "title": "Bagian 4: Controller (.obs, Sorting, Validasi)"},
    {"num": 5, "start": 164.34, "dur": 38.43, "title": "Bagian 5: Antarmuka View (GetView & Obx)"},
    {"num": 6, "start": 202.77, "dur": 39.40, "title": "Bagian 6: Demo CRUD Lengkap & Validasi Form"},
    {"num": 7, "start": 242.17, "dur": 32.29, "title": "Bagian 7: 3 Fitur Khusus Paket 9"},
    {"num": 8, "start": 274.46, "dur": 33.73, "title": "Bagian 8: Bukti Persistensi Data & Unit Test"},
]

# 3. Definisikan visual segments yang tersinkronisasi sempurna dengan audio
visual_segments = [
    # Bagian 1 (0.0s -> 34.28s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\mockups\real_splash.png", "w": 824, "h": 1784, "start": 0.0, "dur": 12.0},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\mockups\real_katalog.png", "w": 1080, "h": 2400, "start": 12.0, "dur": 22.28},
    
    # Bagian 2 (34.28s -> 75.38s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\01_tree_mvc_architecture.png", "w": 2872, "h": 1698, "start": 34.28, "dur": 41.10},
    
    # Bagian 3 (75.38s -> 118.93s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\02_produk_model.png", "w": 2880, "h": 1700, "start": 75.38, "dur": 13.62},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\02b_produk_adapter.png", "w": 2880, "h": 1704, "start": 89.0, "dur": 14.00},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\03_hive_service.png", "w": 2880, "h": 1704, "start": 103.0, "dur": 15.93},
    
    # Bagian 4 (118.93s -> 164.34s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\04_produk_controller.png", "w": 2876, "h": 1702, "start": 118.93, "dur": 25.07},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\05_app_pages.png", "w": 2878, "h": 1702, "start": 144.0, "dur": 20.34},
    
    # Bagian 5 (164.34s -> 202.77s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\06_produk_list_view.png", "w": 2880, "h": 1698, "start": 164.34, "dur": 17.66},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\raw_clips\clip_01_overview_katalog.mp4", "w": 1080, "h": 2400, "start": 182.0, "dur": 20.77},
    
    # Bagian 6 (202.77s -> 242.17s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\raw_clips\clip_02_demo_crud_dan_validasi.mp4", "w": 1080, "h": 2400, "start": 202.77, "dur": 33.23},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\mockups\real_form.png", "w": 1080, "h": 2400, "start": 236.0, "dur": 6.17},
    
    # Bagian 7 (242.17s -> 274.46s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\raw_clips\clip_03_demo_fitur_khusus_paket9.mp4", "w": 1080, "h": 2400, "start": 242.17, "dur": 18.33},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\mockups\real_analitik.png", "w": 1080, "h": 2400, "start": 260.5, "dur": 13.96},
    
    # Bagian 8 (274.46s -> 308.19s)
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\raw_clips\clip_04_bukti_persistensi.mp4", "w": 1080, "h": 2400, "start": 274.46, "dur": 12.54},
    {"file": r"D:\Pemrograman Mobile\cpmk3\docs\video_assets\code_slices\07_flutter_test_passed.png", "w": 2766, "h": 1482, "start": 287.0, "dur": 21.19},
]

# 4. Masukkan seluruh aset video & gambar
print("\n--- INSERTING VISUAL SEGMENTS ---")
for i, seg in enumerate(visual_segments):
    print(f"[{i+1}/{len(visual_segments)}] Visual: {os.path.basename(seg['file'])} ({seg['start']:.2f}s -> {seg['start']+seg['dur']:.2f}s)")
    cmd = [
        "capcut", "add-video", DRAFT_DIR,
        seg["file"],
        f"{seg['start']:.2f}",
        f"{seg['dur']:.2f}",
        "--width", str(seg["w"]),
        "--height", str(seg["h"])
    ]
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if r.returncode != 0:
        print("  Error:", r.stderr or r.stdout)

# 5. Masukkan trek audio voiceover ElevenLabs
print("\n--- INSERTING VOICEOVER AUDIO TRACKS ---")
for vp in voice_parts:
    v_file = os.path.join(VOICE_DIR, f"{vp['num']}.mp3")
    print(f"Audio Part {vp['num']}: {v_file} ({vp['start']:.2f}s -> {vp['start']+vp['dur']:.2f}s)")
    cmd = [
        "capcut", "add-audio", DRAFT_DIR,
        v_file,
        f"{vp['start']:.2f}",
        f"{vp['dur']:.2f}",
        "--volume", "1.0"
    ]
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if r.returncode != 0:
        print("  Error adding audio:", r.stderr or r.stdout)

# 6. Masukkan teks judul per bagian
print("\n--- INSERTING SECTION TITLE BANNERS ---")
for vp in voice_parts:
    t_cmd = [
        "capcut", "add-text", DRAFT_DIR,
        f"{vp['start']:.2f}",
        "8.0", # Tampil selama 8 detik awal bagian
        vp["title"],
        "--color", "#0052FF",
        "--font-size", "10"
    ]
    subprocess.run(t_cmd, shell=True, capture_output=True, text=True)

# 7. Registrasi ulang draft ke root_meta_info.json
print("\n--- AUTO-REGISTER DRAFT TO HOMESCREEN ---")
reg_cmd = ["capcut", "register", DRAFT_DIR, "--apply"]
res_reg = subprocess.run(reg_cmd, shell=True, capture_output=True, text=True)
print("Register output:", res_reg.stdout.strip())

# 8. Linting pemeriksaan timeline
print("\n--- TIMELINE LINT CHECK ---")
lint_cmd = ["capcut", "lint", DRAFT_DIR]
res_lint = subprocess.run(lint_cmd, shell=True, capture_output=True, text=True)
print("Lint output:", res_lint.stdout.strip() if res_lint.stdout else res_lint.stderr)

print("\n=== COMPLETE CAPCUT DRAFT READY FOR EXPORT & REVIEW! ===")
