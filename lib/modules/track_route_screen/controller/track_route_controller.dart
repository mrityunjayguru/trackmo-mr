import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:track_route_pro/constants/constant.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/bottom_screen/controller/bottom_bar_controller.dart';
import 'package:track_route_pro/modules/vehicales/model/filter_model.dart';
import 'package:track_route_pro/service/api_service/api_service.dart';
import 'package:track_route_pro/service/model/presentation/track_route/track_route_vehicle_list.dart';
import 'package:track_route_pro/utils/app_prefrance.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:track_route_pro/utils/enums.dart';
import 'package:track_route_pro/utils/utils.dart';
import 'dart:ui' as ui;
import '../../../constants/project_urls.dart';
import '../../../service/model/presentation/vehicle_type/Data.dart';

class TrackRouteController extends GetxController {
  Rx<TrackRouteVehicleList> vehicleList = Rx(TrackRouteVehicleList());
  RxList<FilterData> filterData = RxList([]);
  var markers = <Marker>[].obs;

  // New Rx lists for filtered results
  RxList<Data> ignitionOnList = <Data>[].obs;
  RxList<Data> ignitionOffList = <Data>[].obs;
  RxList<Data> activeVehiclesList = <Data>[].obs;
  RxList<Data> idleList = <Data>[].obs;
  RxList<Data> allVehicles = <Data>[].obs;
  RxList<DataVehicleType> vehicleTypeList = <DataVehicleType>[].obs;
  RxString devicesOwnerID = RxString('');
  RxString devicesId = RxString('');
  late GoogleMapController mapController;
  bool gpsEnabled = false;
  bool permissionGranted = false;
  RxBool isExpanded = false.obs;
  RxBool isFilterSelected = false.obs;
  RxInt isFilterSelectedindex = RxInt(-1);
  RxBool isvehicleSelected = false.obs;
  RxBool isShowvehicleDetail = false.obs;
  RxInt stackIndex = RxInt(0);
  RxInt selectedVehicleIndex = RxInt(0);
  RxBool isListShow = false.obs;
  RxBool isedit = false.obs;
  StreamSubscription<Position>? positionStream;
  var currentLocation = LatLng(0.0, 0.0).obs; // Current vehicle location
  var polylines = <Polyline>[].obs; // List of polylines to display on the map
  var isLoading = false.obs; // Loading state

  final ApiService apiService = ApiService.create();
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  RxString address = ''.obs;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    checkStatus();

    loadUser().then(
      (value) {
        devicesByOwnerID(true);
      },
    );

    // Set up a timer to call `devicesByOwnerID` every 30 seconds if `isEdit` is false
    _refreshTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      if (!isedit.value) {
        devicesByOwnerID(false); //todo
      }
    });
  }

  Future<void> getAddressFromLatLong(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      address.value =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      address.refresh();
    } catch (e) {
      debugPrint("Error " + e.toString());
      address.value = "Address not available";
    }
  }

  List<Data> getVehiclesWithExpiringSubscriptions() {
    List<Data> expiringVehicles = [];

    DateTime currentDate = DateTime.now();

    vehicleList.value.data?.forEach((vehicle) {
      if (vehicle.subscriptionExp != null) {
        DateTime subscriptionExpDate =
            DateFormat('yyyy-MM-dd').parse(vehicle.subscriptionExp!);

        int daysDifference = subscriptionExpDate.difference(currentDate).inDays;

        if (daysDifference <= 15) {
          expiringVehicles.add(vehicle);
        }
      }
    });

    return expiringVehicles;
  }

  Future<BitmapDescriptor> createMarkerIcon(String indexedImage,
      {int width = 150, int height = 150}) async {
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

  // Function to Filter for Vehicles with Ignition On
  List<Data> filterIgnitionOn(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      return vehicle.trackingData?.ignition?.status == true; // Ignition is on
    }).toList();
  }

  // Function to Filter for Vehicles with Ignition Off
  List<Data> filterIgnitionOff(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      return vehicle.trackingData?.ignition?.status == false; // Ignition is off
    }).toList();
  }

  // Function to Filter for Active Vehicles
  List<Data> filterActiveVehicles(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      return vehicle.status == 'Active'; // Status is Active
    }).toList();
  }

  List<Data> filterIdleVehicles(List<Data> vehicleList) {
    return vehicleList.where((vehicle) {
      debugPrint("STATUS VEHICLE ${vehicle.status}");
      return vehicle.status?.toLowerCase() == 'inactive';
    }).toList();
  }

