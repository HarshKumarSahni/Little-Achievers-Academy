"""
Retrieval Service
Handles RAG (Retrieval-Augmented Generation) using embeddings and similarity search
"""

import math
import firebase_admin
from firebase_admin import credentials, firestore
from sentence_transformers import SentenceTransformer

class RetrievalService:
    def __init__(self, service_account_path):
        # Initialize Firebase
        try:
            firebase_admin.get_app()
        except ValueError:
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred)
        
        self.db = firestore.client()
        self.embed_model = SentenceTransformer('all-MiniLM-L6-v2')
    
    def fetch_chapter_chunks(self, class_id, subject_id, chapter_id):
        """Fetch all chunks for a chapter"""
        chunks = []
        docs = (self.db.collection("classes").document(class_id)
                .collection("subjects").document(subject_id)
                .collection("chapters").document(chapter_id)
                .collection("chunks").stream())
        
        for doc in docs:
            data = doc.to_dict()
            chunks.append({
                "id": doc.id,
                "text": data.get("text", ""),
                "embedding": data.get("embedding"),
                "type": "chapter"
            })
        
        return chunks
    
    def fetch_pyq_chunks(self, class_id, subject_id, chapter_id):
        """Fetch all PYQ chunks for a chapter"""
        chunks = []
        docs = (self.db.collection("classes").document(class_id)
                .collection("subjects").document(subject_id)
                .collection("chapters").document(chapter_id)
                .collection("past_papers").stream())
        
        for doc in docs:
            data = doc.to_dict()
            chunks.append({
                "id": doc.id,
                "text": data.get("text", ""),
                "embedding": data.get("embedding"),
                "type": "pyq",
                "source": data.get("source", "unknown")
            })
        
        return chunks
    
    def cosine_similarity(self, vec1, vec2):
        """Calculate cosine similarity between two vectors"""
        if not vec1 or not vec2:
            return 0.0
        
        dot = sum(a * b for a, b in zip(vec1, vec2))
        norm1 = math.sqrt(sum(a * a for a in vec1))
        norm2 = math.sqrt(sum(b * b for b in vec2))
        
        if norm1 == 0 or norm2 == 0:
            return 0.0
        
        return dot / (norm1 * norm2)
    
    def retrieve_top_k(self, chunks, query, k=6):
        """
        Retrieve top-k most relevant chunks using semantic similarity
        """
        # Generate query embedding
        query_vec = self.embed_model.encode(query).tolist()
        
        # Score all chunks
        scored = []
        for chunk in chunks:
            embedding = chunk.get("embedding")
            if not embedding:
                continue
            
            score = self.cosine_similarity(query_vec, embedding)
            scored.append((score, chunk))
        
        # Sort by score (highest first)
        scored.sort(key=lambda x: x[0], reverse=True)
        
        # Return top-k chunks
        return [chunk for score, chunk in scored[:k]]
    
    def retrieve_context_for_quiz(self, class_id, subject_id, chapter_id, num_questions=10):
        """
        Retrieve relevant context for quiz generation
        Prioritizes PYQs and adds chapter chunks
        """
        # Fetch both types of chunks
        chapter_chunks = self.fetch_chapter_chunks(class_id, subject_id, chapter_id)
        pyq_chunks = self.fetch_pyq_chunks(class_id, subject_id, chapter_id)
        
        # Build query
        query = f"Generate {num_questions} multiple choice questions for class 8 {subject_id} {chapter_id}"
        
        # Combine all chunks
        all_chunks = pyq_chunks + chapter_chunks
        
        # Retrieve top 8 chunks (prioritize variety)
        # Get top 5 PYQs and top 3 chapter chunks
        pyq_top = self.retrieve_top_k(pyq_chunks, query, k=5) if pyq_chunks else []
        chapter_top = self.retrieve_top_k(chapter_chunks, query, k=3) if chapter_chunks else []
        
        # Combine with PYQs first (to bias generation toward exam-style questions)
        context = pyq_top + chapter_top
        
        return context[:8]  # Limit to 8 total chunks to manage token count
