"""
Upload Previous Year Questions (PYQ) PDF with Embeddings
This script extracts text from PYQ PDFs, chunks them, generates embeddings,
and uploads to Firestore for AI-powered question generation.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import pdfplumber
import sys

# Fix encoding for Windows PowerShell
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

# -----------------------------
# CONFIGURATION
# -----------------------------
CLASS_ID = "class 8"
SUBJECT_ID = "science"
CHAPTER_ID = "chapter4"
PYQ_PDF = "chapter4pyq.pdf"  # Your PYQ PDF file
PYQ_DOC_ID = "pyq2024"  # Document ID for this PYQ

# -----------------------------
# FIREBASE INITIALIZATION
# -----------------------------
try:
    app = firebase_admin.get_app()
    print("Using existing Firebase app")
except ValueError:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    print("Initialized new Firebase app")

db = firestore.client()

# -----------------------------
# PDF EXTRACTION
# -----------------------------
def extract_pdf(path):
    """Extract text from PDF file"""
    text = ""
    try:
        with pdfplumber.open(path) as pdf:
            for page_num, page in enumerate(pdf.pages, 1):
                extracted = page.extract_text()
                if extracted:
                    text += extracted + "\n"
        return text
    except Exception as e:
        print(f"Error extracting PDF: {e}")
        return None

# -----------------------------
# CHUNKING LOGIC
# -----------------------------
def chunk_text(text, chunk_size=400):
    """Split text into chunks of approximately chunk_size words"""
    words = text.split()
    chunks = []
    
    for i in range(0, len(words), chunk_size):
        chunk = " ".join(words[i:i+chunk_size])
        chunks.append(chunk)
    
    return chunks

# -----------------------------
# EMBEDDING GENERATION
# -----------------------------
def generate_embeddings(chunks):
    """Generate embeddings for text chunks using sentence-transformers"""
    try:
        from sentence_transformers import SentenceTransformer
        
        print("\nLoading embedding model (all-MiniLM-L6-v2)...")
        model = SentenceTransformer('all-MiniLM-L6-v2')
        
        print("Generating embeddings for chunks...")
        embeddings = model.encode(chunks, show_progress_bar=True)
        
        return embeddings
        
    except ImportError:
        print("\n" + "="*70)
        print("WARNING: sentence-transformers not installed!")
        print("="*70)
        print("\nTo enable embeddings, run:")
        print("  pip install sentence-transformers")
        print("\nContinuing without embeddings...")
        print("="*70 + "\n")
        return None

# -----------------------------
# UPLOAD TO FIRESTORE
# -----------------------------
def upload_pyq_with_embeddings(pdf_path, class_id, subject_id, chapter_id, doc_id):
    """
    Upload PYQ PDF with chunks and embeddings to Firestore
    
    Structure:
    classes/{class_id}/subjects/{subject_id}/chapters/{chapter_id}/past_papers/{doc_id}_chunk{i}
    """
    
    print("=" * 70)
    print("UPLOADING PYQ TO FIRESTORE")
    print("=" * 70)
    print(f"\nPDF File: {pdf_path}")
    print(f"Target: classes/{class_id}/subjects/{subject_id}/chapters/{chapter_id}/past_papers/")
    print(f"Document ID Prefix: {doc_id}")
    print()
    
    # Step 1: Extract text
    print("Step 1: Extracting text from PDF...")
    text = extract_pdf(pdf_path)
    
    if not text:
        print("ERROR: Failed to extract text from PDF")
        return False
    
    print(f"Extracted {len(text)} characters")
    
    # Step 2: Chunk text
    print("\nStep 2: Chunking text...")
    chunks = chunk_text(text, chunk_size=400)
    print(f"Created {len(chunks)} chunks")
    
    # Step 3: Generate embeddings
    print("\nStep 3: Generating embeddings...")
    embeddings = generate_embeddings(chunks)
    
    has_embeddings = embeddings is not None
    
    # Step 4: Upload to Firestore
    print("\nStep 4: Uploading to Firestore...")
    
    base_ref = (db.collection("classes")
                 .document(class_id)
                 .collection("subjects")
                 .document(subject_id)
                 .collection("chapters")
                 .document(chapter_id)
                 .collection("past_papers"))
    
    for i, chunk in enumerate(chunks, start=1):
        doc_data = {
            "chunkNumber": i,
            "text": chunk,
            "source": doc_id,
            "type": "pyq"
        }
        
        # Add embedding if available
        if has_embeddings:
            doc_data["embedding"] = embeddings[i-1].tolist()
        
        chunk_doc_id = f"{doc_id}_chunk{i}"
        base_ref.document(chunk_doc_id).set(doc_data)
        
        status = "with embedding" if has_embeddings else "without embedding"
        print(f"  Uploaded {chunk_doc_id} ({status})")
    
    print("\n" + "=" * 70)
    print(f"SUCCESS! Uploaded {len(chunks)} PYQ chunks")
    if has_embeddings:
        print("With vector embeddings for AI search")
    else:
        print("Without embeddings (install sentence-transformers to enable)")
    print("=" * 70)
    
    return True

# -----------------------------
# MAIN EXECUTION
# -----------------------------
if __name__ == "__main__":
    success = upload_pyq_with_embeddings(
        pdf_path=PYQ_PDF,
        class_id=CLASS_ID,
        subject_id=SUBJECT_ID,
        chapter_id=CHAPTER_ID,
        doc_id=PYQ_DOC_ID
    )
    
    if success:
        print("\nVerify in Firebase Console:")
        print(f"  classes -> {CLASS_ID} -> subjects -> {SUBJECT_ID}")
        print(f"  -> chapters -> {CHAPTER_ID} -> past_papers")
        print(f"\nYou should see documents: {PYQ_DOC_ID}_chunk1, {PYQ_DOC_ID}_chunk2, etc.")
    else:
        print("\nUpload failed. Check error messages above.")
