import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import 'package:lla_sample/pages/add_address_screen.dart';


class BlinkitLocationDialog extends StatefulWidget {
  final UserLocation? currentLocation;
  final Function(UserLocation) onLocationSelected;

  const BlinkitLocationDialog({
    Key? key,
    this.currentLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _BlinkitLocationDialogState createState() => _BlinkitLocationDialogState();
}

class _BlinkitLocationDialogState extends State<BlinkitLocationDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<UserLocation> _savedAddresses = [];
  bool _isLoadingCurrentLocation = false;
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final addresses = await LocationService.getSavedAddresses();
      setState(() {
        _savedAddresses = addresses;
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
      });
      print('Error loading addresses: $e');
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final location = await LocationService.getCurrentLocationWithAddress();
      widget.onLocationSelected(location);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
    }
  }

  void _addNewAddress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          onAddressAdded: (location) async {
            await LocationService.saveAddress(location);
            widget.onLocationSelected(location);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Select delivery location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for area, street name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // Implement Google Places API search here
              },
            ),
            const SizedBox(height: 16),

            // Use Current Location Button
            ListTile(
              leading: _isLoadingCurrentLocation
                  ? CircularProgressIndicator()
                  : Icon(Icons.my_location, color: Colors.green),
              title: Text(
                'Use current location',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              subtitle: widget.currentLocation != null
                  ? Text(widget.currentLocation!.shortAddress)
                  : null,
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _isLoadingCurrentLocation ? null : _useCurrentLocation,
            ),

            Divider(),

            // Add New Address Button
            ListTile(
              leading: Icon(Icons.add, color: Colors.green),
              title: Text(
                'Add new address',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _addNewAddress,
            ),

            Divider(),

            // Saved Addresses Section
            Text(
              'Your saved addresses',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            // Saved Addresses List
            Expanded(
              child: _isLoadingAddresses
                  ? Center(child: CircularProgressIndicator())
                  : _savedAddresses.isEmpty
                  ? Center(
                child: Text('No saved addresses'),
              )
                  : ListView.builder(
                itemCount: _savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = _savedAddresses[index];
                  final isSelected = widget.currentLocation?.id == address.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.green
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(
                        address.label == 'Home'
                            ? Icons.home
                            : address.label == 'Work'
                            ? Icons.work
                            : Icons.location_on,
                        color: isSelected ? Colors.green : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            address.label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                'You are here',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        address.fullAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                          ),
                          PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                          ),
                          PopupMenuItem(
                            child: Text('Share'),
                            value: 'share',
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteAddress(address);
                          }
                          // Implement edit and share
                        },
                      ),
                      onTap: () {
                        widget.onLocationSelected(address);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAddress(UserLocation address) async {
    if (address.id != null) {
      await LocationService.deleteAddress(address.id!);
      _loadSavedAddresses();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
