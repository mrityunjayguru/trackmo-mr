import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:track_route_pro/config/app_sizer.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';
import 'package:track_route_pro/gen/assets.gen.dart';
import 'package:track_route_pro/modules/about_us/view/about_us.dart';
import 'package:track_route_pro/modules/faqs/view/faqs_view.dart';
import 'package:track_route_pro/modules/settig_screen/controller/setting_controller.dart';
import 'package:track_route_pro/modules/support/view/support_view.dart';
import 'package:track_route_pro/routes/app_pages.dart';
import 'package:track_route_pro/utils/app_prefrance.dart';
import 'package:track_route_pro/utils/common_import.dart';

import '../../../constants/project_urls.dart';
import '../../../utils/utils.dart';
import '../../faqs/controller/faqs_controller.dart';
import '../../login_screen/controller/login_controller.dart';
import '../../splash_screen/controller/data_controller.dart';

class SettingView extends StatelessWidget {
  SettingView({super.key});

  final controller = Get.put(SettingController());

  final dataController = Get.isRegistered<DataController>()
      ? Get.find<DataController>() // Find if already registered
      : Get.put(DataController());

  // void initState() {
  @override
  Widget build(BuildContext context) {
    final localizations = getAppLocalizations(context)!;
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(child: Obx(() {
        return Column(
          children: [
            Row(
              children: [
                Image.network(
                    width: 25,
                    height: 25,
                    "${ProjectUrls.imgBaseUrl}${dataController.settings.value.logo}",
                    errorBuilder: (context, error, stackTrace) =>
                        SvgPicture.asset(
                          Assets.images.svg.icIsolationMode,
                          color: AppColors.black,
                        )).paddingOnly(left: 6, right: 8),
                Text(
                  localizations.settings,
                  style: AppTextStyles(context).display20W500,
                )
              ],
            ).paddingOnly(top: 12),

            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radius_15),
                      color: AppColors.grayLighter,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizations.language,
                          style: AppTextStyles(context)
                              .display12W400
                              .copyWith(color: AppColors.grayLight),
                        ),
                        Text(
                          localizations.engUk,
                          style: AppTextStyles(context)
                              .display14W500
                              .copyWith(color: AppColors.grayLight),
                        ),
                      ],
                    ).paddingSymmetric(vertical: 5, horizontal: 16),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radius_15),
                        color: AppColors.selextedindexcolor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            localizations.notifications,
                            style: AppTextStyles(context).display14W500,
                          ),
                          Obx(
                            () => Switch(
                              trackOutlineColor:
                                  WidgetStatePropertyAll(Colors.transparent),
                              activeColor: AppColors.black,
                              value: controller.isNotificationShow.value,

                              activeTrackColor: AppColors.whiteOff,
                              onChanged: (value) {
                                controller.setNotification();
                              },
                            ),
                          )
                        ],
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.to(()=> AboutUsView(), transition: Transition.upToDown, duration: const Duration(milliseconds: 300));
                    },
                    child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.radius_15),
                          color: AppColors.black,
                        ),
                        child: Center(
                          child: Text(
                            localizations.aboutTrackRoutePro,
                            style: AppTextStyles(context)
                                .display13W500
                                .copyWith(color: AppColors.selextedindexcolor),
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.put(FaqsController()).getTopics();
                      Get.put(FaqsController()).getFaq();
                      Get.to(()=> FaqsView(), transition: Transition.upToDown, duration: const Duration(milliseconds: 300));
                      // Get.toNamed(Routes.FAQS);
                    },
                    child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.radius_15),
                          color: AppColors.black,
                        ),
                        child: Center(
                          child: Text(
                            localizations.faq,
                            style: AppTextStyles(context)
                                .display13W500
                                .copyWith(color: AppColors.selextedindexcolor),
                          ),
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.to(()=> SupportView(), transition: Transition.upToDown, duration: const Duration(milliseconds: 300));

                    },
                    child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.radius_15),
                          color: AppColors.selextedindexcolor,
                        ),
                        child: Center(
                          child: Text(
                            localizations.support,
                            style: AppTextStyles(context).display16W700,
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radius_15),
                      ),
                      child: Obx(() {
                        return InkWell(
                          onTap: () {
                            Utils.makePhoneCall(
                                dataController.settings.value.mobileSupport ??
                                    "");
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localizations.orCallUs,
                                style: AppTextStyles(context)
                                    .display14W500
                                    .copyWith(color: AppColors.grayLight.withOpacity(0.7)),
                              ),
                              Text(
                                '${dataController.settings.value.mobileSupport ?? ""}',
                                style: AppTextStyles(context).display16W600,
                              ),
                            ],
                          ).paddingOnly(left: 4),
                        );
                      })),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.addBanner.value.data?.length ?? 0,
                itemBuilder: (context, index) => InkWell(
                  onTap: ()=> Utils.launchLink(controller.addBanner.value.data![index].hyperLink ?? ""),
                  child: Container(
                    child: Image.network(
                        height: 13.h,
                        width: context.width,
                        fit: BoxFit.contain,
                        '${ProjectUrls.imgBaseUrl}${controller.addBanner.value.data![index].image}',
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(
                              Assets.images.svg.icIsolationMode,
                              color: AppColors.black,
                            )).paddingAll(4),
                    height: 13.h,
                    width: context.width,
                    decoration: BoxDecoration(
                        color: AppColors.bannerBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radius_15)),
                  ).paddingOnly(bottom: 2.h),
                ),
              ),
            ),
            // Spacer(),
            InkWell(
              onTap: () async {
                Get.offAllNamed(Routes.LOGIN);
                await Get.put(LoginController()).sendTokenData();
                await AppPreference.removeLoginData();

              },
              child: Container(
                height: 6.h,
                width: 45.w,
                decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(AppSizes.radius_24)),
                child: Center(
                    child: Text(
                  localizations.logOut,
                  style: AppTextStyles(context)
                      .display16W400
                      .copyWith(color: AppColors.selextedindexcolor),
                )),
              ),
            ),
            Container(
              height: 5.h,
              width: 100.w - (4.w * 0.9),
              decoration: BoxDecoration(
                  color: AppColors.grayLighter,
                  borderRadius: BorderRadius.circular(AppSizes.radius_12 * 0.5)),
              child: Center(
                  child: Text(
                localizations.newfeatures,
                style: AppTextStyles(context).display12W500,
              )),
            ).paddingOnly(bottom: 20, top: 20),
            // Expanded(
            //   child: GridView.builder(
            //     itemCount: 2,
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 2,
            //         crossAxisSpacing: 12,
            //         mainAxisSpacing: 12,
            //         childAspectRatio: 3.7),
            //     itemBuilder: (context, index) => Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(AppSizes.radius_16),
            //         color: AppColors.grayLighter,
            //       ),
            //     ),
            //   ),
            // )
          ],
        ).paddingSymmetric(horizontal: 4.w * 0.9);
      })),
    );
  }
}
