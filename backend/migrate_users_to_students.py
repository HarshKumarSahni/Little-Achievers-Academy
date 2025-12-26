"""
Migration Script: Copy data from 'users' collection to 'students' collection in Firestore.
Then optionally delete the 'users' collection.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

# Initialize Firebase (if not already initialized)
if not firebase_admin._apps:
    cred_path = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

def migrate_users_to_students():
    """Copy all documents from 'users' collection to 'students' collection."""
    
    print("Starting migration from 'users' to 'students'...")
    
    # Get all documents from 'users' collection
    users_ref = db.collection('users')
    users_docs = users_ref.stream()
    
    migrated_count = 0
    
    for doc in users_docs:
        user_data = doc.to_dict()
        user_id = doc.id
        
        print(f"Migrating user: {user_id}")
        print(f"  Data: {user_data}")
        
        # Copy to 'students' collection with same document ID
        students_ref = db.collection('students').document(user_id)
        students_ref.set(user_data)
        
        print(f"  ✓ Copied to students/{user_id}")
        migrated_count += 1
    
    print(f"\n✅ Migration complete! {migrated_count} document(s) migrated.")
    return migrated_count

def delete_users_collection():
    """Delete all documents from 'users' collection."""
    
    print("\nDeleting 'users' collection...")
    
    users_ref = db.collection('users')
    users_docs = users_ref.stream()
    
    deleted_count = 0
    
    for doc in users_docs:
        print(f"Deleting: users/{doc.id}")
        doc.reference.delete()
        deleted_count += 1
    
    print(f"\n🗑️ Deleted {deleted_count} document(s) from 'users' collection.")
    return deleted_count

if __name__ == "__main__":
    # Step 1: Migrate data
    count = migrate_users_to_students()
    
    if count > 0:
        # Step 2: Ask before deleting
        confirm = input("\nDo you want to delete the 'users' collection now? (yes/no): ")
        if confirm.lower() == 'yes':
            delete_users_collection()
            print("\n🎉 Migration and cleanup complete!")
        else:
            print("\n✓ Migration complete. 'users' collection preserved.")
    else:
        print("\nNo documents found in 'users' collection to migrate.")
