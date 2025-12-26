import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'design_course_app_theme.dart';
import 'package:lla_sample/models/class_model.dart';
import 'quiz_page.dart';

class AIQuizPage extends StatefulWidget {
  const AIQuizPage({Key? key}) : super(key: key);

  @override
  _AIQuizPageState createState() => _AIQuizPageState();
}

class _AIQuizPageState extends State<AIQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSubject;
  String? _selectedChapter; 
  List<SubjectModel> _subjects = [];
  List<ChapterModel> _chapters = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _loading = true);
    
    try {
      // Load subjects for class 8
      final subjectsSnapshot = await _firestore
          .collection('classes')
          .doc('class 8')
          .collection('subjects')
          .get();

      List<SubjectModel> subjects = subjectsSnapshot.docs
          .map((doc) => SubjectModel.fromJson(doc.data(), docId: doc.id))
          .toList();

      setState(() {
        _subjects = subjects;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to load subjects: $e');
    }
  }

  Future<void> _loadChapters(String subjectId) async {
    setState(() => _loading = true);

    try {
      final chaptersSnapshot = await _firestore
          .collection('classes')
          .doc('class 8')
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .get();

      List<ChapterModel> chapters = chaptersSnapshot.docs
          .map((doc) => ChapterModel.fromJson(doc.data(), docId: doc.id))
          .toList();

      setState(() {
        _chapters = chapters;
        _selectedChapter = null;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to load chapters: $e');
    }
  }

  void _startQuiz() {
    if (_selectedSubject == null || _selectedChapter == null) {
      _showError('Please select both subject and chapter');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          classId: 'class 8',
          subjectId: _selectedSubject!,
          chapterId: _selectedChapter!,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignCourseAppTheme.nearlyWhite,
      appBar: AppBar(
        title: const Text('AI Quiz'),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Subject',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignCourseAppTheme.nearlyBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subject Grid
                  Expanded(
                    flex: 2,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2,
                      ),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        final isSelected = _selectedSubject == subject.id;
                        
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedSubject = subject.id);
                            _loadChapters(subject.id);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        DesignCourseAppTheme.nearlyBlue,
                                        DesignCourseAppTheme.nearlyDarkBlue,
                                      ],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                subject.subjectName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Chapter Dropdown
                  if (_selectedSubject != null) ...[
                    const Text(
                      'Select Chapter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DesignCourseAppTheme.nearlyBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedChapter,
                          hint: const Text('Select a chapter'),
                          items: _chapters.map((chapter) {
                            return DropdownMenuItem(
                              value: chapter.id,
                              child: Text(chapter.chapterName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedChapter = value);
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Start Quiz Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedSubject != null && _selectedChapter != null
                          ? _startQuiz
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey.shade300;
                          }
                          return DesignCourseAppTheme.nearlyBlue;
                        }),
                      ),
                      child: const Text(
                        'Generate AI Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
