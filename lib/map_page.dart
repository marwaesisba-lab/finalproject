import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  // ✅ ممكن تمرر عنوان client مباشرة
  final String? clientAddress;
  final String? clientName;

  const MapPage({Key? key, this.clientAddress, this.clientName})
    : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentLocation = const LatLng(
    36.7372,
    3.0865,
  ); // الجزائر العاصمة default
  LatLng? _destinationLocation;
  String _destinationName = "";
  bool _isLoading = false;
  bool _locationPermissionGranted = false;
  String _searchError = "";

  // ✅ لائحة نتائج البحث
  List<Location> _searchResults = [];
  List<Placemark> _searchPlacemarks = [];

  @override
  void initState() {
    super.initState();
    _initLocation();

    // ✅ إذا جاء عنوان client من صفحة ثانية، نبحث عليه مباشرة
    if (widget.clientAddress != null && widget.clientAddress!.isNotEmpty) {
      _searchController.text = widget.clientAddress!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchAddress(widget.clientAddress!);
      });
    }
  }

  Future<void> _initLocation() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() {
        _isLoading = false;
        _locationPermissionGranted = false;
      });
      return;
    }

    setState(() => _locationPermissionGranted = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentLocation, 14);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ✅ البحث عن عنوان بالنص
  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchError = "";
      _searchResults = [];
      _searchPlacemarks = [];
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      List<Placemark> placemarks = [];

      for (var loc in locations.take(5)) {
        List<Placemark> marks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (marks.isNotEmpty) placemarks.add(marks.first);
      }

      if (locations.isEmpty) {
        setState(() {
          _searchError = "ما لقينا العنوان، جرب بشكل آخر";
          _isLoading = false;
        });
        return;
      }

      // إذا نتيجة وحدة، روح مباشرة
      if (locations.length == 1) {
        _goToLocation(
          locations.first,
          placemarks.isNotEmpty ? placemarks.first : null,
        );
      } else {
        setState(() {
          _searchResults = locations;
          _searchPlacemarks = placemarks;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchError = "خطأ في البحث، تحقق من الاتصال";
        _isLoading = false;
      });
    }
  }

  void _goToLocation(Location location, Placemark? placemark) {
    final dest = LatLng(location.latitude, location.longitude);
    String name = "";
    if (placemark != null) {
      name = [
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.country,
      ].where((e) => e != null && e.isNotEmpty).join(", ");
    }

    setState(() {
      _destinationLocation = dest;
      _destinationName = name.isEmpty ? _searchController.text : name;
      _searchResults = [];
      _searchPlacemarks = [];
      _isLoading = false;
    });

    _mapController.move(dest, 15);
  }

  // ✅ حساب المسافة بين الموظف والوجهة
  String _getDistance() {
    if (_destinationLocation == null) return "";
    final Distance distance = Distance();
    final double km = distance.as(
      LengthUnit.Kilometer,
      _currentLocation,
      _destinationLocation!,
    );
    return km < 1 ? "${(km * 1000).toInt()} م" : "${km.toStringAsFixed(1)} كم";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6),
      body: Stack(
        children: [
          // ✅ الخريطة الأساسية
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourapp.appweb',
              ),
              MarkerLayer(
                markers: [
                  // ✅ موقع الموظف
                  if (_locationPermissionGranted)
                    Marker(
                      point: _currentLocation,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4A4A),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ✅ موقع الوجهة (client)
                  if (_destinationLocation != null)
                    Marker(
                      point: _destinationLocation!,
                      width: 50,
                      height: 70,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          Container(width: 2, height: 16, color: Colors.red),
                        ],
                      ),
                    ),
                ],
              ),
              // ✅ خط يربط الموظف بالوجهة
              if (_destinationLocation != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_currentLocation, _destinationLocation!],
                      strokeWidth: 3,
                      color: const Color(0xFF4A4A4A).withOpacity(0.6),
                      pattern: const StrokePattern.dashed(segments: [12, 6]),
                    ),
                  ],
                ),
            ],
          ),

          // ✅ شريط البحث فوق الخريطة
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.black26,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "ابحث عن عنوان...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF4A4A4A),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _destinationLocation = null;
                                    _searchResults = [];
                                    _searchError = "";
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchAddress,
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                ),

                // ✅ نتائج البحث المتعددة
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final placemark = i < _searchPlacemarks.length
                            ? _searchPlacemarks[i]
                            : null;
                        final name = placemark != null
                            ? [
                                    placemark.street,
                                    placemark.locality,
                                    placemark.country,
                                  ]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(", ")
                            : "نتيجة ${i + 1}";
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF4A4A4A),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () =>
                              _goToLocation(_searchResults[i], placemark),
                        );
                      },
                    ),
                  ),

                // ✅ رسالة خطأ
                if (_searchError.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _searchError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ✅ بطاقة الوجهة تحت الشاشة
          if (_destinationLocation != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.clientName ?? "الوجهة",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _destinationName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            _getDistance(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const Text(
                            "المسافة",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ✅ زر تحديد موقعي
          Positioned(
            bottom: _destinationLocation != null ? 130 : 24,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A4A4A),
              elevation: 6,
              onPressed: _initLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // ✅ Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A4A4A)),
            ),
        ],
      ),
    );
  }
}
