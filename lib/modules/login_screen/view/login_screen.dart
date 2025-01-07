import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/common/textfield/apptextfield.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/constants/constant.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/forgot_password/view/forgot_view.dart';
import 'package:track_route_pro/modules/login_screen/controller/login_controller.dart';
import 'package:track_route_pro/modules/privacy_policy/view/privacy_policy_page.dart';
import 'package:track_route_pro/utils/common_import.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final localizations = getAppLocalizations(context)!;

    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Container(
                height: 35.h,
                color: AppColors.black,
                child: Center(child: SvgPicture.asset(Assets.images.svg.logo)),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => AppTextFormField(
                        color: AppColors.textfield,
                        controller: controller.emailController,
                        hintText: localizations.userID,
                        errorText: controller.errorEmail.isNotEmpty
                            ? controller.errorEmail.value
                            : '',
                        onChanged: (_) {
                          controller.validateEmail(localizations);
                        },
                        border: Border.all(
                            width: 1,
                            color: controller.errorEmail.isNotEmpty
                                ? Colors.red
                                : Colors.transparent),
                      ),
                    ),
                    Obx(
                      () => AppTextFormField(
                        onChanged: (value) {
                          controller.validatePassword(localizations);
                        },
                        obscureText: controller.obscureText.value,
                        onSuffixTap: () {
                          controller.obscureText.value =
                              !controller.obscureText.value;
                        },
                        suffixIcon: !controller.obscureText.value
                            ? Assets.images.svg.icView
                            : 'assets/images/svg/eye_close_icon.svg',
                        color: AppColors.textfield,
                        controller: controller.passwordController,
                        hintText: localizations.password,
                        errorText: controller.errorPassword.isNotEmpty
                            ? controller.errorPassword.value
                            : '',
                        border: Border.all(
                            width: 1,
                            color: controller.errorPassword.isNotEmpty
                                ? Colors.red
                                : Colors.transparent),
                      ),
                    ),
                    Obx(
                      () {
                        return controller.isWrongUser.value
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                          'assets/images/svg/ic_sad.svg'),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      Text(
                                        'Whoops! The username or password entered is incorrect.',
                                        style: AppTextStyles(context)
                                            .display10W400
                                            .copyWith(color: Color(0xffE92E19)),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 10.h),
                    InkWell(
                      onTap: () {
                        controller.checkCredentials(localizations);
                      },
                      child: Container(
                        height: 6.h,
                        child: Center(
                          child: Text(
                            localizations.login,
                            style: AppTextStyles(context)
                                .display18W500
                                .copyWith(color: Color(0xffD9E821)),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.black,
                        ),
                      ),
                    ).paddingOnly(bottom: 20),
                    forgotPasswordMethod(localization: localizations),
                    InkWell(
                      onTap: ()=>  Get.to(()=> PrivacyPolicyView(), transition: Transition.upToDown, duration: const Duration(milliseconds: 300)),
                      child: Text(
                        localizations.bysubmitting,
                        style: AppTextStyles(context).display14W400.copyWith(color: AppColors.grayLight),
                        textAlign: TextAlign.center,
                      ).paddingOnly(top: 40, bottom: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget forgotPasswordMethod({required AppLocalizations localization}) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: localization.forgotPassword,
          style: TextStyle(color: AppColors.grayLight),
          children: [
            TextSpan(
              text: " "+localization.clickhere,
              style: TextStyle(color: AppColors.purpleColor), // Clickable text style
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.to(()=> ForgotView(), transition: Transition.upToDown, duration: const Duration(milliseconds: 300));
                },
            ),
          ],
        ),
      ),
    );
  }
}