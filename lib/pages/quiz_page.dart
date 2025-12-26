import 'package:flutter/material.dart';
import 'package:lla_sample/models/quiz_model.dart';
import 'package:lla_sample/services/quiz_service.dart';
import 'design_course_app_theme.dart';
import 'quiz_results_page.dart';

class QuizPage extends StatefulWidget {
  final String classId;
  final String subjectId;
  final String chapterId;

  const QuizPage({
    Key? key,
    required this.classId,
    required this.subjectId,
    required this.chapterId,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Quiz? _quiz;
  List<int?> _answers = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() => _loading = true);

    try {
      final quiz = await QuizService.generateQuiz(
        classId: widget.classId,
        subjectId: widget.subjectId,
        chapterId: widget.chapterId,
        numQuestions: 10,
      );

      setState(() {
        _quiz = quiz;
        _answers = List.filled(quiz.questions.length, null);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to generate quiz: $e');
      Navigator.pop(context);
    }
  }

  void _submitQuiz() async {
    // Check if all questions are answered
    if (_answers.contains(null)) {
      _showError('Please answer all questions');
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await QuizService.submitQuiz(
        quizId: _quiz!.quizId,
        answers: _answers.cast<int>().toList(),
        studentId: 'student_demo',
      );

      setState(() => _submitting = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsPage(result: result),
        ),
      );
    } catch (e) {
      setState(() => _submitting = false);
      _showError('Failed to submit quiz: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: DesignCourseAppTheme.nearlyWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating AI Quiz...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_quiz == null) return const SizedBox();

    final question = _quiz!.questions[_currentIndex];

    return Scaffold(
      backgroundColor: DesignCourseAppTheme.nearlyWhite,
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_quiz!.questions.length}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DesignCourseAppTheme.nearlyBlue,
                DesignCourseAppTheme.nearlyDarkBlue,
              ],
            ),
          ),
        ),
      ),
      body: _submitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Grading Quiz...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final optionValue = index + 1; // 1-based
                        final isSelected = _answers[_currentIndex] == optionValue;

                        return Card(
                          elevation: isSelected ? 6 : 2,
                          color: isSelected
                              ? DesignCourseAppTheme.nearlyBlue.withOpacity(0.1)
                              : Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: RadioListTile<int>(
                            value: optionValue,
                            groupValue: _answers[_currentIndex],
                            onChanged: (value) {
                              setState(() {
                                _answers[_currentIndex] = value;
                              });
                            },
                            title: Text(
                              '${String.fromCharCode(65 + index)}. ${question.options[index]}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            activeColor: DesignCourseAppTheme.nearlyBlue,
                          ),
                        );
                      },
                    ),
                  ),
                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _currentIndex--);
                            },
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < _quiz!.questions.length - 1) {
                              setState(() => _currentIndex++);
                            } else {
                              _submitQuiz();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentIndex == _quiz!.questions.length - 1
                                ? Colors.green
                                : DesignCourseAppTheme.nearlyBlue,
                          ),
                          child: Text(
                            _currentIndex == _quiz!.questions.length - 1
                                ? 'Submit Quiz'
                                : 'Next',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
