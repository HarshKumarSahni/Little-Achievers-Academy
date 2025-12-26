"""
🔍 FIRESTORE DIAGNOSTIC TOOL
This script runs all diagnostics to find why your upload might not be working.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

# -----------------------------
# INITIALIZE FIREBASE
# -----------------------------
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_app = firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("✅ Firebase initialized successfully\n")
except Exception as e:
    print(f"❌ CRITICAL ERROR: Could not initialize Firebase: {e}")
    exit(1)

# -----------------------------
# CONFIGURATION (MATCH YOUR SCRIPT)
# -----------------------------
CLASS_ID = "class 8"
SUBJECT_ID = "science"
CHAPTER_ID = "chapter4"

print("=" * 70)
print("🔍 FIRESTORE DIAGNOSTIC TOOL")
print("=" * 70)

# -----------------------------
# DIAGNOSTIC 1: Verify Firebase Project
# -----------------------------
print("\n📋 DIAGNOSTIC 1: Firebase Project Connection")
print("-" * 70)
print(f"✓ Connected to Project ID: {firebase_app.project_id}")
print(f"✓ App Name: {firebase_app.name}")
print("\n⚠️  VERIFY: Does this match your Firebase Console project ID?")
print("   Go to Firebase Console → Project Settings → Project ID")

# -----------------------------
# DIAGNOSTIC 2: Verify Working Directory
# -----------------------------
print("\n📋 DIAGNOSTIC 2: Working Directory & Service Account Key")
print("-" * 70)
print(f"✓ Current Directory: {os.getcwd()}")
print(f"✓ Service Account Key Exists: {os.path.isfile('serviceAccountKey.json')}")

if not os.path.isfile('serviceAccountKey.json'):
    print("❌ ERROR: serviceAccountKey.json not found!")
    print("   Download it from Firebase Console → Project Settings → Service Accounts")
    exit(1)

# -----------------------------
# DIAGNOSTIC 3: Verify Upload Path
# -----------------------------
print("\n📋 DIAGNOSTIC 3: Firestore Upload Path")
print("-" * 70)
print(f"✓ Script will write to:")
print(f"   classes/{CLASS_ID}/subjects/{SUBJECT_ID}/chapters/{CHAPTER_ID}")
print("\n⚠️  VERIFY: Does this EXACTLY match your Firebase Console path?")
print("   Including spaces, capitalization, and special characters!")

# -----------------------------
# DIAGNOSTIC 4: Check if 'classes' collection exists
# -----------------------------
print("\n📋 DIAGNOSTIC 4: Check 'classes' Collection")
print("-" * 70)
try:
    classes_docs = db.collection("classes").limit(10).stream()
    class_ids = [doc.id for doc in classes_docs]
    
    if class_ids:
        print(f"✓ Found {len(class_ids)} class document(s):")
        for idx, class_id in enumerate(class_ids, 1):
            print(f"   {idx}. '{class_id}'")
        
        if CLASS_ID in class_ids:
            print(f"\n✅ SUCCESS: Found '{CLASS_ID}' document")
        else:
            print(f"\n❌ ERROR: '{CLASS_ID}' NOT FOUND in classes collection!")
            print(f"   Available: {class_ids}")
            print(f"   Check for typos, spaces, or case differences!")
    else:
        print("❌ ERROR: 'classes' collection is EMPTY or doesn't exist!")
        
except Exception as e:
    print(f"❌ ERROR querying 'classes' collection: {e}")

# -----------------------------
# DIAGNOSTIC 5: Check 'subjects' subcollection
# -----------------------------
print("\n📋 DIAGNOSTIC 5: Check 'subjects' Subcollection")
print("-" * 70)
try:
    subjects_docs = db.collection("classes").document(CLASS_ID).collection("subjects").stream()
    subject_ids = [doc.id for doc in subjects_docs]
    
    if subject_ids:
        print(f"✓ Found {len(subject_ids)} subject(s) in '{CLASS_ID}':")
        for idx, subject_id in enumerate(subject_ids, 1):
            print(f"   {idx}. '{subject_id}'")
        
        if SUBJECT_ID in subject_ids:
            print(f"\n✅ SUCCESS: Found '{SUBJECT_ID}' subject")
        else:
            print(f"\n❌ ERROR: '{SUBJECT_ID}' NOT FOUND!")
            print(f"   Available subjects: {subject_ids}")
    else:
        print(f"❌ ERROR: No subjects found in '{CLASS_ID}'")
        
except Exception as e:
    print(f"❌ ERROR querying subjects: {e}")

# -----------------------------
# DIAGNOSTIC 6: Check 'chapters' subcollection
# -----------------------------
print("\n📋 DIAGNOSTIC 6: Check 'chapters' Subcollection")
print("-" * 70)
try:
    chapters_ref = (db.collection("classes")
                     .document(CLASS_ID)
                     .collection("subjects")
                     .document(SUBJECT_ID)
                     .collection("chapters"))
    
    chapters_docs = chapters_ref.stream()
    chapter_ids = [doc.id for doc in chapters_docs]
    
    if chapter_ids:
        print(f"✓ Found {len(chapter_ids)} chapter(s) in '{SUBJECT_ID}':")
        for idx, chapter_id in enumerate(chapter_ids, 1):
            print(f"   {idx}. '{chapter_id}'")
    else:
        print(f"⚠️  WARNING: No chapters found in '{CLASS_ID}/{SUBJECT_ID}'")
        print(f"   The upload script will CREATE '{CHAPTER_ID}' when run")
        
except Exception as e:
    print(f"❌ ERROR querying chapters: {e}")

# -----------------------------
# DIAGNOSTIC 7: Detailed Subject Analysis
# -----------------------------
print("\n📋 DIAGNOSTIC 7: Detailed Subject Structure Analysis")
print("-" * 70)

try:
    all_subjects = db.collection("classes").document(CLASS_ID).collection("subjects").stream()
    
    for subject_doc in all_subjects:
        subject_id = subject_doc.id
        subject_data = subject_doc.to_dict()
        
        print(f"\n📘 Subject: '{subject_id}'")
        print(f"   Fields: {list(subject_data.keys())}")
        
        # Check for chapters
        chapters = (db.collection("classes")
                     .document(CLASS_ID)
                     .collection("subjects")
                     .document(subject_id)
                     .collection("chapters")
                     .stream())
        
        chapter_list = [ch.id for ch in chapters]
        
        if chapter_list:
            print(f"   ✓ Has 'chapters' subcollection with {len(chapter_list)} chapter(s):")
            for ch_id in chapter_list:
                print(f"      - {ch_id}")
        else:
            print(f"   ✗ No 'chapters' subcollection found")
            
except Exception as e:
    print(f"❌ ERROR in subject analysis: {e}")

# -----------------------------
# DIAGNOSTIC 8: Search for 'chunks' globally
# -----------------------------
print("\n📋 DIAGNOSTIC 8: Global Search for 'chunks'")
print("-" * 70)
print("⚠️  Note: Firestore doesn't support global text search via SDK")
print("   Please manually search in Firebase Console:")
print("   Firebase Console → Firestore → Search icon (top) → Type 'chunks'")

# -----------------------------
# DIAGNOSTIC 9: Test Write Permissions
# -----------------------------
print("\n📋 DIAGNOSTIC 9: Test Write Permissions")
print("-" * 70)
try:
    test_ref = db.collection("_diagnostic_test").document("test_doc")
    test_ref.set({"test": "write", "timestamp": firestore.SERVER_TIMESTAMP})
    print("✓ Write test SUCCESSFUL - you have write permissions")
    
    # Clean up test document
    test_ref.delete()
    print("✓ Test document cleaned up")
    
except Exception as e:
    print(f"❌ WRITE PERMISSION ERROR: {e}")
    print("   Check your service account IAM permissions!")

# -----------------------------
# SUMMARY & RECOMMENDATIONS
# -----------------------------
print("\n" + "=" * 70)
print("📊 DIAGNOSTIC SUMMARY")
print("=" * 70)

print(f"""
Current Configuration:
- Firebase Project: {firebase_app.project_id}
- Target Path: classes/{CLASS_ID}/subjects/{SUBJECT_ID}/chapters/{CHAPTER_ID}
- Service Account Key: {'✓ Found' if os.path.isfile('serviceAccountKey.json') else '✗ Missing'}

Next Steps:
1. Verify the Firebase Project ID matches your Console
2. Confirm the path above matches EXACTLY what you see in Firestore
3. If all diagnostics pass, run your upload script
4. If diagnostics fail, fix the reported errors first

⚠️  IMPORTANT: Document IDs are case-sensitive and must match EXACTLY!
   "class 8" ≠ "class_8" ≠ "Class 8"
""")

print("=" * 70)
print("✅ Diagnostics Complete!")
print("=" * 70)
