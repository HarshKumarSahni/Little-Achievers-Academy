# 📚 PYQ (Previous Year Questions) Upload Guide

## 🎯 Purpose

Upload Previous Year Question papers with AI-powered embeddings for:
- **Semantic search** - Find similar questions
- **Question generation** - Generate new questions based on PYQs
- **Smart recommendations** - Suggest relevant practice questions

---

## 📋 Quick Start

### Step 1: Add Your PYQ PDF

Place your PYQ PDF in the `firestore_upload_scripts/` folder:
- **Filename**: `chapter4pyq.pdf` (or any name)
- **Update script**: Change `PYQ_PDF` variable if different name

### Step 2: Install Sentence Transformers (One-time)

```bash
pip install sentence-transformers
```

This will download ~120 MB of the embedding model.

### Step 3: Run Upload Script

```bash
python upload_pyq.py
```

---

## ⚙️ Configuration

Edit `upload_pyq.py` (lines 16-20):

```python
CLASS_ID = "class 8"          # Your class
SUBJECT_ID = "science"        # Your subject
CHAPTER_ID = "chapter4"       # Your chapter
PYQ_PDF = "chapter4pyq.pdf"   # Your PDF filename
PYQ_DOC_ID = "pyq2024"        # Document ID (year or identifier)
```

---

## 📊 What Gets Created

### Firestore Structure

```
classes/class 8/subjects/science/chapters/chapter4/past_papers/
  ├── pyq2024_chunk1/
  │    ├── chunkNumber: 1
  │    ├── text: "Question 1: What are metals..."
  │    ├── embedding: [0.123, 0.456, ..., 0.789]  ← 384-dim vector
  │    ├── source: "pyq2024"
  │    └── type: "pyq"
  ├── pyq2024_chunk2/
  │    ├── chunkNumber: 2
  │    ├── text: "Question 2: Explain non-metals..."
  │    ├── embedding: [0.234, 0.567, ..., 0.123]
  │    ├── source: "pyq2024"
  │    └── type: "pyq"
  └── ...
```

---

## 🤖 What Are Embeddings?

**Embeddings** = Numbers representing text meaning

- Each chunk → 384 numbers (vector)
- Similar questions → Similar vectors
- Enables "semantic search" (search by meaning, not just keywords)

### Example:

```
"What are metals?" 
  → [0.12, 0.45, 0.67, ...]

"Describe metallic properties"
  → [0.13, 0.46, 0.68, ...]  ← Very similar!

"What is photosynthesis?"
  → [0.89, 0.23, 0.11, ...]  ← Very different!
```

---

## 🔍 Using PYQs for AI Features

### 1. Question Generation

```python
# In your AI system:
query = "Generate questions about metals"
query_embedding = model.encode(query)

# Find similar PYQ chunks
similar_pyqs = vector_search(query_embedding, top_k=5)

# Use as context for LLM
prompt = f"""
Based on these previous year questions:
{similar_pyqs}

Generate 5 new questions about metals.
"""
```

### 2. Smart Practice Recommendations

```python
# User studying chapter 4
chapter_embedding = get_chapter_embedding("chapter4")

# Find relevant PYQs
recommended_pyqs = vector_search(chapter_embedding, top_k=10)

# Show to user: "Practice these PYQs"
```

### 3. Answer Verification

```python
# User asks a question
user_question = "What are the properties of metals?"
question_embedding = model.encode(user_question)

# Find similar PYQ chunks
similar = vector_search(question_embedding, top_k=3)

# Check if answer matches PYQ answers
```

---

## 📈 Expected Output

When you run the script:

```
======================================================================
UPLOADING PYQ TO FIRESTORE
======================================================================

PDF File: chapter4pyq.pdf
Target: classes/class 8/subjects/science/chapters/chapter4/past_papers/
Document ID Prefix: pyq2024

Step 1: Extracting text from PDF...
Extracted 15234 characters

Step 2: Chunking text...
Created 38 chunks

Step 3: Generating embeddings...
Loading embedding model (all-MiniLM-L6-v2)...
Generating embeddings for chunks...
Batches: 100%|████████████████████| 2/2 [00:01<00:00,  1.23it/s]

Step 4: Uploading to Firestore...
  Uploaded pyq2024_chunk1 (with embedding)
  Uploaded pyq2024_chunk2 (with embedding)
  ...
  Uploaded pyq2024_chunk38 (with embedding)

======================================================================
SUCCESS! Uploaded 38 PYQ chunks
With vector embeddings for AI search
======================================================================
```

---

## 🔧 Troubleshooting

### Error: "sentence-transformers not installed"

**Fix**:
```bash
pip install sentence-transformers
```

### Error: "PDF file not found"

**Fix**:
1. Check filename matches `PYQ_PDF` variable
2. Ensure file is in `firestore_upload_scripts/` folder
3. Check file extension is `.pdf`

### Script works but no embeddings

**Check output**: Should say "with embedding" not "without embedding"

**Fix**: Reinstall sentence-transformers:
```bash
pip uninstall sentence-transformers
pip install sentence-transformers
```

---

## 📁 Embedding Model Details

**Model**: `all-MiniLM-L6-v2`

- **Size**: ~80 MB download
- **Vector dimensions**: 384
- **Speed**: ~1000 sentences/second
- **Quality**: Good for general tasks
- **Language**: English (works best)

### Alternative Models

For better quality (slower):
```python
# In upload_pyq.py, change line 79:
model = SentenceTransformer('all-mpnet-base-v2')  # Better quality, larger
```

For faster speed (lower quality):
```python
model = SentenceTransformer('all-MiniLM-L12-v2')  # Faster, smaller
```

---

## 🎯 Next Steps After Upload

### 1. Upload More PYQs

Add different years:
```python
# For 2023:
PYQ_PDF = "chapter4pyq2023.pdf"
PYQ_DOC_ID = "pyq2023"

# For 2022:
PYQ_PDF = "chapter4pyq2022.pdf"
PYQ_DOC_ID = "pyq2022"
```

Run the script for each year.

### 2. Build Vector Search in Flutter

Use a backend to perform vector similarity:
- **Firebase Functions** + **Pinecone** (vector DB)
- **Supabase** (has built-in vector search)
- **Custom backend** with cosine similarity

### 3. Implement AI Features

- Question generator
- Smart recommendations
- Answer checker
- Study plan generator

---

## 📊 Performance

| PYQ PDF Size | Chunks | Embedding Time | Total Time |
|--------------|--------|----------------|------------|
| 500 KB | 25 | ~2 seconds | ~5 seconds |
| 1 MB | 50 | ~4 seconds | ~8 seconds |
| 2 MB | 100 | ~8 seconds | ~15 seconds |

---

**Created**: November 29, 2025  
**Purpose**: Upload PYQs with embeddings for AI-powered features
