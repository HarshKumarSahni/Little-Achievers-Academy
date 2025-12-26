# 🚀 Quick Start Guide

**Get your PDFs into Firestore in 5 minutes!**

---

## ⚡ Quick Setup (3 Commands)

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Add your Firebase credentials
# Download serviceAccountKey.json from Firebase Console
# Place it in this folder

# 3. Run the upload script
python upload_chapter_and_papers.py
```

---

## 📋 Checklist

- [ ] Python 3.7+ installed
- [ ] Ran `pip install -r requirements.txt`
- [ ] Downloaded `serviceAccountKey.json` from Firebase
- [ ] Placed PDF files in this folder
- [ ] Updated script configuration (CLASS_ID, SUBJECT_ID, etc.)
- [ ] Ran `python upload_chapter_and_papers.py`

---

## 📁 What You Need

### 1. Firebase Service Account Key

**Get it here**: [Firebase Console](https://console.firebase.google.com/) → Project Settings → Service Accounts → Generate Key

**Save as**: `serviceAccountKey.json` (in this folder)

### 2. Your PDF Files

Place your PDFs in this folder:
- `chapter4.pdf` (or whatever you name it)
- `paper1.pdf` (optional: question papers)
- `paper2.pdf` (optional: question papers)

---

## ⚙️ Configure the Script

Open `upload_chapter_and_papers.py` and update (around line 113):

```python
CLASS_ID = "class_8"              # Change to your class
SUBJECT_ID = "science"            # Change to your subject
CHAPTER_ID = "chapter4"           # Change to your chapter ID
CHAPTER_NAME = "Your Chapter Name"  # Display name
CHAPTER_PDF = "chapter4.pdf"      # Your PDF filename
```

---

## 🎯 What You'll Get

After running, your Firestore will have:

```
classes/class_8/subjects/science/chapters/chapter4/
  ├── chapter_name: "Materials: Metals and Non-Metals"
  ├── notesURL: ""
  ├── summary: ""
  └── chunks/
       ├── chunk1/ (chunkNumber: 1, text: "...")
       ├── chunk2/ (chunkNumber: 2, text: "...")
       └── ...
```

---

## 💡 Tips

- **First time?** Use `upload_chapter_and_papers.py` (single chapter)
- **Multiple chapters?** Use `upload_multiple_chapters.py` (batch upload)
- **Chunk size** default is 400 words (change in script if needed)

---

## 🆘 Need Help?

See full documentation: [README.md](file:///d:/lla_sample/firestore_upload_scripts/README.md)

---

**Ready?** → `python upload_chapter_and_papers.py` 🚀
