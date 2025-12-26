"""
Verify that chapter4 was uploaded successfully
"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase (check if already initialized)
try:
    app = firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

CLASS_ID = "class 8"
SUBJECT_ID = "science"
CHAPTER_ID = "chapter4"

print("=" * 70)
print("VERIFICATION: Checking chapter4 upload status")
print("=" * 70)

# Check if chapter4 exists
chapter_ref = (db.collection("classes")
                .document(CLASS_ID)
                .collection("subjects")
                .document(SUBJECT_ID)
                .collection("chapters")
                .document(CHAPTER_ID))

chapter_doc = chapter_ref.get()

if chapter_doc.exists:
    print(f"\nSUCCESS! chapter4 exists")
    print("-" * 70)
    
    chapter_data = chapter_doc.to_dict()
    print(f"Chapter Name: {chapter_data.get('chapter_name', 'N/A')}")
    print(f"Notes URL: {chapter_data.get('notesURL', 'N/A')}")
    print(f"Summary: {chapter_data.get('summary', 'N/A')[:50]}..." if chapter_data.get('summary') else "Summary: (empty)")
    
    # Check chunks
    chunks_ref = chapter_ref.collection("chunks")
    chunks = list(chunks_ref.stream())
    
    print(f"\nChunks created: {len(chunks)}")
    if len(chunks) > 0:
        print("First 5 chunks:")
        for i, chunk in enumerate(chunks[:5], 1):
            chunk_data = chunk.to_dict()
            text_preview = chunk_data.get('text', '')[:60]
            print(f"  {chunk.id}: {text_preview}...")
    
    print("\n" + "=" * 70)
    print(f"SUCCESS! chapter4 uploaded with {len(chunks)} chunks")
    print("=" * 70)
    print("\nVerify in Firebase Console:")
    print(f"classes -> class 8 -> subjects -> science -> chapters -> chapter4")
    
else:
    print("\nERROR: chapter4 was not created!")
    print("The upload script may have failed.")
