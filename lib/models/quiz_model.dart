class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;  // 1-based index
  final String explanation;
  final String difficulty;
  final String source;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.source,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['q'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['answer'] ?? 1,
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': question,
      'options': options,
      'answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'source': source,
    };
  }
}

class Quiz {
  final String quizId;
  final List<QuizQuestion> questions;
  final int totalQuestions;

  Quiz({
    required this.quizId,
    required this.questions,
    required this.totalQuestions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<QuizQuestion> questions = questionsList
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    return Quiz(
      quizId: json['quiz_id'] ?? '',
      questions: questions,
      totalQuestions: json['total_questions'] ?? questions.length,
    );
  }
}

class QuizResult {
  final int score;
  final int total;
  final int correct;
  final int incorrect;
  final List<QuestionResult> perQuestion;
  final ImprovementReport report;

  QuizResult({
    required this.score,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.perQuestion,
    required this.report,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    var perQuestionList = json['per_question'] as List? ?? [];
    List<QuestionResult> perQuestion = perQuestionList
        .map((q) => QuestionResult.fromJson(q as Map<String, dynamic>))
        .toList();

    return QuizResult(
      score: json['score'] ?? 0,
      total: json['total'] ?? 0,
      correct: json['correct'] ?? 0,
      incorrect: json['incorrect'] ?? 0,
      perQuestion: perQuestion,
      report: ImprovementReport.fromJson(json['report'] ?? {}),
    );
  }
}

class QuestionResult {
  final String question;
  final int selected;
  final int correct;
  final bool isCorrect;
  final String explanation;

  QuestionResult({
    required this.question,
    required this.selected,
    required this.correct,
    required this.isCorrect,
    required this.explanation,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      question: json['q'] ?? '',
      selected: json['selected'] ?? 0,
      correct: json['correct'] ?? 0,
      isCorrect: json['ok'] ?? false,
      explanation: json['explanation'] ?? '',
    );
  }
}

class ImprovementReport {
  final List<Weakness> weaknesses;
  final List<String> steps;
  final List<String> checklist;
  final String summary;

  ImprovementReport({
    required this.weaknesses,
    required this.steps,
    required this.checklist,
    required this.summary,
  });

  factory ImprovementReport.fromJson(Map<String, dynamic> json) {
    var weaknessesList = json['weaknesses'] as List? ?? [];
    List<Weakness> weaknesses = weaknessesList
        .map((w) => Weakness.fromJson(w as Map<String, dynamic>))
        .toList();

    return ImprovementReport(
      weaknesses: weaknesses,
      steps: List<String>.from(json['steps'] ?? []),
      checklist: List<String>.from(json['checklist'] ?? []),
      summary: json['summary'] ?? '',
    );
  }
}

class Weakness {
  final String topic;
  final int count;
  final String description;

  Weakness({
    required this.topic,
    required this.count,
    required this.description,
  });

  factory Weakness.fromJson(Map<String, dynamic> json) {
    return Weakness(
      topic: json['topic'] ?? '',
      count: json['count'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}
