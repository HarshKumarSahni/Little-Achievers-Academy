"""
Example: Upload Multiple Chapters at Once

This script shows how to upload multiple chapters in a batch.
Modify the CHAPTERS list with your data.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import pdfplumber

# -----------------------------
# FIREBASE INITIALIZATION
# -----------------------------
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# -----------------------------
# PDF EXTRACTION
# -----------------------------
def extract_pdf(path):
    text = ""
    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            extracted = page.extract_text()
            if extracted:
                text += extracted + "\n"
    return text

# -----------------------------
# CHUNKING LOGIC
# -----------------------------
def chunk_text(text, chunk_size=400):
    words = text.split()
    chunks = []
    for i in range(0, len(words), chunk_size):
        chunk = " ".join(words[i:i+chunk_size])
        chunks.append(chunk)
    return chunks

# -----------------------------
# UPLOAD CHAPTER & CHUNKS
# -----------------------------
def upload_chapter(class_id, subject_id, chapter_id, chapter_name, pdf_path, summary=""):
    print(f"\n📘 Uploading Chapter: {chapter_name}")
    
    try:
        # Extract text
        chapter_text = extract_pdf(pdf_path)
        
        # Chunk text
        chunks = chunk_text(chapter_text)
        
        # Firestore document path
        chapter_ref = (db.collection("classes")
                        .document(class_id)
                        .collection("subjects")
                        .document(subject_id)
                        .collection("chapters")
                        .document(chapter_id)
                    )
        
        # Upload chapter metadata
        chapter_ref.set({
            "chapter_name": chapter_name,
            "notesURL": "",
            "summary": summary,
        })
        
        # Upload chunks
        for i, chunk in enumerate(chunks, start=1):
            chapter_ref.collection("chunks").document(f"chunk{i}").set({
                "chunkNumber": i,
                "text": chunk,
            })
            print(f"  ✓ Uploaded chunk {i}/{len(chunks)}")
        
        print(f"  🎉 {chapter_name} - Complete! ({len(chunks)} chunks)")
        return True
        
    except Exception as e:
        print(f"  ❌ Error uploading {chapter_name}: {e}")
        return False

# -----------------------------
# MAIN EXECUTION
# -----------------------------
if __name__ == "__main__":
    
    # Configuration for Class 8 Science
    # IMPORTANT: Use EXACT document IDs from your Firestore console
    CLASS_ID = "class 8"        # ← Use EXACT name with SPACE (not "class_8")
    SUBJECT_ID = "science"      # ← EXACT subject document name
    
    # List of chapters to upload
    # Format: (chapter_id, chapter_name, pdf_filename, summary)
    CHAPTERS = [
        (
            "chapter1",
            "Crop Production and Management",
            "chapter1.pdf",
            "This chapter covers the basics of crop production including preparation of soil, sowing, irrigation, and harvesting."
        ),
        (
            "chapter2",
            "Microorganisms: Friend and Foe",
            "chapter2.pdf",
            "Learn about microorganisms, their types, uses, and harmful effects. Covers bacteria, viruses, fungi, and algae."
        ),
        (
            "chapter3",
            "Synthetic Fibres and Plastics",
            "chapter3.pdf",
            "Explores synthetic fibers like polyester, nylon, and acrylic, along with plastics and their properties."
        ),
        (
            "chapter4",
            "Materials: Metals and Non-Metals",
            "chapter4.pdf",
            "Understanding the properties of metals and non-metals, their uses, and chemical reactions."
        ),
        # Add more chapters here...
    ]
    
    print("="*60)
    print("🔍 FIRESTORE BASE PATH:")
    print(f"   classes/{CLASS_ID}/subjects/{SUBJECT_ID}/chapters/")
    print("="*60)
    print("\n⚠️  Verify this matches your Firebase Console structure!")
    print("   Document names must be EXACT (case-sensitive, with spaces).\n")
    print("="*60)
    print(f"🚀 Starting Batch Upload: {CLASS_ID} - {SUBJECT_ID}")
    print(f"📚 Total Chapters: {len(CHAPTERS)}")
    print("="*60)
    
    success_count = 0
    failed_count = 0
    
    for chapter_id, chapter_name, pdf_path, summary in CHAPTERS:
        result = upload_chapter(
            CLASS_ID, 
            SUBJECT_ID, 
            chapter_id, 
            chapter_name, 
            pdf_path,
            summary
        )
        
        if result:
            success_count += 1
        else:
            failed_count += 1
    
    print("\n" + "="*60)
    print(f"✅ Successfully uploaded: {success_count} chapters")
    print(f"❌ Failed: {failed_count} chapters")
    print("="*60)
    print("\n🎊 Batch upload complete!")
