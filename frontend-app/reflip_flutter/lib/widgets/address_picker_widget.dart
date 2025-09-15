import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/google_maps_service.dart';

class AddressPicker extends StatefulWidget {
  final AddressInfo? initialAddress;
  final Function(AddressInfo) onAddressSelected;

  const AddressPicker({
    Key? key,
    this.initialAddress,
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  State<AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  GoogleMapController? _mapController;
  GoogleMapsConfig? _config;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // 如果有初始地址，设置为选中状态
    if (widget.initialAddress != null) {
      _selectedLocation = LatLng(
        widget.initialAddress!.latitude,
        widget.initialAddress!.longitude,
      );
      _selectedAddress = widget.initialAddress!.formattedAddress;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _config = await GoogleMapsService.getConfig();

      // 如果没有初始地址，使用默认位置或当前位置
      if (_selectedLocation == null && _config != null) {
        // 尝试获取当前位置
        try {
          await _getCurrentLocation();
        } catch (e) {
          // 如果获取当前位置失败，使用默认位置
          _selectedLocation = LatLng(
            _config!.defaultLatitude,
            _config!.defaultLongitude,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize map: $e');
      // 使用香港作为默认位置
      _selectedLocation = const LatLng(22.3193, 114.1694);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    final position = await Geolocator.getCurrentPosition();
    _selectedLocation = LatLng(position.latitude, position.longitude);
    await _getAddressFromCoordinates(_selectedLocation!);
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _selectedAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      }
    } catch (e) {
      debugPrint('Failed to get address from coordinates: $e');
      _selectedAddress =
          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedLocation = newLocation;
        });

        await _getAddressFromCoordinates(newLocation);
        _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Address not found: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapTapped(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
    });

    await _getAddressFromCoordinates(location);

    setState(() {
      _isLoading = false;
    });
  }

  void _onConfirmAddress() {
    if (_selectedLocation != null && _selectedAddress.isNotEmpty) {
      final addressInfo = AddressInfo(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        formattedAddress: _selectedAddress,
        placeId: null, // 可以在后续版本中添加Place ID支持
      );
      widget.onAddressSelected(addressInfo);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _selectedLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? _onConfirmAddress : null,
            child: Text(
              'Confirm',
              style: TextStyle(
                color: _selectedLocation != null
                    ? const Color(0xFFFFA500)
                    : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search address...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFFA500)),
                ),
              ),
              onSubmitted: _searchAddress,
            ),
          ),

          // 地图
          Expanded(
            flex: 3,
            child: _selectedLocation != null
                ? GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation!,
                      zoom: _config?.defaultZoom.toDouble() ?? 15.0,
                    ),
                    onTap: _onMapTapped,
                    markers: {
                      if (_selectedLocation != null)
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: _selectedLocation!,
                          draggable: true,
                          onDragEnd: (LatLng newPosition) {
                            _onMapTapped(newPosition);
                          },
                        ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // 选中的地址信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedAddress.isNotEmpty
                      ? _selectedAddress
                      : 'Tap on map to select address',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedAddress.isNotEmpty
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
                if (_selectedLocation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Getting address...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
