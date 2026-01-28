import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mice_activeg/app/modules/geo_tracking/user_position_model.dart';

import '../../core/services/storage/sharedPrefHelper.dart';

class UserLocationController extends GetxController {
  var users = <UserLocation>[].obs;  // Observable list of users
  var isLoading = true.obs;           // To track the loading state

  // Create Dio instance
  final Dio dio = Dio();


  @override
  void onInit() {
    super.onInit();
    fetchUserLocations(); // Fetch data when controller is initialized
  }

  Future<void> fetchUserLocations() async {
    var fetchmanagerId = await SharedPrefHelper.getpref("manager_user_id");

    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var data = {

      'manager_id': fetchmanagerId,
    };

    try {
      isLoading(true);

      // Send POST request using Dio
      final response = await dio.request(
        'https://transform.cur8.in//webservice/rest/server.php?wstoken=55d122d76ce0b08e792ce0d4f680b1d2&moodlewsrestformat=json&wsfunction=local_courses_get_geo_tracking_by_managerid',
        options: Options(method: 'POST', headers: headers,),
        data: data,
      );

      if (response.statusCode == 200) {
        var data = response.data; // Get response data

        // Loop through the response and reverse geocode the coordinates
        var userList = <UserLocation>[];
        for (var item in data) {
          double latitude = item['latitude'];
          double longitude = item['longitude'];

          // Fetch the address using the latitude and longitude
          List<Placemark> placemarks = await geocodeCoordinates(latitude, longitude);

          // Assuming you get the first placemark, you can modify based on your needs
          String address = placemarks.isNotEmpty
              ? [
            placemarks[0].street ?? "Unknown street",
            placemarks[0].subLocality ?? "Unknown sublocality",
            placemarks[0].locality ?? "Unknown locality",
            placemarks[0].administrativeArea ?? "Unknown area",
          ].join(", ")
              : "Unknown address";


          // Create a UserLocation instance with the fetched address
          userList.add(UserLocation.fromJson({
            'userid': item['userid'],
            'fullname': item['fullname'],
            'latitude': latitude,
            'longitude': longitude,
            'timestamp': item['timestamp'],
            'address': address,  // Set the fetched address here
            'email_id': item['email_id'],
          }));
        }

        users.value = userList;  // Update the users list with the new data
      } else {
        // Handle the error if the API fails
        Get.snackbar('Error', 'Failed to load data');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Method to reverse geocode coordinates (lat, long) to address
  Future<List<Placemark>> geocodeCoordinates(double latitude, double longitude) async {
    try {
      // Fetch address details from latitude and longitude
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch address: $e');
      return [];
    }
  }
}
