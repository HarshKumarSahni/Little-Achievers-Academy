import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check and request location permissions
  static Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return permission;
  }

  // Get current GPS location
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    await checkPermission();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Convert coordinates to address (Reverse Geocoding)
  static Future<UserLocation> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String fullAddress = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        return UserLocation(
          label: 'Current Location',
          fullAddress: fullAddress,
          area: place.subLocality ?? '',
          street: place.street ?? '',
          city: place.locality ?? '',
          state: place.administrativeArea ?? '',
          country: place.country ?? 'India',
          pincode: place.postalCode,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (e) {
      print('Error getting address: $e');
    }

    throw Exception('Could not get address from coordinates');
  }

  // Get current location with address
  static Future<UserLocation> getCurrentLocationWithAddress() async {
    Position position = await getCurrentPosition();
    return await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }

  // Save address to Firestore
  static Future<String> saveAddress(UserLocation location) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .collection('addresses')
        .add(location.toJson());

    return docRef.id;
  }

  // Get all saved addresses
  static Future<List<UserLocation>> getSavedAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UserLocation.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // Update address
  static Future<void> updateAddress(UserLocation location) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || location.id == null) return;

    await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .collection('addresses')
        .doc(location.id)
        .update(location.toJson());
  }

  // Delete address
  static Future<void> deleteAddress(String addressId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('students')
        .doc(user.uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  // Set default location locally
  static Future<void> setDefaultLocation(UserLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_location', location.id ?? '');
  }

  // Get default location
  static Future<UserLocation?> getDefaultLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationId = prefs.getString('default_location');

    if (locationId != null && locationId.isNotEmpty) {
      final addresses = await getSavedAddresses();

      try {
        // Find the address with matching ID
        return addresses.firstWhere((addr) => addr.id == locationId);
      } catch (e) {
        // If not found, return first address or null
        return addresses.isNotEmpty ? addresses.first : null;
      }
    }

    return null;
  }

}
