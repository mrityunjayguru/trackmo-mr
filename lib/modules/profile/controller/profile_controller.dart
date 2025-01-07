import 'package:package_info_plus/package_info_plus.dart';
import 'package:track_route_pro/service/model/auth/login/login_response.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../constants/constant.dart';
import '../../../service/api_service/api_service.dart';
import '../../../service/model/presentation/track_route/track_route_vehicle_list.dart';
import '../../../utils/app_prefrance.dart';
import '../../../utils/enums.dart';
import '../../../utils/utils.dart';
import '../../track_route_screen/controller/track_route_controller.dart';

class ProfileController extends GetxController {
  RxBool isReNewSub = RxBool(false);
  RxInt selectedVehicleIndex = (-1).obs;
  RxString name = "-".obs;
  RxString email = "-".obs;
  RxString phone = "-".obs;
  RxString password = "".obs;
  RxList<Data>  expiringVehicles = <Data>[].obs;
  ApiService apiservice = ApiService.create();

  RxString appVersion = "".obs;
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  void checkForRenewal() {

    TrackRouteController trackRouteController = Get.find<TrackRouteController>();

    expiringVehicles.value = trackRouteController.getVehiclesWithExpiringSubscriptions();

  }

  @override
  void onInit() async {
    super.onInit();
    // Call the checkForRenewal method when the controller is initialized
    getAppVersion();
    name.value = await AppPreference.getStringFromSF(Constants.name) ?? "-";
    email.value = await AppPreference.getStringFromSF(Constants.email) ?? "-";
    phone.value = await AppPreference.getStringFromSF(Constants.phone) ?? "-";
    password.value = await AppPreference.getStringFromSF(Constants.password) ?? "";

  }

  void toggleVehicleSelection(int index) {
    selectedVehicleIndex.value = index; // Select the current index
    selectedVehicleIndex.refresh();
  }

  Future<void> renewService({String? id}) async {
    var response;
    try {
      networkStatus.value =
          NetworkStatus.LOADING; // Set network status to loading
      Map<String,String> body={};
      if(id!=null){
        body = {
          "_id": id
        };
      }
      else{
        if(selectedVehicleIndex.value!=-1){
          body = {
            "_id": expiringVehicles[selectedVehicleIndex.value].sId ?? ""
          };
        }
        else{
          Utils.getSnackbar("Error", "Please select an item for renewal");
        }

      }
      isReNewSub.value=false;

      response = await apiservice.renewSubscription(body);
      // Assuming you handle the response in a similar way
      if (response.status == 200) {
        networkStatus.value = NetworkStatus.SUCCESS;
        Get.put(TrackRouteController()).devicesByOwnerID(false);
        Utils.getSnackbar('Success', 'Generated request for renewal');
      }
      else{
        Utils.getSnackbar('Error', '${response.message}');
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;
      Utils.getSnackbar("Error", "Please try after 24 hours");
      print('Error: $e');
    }
  }

  Future<void> getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

}
