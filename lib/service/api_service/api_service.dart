import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';
import 'package:track_route_pro/constants/project_urls.dart';
import 'package:track_route_pro/service/model/auth/ManageSettingModel.dart';
import 'package:track_route_pro/service/model/auth/forgot_password/generate_otp.dart';
import 'package:track_route_pro/service/model/auth/forgot_password/verify_otp.dart';
import 'package:track_route_pro/service/model/auth/login/login_response.dart';
import 'package:track_route_pro/service/model/auth/reset_password/reset_password.dart';
import 'package:track_route_pro/service/model/faq/FaqListModel.dart';
import 'package:track_route_pro/service/model/listing_base_response.dart';
import 'package:track_route_pro/service/model/presentation/RenewResponse.dart';
import 'package:track_route_pro/service/model/presentation/fcm_token.dart';
import 'package:track_route_pro/service/model/presentation/setting_screen_model/about_us_model.dart';
import 'package:track_route_pro/service/model/presentation/setting_screen_model/setting_add_model.dart';
import 'package:track_route_pro/service/model/presentation/setting_screen_model/support_response.dart';
import 'package:track_route_pro/service/model/presentation/splsh_add/splash_add.dart';
import 'package:track_route_pro/service/model/presentation/track_route/track_route_vehicle_list.dart';
import 'package:track_route_pro/service/model/presentation/vehicle_type/VehicleTypeList.dart';
import 'package:track_route_pro/service/model/privacy_policy/PrivacyPolicyResponse.dart';
import 'package:track_route_pro/service/model/route_history/RouteHistoryResponse.dart';
import 'package:track_route_pro/utils/app_prefrance.dart';
import '../model/alerts/alert/AlertsResponse.dart';
import '../model/faq/Topic.dart';
import '../model/notification/AnnouncementResponse.dart';
import '../model/relay/RelayStatusResponse.dart';
import '../model/relay/relay/RelayResponse.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ProjectUrls.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  static ApiService create() {
    final dio = DioUtil().getDio(
      useAccessToken: true,
    );
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: kDebugMode ? true : false,
        requestBody: kDebugMode ? true : false,
        responseBody: kDebugMode ? true : false,
        responseHeader: kDebugMode ? true : false,
        compact: kDebugMode ? true : false,
      ),
    );
    //kDebugMode ? "" : dio.interceptors.clear();
    return ApiService(dio);
  }

  @POST(ProjectUrls.login)
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );
  @POST(ProjectUrls.forgotPassword)
  Future<generateOtp> forgotPassword(
    @Body() Map<String, dynamic> body,
  );
  @POST(ProjectUrls.verifyOTP)
  Future<VeryfyOTP> verifyOTP(
    @Body() Map<String, dynamic> body,
  );
  @POST(ProjectUrls.resetPassword)
  Future<ResetPassword> resetPassword(
    @Body() Map<String, dynamic> body,
  );
  @POST(ProjectUrls.splashAdd)
  Future<SplashAddResponse> splashAdd();

  @POST(ProjectUrls.sendTokenData)
  Future<FCMDataResponse> sendTokenData(
    @Body() Map<String, dynamic> body,
  );

  @POST(ProjectUrls.settingAdd)
  Future<SettingAddResponse> settingAdd();

  @POST(ProjectUrls.aboutUs)
  Future<AboutUSResponse> aboutUS();

  @POST(ProjectUrls.support)
  Future<SupportResponse> support(
    @Body() Map<String, dynamic> body,
  );
  @POST(ProjectUrls.devicesByOwnerID)
  Future<TrackRouteVehicleList> devicesByOwnerID(
    @Body() Map<String, dynamic> body,
  );
  @POST(ProjectUrls.editdevicesByOwnerID)
  Future editDevicesByOwnerID(
    @Body() Map<String, dynamic> body,
  );

  @POST(ProjectUrls.vehicleType)
  Future<VehicleTypeList> getVehicleType();

  @POST(ProjectUrls.renewSubscription)
  Future<RenewResponse> renewSubscription(
      @Body() Map<String, dynamic> body,
      );

  @POST(ProjectUrls.manageSettings)
  Future<ManageSettingModel> manageSettings();

  @POST(ProjectUrls.faqTopic)
  Future<ListingBaseResponse<Topic>> faqTopic();

  @POST(ProjectUrls.faqList)
  Future<ListingBaseResponse<FaqListModel>> faqList();

  @POST(ProjectUrls.announcements)
  Future<ListingBaseResponse<AnnouncementResponse>> announcements( @Body() Map<String, dynamic> body);

  @POST(ProjectUrls.alerts)
  Future<ListingBaseResponse<AlertsResponse>> alerts(@Body() Map<String, dynamic> body);

  @POST(ProjectUrls.relayCheckStatus)
  Future<RelayStatusResponse> relayStatus( @Body() Map<String, dynamic> body);

  @POST(ProjectUrls.relayStartEngine)
  Future<RelayResponse> relayStartEngine( @Body() Map<String, dynamic> body);

  @POST(ProjectUrls.relayStopEngine)
  Future<RelayResponse> relayStopEngine(@Body() Map<String, dynamic> body);

  @POST(ProjectUrls.routeHistory)
  Future<ListingBaseResponse<RouteHistoryResponse>> routeHistory(@Body() Map<String, dynamic> body);

  @POST(ProjectUrls.privacyPolicy)
  Future<ListingBaseResponse<PrivacyPolicyResponse>> privacyPolicy();
}
