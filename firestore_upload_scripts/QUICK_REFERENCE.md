# ⚡ Quick Reference Card

## 🚀 Run These Commands In Order

### 1️⃣ Install Dependencies (First Time Only)
```bash
cd d:\lla_sample\firestore_upload_scripts
pip install -r requirements.txt
```

### 2️⃣ Run Diagnostics
```bash
python diagnostic_tool.py
```
**Look for:** All ✅ checkmarks, no ❌ errors

### 3️⃣ Standardize All Subjects
```bash
python standardize_structure.py
```
**Type:** `yes` when prompted  
**What it does:** Adds chapters to hindi, mathematics, science, social science

### 4️⃣ Upload Chunks to Science Chapter 4
```bash
python upload_chapter_and_papers.py
```
**Creates:** chunks subcollection in science/chapter4

---

## 📊 What Each Script Does

| Script | Purpose | Creates |
|--------|---------|---------|
| `diagnostic_tool.py` | Check everything is connected correctly | Nothing (read-only) |
| `standardize_structure.py` | Make all subjects have chapters | chapters subcollection |
| `upload_chapter_and_papers.py` | Add chunks to a specific chapter | chunks + past_papers |

---

## ✅ Success Indicators

After running scripts, you should see in Firebase Console:

```
classes/class 8/subjects/science/chapters/
  ├── chapter1/      ← Created by standardize_structure.py
  ├── chapter2/      ← Created by standardize_structure.py
  └── chapter4/      ← Created by upload_chapter_and_papers.py
       ├── chunks/   ← NEW! Contains chunk1, chunk2, etc.
       └── past_papers/  ← NEW! (if you have PDF files)
```

---

## 🚨 Common Issues

### Issue: "class 8 NOT FOUND"
**Fix:** Change `CLASS_ID = "class_8"` to `CLASS_ID = "class 8"` (with space)

### Issue: "Service account key not found"
**Fix:** Place `serviceAccountKey.json` in `firestore_upload_scripts/` folder

### Issue: "Wrong Firebase project"
**Fix:** Download key from correct project in Firebase Console

---

## 📁 Files You Need

```
firestore_upload_scripts/
  ├── serviceAccountKey.json   ← Download from Firebase
  ├── chapter4.pdf             ← (Optional) Your PDF file
  ├── diagnostic_tool.py       ← Run first
  ├── standardize_structure.py ← Run second
  └── upload_chapter_and_papers.py ← Run last
```

---

## 🎯 One-Time Setup Checklist

- [ ] Downloaded `serviceAccountKey.json` from Firebase Console
- [ ] Placed it in `firestore_upload_scripts/` folder
- [ ] Ran `pip install -r requirements.txt`
- [ ] Verified CLASS_ID is `"class 8"` with space in all scripts
- [ ] Ready to run diagnostics!

---

**Quick Help:** See [DIAGNOSIS_GUIDE.md](file:///d:/lla_sample/firestore_upload_scripts/DIAGNOSIS_GUIDE.md) for detailed explanations
