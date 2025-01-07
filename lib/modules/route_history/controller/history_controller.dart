import 'dart:async';
import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/service/api_service/api_service.dart';
import 'package:track_route_pro/service/model/route_history/RouteHistoryResponse.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:track_route_pro/utils/enums.dart';
import 'package:track_route_pro/utils/utils.dart';
import 'dart:ui' as ui;
import '../../../constants/project_urls.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

import '../../../service/model/time_model.dart';

class HistoryController extends GetxController {
  RxString address = ''.obs;
  RxString name = ''.obs;
  RxString updateDate = ''.obs;
  RxString imei = ''.obs;
  RxBool showMap = false.obs;
  RxBool showLoader = false.obs;
  TextEditingController dateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  var time1 = Rx<TimeOption?>(null); // Observable
  var time2 = Rx<TimeOption?>(null); // Observable
  RxList<RouteHistoryResponse> data = <RouteHistoryResponse>[].obs;
  bool isMapControllerInitialized = false;
  var markers = <Marker>[].obs;
  RxList<TimeOption> timeList = <TimeOption>[].obs;
  late GoogleMapController mapController;
  var currentLocation = LatLng(0.0, 0.0).obs; // Current vehicle location
  var polylines = <Polyline>[].obs; // List of polylines to display on the map
  var isLoading = false.obs; // Loading state

