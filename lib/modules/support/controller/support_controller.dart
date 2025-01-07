import 'package:track_route_pro/constants/constant.dart';
import 'package:track_route_pro/service/api_service/api_service.dart';
import 'package:track_route_pro/utils/app_prefrance.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:track_route_pro/utils/enums.dart';

class SupportController extends GetxController {
  ApiService apiservice = ApiService.create();
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  TextEditingController deviceID = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController description = TextEditingController();
  RxString userEmail = ''.obs;
  RxString userId = ''.obs;
  RxBool isSucessSubmit = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    print('object::::::>SupportController ');
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    String? email = await AppPreference.getStringFromSF(Constants.email);
    String? sid = await AppPreference.getStringFromSF(Constants.userId);
    userEmail.value = email ?? '';
    userId.value = sid ?? "";
  }

  Future<void> submitSupportRequest() async {
    var supportRequest = {
      "deviceID": deviceID.text,
      "suport": subject.text,
      "description": description.text,
      "userID": userId.value
    };
    networkStatus.value = NetworkStatus.LOADING;
    try {
      final response = await apiservice.support(supportRequest);
      debugPrint("SUCESS Support");
      if (response.status == 200) {
        isSucessSubmit.value = true;
        deviceID.clear();
        subject.clear();
        description.clear();
        networkStatus.value = NetworkStatus.SUCCESS;
      } else {
        networkStatus.value = NetworkStatus.ERROR;
        ;
      }
    } catch (error) {
      debugPrint("ERROR $error");
      networkStatus.value = NetworkStatus.ERROR;
    }
  }
}
