import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/common/textfield/apptextfield.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/constants/constant.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/create_new_pass/controller/create_new_password_controller.dart';
import 'package:track_route_pro/utils/common_import.dart';

class CreateNewPasswordView extends StatelessWidget {
  CreateNewPasswordView({super.key});
  final controller = Get.put(CreateNewPasswordController());

  @override
  Widget build(BuildContext context) {
    final localizations = getAppLocalizations(context)!;
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey, // Attach the GlobalKey to the Form
          child: Column(
            children: [
              Container(
                height: 35.h,
                color: AppColors.black,
                child: Center(child: SvgPicture.asset(Assets.images.svg.logo)),
              ),
              Container(
                height: 6,
                color: AppColors.selextedindexcolor,
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
                        controller: controller.passwordController,
                        border: Border.all(
                            color: controller.errorPassword.isNotEmpty
                                ? Colors.red
                                : Colors.transparent),
                        hintText: 'Password',
                        errorText: controller.errorPassword.isNotEmpty
                            ? controller.errorPassword.value
                            : '',
                        onChanged: (_) {
                          controller.validatePassword(localizations);
                        },
                      ),
                    ),
                    Obx(
                      () => AppTextFormField(
                        obscureText: controller.obscureText.value,
                        onSuffixTap: () {
                          controller.obscureText.value =
                              !controller.obscureText.value;
                        },
                        suffixIcon: Assets.images.svg.icView,
                        border: Border.all(
                            color: controller.errorConfirmPassword.isNotEmpty
                                ? Colors.red
                                : Colors.transparent),
                        color: AppColors.textfield,
                        controller: controller.confirmpasswordController,
                        hintText: 'Confirm Password',
                        errorText: controller.errorConfirmPassword.isNotEmpty
                            ? controller.errorConfirmPassword.value
                            : '',
                        onChanged: (_) {
                          controller.validateConfirmPassword();
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),
                    InkWell(
                      onTap: () {
                        if (controller.formKey.currentState!.validate()) {
                          // Proceed with the password reset logic
                          controller.resetPassword();
                        }
                      },
                      child: Container(
                        height: 6.h,
                        child: Center(
                          child: Text(
                            'Reset Password',
                            style: AppTextStyles(context)
                                .display18W500
                                .copyWith(color: Color(0xffD9E821)),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.black,
                        ),
                      ).paddingOnly(bottom: 20),
                    ),
                    // forgotPasswordMethod(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
