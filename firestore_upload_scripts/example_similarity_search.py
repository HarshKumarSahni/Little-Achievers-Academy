"""
Example: How to use embeddings for similarity search

This shows how to find similar questions/content using the embeddings
that were generated during PYQ upload.
"""

from sentence_transformers import SentenceTransformer
import numpy as np

# Load the same model used for generating embeddings
model = SentenceTransformer('all-MiniLM-L6-v2')

def cosine_similarity(vec1, vec2):
    """Calculate cosine similarity between two vectors"""
    dot_product = np.dot(vec1, vec2)
    norm1 = np.linalg.norm(vec1)
    norm2 = np.linalg.norm(vec2)
    return dot_product / (norm1 * norm2)

def find_similar_chunks(query_text, all_chunks_with_embeddings, top_k=5):
    """
    Find the most similar chunks to a query
    
    Args:
        query_text: The search query (e.g., "questions about metals")
        all_chunks_with_embeddings: List of dicts with 'text' and 'embedding'
        top_k: Number of top results to return
    
    Returns:
        List of top_k most similar chunks
    """
    
    # Generate embedding for query
    query_embedding = model.encode(query_text)
    
    # Calculate similarity with all chunks
    similarities = []
    for chunk in all_chunks_with_embeddings:
        similarity = cosine_similarity(query_embedding, np.array(chunk['embedding']))
        similarities.append({
            'text': chunk['text'],
            'similarity': similarity,
            'source': chunk.get('source', 'unknown')
        })
    
    # Sort by similarity (highest first)
    similarities.sort(key=lambda x: x['similarity'], reverse=True)
    
    return similarities[:top_k]


# Example usage:
if __name__ == "__main__":
    print("=" * 70)
    print("EXAMPLE: Semantic Search with Embeddings")
    print("=" * 70)
    
    # Simulated chunk data (in real app, fetch from Firestore)
    chunks = [
        {
            'text': 'What are the physical properties of metals? Metals are lustrous, malleable, and ductile.',
            'embedding': model.encode('What are the physical properties of metals? Metals are lustrous, malleable, and ductile.').tolist()
        },
        {
            'text': 'Explain the process of photosynthesis in plants.',
            'embedding': model.encode('Explain the process of photosynthesis in plants.').tolist()
        },
        {
            'text': 'Describe the characteristics of non-metals. Non-metals are brittle and poor conductors.',
            'embedding': model.encode('Describe the characteristics of non-metals. Non-metals are brittle and poor conductors.').tolist()
        }
    ]
    
    # Search query
    query = "properties of metallic elements"
    
    print(f"\nQuery: '{query}'\n")
    print("Top 3 similar chunks:")
    print("-" * 70)
    
    results = find_similar_chunks(query, chunks, top_k=3)
    
    for i, result in enumerate(results, 1):
        print(f"\n{i}. Similarity: {result['similarity']:.4f}")
        print(f"   Text: {result['text'][:100]}...")
    
    print("\n" + "=" * 70)
    print("Notice: Query about 'metallic elements' found 'properties of metals'")
    print("even though exact words don't match - that's semantic search!")
    print("=" * 70)
