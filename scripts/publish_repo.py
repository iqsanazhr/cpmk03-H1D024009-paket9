import os
import sys
import subprocess
import json
import urllib.request
import urllib.error

sys.path.append(r"C:\Users\zbook\.gemini\config\skills\submission-packager\scripts")
from clean_and_package import get_git_credential_token

def main():
    repo_name = "cpmk03-H1D024009-paket9"
    token = get_git_credential_token()
    if not token:
        print("❌ Error: GitHub token not found in Windows Credential Manager.")
        sys.exit(1)

    print(f"[*] GitHub token retrieved (len: {len(token)}).")

    # 1. Check if repo already exists
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "Antigravity-Publisher"
    }

    url = f"https://api.github.com/repos/iqsanazhr/{repo_name}"
    req = urllib.request.Request(url, headers=headers)

    repo_exists = False
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            print(f"[+] Repo already exists: {data.get('html_url')}")
            repo_exists = True
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"[*] Repo does not exist yet. Creating {repo_name}...")
        else:
            print(f"⚠️ Check repo returned HTTP {e.code}")

    if not repo_exists:
        create_url = "https://api.github.com/user/repos"
        payload = {
            "name": repo_name,
            "private": True,
            "description": "KatalogKu: Katalog Produk UMKM (Paket 9) - Coinbase iOS Edition"
        }
        create_req = urllib.request.Request(
            create_url,
            data=json.dumps(payload).encode("utf-8"),
            headers=headers,
            method="POST"
        )
        try:
            with urllib.request.urlopen(create_req) as resp:
                data = json.loads(resp.read().decode())
                print(f"🎉 Created private repository: {data.get('html_url')}")
        except urllib.error.HTTPError as e:
            err_body = e.read().decode()
            print(f"❌ Failed to create repo: HTTP {e.code} - {err_body}")
            sys.exit(1)

    # 2. Setup git
    git_url = f"https://github.com/iqsanazhr/{repo_name}.git"
    auth_push_url = f"https://{token}@github.com/iqsanazhr/{repo_name}.git"

    subprocess.run(["git", "config", "user.name", "iqsanazhr"], check=True)
    subprocess.run(["git", "config", "user.email", "iqsan17azhar@gmail.com"], check=True)

    # Add all files
    subprocess.run(["git", "add", "."], check=True)

    # Commit if needed
    status = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
    if status.stdout.strip():
        subprocess.run(["git", "commit", "-m", "feat: redesign Coinbase iOS edition, logo blending, wordmark umkmku, and mockup showcase"], check=True)
        print("[+] Changes committed.")
    else:
        print("[*] No changes to commit.")

    # Branch to main
    subprocess.run(["git", "branch", "-M", "main"], check=True)

    # Set remote
    subprocess.run(["git", "remote", "remove", "origin"], check=False)
    subprocess.run(["git", "remote", "add", "origin", git_url], check=True)

    # Push to main
    print(f"[*] Pushing to {git_url} (branch: main)...")
    push_res = subprocess.run(["git", "push", "-u", auth_push_url, "main", "--force"], capture_output=True, text=True)
    if push_res.returncode == 0:
        print(f"🎉 SUCCESS! Code pushed to https://github.com/iqsanazhr/{repo_name}")
    else:
        print(f"⚠️ Push error: {push_res.stderr}")

if __name__ == "__main__":
    main()
