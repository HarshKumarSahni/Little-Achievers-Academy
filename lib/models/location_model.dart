class UserLocation {
  final String? id; // For saved addresses
  final String label; // "Home", "Work", "Other"
  final String fullAddress; // Complete address string
  final String? area;
  final String? street;
  final String city;
  final String state;
  final String country;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final bool isDefault;

  UserLocation({
    this.id,
    required this.label,
    required this.fullAddress,
    this.area,
    this.street,
    required this.city,
    required this.state,
    required this.country,
    this.pincode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.isDefault = false,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'],
      label: json['label'] ?? 'Other',
      fullAddress: json['fullAddress'] ?? '',
      area: json['area'],
      street: json['street'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
      pincode: json['pincode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phoneNumber: json['phoneNumber'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'area': area,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }

  String get shortAddress => '$area, $city';
  String get displayName => '$city, $state';
}
