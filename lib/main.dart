import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Locate Yourself'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _controller;
  final List<LatLng> _polylineCoordinates = [];
  final Location _location = Location();
  Set<Marker> _markers = {}; // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.7041, 77.1025),
          zoom: 18.0,
        ),
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        polylines: {
          Polyline(
            polylineId: const PolylineId('polyline'),
            color: Colors.red,
            points: _polylineCoordinates,
          ),
        },
        markers: _markers,
      ),
      // If clicked on the floating action button, then get the current location
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(45.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FloatingActionButton(

              onPressed: _centerMapOnLocation,
              tooltip: 'Center on Location',
              child: const Icon(Icons.location_on),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _getLocationAndDrawPolyline();
  }

  Future<void> _centerMapOnLocation() async {
    if (_polylineCoordinates.isNotEmpty) {
      final lastLocation = _polylineCoordinates.last;
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(lastLocation, 40));
    }

    bool serviceEnabled;
    PermissionStatus permission;

    // Check if location services are enabled.
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Request location permission if not granted.
    permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }

  }


  Future<void> _getLocationAndDrawPolyline() async {
    await _centerMapOnLocation(); // Call the permission method before location updates

    _location.onLocationChanged.listen((locationData) {
      LatLng latLng = LatLng(locationData.latitude!, locationData.longitude!);
      setState(() {
        _polylineCoordinates.add(latLng);

        // Update the marker's position
        _markers.clear(); // Clear the previous markers
        _markers.add(
          Marker(
            markerId: MarkerId('marker1'),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow:  InfoWindow(title: 'My current location $latLng'),
          ),
        );
      });

      _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 18));
    });
  }


}
