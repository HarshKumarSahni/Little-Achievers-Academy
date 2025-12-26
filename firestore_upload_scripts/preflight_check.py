"""
🔧 PRE-FLIGHT CHECKS
Run this before the main diagnostic to verify basic setup.
"""

import os
import json

print("=" * 70)
print("✈️  PRE-FLIGHT CHECKS")
print("=" * 70)

# Check 1: Service Account Key
print("\n📋 CHECK 1: Service Account Key")
print("-" * 70)

if os.path.isfile("serviceAccountKey.json"):
    print("✓ File exists: serviceAccountKey.json")
    
    # Check if it's the real key or placeholder
    try:
        with open("serviceAccountKey.json", "r") as f:
            key_data = json.load(f)
            
        if "NOTE" in key_data or "INSTRUCTIONS" in key_data:
            print("❌ PLACEHOLDER FILE DETECTED!")
            print("\n⚠️  You need to replace this with your REAL Firebase service account key:")
            print("   1. Go to: https://console.firebase.google.com/")
            print("   2. Select project: little-achievers-academy-demo")
            print("   3. Settings → Service Accounts → Generate new private key")
            print("   4. Download and save as 'serviceAccountKey.json'")
            print("   5. Replace the placeholder file in this folder")
            print("\n❌ CANNOT PROCEED WITHOUT REAL KEY\n")
            exit(1)
        else:
            # Check for required fields
            required_fields = ["type", "project_id", "private_key", "client_email"]
            missing = [f for f in required_fields if f not in key_data]
            
            if missing:
                print(f"❌ Invalid key file - missing fields: {missing}")
                exit(1)
            else:
                print(f"✓ Valid Firebase key for project: {key_data.get('project_id')}")
                print(f"✓ Service account: {key_data.get('client_email')}")
    except json.JSONDecodeError:
        print("❌ File is not valid JSON")
        exit(1)
else:
    print("❌ File not found: serviceAccountKey.json")
    print("\n⚠️  Download it from Firebase Console and place it here!")
    exit(1)

# Check 2: Python packages
print("\n📋 CHECK 2: Required Python Packages")
print("-" * 70)

try:
    import firebase_admin
    print("✓ firebase-admin installed")
except ImportError:
    print("❌ firebase-admin not installed")
    print("   Run: pip install -r requirements.txt")
    exit(1)

try:
    import pdfplumber
    print("✓ pdfplumber installed")
except ImportError:
    print("❌ pdfplumber not installed")
    print("   Run: pip install -r requirements.txt")
    exit(1)

# Check 3: PDF files (optional for diagnostics)
print("\n📋 CHECK 3: PDF Files (Optional)")
print("-" * 70)

pdf_files = ["chapter4.pdf", "paper1.pdf", "paper2.pdf"]
found_pdfs = [f for f in pdf_files if os.path.isfile(f)]

if found_pdfs:
    print(f"✓ Found {len(found_pdfs)} PDF file(s):")
    for pdf in found_pdfs:
        print(f"   - {pdf}")
else:
    print("⚠️  No PDF files found (OK for diagnostics)")
    print("   You'll need PDFs to run upload_chapter_and_papers.py")

print("\n" + "=" * 70)
print("✅ PRE-FLIGHT CHECKS COMPLETE!")
print("=" * 70)
print("\n🚀 You can now run: python diagnostic_tool.py")
