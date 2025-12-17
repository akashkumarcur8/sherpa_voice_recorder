import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'AgentDetailController.dart';

class AgentLocationDetailScreen extends StatefulWidget {
  var userId;

  AgentLocationDetailScreen({required this.userId});

  @override
  _AgentLocationDetailScreenState createState() => _AgentLocationDetailScreenState();
}

class _AgentLocationDetailScreenState extends State<AgentLocationDetailScreen> {
  String selectedItem = '';
  GoogleMapController? mapController;
  final AgentController controller = Get.put(AgentController());

  @override
  void initState() {
    super.initState();
    controller.fetchAgentDetails(widget.userId); // Fetch agent data and address
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF565ADD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(
          child: Obx(() {
            if (controller.agentDetail.value == null) {
              return const Text(
                'Loading Agent Details...',
                style: TextStyle(color: Colors.white),
              );
            }
            return Text(
              controller.agentDetail.value!.name,
              style: const TextStyle(color: Colors.white),
            );
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                controller.fetchAgentDetails(widget.userId); // Refresh the data
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final agent = controller.agentDetail.value;
        if (agent == null) {
          return Center(child: Text('Agent details not available.'));
        }

        final historyPolyline = Polyline(
          polylineId: PolylineId('history'),
          points: agent.history.map((h) => h.position).toList(),
          width: 4,
          color: Colors.blueAccent,
        );

        final destMarkers = agent.destinations.asMap().entries.map((entry) {
          int index = entry.key;
          var d = entry.value;
          return Marker(
            markerId: MarkerId('dest_$index'), // Using index for unique ID
            position: d.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                d.scheduledArrival == agent.destinations.first.scheduledArrival
                    ? BitmapDescriptor.hueAzure
                    : (d.status == 'upcoming'
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueOrange)),
            infoWindow: InfoWindow(
              title: 'Destination ${index + 1}',
              snippet: d.address ?? 'No address available', // Full address will be shown here
            ),
            onTap: () {
              // This ensures info window shows when marker is tapped
            },
          );
        }).toSet();

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: agent.history.isNotEmpty
                    ? agent.history.last.position
                    : LatLng(0.0, 0.0),
                zoom: 14,
              ),
              polylines: {historyPolyline},
              markers: destMarkers,
              onMapCreated: (GoogleMapController mapCtrl) {
                mapController = mapCtrl;
              },
            ),
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Last Call Summary"),
                          content: SingleChildScrollView(
                            child: Text(
                              agent.lastCallSummary.body,
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Close"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Last Call Summary",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            agent.lastCallSummary.body,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Read more...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 0.45,
              builder: (_, sc) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border.all(color: Colors.grey.shade300), // Added border around the sheet
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Add padding to the inside of the sheet
                  child: ListView.builder(
                    controller: sc,
                    itemCount: agent.destinations.length,
                    itemBuilder: (_, i) {
                      final d = agent.destinations[i];

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.0), // Space between list items
                        decoration: BoxDecoration(
                          color: selectedItem == d.scheduledArrival
                              ? Color(0xFF565ADD) // Selected item color
                              : (d.scheduledArrival == agent.destinations.first.scheduledArrival
                              ? Colors.blue.shade50 // Highlight the first destination
                              : Colors.transparent),
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners for each item
                          border: Border.all(color: Colors.grey.shade200), // Border around each item
                        ),
                        child: ListTile(
                          leading: Tooltip(
                            message: d.address, // Tooltip showing the full address
                            child: Icon(
                              Icons.place,
                              color: selectedItem == d.scheduledArrival
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                          title: Text(
                            d.address!,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: selectedItem == d.scheduledArrival
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "Arrival ${d.scheduledArrival}",
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedItem == d.scheduledArrival
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),
                          onTap: () async {
                            // Set the selected item
                            setState(() {
                              selectedItem = d.scheduledArrival;
                            });

                            try {
                              // Move camera to the destination and show info window
                              if (mapController != null) {
                                // First, hide any existing info windows
                                await mapController!.hideMarkerInfoWindow(
                                    MarkerId('dest_$i')
                                ).catchError((e) {
                                  // Ignore errors if no info window is showing
                                });

                                // Animate to the destination
                                await mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: d.position,
                                      zoom: 16,
                                    ),
                                  ),
                                );

                                // Wait for animation to complete
                                await Future.delayed(Duration(milliseconds: 800));

                                // Show the info window for this marker using index
                                await mapController!.showMarkerInfoWindow(
                                  MarkerId('dest_$i'),
                                );
                              }
                            } catch (e) {
                              print('Error showing marker info window: $e');
                              // Fallback: Just move the camera without showing info window
                              if (mapController != null) {
                                mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: d.position,
                                      zoom: 16,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}