"""
Flask Backend for AI Quiz System
Provides endpoints for MCQ generation and quiz grading
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
from datetime import datetime

from gemini_service import GeminiService
from retrieval_service import RetrievalService

# Load environment
load_dotenv()

# Initialize app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Initialize services
SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
gemini = GeminiService()
retrieval = RetrievalService(SERVICE_ACCOUNT_PATH)

# In-memory cache for quizzes (in production, use Redis or Firestore)
quiz_cache = {}

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "ok", "message": "AI Quiz Backend is running"})

@app.route('/generate_mcq', methods=['POST'])
def generate_mcq():
    """
    Generate MCQ quiz using RAG + Gemini
    
    Request body:
    {
        "class_id": "class 8",
        "subject_id": "science",
        "chapter_id": "chapter4",
        "num_questions": 10
    }
    
    Response:
    {
        "quiz_id": "...",
        "questions": [...]
    }
    """
    try:
        data = request.json
        class_id = data.get('class_id', 'class 8')
        subject_id = data.get('subject_id')
        chapter_id = data.get('chapter_id')
        num_questions = data.get('num_questions', 10)
        
        if not subject_id or not chapter_id:
            return jsonify({"error": "subject_id and chapter_id are required"}), 400
        
        print(f"Generating quiz: {class_id}/{subject_id}/{chapter_id} ({num_questions} questions)")
        
        # Step 1: Retrieve relevant context using RAG
        context_chunks = retrieval.retrieve_context_for_quiz(
            class_id, subject_id, chapter_id, num_questions
        )
        
        if not context_chunks:
            return jsonify({"error": "No content found for this chapter"}), 404
        
        print(f"Retrieved {len(context_chunks)} context chunks")
        
        # Step 2: Generate MCQs using Gemini
        questions = gemini.generate_mcqs(context_chunks, num_questions)
        
        if not questions:
            return jsonify({"error": "Failed to generate questions"}), 500
        
        print(f"Generated {len(questions)} questions")
        
        # Step 3: Store quiz (simple in-memory for now)
        quiz_id = f"quiz_{datetime.now().timestamp()}"
        quiz_data = {
            "class": class_id,
            "subject": subject_id,
            "chapter": chapter_id,
            "questions": questions,
            "generated_at": datetime.now().isoformat()
        }
        quiz_cache[quiz_id] = quiz_data
        
        # Also save to Firestore
        retrieval.db.collection("quizzes").document(quiz_id).set(quiz_data)
        
        return jsonify({
            "quiz_id": quiz_id,
            "questions": questions,
            "total_questions": len(questions)
        })
        
    except Exception as e:
        print(f"Error in generate_mcq: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/grade_quiz', methods=['POST'])
def grade_quiz():
    """
    Grade quiz and generate improvement analysis
    
    Request body:
    {
        "quiz_id": "...",
        "answers": [1, 3, 2, 4, ...],  // 1-based indices
        "student_id": "..."
    }
    
    Response:
    {
        "score": 75,
        "total": 10,
        "correct": 7,
        "incorrect": 3,
        "per_question": [...],
        "report": {...}
    }
    """
    try:
        data = request.json
        quiz_id = data.get('quiz_id')
        answers = data.get('answers', [])
        student_id = data.get('student_id', 'anonymous')
        
        if not quiz_id or not answers:
            return jsonify({"error": "quiz_id and answers are required"}), 400
        
        # Get quiz from cache or Firestore
        quiz = quiz_cache.get(quiz_id)
        if not quiz:
            quiz_doc = retrieval.db.collection("quizzes").document(quiz_id).get()
            if not quiz_doc.exists:
                return jsonify({"error": "Quiz not found"}), 404
            quiz = quiz_doc.to_dict()
        
        questions = quiz.get('questions', [])
        
        if len(answers) != len(questions):
            return jsonify({"error": f"Expected {len(questions)} answers, got {len(answers)}"}), 400
        
        # Grade each question
        correct_count = 0
        per_question = []
        wrong_topics = {}
        
        for i, (question, user_answer) in enumerate(zip(questions, answers)):
            correct_answer = question.get('answer')
            is_correct = (user_answer == correct_answer)
            
            per_question.append({
                "q": question.get('q'),
                "selected": user_answer,
                "correct": correct_answer,
                "ok": is_correct,
                "explanation": question.get('explanation', ''),
                "source": question.get('source', '')
            })
            
            if is_correct:
                correct_count += 1
            else:
                # Track wrong topics
                source = question.get('source', 'unknown')
                wrong_topics[source] = wrong_topics.get(source, 0) + 1
        
        # Calculate score
        score = int(100 * correct_count / len(questions)) if questions else 0
        
        # Generate improvement analysis using Gemini
        report = gemini.generate_improvement_analysis(score, per_question, wrong_topics)
        
        # Save attempt to Firestore
        attempt_data = {
            "student_id": student_id,
            "quiz_id": quiz_id,
            "answers": answers,
            "score": score,
            "correct": correct_count,
            "total": len(questions),
            "per_question": per_question,
            "report": report,
            "submitted_at": datetime.now().isoformat()
        }
        
        attempt_ref = retrieval.db.collection("attempts").document()
        attempt_ref.set(attempt_data)
        
        return jsonify({
            "score": score,
            "total": len(questions),
            "correct": correct_count,
            "incorrect": len(questions) - correct_count,
            "per_question": per_question,
            "report": report,
            "attempt_id": attempt_ref.id
        })
        
    except Exception as e:
        print(f"Error in grade_quiz: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("=" * 70)
    print("🤖 AI Quiz Backend Server")
    print("=" * 70)
    print("\nEndpoints:")
    print("  GET  /health          - Health check")
    print("  POST /generate_mcq    - Generate quiz")
    print("  POST /grade_quiz      - Grade and analyze")
    print("\n" + "=" * 70)
    print("Starting server on http://localhost:5000")
    print("=" * 70 + "\n")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
