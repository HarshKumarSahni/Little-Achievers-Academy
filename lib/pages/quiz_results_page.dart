import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lla_sample/models/quiz_model.dart';
import 'design_course_app_theme.dart';

class QuizResultsPage extends StatelessWidget {
  final QuizResult result;

  const QuizResultsPage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = result.score / 100.0;
    bool isPassing = result.score >= 50;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8), // Light grey background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Quiz Analysis',
          style: DesignCourseAppTheme.title.copyWith(fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Header Score Section
            _buildScoreHeader(percentage, isPassing),
            const SizedBox(height: 24),
            
            // 2. Question Review Section ("Google Forms" Style)
            _buildSectionTitle('Question Review'),
            _buildQuestionReviewList(context),
            const SizedBox(height: 24),

            // 3. AI Analysis Section
            if (result.report.summary.isNotEmpty) ...[
              _buildSectionTitle('AI Insights'),
              _buildAIAnalysisSection(),
              const SizedBox(height: 24),
            ],
            
            // 4. Detailed AI Recommendations
            if (result.report.weaknesses.isNotEmpty) ...[
              _buildSectionTitle('Focus Areas'),
              _buildWeaknessList(),
              const SizedBox(height: 24),
            ],

            if (result.report.steps.isNotEmpty) ...[
              _buildSectionTitle('Action Plan'),
              _buildActionPlanList(),
              const SizedBox(height: 24),
            ],

            // 5. Back Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignCourseAppTheme.nearlyBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: DesignCourseAppTheme.title.copyWith(
          fontSize: 18, 
          letterSpacing: 0.5,
          color: DesignCourseAppTheme.grey,
        ),
      ),
    );
  }

  Widget _buildScoreHeader(double percentage, bool isPassing) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            animation: true,
            percent: percentage > 1.0 ? 1.0 : percentage,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${result.score}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32.0,
                    color: isPassing ? DesignCourseAppTheme.nearlyBlue : Colors.redAccent,
                  ),
                ),
                Text(
                  isPassing ? "Good Job!" : "Keep Trying",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: isPassing ? DesignCourseAppTheme.nearlyBlue : Colors.redAccent,
            backgroundColor: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "You got ${result.correct} out of ${result.total} questions correct",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: result.perQuestion.asMap().entries.map((entry) {
          int index = entry.key;
          var q = entry.value;
          bool isLast = index == result.perQuestion.length - 1;
          bool isCorrect = q.isCorrect;

          return Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    "Question ${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    q.question,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.question,
                            style: const TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildReviewOption("Your Answer", q.selected, isCorrect ? Colors.green : Colors.red),
                          if (!isCorrect)
                            _buildReviewOption("Correct Answer", q.correct, Colors.green),
                          
                          if (q.explanation.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withOpacity(0.1)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      q.explanation,
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewOption(String label, dynamic value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              "$value",
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: color
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6F56E8).withOpacity(0.1), const Color(0xFF6F56E8).withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6F56E8).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFF6F56E8)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Professor AI says:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6F56E8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.report.summary,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeaknessList() {
    return Column(
      children: result.report.weaknesses.map((weakness) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: Colors.orangeAccent.shade200, width: 4)),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      weakness.topic,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${weakness.count} misses",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  )
                ],
              ),
              if (weakness.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  weakness.description,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionPlanList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: result.report.steps.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          String step = entry.value;
          bool isLast = idx == result.report.steps.length;

          return ListTile(
            leading: CircleAvatar(
              radius: 12,
              backgroundColor: DesignCourseAppTheme.nearlyBlue,
              child: Text(
                "$idx",
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            title: Text(
              step,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          );
        }).toList(),
      ),
    );
  }
}
