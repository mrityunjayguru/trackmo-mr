import 'package:dio/dio.dart';
import 'package:track_route_pro/service/api_service/api_service.dart';
import 'package:track_route_pro/service/model/presentation/setting_screen_model/setting_add_model.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:track_route_pro/utils/enums.dart';

import '../../../constants/constant.dart';
import '../../../utils/app_prefrance.dart';
import '../../login_screen/controller/login_controller.dart';

class SettingController extends GetxController {
  ApiService apiservice = ApiService.create();
  Rx<SettingAddResponse> addBanner = Rx(SettingAddResponse());
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  RxBool isNotificationShow = RxBool(false);
  late ApiService apiService;
  final dio = Dio();
  @override
  void onInit() {
    super.onInit();
    fetchAddData();
    getNotificationData();
    apiService = ApiService(dio);
  }

  Future<void> fetchAddData() async {
    try {
      networkStatus.value =
          NetworkStatus.LOADING; // Set network status to loading

      // Call the API method from ApiService
      final response = await apiservice.settingAdd();

      // Assuming you handle the response in a similar way
      if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        addBanner.value = response;
        addBanner.value.data= addBanner.value.data?.where((element) => element.status =="Active",).toList();
        print('message:::::>${addBanner.value.message}');
        print('data:::::>${addBanner.value.data}');
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;

      print('Error: $e');
    }
  }

  void getNotificationData() async {
    isNotificationShow.value =
        await AppPreference.getBoolFromSF(Constants.notification) ?? true;
  }

  void setNotification(){
    isNotificationShow.value=!isNotificationShow.value;
    AppPreference.addBoolToSF(
        Constants.notification,  isNotificationShow.value);
    Get.put(LoginController()).sendTokenData();
  }

  Future<void> sendTokenData() async {
    final notification = await AppPreference.getBoolFromSF(Constants.notification) ?? true;
    String userId = await AppPreference.getStringFromSF(Constants.userId) ?? "";

    if(userId.isNotEmpty){
      try {
        networkStatus.value =
            NetworkStatus.LOADING; // Set network status to loading

        // Call the API method from ApiService

        var request = {"_id": userId, "firebaseToken": '', "notification": '${notification}'};
        debugPrint("FIREBASE REQUEST ===> $request");
        var response = await apiService
            .sendTokenData(request);

        if (response.message?.isNotEmpty ?? false) {
          networkStatus.value = NetworkStatus.SUCCESS;
        }
      } catch (e) {
        networkStatus.value = NetworkStatus.ERROR;

        print('Error: $e');
      }
    }
  }

}