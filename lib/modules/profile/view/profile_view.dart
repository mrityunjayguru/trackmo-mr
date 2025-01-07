import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/constants/project_urls.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/profile/controller/profile_controller.dart';
import 'package:track_route_pro/modules/profile/view/widget/re_new_subscription.dart';
import 'package:track_route_pro/utils/common_import.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/utils.dart';
import '../../splash_screen/controller/data_controller.dart';

class ProfileView extends StatefulWidget {
  ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final controller = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>() // Find if already registered
      : Get.put(ProfileController());
  final dataController = Get.isRegistered<DataController>()
      ? Get.find<DataController>() // Find if already registered
      : Get.put(DataController());

  void initState() {
    super.initState();

  }

  // Put (register) if not already registered
  @override
  Widget build(BuildContext context) {
    final localizations = getAppLocalizations(context)!;
    return Obx(() {
      return  AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Slide transition from up to down
          return SlideTransition(
            position: Tween<Offset>(
              begin:controller.isReNewSub.value?  Offset(-1,0): Offset(1,0), // Slide from top
              end: Offset.zero, // End position
            ).animate(animation),
            child: child,
          );
        },
        child:  controller.isReNewSub.value
            ? ReNewSubscription()
            : Container(
          color: AppColors.backgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                Obx(
                      () => Row(
                    children: [
                      Image.network(
                          width: 25,
                          height: 25,
                          "${ProjectUrls.imgBaseUrl}${dataController.settings.value.logo}",
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset(
                                Assets.images.svg.icIsolationMode,
                                color: AppColors.black,
                              )).paddingOnly(right:8),
                      Text(
                        localizations.myProfile,
                        style: AppTextStyles(context).display20W500,
                      ),
                      Spacer(),
                      Text(
                        'v${controller.appVersion}',
                        style: AppTextStyles(context).display16W500,
                      ),
                    ],
                  ).paddingOnly(top: 12, right: 3.w * 0.9, left: 3.w * 0.9),
                ),
                SizedBox(height: 16),
                Container(
                  width: 100.w - (4.w * 0.9),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff00000026).withOpacity(0.15),
                            blurRadius: 2,
                            spreadRadius: 0,
                            offset: Offset(0, 2))
                      ],
                      color: AppColors.whiteOff,
                      borderRadius:
                      BorderRadius.circular(AppSizes.radius_24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: AppTextStyles(context)
                            .display12W400
                            .copyWith(color: AppColors.grayLight),
                      ),
                      Text(
                        '${controller.name.value ?? ''}',
                        style: AppTextStyles(context).display14W600,
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Text(
                        'Registered Email ID',
                        style: AppTextStyles(context)
                            .display12W400
                            .copyWith(color: AppColors.grayLight),
                      ),
                      Text(
                        '${controller.email.value ?? ""}',
                        style: AppTextStyles(context).display14W600,
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Text(
                        'Registered Mobile',
                        style: AppTextStyles(context)
                            .display12W400
                            .copyWith(color: AppColors.grayLight),
                      ),
                      Text(
                        '${controller.phone.value}',
                        style: AppTextStyles(context).display14W600,
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset Password',
                                style: AppTextStyles(context)
                                    .display12W400
                                    .copyWith(color: AppColors.grayLight),
                              ),
                              Text(
                                '${controller.password.value.replaceRange(0,controller.password.value.length, "*")}',
                                style: AppTextStyles(context).display14W600.copyWith(color: AppColors.blueColor),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(AppSizes.radius_24),
                              color: AppColors.black,
                            ),
                            child: Center(
                              child: Text(
                                'Reset',
                                style: AppTextStyles(context)
                                    .display12W500
                                    .copyWith(
                                    color:
                                    AppColors.selextedindexcolor),
                              ).paddingSymmetric(
                                  horizontal: 7.w, vertical: 1.4.h),
                            ),
                          )
                        ],
                      )
                    ],
                  ).paddingSymmetric(horizontal: 4.w, vertical: 3.h),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(AppSizes.radius_20),
                      color: AppColors.whiteOff),
                  child: InkWell(
                    onTap: () {
                      controller.checkForRenewal();
                      controller.isReNewSub.value = true;
                      controller.selectedVehicleIndex.value=-1;
                    },
                    child: Container(
                      height: 5.h,
                      width: 70.w,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(AppSizes.radius_20),
                          color: AppColors.black),
                      child: Center(
                        child: Text(
                          'Renew / Extend Subscription',
                          style: AppTextStyles(context)
                              .display12W500
                              .copyWith(
                              color: AppColors.selextedindexcolor),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  // height: 20.h,
                  width: 100.w - (4.w * 0.9),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xff00000026).withOpacity(0.15),
                          blurRadius: 2,
                          spreadRadius: 0,
                          offset: Offset(0, 2))
                    ],
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(AppSizes.radius_24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CachedNetworkImage(
                          height: 50,
                          width: 120,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                          errorWidget: (context, url, error) =>  SvgPicture.asset(
                            "assets/images/svg/tarck_route_pro.svg",
                          ),
                          imageUrl:
                          "${ProjectUrls.imgBaseUrl}${dataController.settings.value.appLogo}",
                        ).paddingOnly(left: 6, right: 8),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        'Explore our wide range of GPS trackers!',
                        style: AppTextStyles(context)
                            .display15W400
                            .copyWith(color: AppColors.whiteOff),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      InkWell(
                        onTap: () async {
                          final url =
                              '${dataController.settings.value.catalogueLink ?? ''}';
                          Utils.launchLink(url);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(AppSizes.radius_24),
                            color: AppColors.selextedindexcolor,
                          ),
                          child: Text(
                            'Product Catalogue',
                            style: AppTextStyles(context).display12W500,
                          ).paddingSymmetric(
                              horizontal: 7.w, vertical: 1.4.h),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      InkWell(
                        onTap: (){
                          final url =
                              '${dataController.settings.value.websiteLink ?? ''}';
                          Utils.launchLink(url);
                        },
                        child: Text('${dataController.settings.value.websiteLabel ?? ''}',
                            style: AppTextStyles(context)
                                .display15W400
                                .copyWith(color: AppColors.whiteOff)),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 20, vertical: 13),
                ),
                SizedBox(
                  height: 3.h,
                )
              ],
            ).paddingSymmetric(horizontal: 4.w * 0.9),
          ),
        )
      );

    });
  }
}
