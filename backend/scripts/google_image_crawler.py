"""Crawl Google Images for a specific shop's products.

Reads shop-specific templates from shop_templates/ directory,
searches Google Images for each product, extracts image URLs
from the HTML, and downloads them locally.
"""

import os
import sys
import json
import glob
import time
import re
import urllib.parse
from playwright.sync_api import sync_playwright

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SHOP_TPL_DIR = os.path.join(SCRIPT_DIR, "shop_templates")
CATEGORY_TPL = os.path.join(SCRIPT_DIR, "product_templates.json")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "..", "test_scripts", "crawled_images")
PROFILE_DIR = os.path.join(SCRIPT_DIR, "..", "test_scripts", "chrome_profile")
IMAGES_PER_PRODUCT = 5

SKIP_DOMAINS = [
    "gstatic.com", "google.com", "googleapis.com",
    "youtube.com", "ggpht.com", "googleusercontent.com",
]


def load_shop_products(shop_index: int) -> list:
    """Load products for the given shop index."""
    for path in glob.glob(os.path.join(SHOP_TPL_DIR, "*.json")):
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if str(shop_index) in data:
            return data[str(shop_index)]
    # Fallback: load from category template
    with open(CATEGORY_TPL, "r", encoding="utf-8") as f:
        categories = json.load(f)
    category_map = {
        1: "electronics", 2: "fashion", 3: "beauty",
        4: "home", 5: "sports", 6: "food"}
    cat = category_map.get(shop_index)
    return categories.get(cat, []) if cat else []


def extract_urls_from_html(html: str, count: int) -> list:
    """Extract original image URLs from page HTML."""
    pattern = r'https://[^\s"\'<>]+\.(?:jpg|jpeg|png|webp)'
    raw = re.findall(pattern, html)
    seen, result = set(), []
    for url in raw:
        if url in seen or len(url) < 40:
            continue
        seen.add(url)
        if any(d in url for d in SKIP_DOMAINS):
            continue
        result.append(url)
    return result[:count]


def crawl_shop(shop_index: int):
    """Crawl images for all products in a shop."""
    products = load_shop_products(shop_index)
    if not products:
        print(f"No products for shop #{shop_index}")
        return

    shop_dir = os.path.join(OUTPUT_DIR, f"shop_{shop_index:02d}")
    os.makedirs(shop_dir, exist_ok=True)

    with sync_playwright() as pw:
        ctx = pw.chromium.launch_persistent_context(
            user_data_dir=PROFILE_DIR, headless=False,
            args=["--disable-blink-features=AutomationControlled",
                   "--no-first-run", "--no-default-browser-check"],
            viewport={"width": 1280, "height": 800},
            locale="vi-VN")
        page = ctx.pages[0] if ctx.pages else ctx.new_page()

        page.goto("https://www.google.com/search?q=test&udm=2",
                   wait_until="domcontentloaded")
        print("Waiting 5s for CAPTCHA...")
        time.sleep(5)

        for idx, product in enumerate(products, start=1):
            name = product["name"]
            print(f"\n[{idx}/{len(products)}] {name}")
            try:
                q = urllib.parse.quote(name)
                page.goto(
                    f"https://www.google.com/search?q={q}&udm=2",
                    wait_until="networkidle", timeout=15000)
                time.sleep(2)
            except Exception as e:
                print(f"  Nav error: {e}")
                continue

            urls = extract_urls_from_html(
                page.content(), IMAGES_PER_PRODUCT)
            print(f"  Found {len(urls)} URLs")

            prod_dir = os.path.join(shop_dir, f"product_{idx:02d}")
            os.makedirs(prod_dir, exist_ok=True)
            for i, url in enumerate(urls, start=1):
                try:
                    r = page.request.get(url, timeout=10000)
                    if r.ok and len(r.body()) > 3000:
                        ct = r.headers.get("content-type", "")
                        ext = "png" if "png" in ct else (
                            "webp" if "webp" in ct else "jpg")
                        p = os.path.join(prod_dir, f"img_{i}.{ext}")
                        with open(p, "wb") as f:
                            f.write(r.body())
                        print(f"  ✓ img_{i}.{ext}")
                except Exception as ex:
                    print(f"  ✗ {str(ex)[:50]}")
            time.sleep(1)
        ctx.close()
    print(f"\nDone! Images saved → {shop_dir}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--shop", type=int, required=True)
    crawl_shop(p.parse_args().shop)
