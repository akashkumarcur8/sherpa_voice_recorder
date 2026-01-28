import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
class LocationController extends GetxController {
  var isLoading = false.obs;
  var statusMessage = ''.obs;
  Timer? _timer;

  // Method to get the current location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      statusMessage.value = 'Location services are disabled.';
      return null;
    }

    // Check and request for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        statusMessage.value = 'Location permission denied.';
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      statusMessage.value = 'Location permission denied forever.';
      return null;
    }

    // Fetch the current location
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // API Integration method to send location data to the server
  Future<void> sendLocationToServer(String lat, String lon, String time,String userEmail,String userId) async {
    isLoading.value = true;
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var data = {
      'userid': userId,
      'email_id': userEmail,
      'latitude': lat,
      'longitude': lon,
      'timestamp': time,
    };

    try {
      var dio = Dio();
      var response = await dio.request(
        'https://transform.cur8.in//webservice/rest/server.php?wstoken=55d122d76ce0b08e792ce0d4f680b1d2&moodlewsrestformat=json&wsfunction=local_courses_geo_track',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        statusMessage.value = 'Location Sent Successfully';
      } else {
        statusMessage.value = 'Error: ${response.statusMessage}';
      }
    } catch (e) {
      statusMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Method to start periodic updates (every 5 minutes)
  void startPeriodicUpdates() {
    // Start a Timer to fetch and send the location every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      Position? position = await getCurrentLocation();

      if (position != null) {
        String lat = position.latitude.toString();
        String lon = position.longitude.toString();
        String time = DateTime.now().toString(); // Example Timestamp (current time)
        String userEmail= await SharedPrefHelper.getpref("email");
        String userId= await SharedPrefHelper.getpref("user_id");

        await sendLocationToServer(lat, lon, time,userEmail,userId);
      } else {
        statusMessage.value = 'Unable to get location';
      }
    });
  }

  // Automatically start periodic updates when the controller is initialized
  @override
  void onInit() {
    super.onInit();
    // Start sending location data as soon as the controller is created
    startPeriodicUpdates();
  }

  // Cancel the periodic task if the app is killed or no longer needed
  @override
  void onClose() {
    _timer?.cancel();  // Properly cancel the timer when the controller is destroyed
    super.onClose();
  }
}
