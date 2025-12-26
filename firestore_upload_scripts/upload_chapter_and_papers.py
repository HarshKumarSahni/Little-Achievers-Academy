import firebase_admin
from firebase_admin import credentials, firestore
import pdfplumber
import sys

# Fix encoding for Windows PowerShell
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

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
def upload_chapter(class_id, subject_id, chapter_id, chapter_name, pdf_path):
    print(f"\n📘 Uploading Chapter: {chapter_name}")

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
        "notesURL": "",  # fill later if needed
        "summary": "",
    })

    # Upload chunks
    for i, chunk in enumerate(chunks, start=1):
        chapter_ref.collection("chunks").document(f"chunk{i}").set({
            "chunkNumber": i,
            "text": chunk,
        })
        print(f"✓ Uploaded chunk {i}")

    print("🎉 Chapter upload complete!")


# -----------------------------
# UPLOAD PAST PAPERS
# -----------------------------
def upload_past_papers(class_id, subject_id, chapter_id, pdf_list):
    print("\n📝 Uploading Past Papers...")

    papers_ref = (db.collection("classes")
                    .document(class_id)
                    .collection("subjects")
                    .document(subject_id)
                    .collection("chapters")
                    .document(chapter_id)
                    .collection("past_papers")
                )

    for index, pdf_path in enumerate(pdf_list, start=1):
        paper_text = extract_pdf(pdf_path)

        papers_ref.document(f"paper{index}").set({
            "paperNumber": index,
            "text": paper_text
        })

        print(f"✓ Uploaded paper {index}")

    print("🎉 Past papers uploaded!")


# -----------------------------
# MAIN EXECUTION
# -----------------------------
if __name__ == "__main__":

    # UPDATE THESE VALUES ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    # IMPORTANT: Use EXACT document IDs from your Firestore console
    CLASS_ID = "class 8"        # ← Use EXACT name with SPACE (not "class_8")
    SUBJECT_ID = "science"      # ← EXACT subject document name
    CHAPTER_ID = "chapter4"     # ← EXACT chapter document name
    CHAPTER_NAME = "Materials: Metals and Non-Metals"

    CHAPTER_PDF = "chapter4.pdf"
    PAST_PAPERS = ["paper1.pdf", "paper2.pdf"]

    # Debug: Show the Firestore path being used
    print("="*60)
    print("🔍 FIRESTORE PATH:")
    print(f"   classes/{CLASS_ID}/subjects/{SUBJECT_ID}/chapters/{CHAPTER_ID}")
    print("="*60)
    print("\n⚠️  Make sure this path matches EXACTLY what you see in Firebase Console!")
    print("   Document names are case-sensitive and must include spaces/symbols.\n")

    # Upload chapter text & chunks
    upload_chapter(CLASS_ID, SUBJECT_ID, CHAPTER_ID, CHAPTER_NAME, CHAPTER_PDF)

    # Upload past papers (skip if PDFs don't exist)
    # Uncomment when you have paper1.pdf and paper2.pdf
    # upload_past_papers(CLASS_ID, SUBJECT_ID, CHAPTER_ID, PAST_PAPERS)
    
    print("\n⚠️  Note: Past papers upload skipped (PDFs not provided)")
    print("   Add paper1.pdf and paper2.pdf to upload question papers later")
