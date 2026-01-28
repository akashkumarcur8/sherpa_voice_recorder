import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import 'agentDetailModel.dart';
class AgentController extends GetxController {
  var agentDetail = Rxn<AgentLocationDetail>(); // Holds agent details
  var isLoading = true.obs;

  final Dio _dio = Dio();

  // Fetch agent details from the API
  Future<void> fetchAgentDetails(String userId) async {

    try {
      isLoading(true);
      var fetchmanagerId = await SharedPrefHelper.getpref("manager_user_id");

      final response = await _dio.get(
        'https://transform.cur8.in//webservice/rest/server.php?wstoken=55d122d76ce0b08e792ce0d4f680b1d2&moodlewsrestformat=json&wsfunction=local_courses_get_user_tracking&emailids%5B0%5D=$userId&managerid=$fetchmanagerId',
      );



      if (response.statusCode == 200) {
        var data = response.data[0]; // Assuming the response is an array

        // Ensure `data` is not null and contains valid fields
        if (data != null && data['latitude'] != null && data['longitude'] != null) {
          agentDetail.value = AgentLocationDetail.fromJson(data);

          // Fetch addresses for each history entry
          await fetchAddressesForHistory();
          // Fetch addresses for each destination
          await fetchAddressesForDestinations();
        } else {
        }
      } else {
      }
    } catch (e) {
    } finally {
      isLoading(false);
    }
  }

  // Function to fetch address for each history entry and update the model
  Future<void> fetchAddressesForHistory() async {
    // Check if history exists and is not null or empty
    if (agentDetail.value?.history != null && agentDetail.value?.history.isNotEmpty == true) {
      for (var history in agentDetail.value!.history) {
        // Ensure that lat and lng are not null
        String address = await fetchAddressFromLatLng(history.lat, history.lng);
        // Set the fetched address in the history model
        history.address = address;
            }
    } else {
    }
  }

  // Function to fetch address from latitude and longitude
  Future<String> fetchAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        // Constructing the full address
        String fullAddress = [
          placemarks[0].street ?? "Unknown street",
          placemarks[0].subLocality ?? "Unknown sublocality",
          placemarks[0].locality ?? "Unknown locality",
          placemarks[0].administrativeArea ?? "Unknown area",
        ].join(", ");
        return fullAddress;
      } else {
        return "Unknown address";
      }
    } catch (e) {
      return "Unknown address";
    }
  }

  // Function to fetch address for each destination and update the model
  Future<void> fetchAddressesForDestinations() async {
    // Check if destinations exists and is not null or empty
    if (agentDetail.value?.destinations != null && agentDetail.value?.destinations.isNotEmpty == true) {
      for (var destination in agentDetail.value!.destinations) {
        // Ensure that lat and lng are not null
        String address = await fetchAddressFromLatLng(destination.lat, destination.lng);
        // Set the fetched address in the destination model
        destination.address = address;
            }
    } else {
    }
  }
}
