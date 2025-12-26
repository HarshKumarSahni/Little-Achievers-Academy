# 🔥 Firestore PDF Upload Script

This Python script extracts text from PDF files, chunks them into manageable segments, and uploads them to your Firestore database for AI/RAG processing.

---

## 📋 Prerequisites

- Python 3.7 or higher
- Firebase Admin SDK credentials
- PDF files to upload

---

## 🚀 Setup Instructions

### Step 1: Install Required Libraries

```bash
pip install firebase-admin pdfplumber
```

**What these do**:
- `firebase-admin`: Official Firebase Admin SDK for Python
- `pdfplumber`: Extracts text from PDF files

---

### Step 2: Get Your Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **little-achievers-academy-demo**
3. Click on **⚙️ Project Settings**
4. Navigate to **Service Accounts** tab
5. Click **"Generate new private key"**
6. Download the JSON file
7. **Rename it to** `serviceAccountKey.json`
8. **Place it in this folder** (`firestore_upload_scripts/`)

> [!CAUTION]
> **NEVER commit `serviceAccountKey.json` to Git!** It contains sensitive credentials. The `.gitignore` file already excludes it.

---

### Step 3: Prepare Your PDF Files

Place your PDF files in this folder:

```
firestore_upload_scripts/
  ├── chapter4.pdf          ← Main chapter PDF
  ├── paper1.pdf            ← Question paper 1
  ├── paper2.pdf            ← Question paper 2
  └── upload_chapter_and_papers.py
```

---

### Step 4: Configure the Script

Open `upload_chapter_and_papers.py` and update these values (around line 113):

```python
# UPDATE THESE VALUES ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
CLASS_ID = "class_8"                          # e.g., "class_8", "class_10"
SUBJECT_ID = "science"                        # e.g., "science", "mathematics"
CHAPTER_ID = "chapter4"                       # e.g., "chapter1", "chapter2"
CHAPTER_NAME = "Materials: Metals and Non-Metals"  # Display name

CHAPTER_PDF = "chapter4.pdf"                  # Your chapter PDF filename
PAST_PAPERS = ["paper1.pdf", "paper2.pdf"]   # List of question paper PDFs
```

---

### Step 5: Run the Script

```bash
python upload_chapter_and_papers.py
```

---

## 📊 Expected Output

```
📘 Uploading Chapter: Materials: Metals and Non-Metals
✓ Uploaded chunk 1
✓ Uploaded chunk 2
✓ Uploaded chunk 3
✓ Uploaded chunk 4
...
🎉 Chapter upload complete!

📝 Uploading Past Papers...
✓ Uploaded paper 1
✓ Uploaded paper 2
🎉 Past papers uploaded!
```

---

## 🗂️ Firestore Structure Created

After running the script, your Firestore database will have:

```
classes/
  └── class_8/
       └── subjects/
            └── science/
                 └── chapters/
                      └── chapter4/
                           ├── chapter_name: "Materials: Metals and Non-Metals"
                           ├── notesURL: ""
                           ├── summary: ""
                           ├── chunks/               ← NEW
                           │    ├── chunk1/
                           │    │    ├── chunkNumber: 1
                           │    │    └── text: "..."
                           │    ├── chunk2/
                           │    │    ├── chunkNumber: 2
                           │    │    └── text: "..."
                           │    └── ...
                           └── past_papers/          ← NEW
                                ├── paper1/
                                │    ├── paperNumber: 1
                                │    └── text: "..."
                                └── paper2/
                                     ├── paperNumber: 2
                                     └── text: "..."
```

---

## ⚙️ How It Works

### 1. **PDF Extraction** (`extract_pdf`)
- Opens PDF file using `pdfplumber`
- Extracts text from each page
- Concatenates all pages into one string

### 2. **Text Chunking** (`chunk_text`)
- Splits text into words
- Groups words into chunks of ~400 words
- Returns list of text chunks

**Why chunk?**
- Smaller chunks are easier for AI to process
- Better for vector embeddings
- Enables granular search and retrieval

### 3. **Chapter Upload** (`upload_chapter`)
- Uploads chapter metadata to Firestore
- Creates `chunks` subcollection
- Uploads each chunk with sequential numbering