  final ApiService apiService = ApiService.create();
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);

  void generateTimeList() {
    timeList.value = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) { // Adjust interval as needed
        String formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        timeList.add(TimeOption(formattedTime));
      }
    }

  }

  void selectDate(context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Formatting the picked date
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      controller.text = formattedDate;
      endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> getRouteHistory() async {
    if (dateController.text.isEmpty)
      Utils.getSnackbar("Error", "Please select valid date");
    else {
      showLoader.value=true;
      var response;
      try {
        networkStatus.value =
            NetworkStatus.LOADING; // Set network status to loading

        String startDate = endDateController.text;
        String? endDate = null;
        if(time1.value!=null) startDate+= " "+ time1.value!.name;
        if(time2.value!=null) endDate = endDateController.text+" "+ time2.value!.name;
        final body = {
          "imei": "868003032593027",
          // "imei":imei.value,
          "startdate": startDate,
          "enddate": endDate
        };
        response = await apiService.routeHistory(body);

        if (response.message == "success") {
          networkStatus.value = NetworkStatus.SUCCESS;
          data.value = response.data;
          data.value = data.where((item) => item.trackingData?.location?.latitude != null && item.trackingData?.location?.longitude != null).toList();


          if (data.isNotEmpty) {
            showMap.value = true;
            updateRoutes();
            markers.value = [];
            showLoader.value=false;
            if (data[0].trackingData?.location?.latitude != null &&
                data[0].trackingData?.location?.longitude != null) {
              updateCameraPosition(
                  data[0].trackingData?.location?.latitude ?? 0,
                  data[0].trackingData?.location?.longitude ?? 0);
            }
            for (var vehicle in data) {
              if (vehicle.trackingData?.location?.latitude != null &&
                  vehicle.trackingData?.location?.longitude != null) {
                Marker m = await createMarker(
                  imei: vehicle.imei ?? "",
                  lat: vehicle.trackingData?.location?.latitude,
                  long: vehicle.trackingData?.location?.longitude,
                  speed: vehicle.trackingData?.currentSpeed,
                  time: vehicle.dateFiled ?? ""
                );
                markers.add(m);
                // debugPrint("MARKER LENGTH ====> ${markers.length}");
              }
            }

            if (data[data.length - 1].trackingData?.location?.latitude !=
                    null &&
                data[data.length - 1].trackingData?.location?.longitude !=
                    null) {
              Marker m = await createMarkerFromNet(
                img: data[data.length - 1].vehicletype?.icons ?? "",
                imei: data[data.length - 1].imei ?? "",
                lat: data[data.length - 1].trackingData?.location?.latitude ?? 0,
                long: data[data.length - 1].trackingData?.location?.longitude ?? 0,
                  time: data[data.length - 1].dateFiled ?? ""
              );
              markers.add(m);
            }
          }
          else {
            Utils.getSnackbar("Error", "No Route History Found");
          }
        } else {
          log("EXCEPTION ${data}");
          debugPrint("EXCEPTION ${data}");
          // Utils.getSnackbar("Error", "Something went wrong");
        }
      } catch (e, s) {
        log("EXCEPTION $e $s");
        debugPrint("EXCEPTION $e $s");
        networkStatus.value = NetworkStatus.ERROR;
        Utils.getSnackbar("Error", "Something went wrong");
      }
    }
    showLoader.value=false;
  }

  Future<String> getAddressFromLatLong(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      return "${place.street}, ${place.locality}, ${place.subLocality}, ${place.country}";
    } catch (e) {
      debugPrint("Error " + e.toString());
      return "Address not available";
    }
  }

  Future<BitmapDescriptor> createMarkerIcon(String indexedImage,
      {int width = 100, int height = 100}) async {
    // Load image from network
    final ByteData data =
        await NetworkAssetBundle(Uri.parse(indexedImage)).load("");
    final Uint8List bytes = data.buffer.asUint8List();

    // Decode the image to get its original size
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Convert the resized image to bytes
    final ByteData? resizedData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = resizedData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  Future<BitmapDescriptor> createMarkerIconFromAssets(
      {int width = 35, int height = 35}) async {
    // Load image from assets
    final ByteData data =
        await rootBundle.load("assets/images/png/route_marker.png");
    final Uint8List bytes = data.buffer.asUint8List();

    // Decode the image to get its original size and resize it
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Convert the resized image to bytes
    final ByteData? resizedData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedBytes = resizedData!.buffer.asUint8List();

    // Create and return BitmapDescriptor
    return BitmapDescriptor.fromBytes(resizedBytes);
  }

  void removeRoute() {
    polylines.clear(); // Clear the polylines
    update(); // Trigger UI update if necessary
  }
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapControllerInitialized = true;

    // If there's a pending update, execute it now
    if (pendingUpdate != null) {
      pendingUpdate!();
      pendingUpdate = null;
    }
  }

  Function? pendingUpdate;
  void updateCameraPosition(double latitude, double longitude) {
    if (isMapControllerInitialized) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 16,
          ),
        ),
      );
    } else {
      // Save the update to execute later
      pendingUpdate = () {
        updateCameraPosition(latitude, longitude);
      };
    }
  }

  Future<void> updateRoutes() async {
    // Clear existing polylines
    polylines.clear();

    // Iterate through the data and generate markers and polylines
    LatLng? previousLocation; // To store the previous location for creating polylines

    for (var vehicle in data) {
      // Check if the location data is valid
      if (vehicle.trackingData?.location?.latitude != null &&
          vehicle.trackingData?.location?.longitude != null) {
        // Get the current location
        LatLng currentLocation = LatLng(
          vehicle.trackingData!.location!.latitude!,
          vehicle.trackingData!.location!.longitude!,
        );

        // Create a polyline if there is a previous location
        if (previousLocation != null) {
          polylines.add(Polyline(
            polylineId: PolylineId(
              'route ${previousLocation.longitude}${currentLocation.longitude}${previousLocation.latitude}${currentLocation.latitude}',
            ),
            color:AppColors.redColor,
            width: 2,
            points: [previousLocation, currentLocation],
          ));
        }

        // Update the previous location to the current location
        previousLocation = currentLocation;
      }
    }
  }



  Future<Marker> createMarker(
      {double? lat,
      double? long,
      double? speed,
      String? time,
      required String imei,}) async {
    // String date, currTime="";
    // if (time?.isNotEmpty ??
    //     false) {
    //   date =
    //   '${DateFormat("dd-MM-yyyy").format(DateTime.parse(time ?? "").toLocal()) ?? ''}';
    //   currTime =
    //   '${DateFormat("hh:mm").format(DateTime.parse(time ?? "").toLocal()) ?? ''}';
    // }
    BitmapDescriptor markerIcon = await createMarkerIconFromAssets();
    // String address = await getAddressFromLatLong(lat ?? 0, long ?? 0);
    final markerId = "$imei$lat$long$time";
    final marker = Marker(
      // rotation: 90,
      markerId: MarkerId(markerId),
      position: LatLng(
        lat ?? 0,
        long ?? 0,
      ),
      infoWindow: InfoWindow(
        title: 'Time: $time',
        snippet: 'Speed: ${speed?.toStringAsFixed(2) ?? "N/A"}',
      ),
      icon: markerIcon,
      // onTap: ()=> _onMarkerTapped(-1,imei)
    );
    return marker;
  }

  Future<Marker> createMarkerFromNet(
      {double? lat,
      double? long,
      String? img,
      String? speed,
      String? time,
      required String imei,}) async {
    // String date, currTime="";
    // if (time?.isNotEmpty ??
    //     false) {
    //   date =
    //   '${DateFormat("dd-MM-yyyy").format(DateTime.parse(time ?? "").toLocal()) ?? ''}';
    //   currTime =
    //   '${DateFormat("hh:mm").format(DateTime.parse(time ?? "").toLocal()) ?? ''}';
    // }
    BitmapDescriptor markerIcon =
        await createMarkerIcon('${ProjectUrls.imgBaseUrl}$img');
    final markerId = "${ProjectUrls.imgBaseUrl}$img";
    // String address = await getAddressFromLatLong(lat ?? 0, long ?? 0);
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(
        lat ?? 0,
        long ?? 0,
      ),
      infoWindow: InfoWindow(
        title:'Time: $time',
      snippet: 'Speed: $speed',
      ),
      icon: markerIcon,
    );
    return marker;
  }
}
