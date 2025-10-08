import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lla_sample/main.dart';
import 'design_course_app_theme.dart';
import '/models/homepage_model.dart';
import 'news_list_UI.dart';
import 'package:lla_sample/models//userprofile.dart';
import 'tutor_UI.dart';
import 'bottom_bar_view.dart';

import 'package:lla_sample/services/location_service.dart';
import 'package:lla_sample/models/location_model.dart';
import 'package:lla_sample/widgets/location_selection_dialog.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _bottomNavIndex = 0;
  String searchQuery = "";
  Set<String> selectedCategories = {}; // Multiple categories can be selected
  final TextEditingController _searchController = TextEditingController();
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  UserLocation? _currentLocation;

  // Define your categories - you can modify these based on your needs
  final List<String> categories = [
    "English",
    "Hindi",
    "Mathematics",
    "Science",
    "Social Science",
    "Computer"
  ];

  @override
  void initState() {
    super.initState();
    // _loadUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Future<void> _loadUserLocation() async {
  //   final location = await LocationService.getUserLocation();
  //   if (mounted) {
  //     setState(() {
  //       _currentLocation = location;
  //     });
  //   }
  // }

  Future<void> _showLocationDialog() async {
    showDialog(
      context: context,
      builder: (context) => BlinkitLocationDialog(
        currentLocation: _currentLocation,
        onLocationSelected: (location) async {
          setState(() {
            _currentLocation = location;
          });
          await LocationService.setDefaultLocation(location);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location updated to ${location.city}'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                getAppBarUI(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        getSearchBarUI(),
                        getCategoriesUI(), // New categories section
                        getNewsUI(),
                        FilteredTutorsSection(
                          searchQuery: searchQuery,
                          selectedCategories: selectedCategories,
                          callBack: (tutor) {
                            print("Tutor tapped: ${tutor.name}");
                          },
                        ),
                        // Add padding at bottom to account for bottom bar
                        SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomBarView(
                tabIconsList: tabIconsList,
                changeIndex: (int index) {
                  setState(() {
                    _bottomNavIndex = index;
                  });
                  _handleBottomNavigation(index);
                },
                addClick: () {
                  _handleAddButtonClick();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    // Handle navigation based on selected tab
    switch (index) {
      case 0:
      // Home tab - already on home page
        print("Home tab selected");
        break;
      case 1:
      // Second tab - you can navigate to another page
        print("Tab 2 selected");
        // Navigator.pushNamed(context, '/page2');
        break;
      case 2:
      // Third tab
        print("Tab 3 selected");
        // Navigator.pushNamed(context, '/page3');
        break;
      case 3:
      // Fourth tab
        print("Tab 4 selected");
        // Navigator.pushNamed(context, '/page4');
        break;
    }
  }

  void _handleAddButtonClick() {
    // Handle the floating action button click
    print("Add button clicked");
    // You can show a dialog, navigate to a new page, etc.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New'),
          content: Text('What would you like to add?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add your action here
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor('#F8FAFB'),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(13.0),
                    bottomLeft: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          controller: _searchController,
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: DesignCourseAppTheme.nearlyBlue,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Search tutors or subjects',
                            border: InputBorder.none,
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('#B9BABC'),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              color: HexColor('#B9BABC'),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value.trim().toLowerCase();
                            });
                          },
                          onEditingComplete: () {
                            // Handle search completion if needed
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        icon: Icon(Icons.search, color: HexColor('#B9BABC')),
                        onPressed: () {
                          // Trigger search
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: SizedBox(),
          )
        ],
      ),
    );
  }

  Widget getCategoriesUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional: Add a title for categories
          // Text(
          //   'Categories',
          //   style: TextStyle(
          //     fontWeight: FontWeight.w600,
          //     fontSize: 16,
          //     color: DesignCourseAppTheme.darkerText,
          //   ),
          // ),
          // SizedBox(height: 12),

          // Categories chips
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: categories.map((category) {
              bool isSelected = selectedCategories.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Multi-select: Add if not selected, remove if already selected
                    if (isSelected) {
                      selectedCategories.remove(category);
                    } else {
                      selectedCategories.add(category);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignCourseAppTheme.nearlyBlue
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? DesignCourseAppTheme.nearlyBlue
                          : DesignCourseAppTheme.grey.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : DesignCourseAppTheme.darkerText,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Location row with tap functionality
                GestureDetector(
                  onTap: _showLocationDialog,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: DesignCourseAppTheme.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentLocation?.displayName ?? 'Select Location',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.2,
                          color: DesignCourseAppTheme.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: DesignCourseAppTheme.grey,
                      ),
                    ],
                  ),
                ),
                // Company name
                Text(
                  'Lil Achievers Acad',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.27,
                    color: DesignCourseAppTheme.darkerText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            child: Image.asset('assets/homepage/userImage.png'),
          )
        ],
      ),
    );
  }

  Widget getNewsUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
          child: Text(
            'Latest News',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
              color: DesignCourseAppTheme.darkerText,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        NewsListView(
          callBack: (newsItem) {
            debugPrint("Tapped on: ${newsItem.title}");
          },
        ),
      ],
    );
  }
}

