"""
Gemini AI Service
Handles all interactions with Google's Gemini API for quiz generation and grading
"""

import os
import json
import re
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

class GeminiService:
    def __init__(self):
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY not found in environment")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.5-flash')
    
    def generate_mcqs(self, context_chunks, num_questions=10):
        """
        Generate MCQ questions using retrieved context chunks
        """
        # Build context from chunks
        context_text = "\n\n---\n\n".join([
            f"SOURCE: {c.get('id', 'unknown')}:\n{c.get('text', '')[:500]}"
            for c in context_chunks
        ])
        
        prompt = f"""You are an exam question generator for Class 8 students. Use ONLY the following CONTEXT to generate {num_questions} multiple-choice questions.

STRICT REQUIREMENTS:
- Each question must have exactly 4 options (A, B, C, D)
- Mark the correct answer with its index (1-4)
- Provide a brief explanation
- Label difficulty: easy, medium, or hard
- Reference the source chunk

Return ONLY a valid JSON array with this exact structure:
[
  {{
    "q": "question text here",
    "options": ["option A", "option B", "option C", "option D"],
    "answer": 2,
    "explanation": "brief explanation using context",
    "difficulty": "medium",
    "source": "chunk id"
  }}
]

CONTEXT:
{context_text}

Generate exactly {num_questions} questions. Return ONLY the JSON array, no other text.
"""
        
        try:
            response = self.model.generate_content(prompt)
            text = response.text
            
            # Extract JSON from response
            questions = self._extract_json(text)
            
            # Validate structure
            if not isinstance(questions, list):
                raise ValueError("Response is not a list")
            
            return questions
            
        except Exception as e:
            print(f"Error generating MCQs: {e}")
            raise
    
    def generate_improvement_analysis(self, score, per_question, wrong_topics):
        """
        Generate detailed improvement analysis based on quiz performance
        """
        # Build errors summary
        errors = [
            f"Q: {pq['q'][:60]}... - Selected: {pq['selected']}, Correct: {pq['correct']}"
            for pq in per_question if not pq.get('ok', False)
        ]
        errors_text = "\n".join(errors) if errors else "All correct!"
        
        topics_text = ", ".join([f"{topic} ({count} errors)" for topic, count in wrong_topics.items()])
"""
Gemini AI Service
Handles all interactions with Google's Gemini API for quiz generation and grading
"""

import os
import json
import re
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

class GeminiService:
    def __init__(self):
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY not found in environment")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.5-flash')
    
    def generate_mcqs(self, context_chunks, num_questions=10):
        """
        Generate MCQ questions using retrieved context chunks
        """
        # Build context from chunks
        context_text = "\n\n---\n\n".join([
            f"SOURCE: {c.get('id', 'unknown')}:\n{c.get('text', '')[:500]}"
            for c in context_chunks
        ])
        
        prompt = f"""You are an exam question generator for Class 8 students. Use ONLY the following CONTEXT to generate {num_questions} multiple-choice questions.

STRICT REQUIREMENTS:
- Each question must have exactly 4 options (A, B, C, D)
- Mark the correct answer with its index (1-4)
- Provide a brief explanation
- Label difficulty: easy, medium, or hard
- Reference the source chunk

Return ONLY a valid JSON array with this exact structure:
[
  {{
    "q": "question text here",
    "options": ["option A", "option B", "option C", "option D"],
    "answer": 2,
    "explanation": "brief explanation using context",
    "difficulty": "medium",
    "source": "chunk id"
  }}
]

CONTEXT:
{context_text}

Generate exactly {num_questions} questions. Return ONLY the JSON array, no other text.
"""
        
        try:
            response = self.model.generate_content(prompt)
            text = response.text
            
            # Extract JSON from response
            questions = self._extract_json(text)
            
            # Validate structure
            if not isinstance(questions, list):
                raise ValueError("Response is not a list")
            
            return questions
            
        except Exception as e:
            print(f"Error generating MCQs: {e}")
            raise
    
    def generate_improvement_analysis(self, score, per_question, wrong_topics):
        """
        Generate detailed improvement analysis based on quiz performance
        """
        # Build errors summary
        errors = [
            f"Q: {pq['q'][:60]}... - Selected: {pq['selected']}, Correct: {pq['correct']}"
            for pq in per_question if not pq.get('ok', False)
        ]
        errors_text = "\n".join(errors) if errors else "All correct!"
        
        topics_text = ", ".join([f"{topic} ({count} errors)" for topic, count in wrong_topics.items()])
        
        prompt = f"""You are an educational coach analyzing a Class 8 student's quiz performance.

STUDENT PERFORMANCE:
- Score: {score}%
- Incorrect questions: {len(errors)}/{len(per_question)}
- Weak topics (internal IDs): {topics_text}

ERRORS:
{errors_text}

Provide a detailed, encouraging improvement report in JSON format.

IMPORTANT INSTRUCTIONS:
1. Map the "internal IDs" (e.g., pyq2024_chunk14) to real NCERT Chapter Topics/Subtopics based on the context of the error. Do NOT show the internal IDs to the user.
2. Suggest specific NCERT chapter sections to read.
3. Be specific, encouraging, and actionable.

Return ONLY a valid JSON object with this exact structure:
{{
  "weaknesses": [
    {{
      "topic": "Real Topic Name (e.g., Reactivity Series of Metals)",
      "count": number_of_errors,
      "description": "Specific concept they missed (e.g., Failed to identify most reactive metal)"
    }},
    ...
  ],
  "steps": [
    "Read Section 4.2 in NCERT Science Book",
    "Practice identifying displacement reactions",
    ...
  ],
  "checklist": [
    "Solve In-text Question #3 on page 45",
    "Review Table 4.1: Physical Properties",
    ...
  ],
  "summary": "encouraging 2-3 sentence summary with specific guidance"
}}

Return ONLY the JSON object. Do not use markdown formatting like ```json.
"""
        
        try:
            response = self.model.generate_content(prompt)
            text = response.text
            
            report = self._extract_json(text)
            
            # Ensure required fields
            if not isinstance(report, dict):
                report = {"summary": text}
            
            return report
            
        except Exception as e:
            print(f"Error generating analysis: {e}")
            # Fallback report
            return {
                "weaknesses": [{"topic": "General Review", "count": 1, "description": "Review the chapter content"}],
                "steps": ["Read the chapter again", "Practice more questions"],
                "checklist": ["Complete chapter exercises"],
                "summary": f"You scored {score}%. Please review the chapter content and try again."
            }
    
    def _extract_json(self, text):
        """Extract JSON from model response that might have extra text"""
        # Remove markdown code blocks if present
        text = re.sub(r'```json\s*', '', text)
        text = re.sub(r'```\s*', '', text)
        text = text.strip()

        # Try direct parse first
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        
        # Try to find JSON array or object
        # Look for array
        array_match = re.search(r'\[\s*\{.*\}\s*\]', text, re.DOTALL)
        if array_match:
            try:
                return json.loads(array_match.group(0))
            except json.JSONDecodeError:
                pass
        
        # Look for object
        object_match = re.search(r'\{\s*".*\}\s*', text, re.DOTALL)
        if object_match:
            try:
                return json.loads(object_match.group(0))
            except json.JSONDecodeError:
                pass
        
        # Give up and return empty
        print(f"FAILED TO EXTRACT JSON: {text}")
        raise ValueError(f"Could not extract JSON from response")
