import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/class_model.dart';
import '/models/student_model.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StudentModel? currentStudent;
  List<SubjectModel> subjects = [];
  bool isLoading = true;
  String? expandedSubject;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  // Load current student data from shared preferences or Firebase Auth
  Future<void> _loadStudentData() async {
    try {
      print('🔍 [DEBUG] Starting to load student data...');
      
      // TODO: Replace with actual student ID from shared preferences or Firebase Auth
      // For now, using a placeholder student ID
      String studentId = 'Gb1ZK892jvE7qn2viG7i'; // Replace with actual student ID
      print('🔍 [DEBUG] Looking for student ID: $studentId');

      DocumentSnapshot studentDoc = await _firestore
          .collection('students')
          .doc(studentId)
          .get();

      print('🔍 [DEBUG] Student document exists: ${studentDoc.exists}');
      
      if (studentDoc.exists) {
        print('🔍 [DEBUG] Student data: ${studentDoc.data()}');
        
        currentStudent = StudentModel.fromJson(
          studentDoc.data() as Map<String, dynamic>,
          docId: studentDoc.id,
        );
        
        print('🔍 [DEBUG] Student loaded - Name: ${currentStudent!.name}, Class: ${currentStudent!.classNumber}');
        await _loadSubjects();
      } else {
        print('❌ [ERROR] Student document does not exist!');
        setState(() {
          isLoading = false;
          errorMessage = 'Student not found (ID: $studentId). Check Firebase Console.';
        });
      }
    } catch (e, stackTrace) {
      print('❌ [ERROR] Error loading student data: $e');
      print('❌ [STACK TRACE] $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading student: $e';
      });
    }
  }

  // Load subjects based on student's class
  Future<void> _loadSubjects() async {
    if (currentStudent == null) {
      print('⚠️ [WARNING] currentStudent is null, cannot load subjects');
      return;
    }

    try {
      // Construct the class document name based on standard (e.g., "class 8")
      String classDocName = 'class ${currentStudent!.classNumber}';
      print('🔍 [DEBUG] Looking for class: $classDocName');

      // Get all subjects for this class
      QuerySnapshot subjectsSnapshot = await _firestore
          .collection('classes')
          .doc(classDocName)
          .collection('subjects')
          .get();

      print('🔍 [DEBUG] Found ${subjectsSnapshot.docs.length} subjects');

      List<SubjectModel> loadedSubjects = [];

      for (var subjectDoc in subjectsSnapshot.docs) {
        print('🔍 [DEBUG] Subject ID: ${subjectDoc.id}, Data: ${subjectDoc.data()}');
        SubjectModel subject = SubjectModel.fromJson(
          subjectDoc.data() as Map<String, dynamic>,
          docId: subjectDoc.id,
        );
        loadedSubjects.add(subject);
        print('✅ [SUCCESS] Loaded subject: ${subject.subjectName}');
      }

      setState(() {
        subjects = loadedSubjects;
        isLoading = false;
        errorMessage = null;
      });
      print('✅ [SUCCESS] Total ${loadedSubjects.length} subjects loaded');
    } catch (e, stackTrace) {
      print('❌ [ERROR] Error loading subjects: $e');
      print('❌ [STACK TRACE] $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading subjects: $e';
      });
    }
  }

  // Load chapters for a specific subject
  Future<List<ChapterModel>> _loadChapters(String subjectId) async {
    if (currentStudent == null) {
      print('⚠️ [WARNING] currentStudent is null, cannot load chapters');
      return [];
    }

    try {
      // Construct the class document name based on standard (e.g., "class 8")
      String classDocName = 'class ${currentStudent!.classNumber}';
      print('🔍 [DEBUG] Loading chapters for subject: $subjectId in class: $classDocName');

      QuerySnapshot chaptersSnapshot = await _firestore
          .collection('classes')
          .doc(classDocName)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .get();

      print('🔍 [DEBUG] Found ${chaptersSnapshot.docs.length} chapters');
      
      List<ChapterModel> chapters = chaptersSnapshot.docs
          .map((doc) {
            print('🔍 [DEBUG] Chapter ID: ${doc.id}, Data: ${doc.data()}');
            return ChapterModel.fromJson(
              doc.data() as Map<String, dynamic>,
              docId: doc.id,
            );
          })
          .toList();
      
      print('✅ [SUCCESS] Loaded ${chapters.length} chapters');
      return chapters;
    } catch (e, stackTrace) {
      print('❌ [ERROR] Error loading chapters for $subjectId: $e');
      print('❌ [STACK TRACE] $stackTrace');
      return [];
    }
  }

  // Open PDF URL
  Future<void> _openPDF(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF URL available')),
      );
      return;
    }

    try {
      final Uri pdfUri = Uri.parse(url);
      if (await canLaunchUrl(pdfUri)) {
        await launchUrl(pdfUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: $url')),
        );
      }
    } catch (e) {
      print('❌ [ERROR] Error opening PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (currentStudent != null)
              Text(
                '${currentStudent!.name} - Class ${currentStudent!.classNumber}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              Text(errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadStudentData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
      )
          : subjects.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No subjects found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                currentStudent != null
                    ? 'Student: ${currentStudent!.name}\nClass: ${currentStudent!.classNumber}'
                    : 'No student data',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  _loadStudentData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final isExpanded = expandedSubject == subject.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SubjectCard(
                subject: subject,
                isExpanded: isExpanded,
                onTap: () async {
                  if (isExpanded) {
                    setState(() {
                      expandedSubject = null;
                    });
                  } else {
                    setState(() {
                      expandedSubject = subject.id;
                    });
                    // Load chapters when expanded
                    List<ChapterModel> chapters = await _loadChapters(subject.id);
                    setState(() {
                      subjects[index] = subject.copyWith(chapters: chapters);
                    });
                  }
                },
                onChapterTap: (chapter) {
                  _openPDF(chapter.notesURL);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(ChapterModel) onChapterTap;

  const SubjectCard({
    Key? key,
    required this.subject,
    required this.isExpanded,
    required this.onTap,
    required this.onChapterTap,
  }) : super(key: key);

  Color _getSubjectColor(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'english':
        return const Color(0xFF4CAF50);
      case 'hindi':
        return const Color(0xFFFF9800);
      case 'mathematics':
        return const Color(0xFF2196F3);
      case 'science':
        return const Color(0xFF9C27B0);
      case 'social science':
        return const Color(0xFFF44336);
      case 'computer':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  IconData _getSubjectIcon(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'english':
        return Icons.book;
      case 'hindi':
        return Icons.language;
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'social science':
        return Icons.public;
      case 'computer':
        return Icons.computer;
      default:
        return Icons.subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color subjectColor = _getSubjectColor(subject.subjectName);

    return Column(
      children: [
        // Subject Card
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [subjectColor, subjectColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: subjectColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubjectIcon(subject.subjectName),
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    subject.subjectName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),

        // Chapters Dropdown
        if (isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: subject.chapters.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No chapters available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subject.chapters.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
              itemBuilder: (context, index) {
                final chapter = subject.chapters[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: subjectColor.withOpacity(0.2),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: subjectColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    chapter.chapterName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(
                    Icons.picture_as_pdf,
                    color: subjectColor,
                  ),
                  onTap: () => onChapterTap(chapter),
                );
              },
            ),
          ),
      ],
    );
  }
}
