import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp, DocumentSnapshot;


/// Top-level model for the homepage payload.
class HomePageModel {
  final String? selectedClass;      // e.g. "5" or "KG"
  final String? selectedSubject;    // e.g. "Math"
  final List<NewsItem> news;        // horizontal scroller
  final List<Tutor> featuredTutors; // top carousel / highlighted tutors
  final List<Tutor> tutors;         // main vertical list (paged)
  final SearchFilter filter;        // current search/filter state
  final int bottomNavIndex;         // 0=home,1=ai test,2=analysis,3=notes
  final int notificationCount;
  final DateTime? lastUpdated;

  HomePageModel({
    this.selectedClass,
    this.selectedSubject,
    required this.news,
    required this.featuredTutors,
    required this.tutors,
    required this.filter,
    this.bottomNavIndex = 0,
    this.notificationCount = 0,
    this.lastUpdated,
  });

  factory HomePageModel.fromJson(Map<String, dynamic> json) {
    return HomePageModel(
      selectedClass: json['selectedClass'] as String?,
      selectedSubject: json['selectedSubject'] as String?,
      news: (json['news'] as List<dynamic>? ?? [])
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredTutors: (json['featuredTutors'] as List<dynamic>? ?? [])
          .map((e) => Tutor.fromJson(e as Map<String, dynamic>))
          .toList(),
      tutors: (json['tutors'] as List<dynamic>? ?? [])
          .map((e) => Tutor.fromJson(e as Map<String, dynamic>))
          .toList(),
      filter: json['filter'] != null
          ? SearchFilter.fromJson(json['filter'] as Map<String, dynamic>)
          : SearchFilter(), // default empty filter
      bottomNavIndex: json['bottomNavIndex'] as int? ?? 0,
      notificationCount: json['notificationCount'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'selectedClass': selectedClass,
    'selectedSubject': selectedSubject,
    'news': news.map((e) => e.toJson()).toList(),
    'featuredTutors': featuredTutors.map((t) => t.toJson()).toList(),
    'tutors': tutors.map((t) => t.toJson()).toList(),
    'filter': filter.toJson(),
    'bottomNavIndex': bottomNavIndex,
    'notificationCount': notificationCount,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };
}

/// A short news/announcement item for the horizontal scroller.
class NewsItem {
  final String id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? link;

  NewsItem({
    required this.id,
    required this.title,
    this.summary,
    this.imageUrl,
    this.publishedAt,
    this.link,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String?,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: json['publishedAt'] != null
          ? (json['publishedAt'] as Timestamp).toDate()
          : null,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'imageUrl': imageUrl,
    'publishedAt': publishedAt?.toIso8601String(),
    'link': link,
  };
}

/// Minimal location object (expand if you need more address components).
class Location {
  final String? city;
  final String? address;
  final double? lat;
  final double? lng;

  Location({this.city, this.address, this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    city: json['city'] as String?,
    address: json['address'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'city': city,
    'address': address,
    'lat': lat,
    'lng': lng,
  };
}

/// Tutor model used in lists (light-weight for fast listing).
class Tutor {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String? bio;
  final List<String> subjects; // e.g. ["Math","Science"]
  final List<String> classes;  // e.g. ["5","6","10"]
  final double rating; // 0.0 - 5.0
  final int reviewsCount;
  final Location? location;
  final int experienceYears;
  final List<String> languages;

  // Optional place for extra metadata (JSON blob)
  final Map<String, dynamic>? extra;

  Tutor({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.bio,
    required this.subjects,
    required this.classes,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.location,
    this.experienceYears = 0,
    this.languages = const [],
    this.extra,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      classes: (json['classes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      experienceYears: json['experienceYears'] as int? ?? 0,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      extra: (json['extra'] as Map<String, dynamic>?) != null
          ? Map<String, dynamic>.from(json['extra'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'subjects': subjects,
    'classes': classes,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'location': location?.toJson(),
    'experienceYears': experienceYears,
    'languages': languages,
    'extra': extra,
  };
}


/// Current search/filter settings for the homepage search bar / filters.
class SearchFilter {
  final String? classLevel;    // e.g. "7"
  final String? subject;       // e.g. "English"
  final double? radiusKm;      // proximity search
  final double? minRating;     // 0-5
  final double? maxFee;        // rupees/hours or chosen currency
  final String sortBy;         // "relevance","rating","distance","fee","experience"
  final String teachingMode;   // "any","online","offline"

  SearchFilter({
    this.classLevel,
    this.subject,
    this.radiusKm,
    this.minRating,
    this.maxFee,
    this.sortBy = 'relevance',
    this.teachingMode = 'any',
  });

  factory SearchFilter.fromJson(Map<String, dynamic> json) => SearchFilter(
    classLevel: json['classLevel'] as String?,
    subject: json['subject'] as String?,
    radiusKm: (json['radiusKm'] as num?)?.toDouble(),
    minRating: (json['minRating'] as num?)?.toDouble(),
    maxFee: (json['maxFee'] as num?)?.toDouble(),
    sortBy: json['sortBy'] as String? ?? 'relevance',
    teachingMode: json['teachingMode'] as String? ?? 'any',
  );

  Map<String, dynamic> toJson() => {
    'classLevel': classLevel,
    'subject': subject,
    'radiusKm': radiusKm,
    'minRating': minRating,
    'maxFee': maxFee,
    'sortBy': sortBy,
    'teachingMode': teachingMode,
  };
}
