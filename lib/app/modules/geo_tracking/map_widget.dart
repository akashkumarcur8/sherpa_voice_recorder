
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mice_activeg/app/modules/geo_tracking/user_position_model.dart';
import 'package:mice_activeg/app/modules/geo_tracking/user_postion_widget.dart';
import 'UserDataController.dart';

class GeoTrackingScreen extends StatefulWidget {
  const GeoTrackingScreen({super.key});

  @override
  _GeoTrackingScreenState createState() => _GeoTrackingScreenState();
}

class _GeoTrackingScreenState extends State<GeoTrackingScreen> {
  GoogleMapController? _mapCtrl;
  int? _selectedUserId;

  final UserLocationController _controller = Get.put(UserLocationController());
  String formatDate(DateTime dateTime) {
    return DateFormat('d MMM h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ADD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Text(
            'Geo Tracking',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _controller.fetchUserLocations(); // Refresh the data
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Display loading indicator while the data is being fetched
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // Create markers for each user location
          final markers = _controller.users.map((u) {
            return Marker(
              markerId: MarkerId(u.userId.toString()),
              position: u.latLng,
              infoWindow: InfoWindow(
                title: u.name,
                snippet: u.address, // Show the dynamically fetched address
                onTap: () => _openDetail(u),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  u.userId == _selectedUserId ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed),
              onTap: () {
                _selectedUserId = u.userId;
                _mapCtrl?.animateCamera(CameraUpdate.newLatLng(u.latLng));
              },
            );
          }).toSet();

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _controller.users.isNotEmpty
                      ? _controller.users.first.latLng
                      : const LatLng(0.0, 0.0),
                  zoom: 12,
                ),
                markers: markers,
                onMapCreated: (controller) => _mapCtrl = controller,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.15,
                minChildSize: 0.10,
                maxChildSize: 0.4,
                builder: (ctx, sc) => Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  child: ListView.builder(
                    controller: sc,
                    itemCount: _controller.users.length,
                    itemBuilder: (_, i) {
                      final u = _controller.users[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(u.name[0])),
                        title: Text(u.name),
                        subtitle: Text(
                          '${u.address} \nLast seen: ${formatDate(u.lastSeen.toLocal())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _openDetail(u),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }


  void _openDetail(UserLocation u) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AgentLocationDetailScreen(userId: u.emailid),
    ));
  }
}
