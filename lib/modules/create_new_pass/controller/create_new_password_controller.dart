import 'package:track_route_pro/constants/constant.dart';
import 'package:track_route_pro/routes/app_pages.dart';
import 'package:track_route_pro/service/api_service/api_service.dart';
import 'package:track_route_pro/utils/app_prefrance.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:track_route_pro/utils/enums.dart';

class CreateNewPasswordController extends GetxController {
  ApiService apiservice = ApiService.create();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Rx<NetworkStatus> networkStatus = Rx(NetworkStatus.IDLE);
  RxBool obscureText = RxBool(true); // Default to hide password
  RxString errorConfirmPassword = ''.obs;
  RxString errorPassword = ''.obs;
  RxString email = ''.obs;
  RxString otp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    String? forgotemail =
        await AppPreference.getStringFromSF(Constants.forgotemail);
    String? getotp = await AppPreference.getStringFromSF(Constants.otp);

    email.value = forgotemail ?? "";
    otp.value = getotp ?? "";
  }

  void validatePassword(AppLocalizations localizations) {
    final password = passwordController.text;
    if (password.isEmpty) {
      errorPassword.value =
          localizations.pleasePassword; // Localized error message
    } else if (password.length < 6) {
      errorPassword.value =
          localizations.pleaseValidPassword; // Localized error message
    } else {
      errorPassword.value = ''; // Clear error
    }
  }

  Future<void> resetPassword() async {
    try {
      final body = {
        "emailAddress": email.value,
        "otp": otp.value,
        "password": '${confirmpasswordController.text}'
      };
      networkStatus.value = NetworkStatus.LOADING;

      final response = await apiservice.resetPassword(body);

      if (response.status == 200) {
        Get.offAllNamed(Routes.LOGIN);
        networkStatus.value = NetworkStatus.SUCCESS;
      } else if (response.status == 400) {
        networkStatus.value = NetworkStatus.ERROR;
      }
    } catch (e) {
      networkStatus.value = NetworkStatus.ERROR;

      print("Error during OTP verification: $e");
    }
  }

  void validateConfirmPassword() {
    final confirmPassword = confirmpasswordController.text;
    final password = passwordController.text;

    if (confirmPassword.isEmpty) {
      errorConfirmPassword.value =
          'Please enter the confirm password'; // Custom error message
    } else if (confirmPassword != password) {
      errorConfirmPassword.value =
          'Passwords do not match'; // Custom error message
    } else {
      errorConfirmPassword.value = ''; // Clear error
    }
  }
}
