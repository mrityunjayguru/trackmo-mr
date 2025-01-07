import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:track_route_pro/service/model/notification/AnnouncementResponse.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../constants/constant.dart';
import '../../../service/api_service/api_service.dart';
import '../../../service/model/alerts/alert/AlertsResponse.dart';
import '../../../utils/app_prefrance.dart';
import '../../../utils/enums.dart';

class AlertController extends GetxController {
  RxInt selectedIndex = RxInt(0);
  RxInt selectedVehicleIndex = RxInt(-1);
  RxString devicesOwnerID = RxString('');
  RxString selectedVehicleName = RxString('');
  RxBool vehicleSelected = RxBool(false);
  RxBool isExpanded = RxBool(false);
  RxList<AnnouncementResponse> announcements = <AnnouncementResponse>[].obs;
  RxList<AlertsResponse> alerts = <AlertsResponse>[].obs;
  // RxList<AlertDataModel> alertsData = <AlertDataModel>[].obs;
  RxList<AlertsResponse> unfilteredAlerts = <AlertsResponse>[].obs;
  final ApiService apiService = ApiService.create();
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  final IgnitionOn = ValueNotifier<bool>(true);
  final IgnitionOff = ValueNotifier<bool>(true);
  final OverSpeed = ValueNotifier<bool>(true);
  final MovementStop = ValueNotifier<bool>(true);
  final Parking = ValueNotifier<bool>(true);
  final DevicePowerCut = ValueNotifier<bool>(true);
  final DeviceLowBattery = ValueNotifier<bool>(true);
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.max,
  );

  @override
  void onInit() {
    super.onInit();
    // _loadPreferences();
  }
  //
  // Future<void> _loadPreferences() async {
  //   final jsonData =
  //       await AppPreference.getJsonFromPrefs(AppPreference.alertPreferences);
  //
  //   AlertsFilterModel alertSettings = jsonData != null
  //       ? AlertsFilterModel.fromJson(jsonData)
  //       : AlertsFilterModel();
  //
  //   if (jsonData == null) {
  //     _saveDefaultsToPrefs();
  //   } else {
  //     IgnitionOn.value = alertSettings.ignitionOn ?? true;
  //     IgnitionOff.value = alertSettings.ignitionOff ?? true;
  //     // GeoFenceIn.value = alertSettings.geofenceIn ?? true;
  //     // GeoFenceOut.value = alertSettings.geofenceOut ?? true;
  //     OverSpeed.value = alertSettings.overspeed ?? true;
  //     DevicePowerCut.value = alertSettings.powerCut ?? true;
  //     MovementStop.value = alertSettings.vibration ?? true;
  //     DeviceLowBattery.value = alertSettings.lowbattery ?? true;
  //   }
  //
  //   _addListeners();
  //   _filterData();
  // }
  //
  // Future<void> _saveDefaultsToPrefs() async {
  //   final alertSettings = AlertsFilterModel(
  //     ignitionOn: true,
  //     ignitionOff: true,
  //     // geofenceIn: GeoFenceIn.value,
  //     // geofenceOut: GeoFenceOut.value,
  //     overspeed: true,
  //     powerCut: true,
  //     vibration: true,
  //     lowbattery: true,
  //     // others: Others.value,
  //   );
  //
  //   await AppPreference.saveJsonToPrefs(
  //       AppPreference.alertPreferences, alertSettings);
  // }
  //
  // void _addListeners() {
  //   IgnitionOn.addListener(() => _savePreferences());
  //   IgnitionOff.addListener(() => _savePreferences());
  //   OverSpeed.addListener(() => _savePreferences());
  //   MovementStop.addListener(() => _savePreferences());
  //   Parking.addListener(() => _savePreferences());
  //   DevicePowerCut.addListener(() => _savePreferences());
  //   DeviceLowBattery.addListener(() => _savePreferences());
  // }
  //
  // // Save current values to SharedPreferences
  // Future<void> _savePreferences() async {
  //   final alertSettings = AlertsFilterModel(
  //     ignitionOn: IgnitionOn.value,
  //     ignitionOff: IgnitionOff.value,
  //     // geofenceIn: GeoFenceIn.value,
  //     // geofenceOut: GeoFenceOut.value,
  //     overspeed: OverSpeed.value,
  //     powerCut: DevicePowerCut.value,
  //     vibration: MovementStop.value,
  //     lowbattery: DeviceLowBattery.value,
  //     // others: Others.value,
  //
  //   );
  //
  //   await AppPreference.saveJsonToPrefs(
  //       AppPreference.alertPreferences, alertSettings);
  //   _filterData();
  // }

  void getData() {
    isExpanded.value = false;
    selectedVehicleIndex.value = -1;
    selectedVehicleName.value = "";
    vehicleSelected.value = false;
    loadUser().then(
      (value) {
        getAnnouncements();
        getAlerts();
      },
    );
  }

  Future<void> loadUser() async {
    String? userId = await AppPreference.getStringFromSF(Constants.userId);
    print('userid:::::>${userId}');
    devicesOwnerID.value = userId ?? '';
  }

  Future<void> getAnnouncements() async {
    try {
      final body = {"_id": "${devicesOwnerID.value}"};
      networkStatus.value = NetworkStatus.LOADING;

      final response = await apiService.announcements(body);

      if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        announcements.value = response.data ?? [];
        announcements.sort((a, b) => DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
      } else if (response.status == 400) {
        networkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;
    }
  }

  Future<void> getAlerts() async {
    try {
      final body = {"ownerID": "${devicesOwnerID.value}"};
      networkStatus.value = NetworkStatus.LOADING;

      final response = await apiService.alerts(body);

      if (response.message?.toLowerCase() == "success") {
        networkStatus.value = NetworkStatus.SUCCESS;
        unfilteredAlerts.value = response.data ?? [];
        alerts.value = unfilteredAlerts;
        debugPrint("ALERTS ====> ${alerts.length}");
        // _filterData();
      } else {
        networkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e, s) {
      log("ERROR ALERTS $e $s");
      networkStatus.value = NetworkStatus.ERROR;
    }
  }

  Future<String> getAddressFromLatLong(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      Placemark place = placemarks[0];

      String address =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      return address;
    } catch (e) {
      debugPrint("Error " + e.toString());
      String address = "Address not available";
      return address;
    }
  }

  void filterAlerts(bool isSelected, String vehicleNo, int index) {
    isExpanded.value = false;
    vehicleSelected.value = isSelected;
    if (isSelected) {
      selectedVehicleName.value = vehicleNo;
      selectedVehicleIndex.value = index;
      alerts.value = unfilteredAlerts
          .where(
            (element) => element.deviceDetails?.vehicleNo == vehicleNo,
          )
          .toList();
    } else {
      selectedVehicleName.value = "";
      selectedVehicleIndex.value = -1;
      alerts.value = unfilteredAlerts;
    }
    alerts.sort((a, b) => DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
  }

  // void _filterData() {
  //   unfilteredAlerts.value=[];
  //   for(AlertsResponse data in alerts){
  //     if ( IgnitionOn.value && (data.trackingData?.ignition?.status ?? false)) {
  //       unfilteredAlerts.add(AlertDataModel.convertData(data, "Ignition On", Colors.green));
  //     }
  //     if ( IgnitionOn.value && !(data.trackingData?.ignition?.status ?? false)) {
  //       unfilteredAlerts.add(AlertDataModel.convertData(data, "Ignition Off", Colors.red));
  //     }
  //     if ( OverSpeed.value && ((data.trackingData?.currentSpeed ?? 0) >80)) {
  //       unfilteredAlerts.add(AlertDataModel.convertData(data, "Over speed (${(data.trackingData?.currentSpeed ?? 0)})", Colors.red));
  //     }
  //     if ( DeviceLowBattery.value && ((data.trackingData?.externalBattery ?? 0) <20)) {
  //       unfilteredAlerts.add(AlertDataModel.convertData(data, "Low Battery", Colors.yellow));
  //     }
  //   }
  //
  //   filterAlerts(vehicleSelected.value, selectedVehicleName.value,  selectedVehicleIndex.value);
  //
  // }
}
