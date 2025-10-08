import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'design_course_app_theme.dart';
import 'package:lla_sample/main.dart';
import '/models/homepage_model.dart';

class TutorListView extends StatefulWidget {
  const TutorListView({Key? key, this.callBack}) : super(key: key);

  final Function(Tutor)? callBack;

  @override
  _TutorListViewState createState() => _TutorListViewState();
}

class FeaturedTutorsSection extends StatelessWidget {
  const FeaturedTutorsSection({Key? key, this.callBack}) : super(key: key);

  final Function(Tutor)? callBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
          child: Text(
            'Featured Tutors',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
              color: DesignCourseAppTheme.darkerText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TutorListView(callBack: callBack),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _TutorListViewState extends State<TutorListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tutors')
            .limit(10)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading tutors',
                style: TextStyle(
                  color: DesignCourseAppTheme.grey,
                  fontSize: 16,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tutors available',
                style: TextStyle(
                  color: DesignCourseAppTheme.grey,
                  fontSize: 16,
                ),
              ),
            );
          }

          List<Tutor> tutors = snapshot.data!.docs.map((doc) {
            return Tutor.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          // AUTO-ADAPTIVE: Let GridView determine its own height based on content
          return LayoutBuilder(
            builder: (context, constraints) {
              // Get screen width to calculate optimal card size
              double screenWidth = constraints.maxWidth;
              double cardWidth = (screenWidth - 32) / 2; // 2 columns with padding

              // Calculate optimal aspect ratio based on screen size
              double aspectRatio;
              if (screenWidth > 400) {
                aspectRatio = 0.75; // Wider screens can handle taller cards
              } else if (screenWidth > 320) {
                aspectRatio = 0.68; // Medium screens
              } else {
                aspectRatio = 0.6; // Smaller screens need more height for content
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true, // AUTO-SIZE: Grid takes only needed space
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: tutors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: aspectRatio, // Dynamic based on screen size
                ),
                itemBuilder: (context, index) {
                  final int count = tutors.length;
                  final Animation<double> animation =
                  Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval(
                        (1 / count) * index,
                        1.0,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                  );
                  animationController?.forward();

                  return TutorView(
                    callback: () => widget.callBack?.call(tutors[index]),
                    tutor: tutors[index],
                    animation: animation,
                    animationController: animationController,
                    cardWidth: cardWidth, // Pass calculated width
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TutorView extends StatelessWidget {
  const TutorView({
    Key? key,
    this.tutor,
    this.animationController,
    this.animation,
    this.callback,
    this.cardWidth = 180.0, // Default fallback width
  }) : super(key: key);

  final VoidCallback? callback;
  final Tutor? tutor;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    // RESPONSIVE: Calculate sizes based on card width
    double imageHeight = cardWidth * 0.8; // 60% of card width
    double fontSize = cardWidth < 150 ? 12 : 14;
    double subjectFontSize = cardWidth < 150 ? 10 : 11;
    double iconSize = cardWidth < 150 ? 12 : 14;

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              50 * (1.0 - animation!.value),
              0.0,
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: callback,
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor('#F8FAFB'),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: DesignCourseAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(0.0, 2.0),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    // RESPONSIVE: Dynamic image height
                    Container(
                      height: imageHeight,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          child: tutor!.profileImageUrl != null &&
                              tutor!.profileImageUrl!.isNotEmpty
                              ? Image.network(
                            tutor!.profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                    ),

                    // RESPONSIVE: Content section that adapts to remaining space
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Name and subjects section
                            Flexible(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    tutor!.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize, // Dynamic font size
                                      letterSpacing: 0.27,
                                      color: DesignCourseAppTheme.darkerText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tutor!.subjects.take(2).join(', '),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: subjectFontSize, // Dynamic font size
                                      letterSpacing: 0.27,
                                      color: DesignCourseAppTheme.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom info section
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      '${tutor!.experienceYears} years exp',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: subjectFontSize - 1,
                                        letterSpacing: 0.27,
                                        color: DesignCourseAppTheme.grey,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        '${tutor!.rating.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: fontSize - 1,
                                          letterSpacing: 0.27,
                                          color: DesignCourseAppTheme.darkerText,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.star,
                                        color: DesignCourseAppTheme.nearlyBlue,
                                        size: iconSize,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignCourseAppTheme.nearlyBlue,
            DesignCourseAppTheme.nearlyBlue.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: cardWidth * 0.25, // RESPONSIVE: Icon size based on card width
          color: Colors.white,
        ),
      ),
    );
  }
}