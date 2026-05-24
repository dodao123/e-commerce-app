"""Seed products for a specific shop using pre-crawled images.

Logs in as the seller, loads shop-specific product templates,
and uploads the crawled images to the API.
"""

import os
import sys
import json
import glob
import random
import argparse
import requests

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SHOP_TPL_DIR = os.path.join(SCRIPT_DIR, "shop_templates")
CATEGORY_TPL = os.path.join(SCRIPT_DIR, "product_templates.json")
CRAWLED_DIR = os.path.join(SCRIPT_DIR, "..", "test_scripts", "crawled_images")
BASE_URL = "http://localhost:8081"
PASSWORD = "SellerPass123!"


def load_shop_products(shop_index: int, category: str) -> list:
    """Load products for a given shop index.

    First checks shop_templates/shops_*.json for shop-specific data.
    Falls back to category-level product_templates.json.
    """
    for path in glob.glob(os.path.join(SHOP_TPL_DIR, "*.json")):
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if str(shop_index) in data:
            return data[str(shop_index)]
    # Fallback to category template
    with open(CATEGORY_TPL, "r", encoding="utf-8") as f:
        return json.load(f).get(category, [])


def get_crawled_images(shop_index: int, product_index: int) -> list:
    """Return file paths of crawled images for a product."""
    prod_dir = os.path.join(
        CRAWLED_DIR, f"shop_{shop_index:02d}",
        f"product_{product_index:02d}")
    if not os.path.isdir(prod_dir):
        return []
    files = sorted(os.listdir(prod_dir))
    return [
        os.path.join(prod_dir, f) for f in files
        if f.lower().endswith((".jpg", ".jpeg", ".png", ".webp"))
    ]


def upload_image(prod_id, img_path, headers):
    """Upload a single image to the product."""
    with open(img_path, "rb") as f:
        data = f.read()
    if len(data) < 3000:
        return False
    fname = os.path.basename(img_path)
    ctype = "image/jpeg"
    if fname.endswith(".png"):
        ctype = "image/png"
    elif fname.endswith(".webp"):
        ctype = "image/webp"
    files = {"images": (fname, data, ctype)}
    res = requests.post(
        f"{BASE_URL}/api/v1/products/{prod_id}/images",
        files=files, headers=headers)
    return res.status_code == 200


def seed_shop(email: str):
    """Seed all products for the shop belonging to this email."""
    # Extract shop index from email
    shop_index = int(email.split("_")[-1].split("@")[0])

    login = requests.post(
        f"{BASE_URL}/api/v1/auth/login",
        json={"email": email, "password": PASSWORD})
    if login.status_code != 200:
        print(f"Login failed: {login.text}")
        return
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    shop = requests.get(f"{BASE_URL}/api/v1/shops/me", headers=headers)
    if shop.status_code != 200:
        print(f"Shop fetch failed: {shop.text}")
        return
    category = shop.json().get("category", "")
    shop_name = shop.json().get("shop_name", "")
    print(f"Shop #{shop_index}: {shop_name} | {category}")

    templates = load_shop_products(shop_index, category)
    if not templates:
        print("No templates found!")
        return

    success = 0
    for idx, item in enumerate(templates, start=1):
        print(f"\n[{idx}/{len(templates)}] {item['name']}")
        payload = {
            "name": item["name"], "description": item["desc"],
            "category": category, "price": item["price"],
            "stock": random.randint(15, 80),
            "base_shipping_fee": 15000,
            "condition": "new", "images": []}
        res = requests.post(
            f"{BASE_URL}/api/v1/products",
            json=payload, headers=headers)
        if res.status_code != 201:
            print(f"  Error: {res.text}")
            continue
        prod_id = res.json()["id"]

        images = get_crawled_images(shop_index, idx)
        uploaded = 0
        for img in images[:5]:
            if upload_image(prod_id, img, headers):
                uploaded += 1
                print(f"  ✓ {os.path.basename(img)}")
        print(f"  → {uploaded} images")
        success += 1

    print(f"\nDone! {success}/{len(templates)} seeded.")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--email", required=True)
    args = parser.parse_args()
    seed_shop(args.email)
