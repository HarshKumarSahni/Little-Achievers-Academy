import 'package:flutter/material.dart';
import '../models/location_model.dart';

class AddAddressScreen extends StatefulWidget {
  final Function(UserLocation) onAddressAdded;

  const AddAddressScreen({Key? key, required this.onAddressAdded})
      : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedLabel = 'Home';

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final fullAddress = '${_flatController.text}, ${_areaController.text}, '
          '${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}';

      final location = UserLocation(
        label: _selectedLabel,
        fullAddress: fullAddress,
        area: _areaController.text,
        street: _flatController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: 'India',
        pincode: _pincodeController.text,
        phoneNumber: _phoneController.text,
      );

      widget.onAddressAdded(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Address type selector
            Row(
              children: [
                _buildLabelChip('Home'),
                SizedBox(width: 8),
                _buildLabelChip('Work'),
                SizedBox(width: 8),
                _buildLabelChip('Other'),
              ],
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _flatController,
              decoration: InputDecoration(
                labelText: 'Flat / House no / Floor / Building',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Area / Sector / Locality',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _pincodeController,
              decoration: InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Required' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Save Address',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    final isSelected = _selectedLabel == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedLabel = label;
        });
      },
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  void dispose() {
    _flatController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