// Method to call the API to get directions with destination coordinates

  // Future<void> fetchDirections(
  //     double destinationLat, double destinationLng) async {
  //   isLoading.value = true;
  //   try {
  //     String url =
  //         "https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation.value.latitude},${currentLocation.value.longitude}&destination=${destinationLat},${destinationLng}&key=${Constants.googleApiKey}";
  //
  //     // No need to decode response.data; use it directly
  //     final response = await Dio().get(url);
  //
  //     if (response.statusCode == 200) {
  //       // Use response.data directly
  //       final data = response.data; // Now data is a Map<String, dynamic>
  //       log('data::::::>${data}');
  //       List<Polyline> fetchedPolylines = [];
  //
  //       for (var route in data['routes']) {
  //         final points = route['polyline']['points'];
  //         fetchedPolylines.add(Polyline(
  //           polylineId: PolylineId(route['summary']),
  //           points: decodePoly(points),
  //           color: Colors.yellow,
  //           width: 5,
  //         ));
  //       }
  //       log('fetchedPolylines::::::${fetchedPolylines}');
  //       // Update the polylines observable
  //       polylines.assignAll(fetchedPolylines);
  //     } else {
  //       log('Error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log('Error fetching directions: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

// // Utility function to decode polyline points from the encoded string
//   List<LatLng> decodePoly(String poly) {
//     List<LatLng> list = [];
//     int index = 0, len = poly.length;
//     int lat = 0, lng = 0;
//
//     while (index < len) {
//       int b;
//       int shift = 0;
//       int result = 0;
//
//       do {
//         b = poly.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = poly.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       LatLng p = LatLng((lat / 1E5), (lng / 1E5));
//       list.add(p);
//     }
//     return list;
//   }

  // Method to get the current location

  Future<Position?> getCurrentLocation() async {
    try {
      await _requestLocationPermission();
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  void removeRoute() {
    polylines.clear(); // Clear the polylines
    update(); // Trigger UI update if necessary
  }

  void updateCameraPosition(double latitude, double longitude) {
    if (Get.put(BottomBarController()).selectedIndex == 2) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude, longitude), zoom: 4),
        ),
      );
    }
  }

  void updateCameraPositionToCurrentLocation() async {
    if (Get.put(BottomBarController()).selectedIndex == 2) {
      Position? data = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (data != null) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(data.latitude, data.longitude), zoom: 4),
          ),
        );
      }
    }
  }

  void updateCameraPositionWithZoom(double latitude, double longitude) {
    if (Get.put(BottomBarController()).selectedIndex == 2) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 16,
          ),
        ),
      );
    }
  }

  // Method to update the route on the map
  Future<void> updateRoute(LatLng start, LatLng end) async {
    polylines.clear();
    polylines.add(Polyline(
      polylineId: PolylineId('route'),
      color: Colors.red,
      width: 5,
      points: [start, end],
    ));

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            start.latitude < end.latitude ? start.latitude : end.latitude,
            start.longitude < end.longitude ? start.longitude : end.longitude,
          ),
          northeast: LatLng(
            start.latitude > end.latitude ? start.latitude : end.latitude,
            start.longitude > end.longitude ? start.longitude : end.longitude,
          ),
        ),
        0,
      ),
    );
  }

  // On Map Created
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMarkerTapped(int index, String imei, double lat, double long) {
    removeRoute();
    isShowVehicleDetails(index);
    devicesByDetails(imei, updateCamera: false);
    updateCameraPositionWithZoom(lat, long);
    isExpanded.value = false;
  }

  Future<void> loadUser() async {
    String? userId = await AppPreference.getStringFromSF(Constants.userId);
    print('userid:::::>${userId}');
    devicesOwnerID.value = userId ?? '';
  }

  Future<void> isShowVehicleDetails(int index) async {
    isShowvehicleDetail.value = true;
    selectedVehicleIndex.value = index;
  }

  // Method to check location permissions and GPS status
  Future<void> checkStatus() async {
    bool _permissionGranted = await _isPermissionGranted();
    bool _gpsEnabled = await _isGpsEnabled();

    if (_gpsEnabled && _permissionGranted) {
      _startLocationTracking();
    } else {
      if (!_gpsEnabled) await _requestEnableGps();
      if (!_permissionGranted) await _requestLocationPermission();
    }
  }

  // Method to request location permission
  Future<bool> _isPermissionGranted() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  // Method to check if GPS is enabled
  Future<bool> _isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request to enable GPS
  Future<void> _requestEnableGps() async {
    bool isGpsActive = await Geolocator.openLocationSettings();
    gpsEnabled = isGpsActive;
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    PermissionStatus permissionStatus =
        await Permission.locationWhenInUse.request();
    permissionGranted = permissionStatus == PermissionStatus.granted;
    if (permissionGranted) {
      _startLocationTracking();
    }
  }

  void _startLocationTracking() async {
    // getCurrentLocation();
    Position pos = await Geolocator.getCurrentPosition();

    currentLocation.value = LatLng(pos.latitude, pos.longitude);
    mapController.animateCamera(
      CameraUpdate.newLatLng(currentLocation.value),
    );
    // positionStream = Geolocator.getPositionStream(
    //         locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
    //     .listen((Position position) {
    //   updateCurrentPosition(position.latitude, position.longitude);
    // });
  }

  // Method to update current position on the map
  void updateCurrentPosition(double latitude, double longitude) {
    // currentLocation.value = LatLng(latitude, longitude);
    // mapController.animateCamera(CameraUpdate.newLatLng(currentLocation.value));
  }

  @override
  void onClose() {
    positionStream?.cancel();
    super.onClose();
  }

  ///API SERVICE FOR ALL DEVICE

  Future<void> devicesByOwnerID(bool updateCamera) async {
    bool isLogIn = await AppPreference.getBoolFromSF(Constants.isLogIn) ?? false;
    if(isLogIn){
      try {
        final body = {"ownerId": "${devicesOwnerID.value}"};
        networkStatus.value = NetworkStatus.LOADING;

        final response = await apiService.devicesByOwnerID(body);
        if (response.status == 200) {
          networkStatus.value = NetworkStatus.SUCCESS;
          vehicleList.value = response;

          final allVehiclesRes =
              vehicleList.value.data ?? []; // Assuming data is a List<Data>

          // log("DATA ${allVehiclesRes.length}");
          allVehicles.value = allVehiclesRes;
          ignitionOnList.value = filterIgnitionOn(allVehiclesRes).obs;
          ignitionOffList.value = filterIgnitionOff(allVehiclesRes).obs;
          activeVehiclesList.value = filterActiveVehicles(allVehiclesRes).obs;
          idleList.value = filterIdleVehicles(allVehiclesRes).obs;
          // log("activeVehiclesList===>${jsonEncode(activeVehiclesList)}");
          // log("ignitionOnList===>${jsonEncode(ignitionOnList)}");
          // log("ignitionOffList===>$ignitionOffList");
          // log("idleList===>$idleList");
          // Initialize filter data after API call and filtering
          filterData.value = [
            FilterData(
                image: Assets.images.svg.icCheck,
                count: activeVehiclesList.length,
                title: 'Active'),
            FilterData(
                image: Assets.images.svg.icFlashGreen,
                count: ignitionOnList.length,
                title: 'Ignition On'),
            FilterData(
                image: Assets.images.svg.icFlashRed,
                count: ignitionOffList.length,
                title: 'Ignition Off'),
            FilterData(
                image: Assets.images.svg.icLoading,
                count: idleList.length,
                title: 'Idle'),
          ];

          getVehicleTypeList();

          if (!isFilterSelected.value && !isShowvehicleDetail.value) {
            markers.value = [];
            for (var vehicle in allVehiclesRes) {
              if (vehicle.trackingData?.location?.latitude != null &&
                  vehicle.trackingData?.location?.longitude != null) {
                Marker m = await createMarker(
                    imei: vehicle.imei ?? "",
                    lat: vehicle.trackingData?.location?.latitude,
                    long: vehicle.trackingData?.location?.longitude,
                    img: vehicle.vehicletype?.icons,
                    id: vehicle.sId,
                    vehicleNo: vehicle.vehicleNo);
                markers.add(m);
              }
            }
            if (updateCamera &&
                allVehiclesRes.isNotEmpty &&
                allVehiclesRes[0].trackingData?.location?.latitude != null &&
                allVehiclesRes[0].trackingData?.location?.longitude != null) {
              updateCameraPosition(
                  allVehiclesRes[0].trackingData?.location?.latitude ?? 0,
                  allVehiclesRes[0].trackingData?.location?.longitude ?? 0);
            }
          } else if (isFilterSelected.value) {
            checkFilterIndex(false);
          } else if (isShowvehicleDetail.value &&
              selectedVehicleIndex.value != -1) {
            devicesByDetails(
                vehicleList.value.data?[selectedVehicleIndex.value].imei ?? '',
                updateCamera: false);
          }
        } else if (response.status == 400) {
          networkStatus.value = NetworkStatus.ERROR;
        }
      } catch (e, s) {
        log("erroe in vehicle $e $s");
        networkStatus.value = NetworkStatus.ERROR;
      }
    }

  }

  Future<void> getVehicleTypeList() async {
    try {
      networkStatus.value = NetworkStatus.LOADING;
      final response = await apiService.getVehicleType();

      if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        vehicleTypeList.value = response.data ?? [];

        // log("vehicle type list ===>${jsonEncode(vehicleTypeList)}");
      } else if (response.status == 400) {
        networkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;

      print("Error during OTP verification: $e");
    }
  }

  Rx<TrackRouteVehicleList> deviceDetail = Rx(TrackRouteVehicleList());

  // ///API SEVICE FOR DEVICE DETAILS
  Future<void> devicesByDetails(String imei, {bool updateCamera = true}) async {
    try {
      final body = {"deviceId": "${imei}"};
      networkStatus.value = NetworkStatus.LOADING;

      final response = await apiService.devicesByOwnerID(body);
      deviceDetail.value.data?.clear();

      if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        deviceDetail.value = response;
        final data = deviceDetail.value.data?[0];

        if (updateCamera) {
          updateCameraPosition(data?.trackingData?.location?.latitude ?? 0,
              data?.trackingData?.location?.longitude ?? 0);
        }

        relayStatus.value = response.data?[0].immobiliser ?? "Stop";
        vehicleRegistrationNumber.text = data?.vehicleRegistrationNo ?? '';
        dateAdded.text = formatDate(data?.dateAdded);
        driverName.text = data?.driverName ?? '';
        driverMobileNo.text = data?.mobileNo ?? '';
        vehicleBrand.text = data?.vehicleBrand ?? '';
        vehicleModel.text = data?.vehicleModel ?? '';
        maxSpeedUpdate.text = data?.maxSpeed ?? '';
        latitudeUpdate.text = (data?.location?.latitude ?? '').toString();
        longitudeUpdate.text = (data?.location?.longitude ?? '').toString();
        parkingUpdate.value = data?.parking ?? false;
        geofence.value = data?.location?.latitude != null && data?.location?.latitude != 0;
        areaUpdate.text = (data?.area ?? '').toString();
        vehicleModel.text = data?.vehicleModel ?? '';
        vehicleModel.text = data?.vehicleModel ?? '';

        vehicleType.value = DataVehicleType(
            id: data?.vehicletype?.sId ?? "",
            name: data?.vehicletype?.vehicleTypeName ?? "");
        insuranceExpiryDate.text = formatDate(data?.insuranceExpiryDate);
        pollutionExpiryDate.text = formatDate(data?.pollutionExpiryDate);
        fitnessExpiryDate.text = formatDate(data?.fitnessExpiryDate);
        nationalPermitExpiryDate.text =
            formatDate(data?.nationalPermitExpiryDate);
        if (data?.trackingData?.location?.latitude != null &&
            data?.trackingData?.location?.longitude != null) {
          Marker m = await createMarker(
              imei: data?.imei ?? "",
              lat: data?.trackingData?.location?.latitude,
              long: data?.trackingData?.location?.longitude,
              img: data?.vehicletype?.icons,
              id: data?.sId,
              vehicleNo: data?.vehicleNo);
          markers.value = [];
          markers.add(m);
        }
      } else if (response.status == 400) {
        networkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;

      log("Error : $e");
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return ''; // Handle null case
    try {
      // Parse the date string to a DateTime object
      DateTime dateTime = DateTime.parse(dateStr);
      // Format the date as dd-mm-yyyy
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return '-'; // Handle parsing error
    }
  }

// ALL VAR FOR EDIT DETAILS

  TextEditingController vehicleRegistrationNumber = TextEditingController();
  TextEditingController dateAdded = TextEditingController();
  TextEditingController driverName = TextEditingController();
  TextEditingController driverMobileNo = TextEditingController();
  TextEditingController vehicleBrand = TextEditingController();
  TextEditingController vehicleModel = TextEditingController();
  TextEditingController insuranceExpiryDate = TextEditingController();
  TextEditingController pollutionExpiryDate = TextEditingController();
  TextEditingController fitnessExpiryDate = TextEditingController();
  TextEditingController nationalPermitExpiryDate = TextEditingController();
  TextEditingController latitudeUpdate = TextEditingController();
  TextEditingController longitudeUpdate = TextEditingController();
  TextEditingController areaUpdate = TextEditingController();
  TextEditingController maxSpeedUpdate = TextEditingController();
  Rx<DataVehicleType> vehicleType = Rx(DataVehicleType());
  Rx<bool> parkingUpdate = Rx(false);
  Rx<bool> geofence = Rx(false);
  Rx<bool> selectCurrentLocationUpdate = Rx(false);

  //edit detail api

  Future<void> editDevicesByDetails(
      {bool editGeofence = false,
      bool editSpeed = false,
      bool editGeneral = false, required BuildContext context}) async {
    try {
      double? lat;
      double? long;
      if (editGeofence) {
        lat = double.tryParse(latitudeUpdate.text) ?? 0.0;
        long = double.tryParse(longitudeUpdate.text) ?? 0.0;
        if (selectCurrentLocationUpdate.value) {
          Position? data = await getCurrentLocation();
          lat = data?.latitude;
          long = data?.longitude;
        }
      } else {
        selectCurrentLocationUpdate.value=false;
        geofence.value =deviceDetail.value.data?[0].location?.latitude !=null && deviceDetail.value.data?[0].location?.latitude!=0;
        latitudeUpdate.text = (deviceDetail.value.data?[0].location?.latitude ?? '').toString();
        longitudeUpdate.text = (deviceDetail.value.data?[0].location?.longitude ?? '').toString();
        // parkingUpdate.value = deviceDetail.value.data?[0].parking ?? false;
        areaUpdate.text = (deviceDetail.value.data?[0].area ?? '').toString();
      }

      if(!editSpeed){
        maxSpeedUpdate.text=deviceDetail.value.data?[0].maxSpeed ?? '';
      }

      if(!editGeneral){
        final data = deviceDetail.value.data?[0];

        vehicleRegistrationNumber.text = data?.vehicleRegistrationNo ?? '';
        dateAdded.text = formatDate(data?.dateAdded);
        driverName.text = data?.driverName ?? '';
        driverMobileNo.text = data?.mobileNo ?? '';
        vehicleBrand.text = data?.vehicleBrand ?? '';
        vehicleModel.text = data?.vehicleModel ?? '';
        vehicleType.value = DataVehicleType(
            id: data?.vehicletype?.sId ?? "",
            name: data?.vehicletype?.vehicleTypeName ?? "");
        insuranceExpiryDate.text = formatDate(data?.insuranceExpiryDate);
        pollutionExpiryDate.text = formatDate(data?.pollutionExpiryDate);
        fitnessExpiryDate.text = formatDate(data?.fitnessExpiryDate);
        nationalPermitExpiryDate.text =
            formatDate(data?.nationalPermitExpiryDate);
      }

      final body = {
        "vehicleRegistrationNo": vehicleRegistrationNumber.text,
        "dateAdded": dateAdded.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd')
                .format(DateFormat('dd-MM-yyyy').parse(dateAdded.text))
            : "",
        "driverName": driverName.text,
        "mobileNo": driverMobileNo.text,
        "vehicleType": vehicleType.value.id.toString(),
        "vehicleBrand": vehicleBrand.text,
        "vehicleModel": vehicleModel.text,
        "insuranceExpiryDate": insuranceExpiryDate.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('dd-MM-yyyy').parse(insuranceExpiryDate.text))
            : "",
        "pollutionExpiryDate": pollutionExpiryDate.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('dd-MM-yyyy').parse(pollutionExpiryDate.text))
            : "",
        "fitnessExpiryDate": fitnessExpiryDate.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd')
                .format(DateFormat('dd-MM-yyyy').parse(fitnessExpiryDate.text))
            : "",
        "nationalPermitExpiryDate": nationalPermitExpiryDate.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('dd-MM-yyyy').parse(nationalPermitExpiryDate.text))
            : "",
        "_id": deviceDetail.value.data?[0].sId ?? '',
        "maxSpeed": maxSpeedUpdate.text.trim(),
        "parking": parkingUpdate.value,
        "Area": areaUpdate.text.trim(),
        "location": {"longitude": lat, "latitude": long}
      };
      networkStatus.value = NetworkStatus.LOADING;

      await apiService.editDevicesByOwnerID(body);
      devicesByDetails(deviceDetail.value.data?[0].imei ?? "", updateCamera : true);
      Utils.getSnackbar('Success', 'Your detail is Updated');
      // deviceDetail.value.data?.clear();
      /* if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        stackIndex.value = 0;

      } else if (response.status == 400) {
        networkStatus.value = NetworkStatus.ERROR;
      }*/
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;

      print("Error during data update: $e");
    }


  }

  Future<Marker> createMarker(
      {double? lat,
      double? long,
      String? img,
      String? id,
      required String imei,
      String? vehicleNo}) async {
    BitmapDescriptor markerIcon =
        await createMarkerIcon('${ProjectUrls.imgBaseUrl}$img');
    final markerId = "${ProjectUrls.imgBaseUrl}$img$id";
    final marker = Marker(
        // rotation: 90,
        markerId: MarkerId(markerId),
        position: LatLng(
          lat ?? 0,
          long ?? 0,
        ),
        infoWindow: InfoWindow(
          title: vehicleNo,
          snippet: 'Vehicle ID: ${id}',
        ),
        icon: markerIcon,
        onTap: () => _onMarkerTapped(-1, imei, lat ?? 0, long ?? 0));
    return marker;
  }

  void showAllVehicles() async {
    isShowvehicleDetail.value = false;
    polylines.value = [];
    markers.value = [];
    selectedVehicleIndex.value = -1;
    isvehicleSelected.value = false;

    for (var vehicle in vehicleList.value.data ?? []) {
      if (vehicle.trackingData?.location?.latitude != null &&
          vehicle.trackingData?.location?.longitude != null) {
        Marker m = await createMarker(
            imei: vehicle.imei ?? "",
            lat: vehicle.trackingData?.location?.latitude,
            long: vehicle.trackingData?.location?.longitude,
            img: vehicle.vehicletype?.icons,
            id: vehicle.sId,
            vehicleNo: vehicle.vehicleNo);
        markers.add(m);
      }
    }
    if ((vehicleList.value.data?.isNotEmpty ?? false) &&
        vehicleList.value.data?[0].trackingData?.location?.latitude != null &&
        vehicleList.value.data?[0].trackingData?.location?.longitude != null) {
      updateCameraPosition(
          vehicleList.value.data?[0].trackingData?.location?.latitude ?? 0,
          vehicleList.value.data?[0].trackingData?.location?.longitude ?? 0);
    } else {
      updateCameraPositionToCurrentLocation();
    }
  }

  void checkFilterIndex(bool updateCamera) async {
    List<Data> vehiclesToDisplay = [];

    if (isFilterSelectedindex.value == 0) {
      vehiclesToDisplay = activeVehiclesList;
    } else if (isFilterSelectedindex.value == 1) {
      vehiclesToDisplay = ignitionOnList;
    } else if (isFilterSelectedindex.value == 2) {
      vehiclesToDisplay = ignitionOffList;
    } else if (isFilterSelectedindex.value == 3) {
      vehiclesToDisplay = idleList;
    } else {
      vehiclesToDisplay = allVehicles;
    }
    if (vehiclesToDisplay.isNotEmpty &&
        updateCamera &&
        vehiclesToDisplay[0].trackingData?.location?.latitude != null &&
        vehiclesToDisplay[0].trackingData?.location?.longitude != null) {
      updateCameraPosition(
          vehiclesToDisplay[0].trackingData?.location?.latitude ?? 0,
          vehiclesToDisplay[0].trackingData?.location?.longitude ?? 0);
    } else {
      updateCameraPositionToCurrentLocation();
    }

    for (var vehicle in vehiclesToDisplay) {
      if (vehicle.trackingData?.location?.latitude != null &&
          vehicle.trackingData?.location?.longitude != null) {
        Marker marker = await createMarker(
            id: vehicle.sId,
            img: vehicle.vehicletype?.icons,
            long: vehicle.trackingData?.location?.longitude,
            lat: vehicle.trackingData?.location?.latitude,
            vehicleNo: vehicle.vehicleNo,
            imei: vehicle.imei ?? "");
        markers.add(marker);
      }
    }
  }

  RxString relayStatus = "".obs;

  Future<void> checkRelayStatus(String imei) async {
    var response;
    try {
      networkStatus.value =
          NetworkStatus.LOADING; // Set network status to loading
      final body = {"imei": imei};
      log("CHECK RELAY $body");
      response = await apiService.relayStatus(body);
      debugPrint("RESPONSE $response");
      if (response.data.status != null && response.data.status == "success") {
        relayStatus.value = response.data.response.type;
        networkStatus.value = NetworkStatus.SUCCESS;
      } else {
        Utils.getSnackbar("Engine Status", response.data.message);
      }
    } catch (e) {
      debugPrint("EXCEPTION $e");
      networkStatus.value = NetworkStatus.ERROR;
    }
  }

  Future<void> stopEngine(String imei) async {
    var response;
    try {
      networkStatus.value =
          NetworkStatus.LOADING; // Set network status to loading
      final body = {"imei": imei};
      response = await apiService.relayStopEngine(body);
      if (response.data.message != null) {
        Utils.getSnackbar("Engine", response.data.message);
      }

      if (response.message == "success") {
        devicesByDetails(imei, updateCamera: false);
        // checkRelayStatus(imei);
        networkStatus.value = NetworkStatus.SUCCESS;
      }
      Utils.getSnackbar("Engine", response.data.message);
    } catch (e) {
      debugPrint("EXCEPTION $e");
      networkStatus.value = NetworkStatus.ERROR;
    }
  }

  Future<void> startEngine(String imei) async {
    var response;
    try {
      networkStatus.value =
          NetworkStatus.LOADING; // Set network status to loading
      final body = {"imei": imei};
      response = await apiService.relayStartEngine(body);
      if (response.data.message != null) {
        Utils.getSnackbar("Engine", response.data.message);
      }
      if (response.message == "success") {
        devicesByDetails(imei, updateCamera: false);
        // checkRelayStatus(imei);
        networkStatus.value = NetworkStatus.SUCCESS;
      }
    } catch (e) {
      debugPrint("EXCEPTION $e");
      networkStatus.value = NetworkStatus.ERROR;
    }
  }
}
