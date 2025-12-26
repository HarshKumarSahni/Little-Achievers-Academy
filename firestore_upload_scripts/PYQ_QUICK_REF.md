# ⚡ Quick Reference: PYQ Upload

## 📋 Prerequisites

- [x] ✅ Python installed
- [x] ✅ Firebase credentials (`serviceAccountKey.json`)
- [x] ✅ sentence-transformers installed
- [ ] ⏳ Add `chapter4pyq.pdf` to firestore_upload_scripts folder

---

## 🚀 Quick Start (3 Steps)

### 1. Add Your PYQ PDF
Place `chapter4pyq.pdf` in:
```
d:\lla_sample\firestore_upload_scripts\chapter4pyq.pdf
```

### 2. (Optional) Configure
Edit `upload_pyq.py` if needed:
```python
PYQ_PDF = "chapter4pyq.pdf"    # Change if different filename
PYQ_DOC_ID = "pyq2024"         # Change year/identifier
```

### 3. Run Upload
```bash
python upload_pyq.py
```

---

## 📊 What Gets Created

```
past_papers/
  ├── pyq2024_chunk1/
  │    ├── text: "Question text..."
  │    ├── embedding: [384 numbers]  ← AI vector
  │    ├── chunkNumber: 1
  │    ├── source: "pyq2024"
  │    └── type: "pyq"
  ├── pyq2024_chunk2/
  └── ...
```

**Each chunk has**:
- ✅ Text content
- ✅ 384-dimensional embedding vector
- ✅ Metadata (chunk number, source, type)

---

## 🎯 Why Embeddings?

**Without embeddings** (keyword search):
- Query: "properties of metals"
- Finds: Only docs with exact words "properties" AND "metals"

**With embeddings** (semantic search):
- Query: "properties of metals"
- Finds: "metallic characteristics", "features of metal elements", etc.
- Understands MEANING, not just keywords!

---

## 🔍 Example Use Cases

### 1. Generate Similar Questions
```
User studying "metals" 
→ Find PYQ embeddings similar to "metals"
→ Show relevant past year questions
```

### 2. AI Question Generator
```
Get top 5 similar PYQ chunks
→ Feed to LLM as context
→ Generate new practice questions
```

### 3. Answer Validation
```
User answers a question
→ Compare with PYQ answer embeddings
→ Check semantic similarity
→ Provide feedback
```

---

## ✅ Success Indicators

After running upload_pyq.py:

```
SUCCESS! Uploaded 38 PYQ chunks
With vector embeddings for AI search
```

**Verify in Firebase Console**:
```
classes → class 8 → subjects → science 
→ chapters → chapter4 → past_papers
```

You should see: `pyq2024_chunk1`, `pyq2024_chunk2`, etc.

---

## 🛠️ Troubleshooting

| Issue | Fix |
|-------|-----|
| PDF not found | Add file to folder |
| No embeddings | Run `pip install sentence-transformers` |
| Slow upload | Normal for first run (downloads model) |
| Encoding error | Already fixed in script |

---

## 📈 Performance

- **First run**: ~2-3 minutes (downloads model)
- **Subsequent runs**: ~10-30 seconds
- **Model size**: ~80 MB (cached locally)

---

## 🎊 After Upload

You can:
1. ✅ **Search** PYQs semantically in your app
2. ✅ **Generate** new questions using AI
3. ✅ **Recommend** relevant practice problems
4. ✅ **Compare** user answers with PYQ answers

---

**Ready to upload?** Just add the PDF and run the script!

```bash
python upload_pyq.py
```

---

**Files**:
- [upload_pyq.py](file:///d:/lla_sample/firestore_upload_scripts/upload_pyq.py) - Main upload script
- [PYQ_UPLOAD_GUIDE.md](file:///d:/lla_sample/firestore_upload_scripts/PYQ_UPLOAD_GUIDE.md) - Full documentation
- [example_similarity_search.py](file:///d:/lla_sample/firestore_upload_scripts/example_similarity_search.py) - How to use embeddings
