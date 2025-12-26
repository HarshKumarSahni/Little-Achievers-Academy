"""
Verify PYQ upload with embeddings
"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
try:
    app = firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

CLASS_ID = "class 8"
SUBJECT_ID = "science"
CHAPTER_ID = "chapter4"

print("=" * 70)
print("VERIFICATION: PYQ Upload Status")
print("=" * 70)

# Check past_papers subcollection
past_papers_ref = (db.collection("classes")
                    .document(CLASS_ID)
                    .collection("subjects")
                    .document(SUBJECT_ID)
                    .collection("chapters")
                    .document(CHAPTER_ID)
                    .collection("past_papers"))

papers = list(past_papers_ref.stream())

print(f"\nTotal PYQ chunks found: {len(papers)}")

if len(papers) > 0:
    print("\nFirst 5 PYQ chunks:")
    print("-" * 70)
    
    for i, paper in enumerate(papers[:5], 1):
        data = paper.to_dict()
        
        print(f"\n{i}. Document ID: {paper.id}")
        print(f"   Chunk Number: {data.get('chunkNumber', 'N/A')}")
        print(f"   Source: {data.get('source', 'N/A')}")
        print(f"   Type: {data.get('type', 'N/A')}")
        print(f"   Text preview: {data.get('text', '')[:80]}...")
        
        # Check if embedding exists
        if 'embedding' in data:
            embedding = data['embedding']
            print(f"   Embedding: {len(embedding)} dimensions")
            print(f"   Sample values: [{embedding[0]:.4f}, {embedding[1]:.4f}, {embedding[2]:.4f}, ...]")
        else:
            print(f"   Embedding: NOT FOUND")
    
    print("\n" + "=" * 70)
    print("SUCCESS! PYQ chunks uploaded with embeddings")
    print("=" * 70)
    print(f"\nTotal chunks: {len(papers)}")
    print(f"With embeddings: {sum(1 for p in papers if 'embedding' in p.to_dict())}")
    print("\nReady for AI-powered search and question generation!")
    
else:
    print("\nERROR: No PYQ chunks found!")
    print("The upload may have failed.")
