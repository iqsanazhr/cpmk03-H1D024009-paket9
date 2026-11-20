import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

def main():
    web_dir = os.path.abspath("build/web")
    port = 8089
    server_proc = subprocess.Popen(
        [sys.executable, "-m", "http.server", str(port), "--directory", web_dir],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    time.sleep(1.5)

    out_dir = os.path.abspath("docs/raw_screenshots")
    os.makedirs(out_dir, exist_ok=True)

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                viewport={"width": 393, "height": 852},
                device_scale_factor=2,
                is_mobile=True,
                has_touch=True,
            )
            page = context.new_page()

            # Wait for app load
            page.goto(f"http://localhost:{port}/", wait_until="networkidle")
            page.wait_for_selector("flt-glass-pane, flutter-view, canvas", timeout=15000)
            time.sleep(2.5)

            # 1. Capture Splash screen explicitly
            page.goto(f"http://localhost:{port}/#/splash")
            time.sleep(0.5)
            splash_path = os.path.join(out_dir, "00_splash.png")
            page.screenshot(path=splash_path)
            print(f"Saved splash: {splash_path}")

            # 2. Capture Dashboard Top (Valuation + Chart + Asset Rows)
            page.goto(f"http://localhost:{port}/#/daftar", wait_until="networkidle")
            time.sleep(2)
            dash_path = os.path.join(out_dir, "01_dashboard.png")
            page.screenshot(path=dash_path)
            print(f"Saved dashboard: {dash_path}")

            # 3. Collapse chart by clicking chevron button (x=355, y=105) to reveal Katalog Produk
            page.mouse.click(355, 105)
            time.sleep(1.0)
            katalog_path = os.path.join(out_dir, "03_katalog_list.png")
            page.screenshot(path=katalog_path)
            print(f"Saved katalog list: {katalog_path}")

            # 4. Capture Form / Trade Screen
            page.goto(f"http://localhost:{port}/#/form", wait_until="networkidle")
            time.sleep(1.8)

            # Tap keypad numbers
            page.mouse.click(65, 725)   # 1
            time.sleep(0.2)
            page.mouse.click(196, 825)  # 8
            time.sleep(0.2)
            page.mouse.click(65, 875)   # 000
            time.sleep(0.5)

            form_path = os.path.join(out_dir, "02_form_tambah.png")
            page.screenshot(path=form_path)
            print(f"Saved form: {form_path}")

            browser.close()
    finally:
        server_proc.terminate()
        print("Done capturing.")

if __name__ == "__main__":
    main()
