"""
🔧 STANDARDIZE FIRESTORE STRUCTURE
This script will make ALL subjects match the 'english' structure:
- subject_name field
- chapters subcollection with sample chapters

Run this ONCE to standardize your database.
"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Configuration
CLASS_ID = "class 8"

# Subjects to standardize (all except english which already has chapters)
SUBJECTS_TO_UPDATE = ["hindi", "mathematics", "science", "social science"]

# Sample chapters to create for each subject
SAMPLE_CHAPTERS = [
    {
        "id": "chapter1",
        "chapter_name": "Chapter 1",
        "notesURL": "",  # You can fill this later
        "summary": ""
    },
    {
        "id": "chapter2",
        "chapter_name": "Chapter 2",
        "notesURL": "",
        "summary": ""
    }
]

def standardize_subject(class_id, subject_id):
    """
    Ensure a subject has:
    1. subject_name field
    2. chapters subcollection with sample chapters
    """
    print(f"\n📘 Processing subject: {subject_id}")
    print("-" * 60)
    
    subject_ref = (db.collection("classes")
                    .document(class_id)
                    .collection("subjects")
                    .document(subject_id))
    
    # Get current subject data
    subject_doc = subject_ref.get()
    
    if subject_doc.exists:
        subject_data = subject_doc.to_dict()
        print(f"✓ Subject document exists")
        print(f"  Current fields: {list(subject_data.keys())}")
        
        # Ensure subject_name field exists
        if 'subject_name' not in subject_data:
            print(f"  ⚠️  Adding 'subject_name' field...")
            subject_ref.update({"subject_name": subject_id})
            print(f"  ✓ Added subject_name: {subject_id}")
        else:
            print(f"  ✓ subject_name already exists: {subject_data['subject_name']}")
    else:
        print(f"⚠️  Subject document doesn't exist, creating it...")
        subject_ref.set({"subject_name": subject_id})
        print(f"✓ Created subject with subject_name: {subject_id}")
    
    # Check if chapters subcollection exists
    chapters_ref = subject_ref.collection("chapters")
    existing_chapters = list(chapters_ref.stream())
    
    if existing_chapters:
        print(f"✓ Chapters subcollection already has {len(existing_chapters)} chapter(s):")
        for ch in existing_chapters:
            print(f"   - {ch.id}")
    else:
        print(f"⚠️  No chapters found, creating sample chapters...")
        
        # Create sample chapters
        for chapter_data in SAMPLE_CHAPTERS:
            chapter_id = chapter_data["id"]
            chapter_fields = {
                "chapter_name": chapter_data["chapter_name"],
                "notesURL": chapter_data["notesURL"],
                "summary": chapter_data["summary"]
            }
            chapters_ref.document(chapter_id).set(chapter_fields)
            print(f"   ✓ Created chapter: {chapter_id}")
        
        print(f"✓ Created {len(SAMPLE_CHAPTERS)} sample chapters")
    
    print(f"✅ {subject_id} is now standardized!")


def main():
    print("=" * 70)
    print("🔧 FIRESTORE STRUCTURE STANDARDIZATION TOOL")
    print("=" * 70)
    print(f"\nTarget: classes/{CLASS_ID}/subjects/")
    print(f"Subjects to update: {', '.join(SUBJECTS_TO_UPDATE)}")
    print("\n⚠️  This will:")
    print("   1. Ensure all subjects have 'subject_name' field")
    print("   2. Create 'chapters' subcollection if missing")
    print("   3. Add 2 sample chapters to subjects without chapters")
    print("\n" + "=" * 70)
    
    # Ask for confirmation
    response = input("\n🤔 Do you want to proceed? (yes/no): ").strip().lower()
    
    if response != "yes":
        print("❌ Cancelled. No changes made.")
        return
    
    print("\n🚀 Starting standardization...")
    
    # Process each subject
    for subject_id in SUBJECTS_TO_UPDATE:
        try:
            standardize_subject(CLASS_ID, subject_id)
        except Exception as e:
            print(f"❌ Error processing {subject_id}: {e}")
    
    print("\n" + "=" * 70)
    print("✅ STANDARDIZATION COMPLETE!")
    print("=" * 70)
    print("\n📊 Summary:")
    print(f"   - Processed {len(SUBJECTS_TO_UPDATE)} subjects")
    print(f"   - All subjects now have:")
    print(f"      ✓ subject_name field")
    print(f"      ✓ chapters subcollection")
    print(f"      ✓ Sample chapters (if they didn't exist)")
    print("\n🎯 Next Steps:")
    print("   1. Check Firebase Console to verify the structure")
    print("   2. Run 'diagnostic_tool.py' to verify everything")
    print("   3. Run 'upload_chapter_and_papers.py' to add chunks")
    print("=" * 70)


if __name__ == "__main__":
    main()
