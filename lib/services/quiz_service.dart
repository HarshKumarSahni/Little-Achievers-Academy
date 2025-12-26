import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lla_sample/models/quiz_model.dart';

class QuizService {
  // Change this to your backend URL
  // For local testing: 'http://localhost:5000'
  // For deployed backend: 'https://your-backend-url.com'
  static const String baseUrl = 'http://192.168.1.40:5000';

  /// Generate MCQ quiz for a chapter
  static Future<Quiz> generateQuiz({
    required String classId,
    required String subjectId,
    required String chapterId,
    int numQuestions = 10,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate_mcq'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'class_id': classId,
          'subject_id': subjectId,
          'chapter_id': chapterId,
          'num_questions': numQuestions,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quiz.fromJson(data);
      } else {
        throw Exception('Failed to generate quiz: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating quiz: $e');
    }
  }

  /// Submit quiz answers and get results with AI analysis
  static Future<QuizResult> submitQuiz({
    required String quizId,
    required List<int> answers,
    String studentId = 'anonymous',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/grade_quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quiz_id': quizId,
          'answers': answers,
          'student_id': studentId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuizResult.fromJson(data);
      } else {
        throw Exception('Failed to grade quiz: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error grading quiz: $e');
    }
  }

  /// Check backend health
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
