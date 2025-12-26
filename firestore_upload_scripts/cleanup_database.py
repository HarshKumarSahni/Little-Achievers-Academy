"""
PHASE 1: Database Cleanup Script
- Delete 'mathametics' subject
- Rename English chapters 'ch1' → 'chapter 1', 'ch2' → 'chapter 2'
"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
try:
    app = firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

CLASS_ID = "class 8"

print("=" * 70)
print("DATABASE CLEANUP")
print("=" * 70)

# ============================================================================
# TASK 1: Delete 'mathametics' subject
# ============================================================================
print("\n1. Deleting 'mathametics' subject...")

mathametics_ref = (db.collection("classes")
                    .document(CLASS_ID)
                    .collection("subjects")
                    .document("mathametics"))

# Check if exists
if mathametics_ref.get().exists:
    # Delete all subcollections first (chapters if any)
    chapters = mathametics_ref.collection("chapters").stream()
    for ch in chapters:
        ch.reference.delete()
        print(f"   Deleted chapter: {ch.id}")
    
    # Delete the subject document
    mathametics_ref.delete()
    print("   ✓ Deleted 'mathametics' subject")
else:
    print("   ⚠️  'mathametics' not found (may already be deleted)")

# ============================================================================
# TASK 2: Rename English chapters
# ============================================================================
print("\n2. Renaming English chapters...")

english_ref = (db.collection("classes")
                .document(CLASS_ID)
                .collection("subjects")
                .document("english")
                .collection("chapters"))

# Rename 'ch1' → 'chapter 1'
ch1_ref = english_ref.document("ch1")
ch1_doc = ch1_ref.get()

if ch1_doc.exists:
    ch1_data = ch1_doc.to_dict()
    
    # Create new 'chapter 1' document with same data
    chapter1_ref = english_ref.document("chapter 1")
    chapter1_ref.set(ch1_data)
    print("   ✓ Created 'chapter 1'")
    
    # Delete old 'ch1' document
    ch1_ref.delete()
    print("   ✓ Deleted 'ch1'")
else:
    print("   ⚠️  'ch1' not found")

# Rename 'ch2' → 'chapter 2'
ch2_ref = english_ref.document("ch2")
ch2_doc = ch2_ref.get()

if ch2_doc.exists:
    ch2_data = ch2_doc.to_dict()
    
    # Update chapter_name field to proper format
    if ch2_data.get('chapter_name') == 'ch2':
        ch2_data['chapter_name'] = 'Chapter 2'
    
    # Create new 'chapter 2' document
    chapter2_ref = english_ref.document("chapter 2")
    chapter2_ref.set(ch2_data)
    print("   ✓ Created 'chapter 2'")
    
    # Delete old 'ch2' document
    ch2_ref.delete()
    print("   ✓ Deleted 'ch2'")
else:
    print("   ⚠️  'ch2' not found")

print("\n" + "=" * 70)
print("CLEANUP COMPLETE!")
print("=" * 70)
print("\nVerify in Firebase Console:")
print(f"  classes → {CLASS_ID} → subjects → english → chapters")
print("  Should see: 'chapter 1' and 'chapter 2'")
print(f"\n  'mathametics' subject should be deleted")
