"""
Quick test script to add sample chunks to science/chapter1
This will verify the upload mechanism works without needing a PDF.
"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Configuration
CLASS_ID = "class 8"
SUBJECT_ID = "science"
CHAPTER_ID = "chapter1"  # Use existing chapter1

# Sample chunks (no PDF needed for testing)
SAMPLE_CHUNKS = [
    "Metals are elements that are generally hard, lustrous, malleable and ductile. They are good conductors of heat and electricity.",
    "Non-metals are usually brittle and are poor conductors of heat and electricity. They are neither malleable nor ductile.",
    "Some elements show properties of both metals and non-metals. These elements are called metalloids. Examples include silicon and germanium."
]

print("=" * 70)
print("🧪 TEST: Adding Sample Chunks to science/chapter1")
print("=" * 70)

# Get chapter reference
chapter_ref = (db.collection("classes")
                .document(CLASS_ID)
                .collection("subjects")
                .document(SUBJECT_ID)
                .collection("chapters")
                .document(CHAPTER_ID))

print(f"\n📍 Target: classes/{CLASS_ID}/subjects/{SUBJECT_ID}/chapters/{CHAPTER_ID}")
print(f"\n📝 Creating {len(SAMPLE_CHUNKS)} sample chunks...")

# Create chunks
for i, chunk_text in enumerate(SAMPLE_CHUNKS, start=1):
    chunk_ref = chapter_ref.collection("chunks").document(f"chunk{i}")
    chunk_ref.set({
        "chunkNumber": i,
        "text": chunk_text
    })
    print(f"   ✓ Created chunk{i}")

print("\n" + "=" * 70)
print("✅ SUCCESS! Chunks added to science/chapter1")
print("=" * 70)
print("\n🔍 Verify in Firebase Console:")
print(f"   classes → class 8 → subjects → science → chapters → chapter1 → chunks")
print("\nYou should see 3 chunks (chunk1, chunk2, chunk3)")
