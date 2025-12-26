# ⚠️ CRITICAL: Firestore Document Naming

## 🚨 Common Mistake That Will Break Your Upload

### ❌ **WRONG** (Will NOT work):
```python
CLASS_ID = "class_8"  # ← Underscore
```

### ✅ **CORRECT** (Will work):
```python
CLASS_ID = "class 8"  # ← Space
```

---

## 🔍 Why This Matters

Your Firestore database uses **"class 8"** (with a space) as the document ID, NOT "class_8" (with underscore).

This comes from your Flutter code in [`notes.dart`](file:///d:/lla_sample/lib/pages/notes.dart):

```dart
// Line 81
String classDocName = 'class ${currentStudent!.classNumber}';
```

When `classNumber = 8`, this creates: **"class 8"** ← with a space!

---

## 🗂️ Your Actual Firestore Structure

```
classes/
  └── class 8/              ← Space, not underscore!
       └── subjects/
            └── science/
                 └── chapters/
                      └── chapter4/
```

---

## ✅ Correct Configuration

### For Single Chapter Upload

**File**: `upload_chapter_and_papers.py`

```python
# Line ~110
CLASS_ID = "class 8"        # ✅ EXACT match to Firestore
SUBJECT_ID = "science"      # ✅ EXACT match
CHAPTER_ID = "chapter4"     # ✅ EXACT match
```

### For Batch Upload

**File**: `upload_multiple_chapters.py`

```python
# Line ~90
CLASS_ID = "class 8"        # ✅ EXACT match to Firestore
SUBJECT_ID = "science"      # ✅ EXACT match
```

---

## 🧪 How to Verify Before Running

### Method 1: Check Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Go to Firestore Database
3. Look at the `classes` collection
4. **What do you see?**
   - ✅ "class 8" → Use `CLASS_ID = "class 8"`
   - ❌ "class_8" → Use `CLASS_ID = "class_8"`

### Method 2: Check Debug Output

When you run the script, it will print:

```
============================================================
🔍 FIRESTORE PATH:
   classes/class 8/subjects/science/chapters/chapter4
============================================================

⚠️  Make sure this path matches EXACTLY what you see in Firebase Console!
   Document names are case-sensitive and must include spaces/symbols.
```

**Compare this path with your Firebase Console!**

---

## 🎯 Rules for Document IDs

1. **Case-sensitive**: "Science" ≠ "science"
2. **Spaces matter**: "class 8" ≠ "class_8"
3. **Must match exactly**: Copy from Firebase Console if unsure
4. **No automatic conversion**: Python won't convert underscores to spaces

---

## 🔧 What If I Used the Wrong Name?

### Scenario 1: Script created wrong path

**Problem**: You used `CLASS_ID = "class_8"` but your app expects `"class 8"`

**Result**: Data uploaded to wrong location. Your Flutter app won't find it.

**Solution**:
1. Delete the wrong documents from Firestore Console
2. Fix the script to use `CLASS_ID = "class 8"`
3. Re-run the upload

### Scenario 2: Not sure what to use

**Solution**:
1. Open [`notes.dart`](file:///d:/lla_sample/lib/pages/notes.dart)
2. Look at line 81: `String classDocName = 'class ${currentStudent!.classNumber}';`
3. If `classNumber = 8`, the document ID is `"class 8"`

---

## 📋 Pre-Flight Checklist

Before running the upload script:

- [ ] Checked Firebase Console for exact document names
- [ ] Verified CLASS_ID has space: `"class 8"` not `"class_8"`
- [ ] Verified SUBJECT_ID matches exactly (e.g., `"science"`)
- [ ] Verified CHAPTER_ID matches your naming pattern (e.g., `"chapter4"`)
- [ ] Read the debug output to confirm path is correct

---

## 💡 Pro Tip

**Always use the debug output to verify your path BEFORE the upload completes!**

The script now prints the full Firestore path. If it doesn't match what you see in Firebase Console, **STOP** (Ctrl+C) and fix it.

---

## 🎊 When It's Correct

You'll see data appear in Firebase Console at:

```
classes → class 8 → subjects → science → chapters → chapter4 → chunks
```

Your Flutter app will be able to read this data using the same path.

---

**Last updated**: November 29, 2025  
**Critical for**: Firestore data alignment between Python upload and Flutter app
