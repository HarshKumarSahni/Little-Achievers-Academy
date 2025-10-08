import 'design_course_app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/homepage_model.dart';

class NewsListView extends StatefulWidget {
  const NewsListView({Key? key, this.callBack}) : super(key: key);

  final Function(NewsItem)? callBack;
  @override
  _NewsListViewState createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView>
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
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('news') // <-- Firestore collection name
              .orderBy('publishedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final newsList = snapshot.data!.docs
                .map((doc) => NewsItem.fromJson(
              doc.data() as Map<String, dynamic>,
            ))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: newsList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final count = newsList.length > 10 ? 10 : newsList.length;
                final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
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

                return NewsCard(
                  newsItem: newsList[index],
                  animation: animation,
                  animationController: animationController,
                  callback: widget.callBack,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({
    Key? key,
    required this.newsItem,
    this.animationController,
    this.animation,
    this.callback,
  }) : super(key: key);

  final NewsItem newsItem;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final Function(NewsItem)? callback;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              100 * (1.0 - animation!.value),
              0.0,
              0.0,
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () => callback?.call(newsItem),
              child: SizedBox(
                width: 280,
                child: Stack(
                  children: <Widget>[
                    // Background card with text
                    Container(
                      margin: const EdgeInsets.only(left: 48), // leave space for image
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 60, // shift text further right from image
                          top: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: DesignCourseAppTheme.darkerText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (newsItem.summary != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                                child: Text(
                                  newsItem.summary!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DesignCourseAppTheme.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (newsItem.publishedAt != null)
                              Text(
                                DateFormat.yMMMd().format(newsItem.publishedAt!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Image on the left
                    Positioned(
                      top: 16,
                      left: 16,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                        child: Image.network(
                          newsItem.imageUrl ?? '',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
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

}