### 4. **Past Papers Upload** (`upload_past_papers`)
- Extracts full text from each question paper PDF
- Creates `past_papers` subcollection
- Uploads each paper with sequential numbering

---

## 🎯 Customization Options

### Change Chunk Size

Default is 400 words. To change:

```python
# Line 30
def chunk_text(text, chunk_size=400):  # Change to 500, 300, etc.
```

**Recommendations**:
- **Small chunks (200-300 words)**: Better for precise search
- **Large chunks (500-700 words)**: Better context for AI
- **Default (400 words)**: Balanced approach

### Add Summary Field

To add an AI-generated summary:

```python
chapter_ref.set({
    "chapter_name": chapter_name,
    "notesURL": "",
    "summary": "This chapter covers...",  # Add your summary
})
```

### Upload Multiple Chapters

Wrap the main execution in a loop:

```python
chapters = [
    ("chapter1", "Chapter 1 Name", "chapter1.pdf"),
    ("chapter2", "Chapter 2 Name", "chapter2.pdf"),
    ("chapter3", "Chapter 3 Name", "chapter3.pdf"),
]

for chapter_id, chapter_name, pdf_path in chapters:
    upload_chapter(CLASS_ID, SUBJECT_ID, chapter_id, chapter_name, pdf_path)
```

---

## 🔍 Querying Uploaded Data

### Get All Chunks for a Chapter

```dart
// In your Flutter app
final chunksSnapshot = await FirebaseFirestore.instance
  .collection('classes')
  .doc('class_8')
  .collection('subjects')
  .doc('science')
  .collection('chapters')
  .doc('chapter4')
  .collection('chunks')
  .orderBy('chunkNumber')
  .get();

List<ChunkModel> chunks = chunksSnapshot.docs
  .map((doc) => ChunkModel.fromJson(doc.data(), doc.id))
  .toList();
```

### Search Within Chunks

```dart
// Get specific chunk
final chunk5 = await chaptersRef
  .collection('chunks')
  .doc('chunk5')
  .get();

print(chunk5.data()['text']);
```

---

## 🛠️ Troubleshooting

### Error: "File not found: serviceAccountKey.json"

**Solution**: Make sure you've downloaded the Firebase Admin SDK key and placed it in the `firestore_upload_scripts/` folder.

---

### Error: "Permission denied"

**Solution**: Your Firebase Admin SDK key might not have Firestore write permissions. Generate a new key with proper permissions.

---

### Error: "Could not open PDF file"

**Solution**: 
- Check that the PDF filename matches exactly (case-sensitive)
- Ensure the PDF is in the same folder as the script
- Try opening the PDF manually to verify it's not corrupted

---

### Script runs but no data appears in Firestore

**Solution**:
- Check Firebase Console to verify the `classes` collection exists
- Verify you're looking at the correct Firebase project
- Check the script output for error messages

---

## 📝 Performance Notes

- **Upload Speed**: ~1-2 seconds per chunk (depends on internet)
- **Chunk Size**: 400 words ≈ 2000-2500 characters
- **Firestore Limits**: 
  - Max document size: 1 MB
  - Max subcollection depth: 100 levels (you're using 4)
  - Max writes per second: 500

---

## 🔐 Security Best Practices

> [!WARNING]
> **Never share or commit `serviceAccountKey.json`!**

✅ **DO**:
- Use `.gitignore` to exclude credentials
- Store service account keys securely
- Rotate keys periodically
- Use environment variables in production

❌ **DON'T**:
- Commit service account keys to Git
- Share keys via email or chat
- Use the same key across multiple projects
- Store keys in public repositories

---

## 📚 Additional Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [pdfplumber Documentation](https://github.com/jsvine/pdfplumber)
- [Python Firebase Admin Reference](https://firebase.google.com/docs/reference/admin/python)

---

## 🎉 You're All Set!

Your Firestore database is now ready for AI/RAG applications. The chunks can be used for:

- 📖 **Vector search** (add embeddings later)
- 🤖 **AI question answering**
- 🔍 **Semantic search**
- 📝 **Content summarization**
- 💬 **Chatbot training**

---

**Created**: November 29, 2025  
**Project**: Little Achievers Academy  
**Firebase Project**: `little-achievers-academy-demo`
