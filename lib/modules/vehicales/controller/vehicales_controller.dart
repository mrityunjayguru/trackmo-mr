import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:track_route_pro/constants/constant.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/track_route_screen/controller/track_route_controller.dart';
import 'package:track_route_pro/modules/vehicales/model/filter_model.dart';
import 'package:track_route_pro/service/api_service/api_service.dart';
import 'package:track_route_pro/service/model/presentation/track_route/track_route_vehicle_list.dart';
import 'package:track_route_pro/utils/app_prefrance.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:track_route_pro/utils/enums.dart';

class VehicalesController extends GetxController {
  final ApiService apiService = ApiService.create();
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  RxString devicesOwnerID = RxString('');
  final trackRouteController = Get.find<TrackRouteController>();
  Rx<TrackRouteVehicleList> vehicleList = Rx(TrackRouteVehicleList());
  RxList<FilterData> filterData = RxList([]);
  RxList<Data> ignitionOnList = <Data>[].obs;
  RxList<Data> ignitionOffList = <Data>[].obs;
  RxList<Data> activeVehiclesList = <Data>[].obs;
  RxList<Data> idleVehiclesList = <Data>[].obs;
  RxInt SelectedFilterIndex = RxInt(0);
  TextEditingController searchController = TextEditingController();
  RxList<Data> filteredVehicleList = <Data>[].obs; // List for search results


  RxString address = ''.obs;

  Future<String> getAddressFromLatLong(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      Placemark place = placemarks[0];

      String address= "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

      log("ADDRESS =====> $address");
      return address;
    } catch (e) {
      debugPrint("Error " + e.toString());
      address.value = "Address not available";
      return address.value;
    }
  }
  @override
  void onInit() {
    super.onInit();
    loadUser().then((_) {
      devicesByOwnerID();
    });
    searchController.addListener(() {
      filterVehicles(searchController.text); // Listen for search changes
    });
  }

  // Function to filter vehicles based on search query and selected filter index
  void filterVehicles(String query) {
    List<Data> allVehicles = vehicleList.value.data ?? [];

    List<Data> filtered = allVehicles.where((vehicle) {
      // Filter by the search query
      final matchesQuery =
          vehicle.vehicleNo?.toLowerCase().contains(query.toLowerCase());

      bool matchesFilter = false;

      switch (SelectedFilterIndex.value) {
        case 0: // Active
          matchesFilter = vehicle.status == 'Active';
          break;
        case 1: // Ignition On
          matchesFilter = vehicle.trackingData?.ignition?.status == true;
          break;
        case 2: // Ignition Off
          matchesFilter = vehicle.trackingData?.ignition?.status == false;
          break;
        case 3: // Ignition Off
          matchesFilter = vehicle.status == "InActive";
          break;
        default:
          matchesFilter = true; // Show all if no filter is selected
          break;
      }

      return (matchesQuery ?? false) && matchesFilter;
    }).toList();

    // Update the filtered vehicle list
    filteredVehicleList.value = filtered;
  }

  void updateFilteredList() {
    // debugPrint("HELLO FILTER ${SelectedFilterIndex.value}");
    // Get the complete list of vehicles
    List<Data> allVehicles = vehicleList.value.data ?? [];

    // Apply search filtering
    List<Data> filteredBySearch = allVehicles.where((vehicle) {
      return vehicle.vehicleNo?.toLowerCase()
          .contains(searchController.text.toLowerCase()) ?? false;
    }).toList();

    // Further filter based on the selected filter index
    List<Data> finalFilteredList = filteredBySearch.where((vehicle) {
      switch (SelectedFilterIndex.value) {
        case 0: // Active
          return vehicle.status == 'Active';
        case 1: // Ignition On
          return vehicle.trackingData?.ignition?.status == true;
        case 2: // Ignition Off
          return vehicle.trackingData?.ignition?.status == false;
        case 3: // Ignition Off
       return vehicle.status == "InActive";
        default:
          return true; // No specific filter applied
      }
    }).toList();

    // Update the filtered vehicle list
    filteredVehicleList.value = finalFilteredList;
  }

  // Function to filter vehicles with Ignition On
  List<Data> filterIgnitionOn(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      return vehicle.trackingData?.ignition?.status == true; // Ignition is on
    }).toList();
  }

  // Function to filter vehicles with Ignition Off
  List<Data> filterIgnitionOff(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      return vehicle.trackingData?.ignition?.status == false; // Ignition is off
    }).toList();
  }

  // Function to filter Active Vehicles
  List<Data> filterActiveVehicles(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      return vehicle.status == 'Active'; // Status is Active
    }).toList();
  }

  List<Data> filterIdleVehicles(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {

      return vehicle.status?.toLowerCase() == 'inactive';
    }).toList();
  }

  Future<void> loadUser() async {
    String? userId = await AppPreference.getStringFromSF(Constants.userId);
    devicesOwnerID.value = userId ?? '';
  }

  // API service to get devices by owner ID
  Future<void> devicesByOwnerID() async {
    try {

      final body = {"ownerId": "${devicesOwnerID.value}"};
      networkStatus.value = NetworkStatus.LOADING;

      final response = await apiService.devicesByOwnerID(body);

      if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        vehicleList.value = response;

        // After successfully fetching data, apply the filters
        final allVehicles = vehicleList.value.data ?? [];

        ignitionOnList.value = filterIgnitionOn(allVehicles).obs;
        ignitionOffList.value = filterIgnitionOff(allVehicles).obs;

        activeVehiclesList.value = filterActiveVehicles(allVehicles).obs;
        idleVehiclesList.value = filterIdleVehicles(allVehicles).obs;

        // Initialize filter data after API call and filtering
        filterData.value = [
          FilterData(
            image: Assets.images.svg.icCheck,
            count: activeVehiclesList.length,
            title: 'Active',
          ),
          FilterData(
            image: Assets.images.svg.icFlashGreen,
            count: ignitionOnList.length,
            title: 'Ignition On',
          ),
          FilterData(
            image: Assets.images.svg.icFlashRed,
            count: ignitionOffList.length,
            title: 'Ignition Off',
          ),
          FilterData(
            image: Assets.images.svg.icLoading,
            count: idleVehiclesList.length,
            title: 'Idle',
          ),
        ];

        // Update the filtered list to show all vehicles initially
        filteredVehicleList.value = activeVehiclesList;
       SelectedFilterIndex.value = 0;
       searchController.clear();

      } else if (response.status == 400) {
        networkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;
      print("Error during fetching vehicles: $e");
    }
  }
}