// Enhanced Featured Tutors Section with filtering
class FilteredTutorsSection extends StatelessWidget {
  const FilteredTutorsSection({
    Key? key,
    this.callBack,
    required this.searchQuery,
    required this.selectedCategories,
  }) : super(key: key);

  final Function(Tutor)? callBack;
  final String searchQuery;
  final Set<String> selectedCategories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
          child: Text(
            _getSectionTitle(),
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
        FilteredTutorListView(
          callBack: callBack,
          searchQuery: searchQuery,
          selectedCategories: selectedCategories,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _getSectionTitle() {
    if (searchQuery.isNotEmpty) {
      return 'Search Results';
    } else if (selectedCategories.isNotEmpty) {
      if (selectedCategories.length == 1) {
        return '${selectedCategories.first} Tutors';
      } else {
        return 'Filtered Tutors (${selectedCategories.length} subjects)';
      }
    } else {
      return 'Featured Tutors';
    }
  }
}

// Enhanced Tutor List View with filtering
class FilteredTutorListView extends StatefulWidget {
  const FilteredTutorListView({
    Key? key,
    this.callBack,
    required this.searchQuery,
    required this.selectedCategories,
  }) : super(key: key);

  final Function(Tutor)? callBack;
  final String searchQuery;
  final Set<String> selectedCategories;

  @override
  _FilteredTutorListViewState createState() => _FilteredTutorListViewState();
}

class _FilteredTutorListViewState extends State<FilteredTutorListView>
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

  // Filter tutors based on search query and selected categories
  List<Tutor> filterTutors(List<Tutor> tutors) {
    List<Tutor> filtered = tutors;

    // Apply category filter - show tutors who teach ALL of the selected subjects (AND logic)
    if (widget.selectedCategories.isNotEmpty) {
      filtered = filtered.where((tutor) {
        // Check if tutor has ALL selected subjects
        return widget.selectedCategories.every((selectedCategory) {
          return tutor.subjects.any((subject) {
            // More flexible matching - check if subject contains category or vice versa
            String subjectLower = subject.toLowerCase().trim();
            String categoryLower = selectedCategory.toLowerCase().trim();

            return subjectLower.contains(categoryLower) ||
                categoryLower.contains(subjectLower) ||
                subjectLower == categoryLower;
          });
        });
      }).toList();
    }

    // Apply search filter
    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((tutor) {
        // Search in tutor name
        bool nameMatch = tutor.name.toLowerCase().contains(widget.searchQuery);

        // Search in tutor subjects
        bool subjectMatch = tutor.subjects.any((subject) =>
            subject.toLowerCase().contains(widget.searchQuery)
        );

        return nameMatch || subjectMatch;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tutors')
            .limit(20) // Increased limit for better search results
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

          List<Tutor> allTutors = snapshot.data!.docs.map((doc) {
            return Tutor.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          // Apply filters
          List<Tutor> filteredTutors = filterTutors(allTutors);

          // Show "no results" message if filtered list is empty
          if (filteredTutors.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: DesignCourseAppTheme.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tutors found',
                      style: TextStyle(
                        color: DesignCourseAppTheme.darkerText,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.searchQuery.isNotEmpty
                          ? 'Try searching with different keywords'
                          : 'No tutors available for this category',
                      style: TextStyle(
                        color: DesignCourseAppTheme.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double aspectRatio;

              if (screenWidth > 400) {
                aspectRatio = 0.75;
              } else if (screenWidth > 320) {
                aspectRatio = 0.68;
              } else {
                aspectRatio = 0.6;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: filteredTutors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  final int count = filteredTutors.length;
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
                    callback: () => widget.callBack?.call(filteredTutors[index]),
                    tutor: filteredTutors[index],
                    animation: animation,
                    animationController: animationController,
                    cardWidth: (screenWidth - 32) / 2,
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