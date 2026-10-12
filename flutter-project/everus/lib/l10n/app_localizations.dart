import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @flowStartComment1.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng chưa nào? 💪'**
  String get flowStartComment1;

  /// No description provided for @flowStartComment2.
  ///
  /// In vi, this message translates to:
  /// **'Cùng tạo kỉ niệm nhé!'**
  String get flowStartComment2;

  /// No description provided for @flowStartComment3.
  ///
  /// In vi, this message translates to:
  /// **'Đến lúc tỏa sáng rồi! ✨'**
  String get flowStartComment3;

  /// No description provided for @flowStartComment4.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc phiêu lưu đang chờ đón! 🌟'**
  String get flowStartComment4;

  /// No description provided for @flowCompleteComment1.
  ///
  /// In vi, this message translates to:
  /// **'Hai bạn thật tuyệt vời! 💕'**
  String get flowCompleteComment1;

  /// No description provided for @flowCompleteComment2.
  ///
  /// In vi, this message translates to:
  /// **'Ngập tràn tình yêu luôn! 🥰'**
  String get flowCompleteComment2;

  /// No description provided for @flowCompleteComment3.
  ///
  /// In vi, this message translates to:
  /// **'Cặp đôi hoàn hảo nhất quả đất! 👑'**
  String get flowCompleteComment3;

  /// No description provided for @flowCompleteComment4.
  ///
  /// In vi, this message translates to:
  /// **'Khoảnh khắc này thật đẹp! 🌸'**
  String get flowCompleteComment4;

  /// No description provided for @flowPhotoUploadComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng tải ảnh lên đang được phát triển!'**
  String get flowPhotoUploadComingSoon;

  /// No description provided for @flowNiceJob.
  ///
  /// In vi, this message translates to:
  /// **'Giỏi lắm! 🎯'**
  String get flowNiceJob;

  /// No description provided for @flowLevelComingUp.
  ///
  /// In vi, this message translates to:
  /// **'Sắp tới mức {level} rồi!'**
  String flowLevelComingUp(int level);

  /// No description provided for @flowKeepGoing.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục nào! 🚀'**
  String get flowKeepGoing;

  /// No description provided for @flowWeDidIt.
  ///
  /// In vi, this message translates to:
  /// **'Tụi mình làm được rồi! 🎉'**
  String get flowWeDidIt;

  /// No description provided for @flowUnlockTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mở khoá thêm các mức! 💖'**
  String get flowUnlockTitle;

  /// No description provided for @flowUnlockBody.
  ///
  /// In vi, this message translates to:
  /// **'Để tiếp tục cuộc phiêu lưu hẹn hò và mở khóa các mức tiếp theo, vui lòng đăng nhập hoặc tạo tài khoản.'**
  String get flowUnlockBody;

  /// No description provided for @flowLoginOrSignUp.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập / Đăng ký'**
  String get flowLoginOrSignUp;

  /// No description provided for @flowIntroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cuộc Phiêu Lưu Đang Chờ'**
  String get flowIntroTitle;

  /// No description provided for @flowSecretLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bí mật cần ghi nhớ:'**
  String get flowSecretLabel;

  /// No description provided for @flowDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng'**
  String get flowDuration;

  /// No description provided for @flowLevels.
  ///
  /// In vi, this message translates to:
  /// **'Mức'**
  String get flowLevels;

  /// No description provided for @flowCheckIns.
  ///
  /// In vi, this message translates to:
  /// **'Check-in'**
  String get flowCheckIns;

  /// No description provided for @flowBegin.
  ///
  /// In vi, this message translates to:
  /// **'Bắt Đầu Hành Trình'**
  String get flowBegin;

  /// No description provided for @flowLevelProgress.
  ///
  /// In vi, this message translates to:
  /// **'Mức {current}/{total}'**
  String flowLevelProgress(int current, int total);

  /// No description provided for @flowLevelUpper.
  ///
  /// In vi, this message translates to:
  /// **'MỨC {level}'**
  String flowLevelUpper(int level);

  /// No description provided for @flowPhotoPermission.
  ///
  /// In vi, this message translates to:
  /// **'Quyền truy cập Máy ảnh / Thư viện'**
  String get flowPhotoPermission;

  /// No description provided for @flowUploadPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để tải ảnh lên'**
  String get flowUploadPhoto;

  /// No description provided for @flowFinish.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành! 🎉'**
  String get flowFinish;

  /// No description provided for @flowNextLevel.
  ///
  /// In vi, this message translates to:
  /// **'Mức tiếp theo'**
  String get flowNextLevel;

  /// No description provided for @flowLevel.
  ///
  /// In vi, this message translates to:
  /// **'Mức {level}'**
  String flowLevel(int level);

  /// No description provided for @flowReturnHome.
  ///
  /// In vi, this message translates to:
  /// **'Về Trang Chủ'**
  String get flowReturnHome;

  /// No description provided for @matcherStageTalking.
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện'**
  String get matcherStageTalking;

  /// No description provided for @matcherStage1to3.
  ///
  /// In vi, this message translates to:
  /// **'1–3 tháng'**
  String get matcherStage1to3;

  /// No description provided for @matcherStage3to6.
  ///
  /// In vi, this message translates to:
  /// **'3–6 tháng'**
  String get matcherStage3to6;

  /// No description provided for @matcherStageOver6.
  ///
  /// In vi, this message translates to:
  /// **'Trên 6 tháng'**
  String get matcherStageOver6;

  /// No description provided for @matcherHeaderTag.
  ///
  /// In vi, this message translates to:
  /// **'GỢI Ý HẸN HÒ'**
  String get matcherHeaderTag;

  /// No description provided for @matcherHeaderBody.
  ///
  /// In vi, this message translates to:
  /// **'Hãy cho tụi mình biết vibe của hai bạn — tụi mình sẽ tìm ý tưởng hẹn hò phù hợp nhất.'**
  String get matcherHeaderBody;

  /// No description provided for @matcherHowItWorksTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách hoạt động'**
  String get matcherHowItWorksTitle;

  /// No description provided for @matcherHowItWorksBody.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh sở thích của hai bạn qua 5 khía cạnh. Thuật toán sẽ tìm ý tưởng phù hợp nhất cho cả hai.'**
  String get matcherHowItWorksBody;

  /// No description provided for @matcherAlgorithmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thuật toán'**
  String get matcherAlgorithmTitle;

  /// No description provided for @matcherAlgorithmBody.
  ///
  /// In vi, this message translates to:
  /// **'Phương pháp bình phương tối thiểu giúp tìm điểm khớp nhất trong không gian ý tưởng.'**
  String get matcherAlgorithmBody;

  /// No description provided for @matcherResultsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả của bạn'**
  String get matcherResultsTitle;

  /// No description provided for @matcherResultsBody.
  ///
  /// In vi, this message translates to:
  /// **'Nhận danh sách ý tưởng được xếp hạng, phân tích khía cạnh và điểm số tương thích.'**
  String get matcherResultsBody;

  /// No description provided for @matcherAdjustYours.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh sở thích của bạn'**
  String get matcherAdjustYours;

  /// No description provided for @dimensionRomance.
  ///
  /// In vi, this message translates to:
  /// **'Lãng mạn'**
  String get dimensionRomance;

  /// No description provided for @dimensionAdventure.
  ///
  /// In vi, this message translates to:
  /// **'Phiêu lưu'**
  String get dimensionAdventure;

  /// No description provided for @dimensionCreative.
  ///
  /// In vi, this message translates to:
  /// **'Sáng tạo'**
  String get dimensionCreative;

  /// No description provided for @dimensionIndoor.
  ///
  /// In vi, this message translates to:
  /// **'Trong nhà'**
  String get dimensionIndoor;

  /// No description provided for @dimensionEnergy.
  ///
  /// In vi, this message translates to:
  /// **'Năng lượng'**
  String get dimensionEnergy;

  /// No description provided for @matcherAddPartner.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sở thích của Người ấy'**
  String get matcherAddPartner;

  /// No description provided for @matcherBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'💸 Khoảng ngân sách'**
  String get matcherBudgetTitle;

  /// No description provided for @matcherBudgetMin.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu (VND)'**
  String get matcherBudgetMin;

  /// No description provided for @matcherBudgetMax.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa (VND)'**
  String get matcherBudgetMax;

  /// No description provided for @matcherStageTitle.
  ///
  /// In vi, this message translates to:
  /// **'💑 Giai đoạn mối quan hệ'**
  String get matcherStageTitle;

  /// No description provided for @matcherCoupleModeNote.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ đôi: Tụi mình sẽ tìm ý tưởng hẹn hò phù hợp nhất với sở thích của cả hai bằng phương pháp tối thiểu hoá bình phương.'**
  String get matcherCoupleModeNote;

  /// No description provided for @matcherCta.
  ///
  /// In vi, this message translates to:
  /// **'✨ Tìm ý tưởng hẹn hò hoàn hảo'**
  String get matcherCta;

  /// No description provided for @spiderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phân Tích Độ Tương Hợp Ý Tưởng'**
  String get spiderTitle;

  /// No description provided for @spiderSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Ý Tưởng vs Sở Thích Của Bạn'**
  String get spiderSubtitle;

  /// No description provided for @spiderLegendIdea.
  ///
  /// In vi, this message translates to:
  /// **'Độ khớp của ý tưởng'**
  String get spiderLegendIdea;

  /// No description provided for @spiderLegendIdeaDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ ý tưởng'**
  String get spiderLegendIdeaDesc;

  /// No description provided for @spiderLegendYou.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích của bạn'**
  String get spiderLegendYou;

  /// No description provided for @spiderLegendYouDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ mong muốn'**
  String get spiderLegendYouDesc;

  /// No description provided for @spiderLegendIdeal.
  ///
  /// In vi, this message translates to:
  /// **'Tương thích lý tưởng'**
  String get spiderLegendIdeal;

  /// No description provided for @spiderLegendIdealDesc.
  ///
  /// In vi, this message translates to:
  /// **'Điểm 10 hoàn hảo'**
  String get spiderLegendIdealDesc;

  /// No description provided for @spiderTapHint.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào các biểu tượng để xem phần trăm tương thích'**
  String get spiderTapHint;

  /// No description provided for @spiderMetricIdea.
  ///
  /// In vi, this message translates to:
  /// **'Ý tưởng'**
  String get spiderMetricIdea;

  /// No description provided for @spiderMetricPreference.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích'**
  String get spiderMetricPreference;

  /// No description provided for @spiderMetricMatch.
  ///
  /// In vi, this message translates to:
  /// **'Độ khớp'**
  String get spiderMetricMatch;

  /// No description provided for @dashboardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả tương thích'**
  String get dashboardTitle;

  /// No description provided for @dashboardCompatibility.
  ///
  /// In vi, this message translates to:
  /// **'Độ tương hợp'**
  String get dashboardCompatibility;

  /// No description provided for @dashboardBudget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách'**
  String get dashboardBudget;

  /// No description provided for @dashboardLevels.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ'**
  String get dashboardLevels;

  /// No description provided for @dashboardActivityCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} hoạt động'**
  String dashboardActivityCount(int count);

  /// No description provided for @dashboardStartNow.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ngay! '**
  String get dashboardStartNow;

  /// No description provided for @dashboardYourPreferences.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích của hai bạn'**
  String get dashboardYourPreferences;

  /// No description provided for @dashboardAllIdeas.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả ý tưởng ({count} tổng số)'**
  String dashboardAllIdeas(int count);

  /// No description provided for @challengeNoMatchResult.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy kết quả phù hợp.'**
  String get challengeNoMatchResult;

  /// No description provided for @challengeNoActivitySelected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn hoạt động nào.'**
  String get challengeNoActivitySelected;

  /// No description provided for @challengeActivityNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy hoạt động đã chọn.'**
  String get challengeActivityNotFound;

  /// No description provided for @errorAuthFailed.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực thất bại'**
  String get errorAuthFailed;

  /// No description provided for @errorAuthInvalidResponse.
  ///
  /// In vi, this message translates to:
  /// **'Phản hồi từ máy chủ xác thực không hợp lệ'**
  String get errorAuthInvalidResponse;

  /// No description provided for @errorAuthConnection.
  ///
  /// In vi, this message translates to:
  /// **'Không thể kết nối tới máy chủ. Vui lòng thử lại sau!'**
  String get errorAuthConnection;

  /// No description provided for @errorGoogleTokens.
  ///
  /// In vi, this message translates to:
  /// **'Không lấy được thông tin xác thực Google.'**
  String get errorGoogleTokens;

  /// No description provided for @errorGoogleSignIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Google thất bại: {error}'**
  String errorGoogleSignIn(String error);

  /// No description provided for @errorAddressNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy địa chỉ này. Hãy thử nhập chi tiết hơn nhé!'**
  String get errorAddressNotFound;

  /// No description provided for @errorLocationUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không thể truy cập vị trí. Hãy nhập địa chỉ của bạn nhé!'**
  String get errorLocationUnavailable;

  /// No description provided for @errorPlannerConnection.
  ///
  /// In vi, this message translates to:
  /// **'Không thể kết nối tới máy chủ EverUs. Vui lòng thử lại!'**
  String get errorPlannerConnection;

  /// No description provided for @errorPlanFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tạo kế hoạch (lỗi {status}). Vui lòng thử lại!'**
  String errorPlanFailed(int status);

  /// No description provided for @plannerDefaultDateType.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch Hẹn hò'**
  String get plannerDefaultDateType;

  /// No description provided for @inviteCreateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Thư Mời Hẹn Hò'**
  String get inviteCreateTitle;

  /// No description provided for @inviteReadyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lời Mời Đã Sẵn Sàng! 🎉'**
  String get inviteReadyTitle;

  /// No description provided for @inviteSenderLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xưng hô của bạn (Sender)'**
  String get inviteSenderLabel;

  /// No description provided for @inviteReceiverLabel.
  ///
  /// In vi, this message translates to:
  /// **'Gọi đối phương (Receiver)'**
  String get inviteReceiverLabel;

  /// No description provided for @inviteDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày hẹn'**
  String get inviteDateLabel;

  /// No description provided for @inviteTimeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giờ hẹn gặp'**
  String get inviteTimeLabel;

  /// No description provided for @inviteLocationLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm hẹn gặp / Khu vực'**
  String get inviteLocationLabel;

  /// No description provided for @invitePickupLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ai sẽ đón ai? 🚗'**
  String get invitePickupLabel;

  /// No description provided for @inviteBodyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung thư mời (Tự do điều chỉnh theo ý muốn):'**
  String get inviteBodyLabel;

  /// No description provided for @inviteCreating.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý lời mời...'**
  String get inviteCreating;

  /// No description provided for @inviteSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Xác Nhận & Tạo Lời Mời 💖'**
  String get inviteSubmit;

  /// No description provided for @inviteLinkReady.
  ///
  /// In vi, this message translates to:
  /// **'Đường Dẫn Lời Mời Đã Sẵn Sàng!'**
  String get inviteLinkReady;

  /// No description provided for @inviteLinkInstructions.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép liên kết bên dưới và gửi cho đối phương. Lời mời sẽ mở ra trang web lãng mạn chứa nhạc nền riêng biệt:'**
  String get inviteLinkInstructions;

  /// No description provided for @inviteCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã chép!'**
  String get inviteCopied;

  /// No description provided for @inviteBackToItinerary.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại Lộ Trình Hẹn Hò'**
  String get inviteBackToItinerary;

  /// No description provided for @inviteCreateFailed.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lời mời không thành công.'**
  String get inviteCreateFailed;

  /// No description provided for @commonError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String commonError(String error);

  /// No description provided for @mascotGreeting.
  ///
  /// In vi, this message translates to:
  /// **'Chào cậu nhé! Chạm vào tớ đi! 💖'**
  String get mascotGreeting;

  /// No description provided for @mascotComment1.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay tụi mình đi đâu chơi nhỉ? 🤔'**
  String get mascotComment1;

  /// No description provided for @mascotComment2.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cậu nhiều lắm á! ♥'**
  String get mascotComment2;

  /// No description provided for @mascotComment3.
  ///
  /// In vi, this message translates to:
  /// **'Lên lịch hẹn hò thôi! Tớ đã sẵn sàng! 🚀'**
  String get mascotComment3;

  /// No description provided for @mascotComment4.
  ///
  /// In vi, this message translates to:
  /// **'Cùng tạo nên thật nhiều kỉ niệm nhé! 🥳'**
  String get mascotComment4;

  /// No description provided for @mascotComment5.
  ///
  /// In vi, this message translates to:
  /// **'Hai cậu trông thật là đẹp đôi luôn á! 💑'**
  String get mascotComment5;

  /// No description provided for @mascotComment6.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào tớ tiếp đi, tớ thích lắm! 🥰'**
  String get mascotComment6;

  /// No description provided for @miniLoveCounterHeading.
  ///
  /// In vi, this message translates to:
  /// **'CHÚNG MÌNH ĐÃ BÊN NHAU'**
  String get miniLoveCounterHeading;

  /// No description provided for @miniLoveCounterDays.
  ///
  /// In vi, this message translates to:
  /// **'ngày'**
  String get miniLoveCounterDays;

  /// No description provided for @featurePlanDate.
  ///
  /// In vi, this message translates to:
  /// **'Lên Lịch Hẹn Hò'**
  String get featurePlanDate;

  /// No description provided for @featureReflection.
  ///
  /// In vi, this message translates to:
  /// **'Nhìn Lại\nMối Quan Hệ'**
  String get featureReflection;

  /// No description provided for @optionsDialogSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn trải nghiệm bạn muốn cùng thực hiện'**
  String get optionsDialogSubtitle;

  /// No description provided for @optionsPlanTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lên kế hoạch hẹn hò'**
  String get optionsPlanTitle;

  /// No description provided for @optionsPlanSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tự tạo lộ trình chi tiết cho buổi hẹn'**
  String get optionsPlanSubtitle;

  /// No description provided for @optionsChallengeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thử thách hẹn hò'**
  String get optionsChallengeTitle;

  /// No description provided for @optionsChallengeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá ý tưởng & thử thách thú vị'**
  String get optionsChallengeSubtitle;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @loginSignUpSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký tài khoản thành công! Chào mừng bạn đến với EverUs!'**
  String get loginSignUpSuccess;

  /// No description provided for @loginSignOutFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất thất bại: {error}'**
  String loginSignOutFailed(String error);

  /// No description provided for @loginAnswersSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu câu trả lời của bạn!'**
  String get loginAnswersSaved;

  /// No description provided for @loginTagline.
  ///
  /// In vi, this message translates to:
  /// **'kết nối với nửa kia của bạn'**
  String get loginTagline;

  /// No description provided for @loginProfileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của bạn'**
  String get loginProfileTitle;

  /// No description provided for @loginDefaultName.
  ///
  /// In vi, this message translates to:
  /// **'Người ấy'**
  String get loginDefaultName;

  /// No description provided for @loginSignUpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get loginSignUpTitle;

  /// No description provided for @loginSignInTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginSignInTitle;

  /// No description provided for @loginNameHint.
  ///
  /// In vi, this message translates to:
  /// **'tên của bạn'**
  String get loginNameHint;

  /// No description provided for @loginNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên của bạn'**
  String get loginNameRequired;

  /// No description provided for @loginEmailHint.
  ///
  /// In vi, this message translates to:
  /// **'địa chỉ email'**
  String get loginEmailHint;

  /// No description provided for @loginEmailRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email của bạn'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email hợp lệ'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'mật khẩu'**
  String get loginPasswordHint;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải dài ít nhất 6 ký tự'**
  String get loginPasswordTooShort;

  /// No description provided for @loginSignUpButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng Ký'**
  String get loginSignUpButton;

  /// No description provided for @loginSignInButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng Nhập'**
  String get loginSignInButton;

  /// No description provided for @loginOr.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get loginOr;

  /// No description provided for @loginHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? '**
  String get loginHaveAccount;

  /// No description provided for @loginNoAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? '**
  String get loginNoAccount;

  /// No description provided for @loginSkipAsGuest.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua & Tiếp tục thiết lập ➔'**
  String get loginSkipAsGuest;

  /// No description provided for @profileEditAnswers.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa câu trả lời'**
  String get profileEditAnswers;

  /// No description provided for @profileSignOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get profileSignOut;

  /// No description provided for @googleContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với Google'**
  String get googleContinue;

  /// No description provided for @gentleLoginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu đăng nhập 💖'**
  String get gentleLoginTitle;

  /// No description provided for @gentleLoginBody.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng này cần đăng nhập để đồng bộ thông tin giữa hai bạn. Bạn có muốn đăng nhập ngay không?'**
  String get gentleLoginBody;

  /// No description provided for @commonLater.
  ///
  /// In vi, this message translates to:
  /// **'Để sau'**
  String get commonLater;

  /// No description provided for @loveUploadPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh lên'**
  String get loveUploadPhoto;

  /// No description provided for @loveGallery.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện'**
  String get loveGallery;

  /// No description provided for @loveCamera.
  ///
  /// In vi, this message translates to:
  /// **'Máy ảnh'**
  String get loveCamera;

  /// No description provided for @loveAnniversaryRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ngày kỷ niệm của hai bạn.'**
  String get loveAnniversaryRequired;

  /// No description provided for @loveSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thông tin kỷ niệm thành công! 💖'**
  String get loveSaved;

  /// No description provided for @loveFinishSetup.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng hoàn thành thiết lập để tiếp tục! 💖'**
  String get loveFinishSetup;

  /// No description provided for @loveTogetherHeading.
  ///
  /// In vi, this message translates to:
  /// **'CHÚNG TA ĐÃ BÊN NHAU ĐƯỢC'**
  String get loveTogetherHeading;

  /// No description provided for @loveDaysUpper.
  ///
  /// In vi, this message translates to:
  /// **'NGÀY'**
  String get loveDaysUpper;

  /// No description provided for @loveHideDetails.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn chi tiết'**
  String get loveHideDetails;

  /// No description provided for @loveShowDetails.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết (Giờ/Phút/Giây)'**
  String get loveShowDetails;

  /// No description provided for @loveUnitDays.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get loveUnitDays;

  /// No description provided for @loveUnitHours.
  ///
  /// In vi, this message translates to:
  /// **'Giờ'**
  String get loveUnitHours;

  /// No description provided for @loveUnitMinutes.
  ///
  /// In vi, this message translates to:
  /// **'Phút'**
  String get loveUnitMinutes;

  /// No description provided for @loveUnitSeconds.
  ///
  /// In vi, this message translates to:
  /// **'Giây'**
  String get loveUnitSeconds;

  /// No description provided for @lovePickDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get lovePickDate;

  /// No description provided for @loveSetupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Bộ Đếm Ngày Yêu'**
  String get loveSetupTitle;

  /// No description provided for @loveSetupSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại cột mốc của bạn. Tất cả dữ liệu được bảo mật 100% trên điện thoại.'**
  String get loveSetupSubtitle;

  /// No description provided for @loveYou.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get loveYou;

  /// No description provided for @loveAnniversaryLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kỷ niệm'**
  String get loveAnniversaryLabel;

  /// No description provided for @loveYourName.
  ///
  /// In vi, this message translates to:
  /// **'Tên của bạn'**
  String get loveYourName;

  /// No description provided for @lovePartnerNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên người ấy'**
  String get lovePartnerNameRequired;

  /// No description provided for @lovePartnerName.
  ///
  /// In vi, this message translates to:
  /// **'Tên người ấy'**
  String get lovePartnerName;

  /// No description provided for @loveSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu & Đếm Ngày Yêu'**
  String get loveSave;

  /// No description provided for @loveAddPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get loveAddPhoto;

  /// No description provided for @notificationsLoginRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem thông báo.'**
  String get notificationsLoginRequired;

  /// No description provided for @notificationsLoadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách thông báo ({status}).'**
  String notificationsLoadFailed(int status);

  /// No description provided for @notificationsPlanLoadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải kế hoạch hẹn hò này.'**
  String get notificationsPlanLoadFailed;

  /// No description provided for @notificationsPlanLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải kế hoạch: {error}'**
  String notificationsPlanLoadError(String error);

  /// No description provided for @notificationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông Báo Hẹn Hò'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có thông báo nào.'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Các hoạt động tương tác từ đối phương sẽ hiển thị tại đây.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsDefaultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notificationsDefaultTitle;

  /// No description provided for @notificationsAcceptedAt.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian chấp nhận: {time}'**
  String notificationsAcceptedAt(String time);

  /// No description provided for @notificationsViewItinerary.
  ///
  /// In vi, this message translates to:
  /// **'Xem lộ trình'**
  String get notificationsViewItinerary;

  /// No description provided for @notificationsMarkRead.
  ///
  /// In vi, this message translates to:
  /// **'Đã đọc'**
  String get notificationsMarkRead;

  /// No description provided for @pushInviteAcceptedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lời mời được chấp nhận! 🎉'**
  String get pushInviteAcceptedTitle;

  /// No description provided for @pushInviteAcceptedBody.
  ///
  /// In vi, this message translates to:
  /// **'{name} đã chấp nhận lời mời hẹn hò của bạn.'**
  String pushInviteAcceptedBody(String name);

  /// No description provided for @pushChannelName.
  ///
  /// In vi, this message translates to:
  /// **'Lời mời EverUs'**
  String get pushChannelName;

  /// No description provided for @pushChannelDescription.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo khi đối phương chấp nhận lời mời'**
  String get pushChannelDescription;

  /// No description provided for @inviteModalDefaultPartner.
  ///
  /// In vi, this message translates to:
  /// **'Đối phương'**
  String get inviteModalDefaultPartner;

  /// No description provided for @inviteModalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lời Mời Đã Được Đồng Ý! 🎉'**
  String get inviteModalTitle;

  /// No description provided for @inviteModalMessage.
  ///
  /// In vi, this message translates to:
  /// **' đã chấp nhận lời mời hẹn hò lãng mạn của bạn. Hãy chuẩn bị tinh thần hẹn hò nhé! 💕'**
  String get inviteModalMessage;

  /// No description provided for @inviteModalDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get inviteModalDate;

  /// No description provided for @inviteModalTime.
  ///
  /// In vi, this message translates to:
  /// **'Giờ'**
  String get inviteModalTime;

  /// No description provided for @inviteModalLocation.
  ///
  /// In vi, this message translates to:
  /// **'Nơi hẹn'**
  String get inviteModalLocation;

  /// No description provided for @inviteModalPickup.
  ///
  /// In vi, this message translates to:
  /// **'Đón đưa'**
  String get inviteModalPickup;

  /// No description provided for @inviteModalViewItinerary.
  ///
  /// In vi, this message translates to:
  /// **'Xem Lộ Trình ➔'**
  String get inviteModalViewItinerary;

  /// No description provided for @notificationViewPlan.
  ///
  /// In vi, this message translates to:
  /// **'Xem kế hoạch ➔'**
  String get notificationViewPlan;

  /// No description provided for @distanceNear.
  ///
  /// In vi, this message translates to:
  /// **'Gần'**
  String get distanceNear;

  /// No description provided for @distanceNearHint.
  ///
  /// In vi, this message translates to:
  /// **'dưới 5km'**
  String get distanceNearHint;

  /// No description provided for @distanceFar.
  ///
  /// In vi, this message translates to:
  /// **'Xa'**
  String get distanceFar;

  /// No description provided for @distanceFarHint.
  ///
  /// In vi, this message translates to:
  /// **'5 - 15 km'**
  String get distanceFarHint;

  /// No description provided for @distanceRandom.
  ///
  /// In vi, this message translates to:
  /// **'Tuỳ hứng'**
  String get distanceRandom;

  /// No description provided for @distanceRandomHint.
  ///
  /// In vi, this message translates to:
  /// **'Để EverUs chọn'**
  String get distanceRandomHint;

  /// No description provided for @plannerNoPlacesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không Tìm Thấy Địa Điểm'**
  String get plannerNoPlacesTitle;

  /// No description provided for @plannerItineraryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lộ Trình Hẹn Hò'**
  String get plannerItineraryTitle;

  /// No description provided for @plannerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết Kế Hẹn Hò'**
  String get plannerTitle;

  /// No description provided for @plannerAddressRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập địa chỉ của bạn!'**
  String get plannerAddressRequired;

  /// No description provided for @plannerLocationRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng cho phép truy cập vị trí hoặc nhập địa chỉ của bạn!'**
  String get plannerLocationRequired;

  /// No description provided for @plannerMinBudget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách tối thiểu là {amount} VND / người.'**
  String plannerMinBudget(String amount);

  /// No description provided for @plannerLoadingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải kế hoạch...'**
  String get plannerLoadingTitle;

  /// No description provided for @plannerLoadingBody.
  ///
  /// In vi, this message translates to:
  /// **'Đang lấy thông tin mới nhất cho buổi hẹn hò của bạn... 💕'**
  String get plannerLoadingBody;

  /// No description provided for @plannerErrorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tạo kế hoạch'**
  String get plannerErrorTitle;

  /// No description provided for @plannerRetry.
  ///
  /// In vi, this message translates to:
  /// **'THỬ LẠI'**
  String get plannerRetry;

  /// No description provided for @plannerBackToEdit.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại chỉnh sửa'**
  String get plannerBackToEdit;

  /// No description provided for @plannerGenerating.
  ///
  /// In vi, this message translates to:
  /// **'EverUs đang lên lộ trình...'**
  String get plannerGenerating;

  /// No description provided for @vibeCasual.
  ///
  /// In vi, this message translates to:
  /// **'Đời\nthường'**
  String get vibeCasual;

  /// No description provided for @vibeCasualDescription.
  ///
  /// In vi, this message translates to:
  /// **'trà chiều, đi dạo\n& những điều bình dị'**
  String get vibeCasualDescription;

  /// No description provided for @vibeRomantic.
  ///
  /// In vi, this message translates to:
  /// **'Lãng\nmạn'**
  String get vibeRomantic;

  /// No description provided for @vibeRomanticDescription.
  ///
  /// In vi, this message translates to:
  /// **'ánh nến, hoàng hôn\n& kết nối ngọt ngào'**
  String get vibeRomanticDescription;

  /// No description provided for @vibeAdventure.
  ///
  /// In vi, this message translates to:
  /// **'Trải\nnghiệm'**
  String get vibeAdventure;

  /// No description provided for @vibeAdventureDescription.
  ///
  /// In vi, this message translates to:
  /// **'trò chơi, khám phá\n& phiêu lưu cùng nhau'**
  String get vibeAdventureDescription;

  /// No description provided for @plannerVibeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vibe buổi hẹn hò'**
  String get plannerVibeTitle;

  /// No description provided for @plannerDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày hẹn hò'**
  String get plannerDateLabel;

  /// No description provided for @plannerTimeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get plannerTimeLabel;

  /// No description provided for @plannerTimeTo.
  ///
  /// In vi, this message translates to:
  /// **'đến'**
  String get plannerTimeTo;

  /// No description provided for @plannerNextDay.
  ///
  /// In vi, this message translates to:
  /// **'(hôm sau)'**
  String get plannerNextDay;

  /// No description provided for @plannerMinDuration.
  ///
  /// In vi, this message translates to:
  /// **'Buổi hẹn cần dài ít nhất 1 tiếng nhé!'**
  String get plannerMinDuration;

  /// No description provided for @plannerLocating.
  ///
  /// In vi, this message translates to:
  /// **'Đang xác định vị trí...'**
  String get plannerLocating;

  /// No description provided for @plannerAddressHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ xuất phát, VD: 45 Lê Lợi, Q1'**
  String get plannerAddressHint;

  /// No description provided for @plannerAddressSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm'**
  String get plannerAddressSearch;

  /// No description provided for @plannerNoLocation.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có vị trí của bạn'**
  String get plannerNoLocation;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @plannerDistanceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng cách'**
  String get plannerDistanceTitle;

  /// No description provided for @plannerTransportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phương tiện di chuyển'**
  String get plannerTransportTitle;

  /// No description provided for @plannerBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách tối đa cho 1 người'**
  String get plannerBudgetTitle;

  /// No description provided for @plannerBudgetHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền'**
  String get plannerBudgetHint;

  /// No description provided for @plannerHistoryLink.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại lịch sử ý tưởng'**
  String get plannerHistoryLink;

  /// No description provided for @plannerSubmit.
  ///
  /// In vi, this message translates to:
  /// **'BẮT ĐẦU LÊN Ý TƯỞNG'**
  String get plannerSubmit;

  /// No description provided for @transportWalking.
  ///
  /// In vi, this message translates to:
  /// **'Đi bộ'**
  String get transportWalking;

  /// No description provided for @transportMotorbike.
  ///
  /// In vi, this message translates to:
  /// **'Xe máy'**
  String get transportMotorbike;

  /// No description provided for @transportTaxi.
  ///
  /// In vi, this message translates to:
  /// **'Taxi'**
  String get transportTaxi;

  /// No description provided for @calendarMonthWithYear.
  ///
  /// In vi, this message translates to:
  /// **'{month}/{year}'**
  String calendarMonthWithYear(String month, String year);

  /// No description provided for @calendarWeekdays.
  ///
  /// In vi, this message translates to:
  /// **'CN,T2,T3,T4,T5,T6,T7'**
  String get calendarWeekdays;

  /// No description provided for @questionnaireSaveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được câu trả lời. Vui lòng thử lại!'**
  String get questionnaireSaveFailed;

  /// No description provided for @questionnairePrevious.
  ///
  /// In vi, this message translates to:
  /// **'Câu trước'**
  String get questionnairePrevious;

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get commonCancel;

  /// No description provided for @questionnaireSkip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get questionnaireSkip;

  /// No description provided for @questionnaireSaveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get questionnaireSaveChanges;

  /// No description provided for @questionnaireFinish.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành & Bắt đầu'**
  String get questionnaireFinish;

  /// No description provided for @commonContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get commonContinue;

  /// No description provided for @questionnaireSkipAll.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua tất cả & Bắt đầu trải nghiệm ➔'**
  String get questionnaireSkipAll;

  /// No description provided for @questionnaireMultiSelect.
  ///
  /// In vi, this message translates to:
  /// **'Có thể chọn nhiều đáp án'**
  String get questionnaireMultiSelect;

  /// No description provided for @resultsNearYou.
  ///
  /// In vi, this message translates to:
  /// **'Gần bạn'**
  String get resultsNearYou;

  /// No description provided for @shareHeader.
  ///
  /// In vi, this message translates to:
  /// **'✨ KẾ HOẠCH HẸN HÒ: {dateType} {emoji} ✨'**
  String shareHeader(String dateType, String emoji);

  /// No description provided for @shareDate.
  ///
  /// In vi, this message translates to:
  /// **'📅 Ngày hẹn: {date}'**
  String shareDate(String date);

  /// No description provided for @shareTotalDuration.
  ///
  /// In vi, this message translates to:
  /// **'⏱️ Tổng thời lượng: {minutes} phút (~{hours} tiếng)'**
  String shareTotalDuration(int minutes, String hours);

  /// No description provided for @shareBudget.
  ///
  /// In vi, this message translates to:
  /// **'💰 Ngân sách: {budget} / người'**
  String shareBudget(String budget);

  /// No description provided for @shareArea.
  ///
  /// In vi, this message translates to:
  /// **'📍 Khu vực: {area}'**
  String shareArea(String area);

  /// No description provided for @shareTransport.
  ///
  /// In vi, this message translates to:
  /// **'🏍️ Phương tiện: {transport}'**
  String shareTransport(String transport);

  /// No description provided for @sharePurpose.
  ///
  /// In vi, this message translates to:
  /// **'🎯 Mục tiêu buổi hẹn: {purpose}'**
  String sharePurpose(String purpose);

  /// No description provided for @shareStage.
  ///
  /// In vi, this message translates to:
  /// **'📍 Chặng {num}: {title}'**
  String shareStage(int num, String title);

  /// No description provided for @shareStageTime.
  ///
  /// In vi, this message translates to:
  /// **'⏰ Thời gian: {start} - {end} ({minutes} phút)'**
  String shareStageTime(String start, String end, int minutes);

  /// No description provided for @shareStagePurpose.
  ///
  /// In vi, this message translates to:
  /// **'🎯 Mục tiêu: {purpose}'**
  String shareStagePurpose(String purpose);

  /// No description provided for @shareStageCategory.
  ///
  /// In vi, this message translates to:
  /// **'🍴 Thể loại: {category}'**
  String shareStageCategory(String category);

  /// No description provided for @sharePlace.
  ///
  /// In vi, this message translates to:
  /// **'📍 Địa điểm: {place}'**
  String sharePlace(String place);

  /// No description provided for @shareAddress.
  ///
  /// In vi, this message translates to:
  /// **'   Địa chỉ: {address}'**
  String shareAddress(String address);

  /// No description provided for @shareTasks.
  ///
  /// In vi, this message translates to:
  /// **'✨ Hoạt động gợi ý:'**
  String get shareTasks;

  /// No description provided for @shareTips.
  ///
  /// In vi, this message translates to:
  /// **'💡 Mách nhỏ:'**
  String get shareTips;

  /// No description provided for @shareFooter.
  ///
  /// In vi, this message translates to:
  /// **'👉 Tạo kế hoạch hẹn hò của riêng bạn trên app EverUs!'**
  String get shareFooter;

  /// No description provided for @shareCopied.
  ///
  /// In vi, this message translates to:
  /// **'📋 Đã sao chép lộ trình vào bộ nhớ tạm!'**
  String get shareCopied;

  /// No description provided for @resultsDurationBadge.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút (~{hours}h)'**
  String resultsDurationBadge(int minutes, String hours);

  /// No description provided for @resultsStagesTitle.
  ///
  /// In vi, this message translates to:
  /// **'LỘ TRÌNH CHI TIẾT'**
  String get resultsStagesTitle;

  /// No description provided for @resultsOpenFullMap.
  ///
  /// In vi, this message translates to:
  /// **'MỞ BẢN ĐỒ TOÀN LỘ TRÌNH'**
  String get resultsOpenFullMap;

  /// No description provided for @resultsRegenerate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lại'**
  String get resultsRegenerate;

  /// No description provided for @resultsRegenerateFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tạo lại kế hoạch: {error}'**
  String resultsRegenerateFailed(String error);

  /// No description provided for @resultsCopy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get resultsCopy;

  /// No description provided for @resultsHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get resultsHistory;

  /// No description provided for @resultsCentralArea.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực trung tâm'**
  String get resultsCentralArea;

  /// No description provided for @resultsHours.
  ///
  /// In vi, this message translates to:
  /// **'{hours} tiếng'**
  String resultsHours(String hours);

  /// No description provided for @resultsInviteAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Lời mời đã được chấp nhận!'**
  String get resultsInviteAccepted;

  /// No description provided for @resultsInviteAcceptedBody.
  ///
  /// In vi, this message translates to:
  /// **'Đối phương đã đồng ý tham gia buổi hẹn hò này.'**
  String get resultsInviteAcceptedBody;

  /// No description provided for @resultsResendInvite.
  ///
  /// In vi, this message translates to:
  /// **'XEM / GỬI LẠI LỜI MỜI HẸN HÒ'**
  String get resultsResendInvite;

  /// No description provided for @resultsSendInvite.
  ///
  /// In vi, this message translates to:
  /// **'GỬI LỜI MỜI HẸN HÒ'**
  String get resultsSendInvite;

  /// No description provided for @resultsPurposeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mục Tiêu Buổi Hẹn'**
  String get resultsPurposeTitle;

  /// No description provided for @resultsStagePurpose.
  ///
  /// In vi, this message translates to:
  /// **'Mục đích'**
  String get resultsStagePurpose;

  /// No description provided for @resultsStageCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại'**
  String get resultsStageCategory;

  /// No description provided for @resultsStageDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng'**
  String get resultsStageDuration;

  /// No description provided for @resultsMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String resultsMinutes(int minutes);

  /// No description provided for @resultsSuggestedTasks.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động gợi ý'**
  String get resultsSuggestedTasks;

  /// No description provided for @resultsSuggestedPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm gợi ý'**
  String get resultsSuggestedPlaces;

  /// No description provided for @resultsHideBackups.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn lựa chọn dự phòng'**
  String get resultsHideBackups;

  /// No description provided for @resultsShowBackups.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm lựa chọn dự phòng ({count})'**
  String resultsShowBackups(int count);

  /// No description provided for @resultsTipsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mách Nhỏ Cho Hai Bạn'**
  String get resultsTipsTitle;

  /// No description provided for @resultsUnlike.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ thích'**
  String get resultsUnlike;

  /// No description provided for @resultsLike.
  ///
  /// In vi, this message translates to:
  /// **'Thích địa điểm này'**
  String get resultsLike;

  /// No description provided for @resultsUndislike.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ không thích'**
  String get resultsUndislike;

  /// No description provided for @resultsDislike.
  ///
  /// In vi, this message translates to:
  /// **'Không thích địa điểm này'**
  String get resultsDislike;

  /// No description provided for @resultsBackupBadge.
  ///
  /// In vi, this message translates to:
  /// **'LỰA CHỌN DỰ PHÒNG'**
  String get resultsBackupBadge;

  /// No description provided for @resultsDefaultAddress.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực trung tâm, Hồ Chí Minh'**
  String get resultsDefaultAddress;

  /// No description provided for @resultsPriceRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng giá: {range}'**
  String resultsPriceRange(String range);

  /// No description provided for @resultsRating.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá {rating}/5 ({count} lượt)'**
  String resultsRating(String rating, int count);

  /// No description provided for @resultsViewOnMap.
  ///
  /// In vi, this message translates to:
  /// **'Xem trên bản đồ'**
  String get resultsViewOnMap;

  /// No description provided for @resultsMakePrimary.
  ///
  /// In vi, this message translates to:
  /// **'Đặt làm chính'**
  String get resultsMakePrimary;

  /// No description provided for @resultsTransit.
  ///
  /// In vi, this message translates to:
  /// **'{transport}: ~ {km} km (~{minutes} phút)'**
  String resultsTransit(String transport, String km, int minutes);

  /// No description provided for @resultsDateTypeSuggestion.
  ///
  /// In vi, this message translates to:
  /// **'GỢI Ý KIỂU HẸN HÒ'**
  String get resultsDateTypeSuggestion;

  /// No description provided for @savedPlansLoginRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem các kế hoạch đã lưu.'**
  String get savedPlansLoginRequired;

  /// No description provided for @savedPlansLoadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách kế hoạch từ máy chủ ({status}).'**
  String savedPlansLoadFailed(int status);

  /// No description provided for @errorServerConnection.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra khi kết nối tới máy chủ.'**
  String get errorServerConnection;

  /// No description provided for @savedPlansDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xoá kế hoạch thành công 💖'**
  String get savedPlansDeleted;

  /// No description provided for @savedPlansDeleteFailed.
  ///
  /// In vi, this message translates to:
  /// **'Xoá thất bại: {status}'**
  String savedPlansDeleteFailed(int status);

  /// No description provided for @savedPlansDeleteConnectionError.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra khi kết nối để xoá kế hoạch.'**
  String get savedPlansDeleteConnectionError;

  /// No description provided for @savedPlansConfirmDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xoá'**
  String get savedPlansConfirmDeleteTitle;

  /// No description provided for @savedPlansConfirmDeleteBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xoá kế hoạch hẹn hò này không? Thao tác này không thể hoàn tác.'**
  String get savedPlansConfirmDeleteBody;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get commonDelete;

  /// No description provided for @vibeLabelRomantic.
  ///
  /// In vi, this message translates to:
  /// **'Lãng mạn'**
  String get vibeLabelRomantic;

  /// No description provided for @vibeLabelFun.
  ///
  /// In vi, this message translates to:
  /// **'Sôi nổi'**
  String get vibeLabelFun;

  /// No description provided for @vibeLabelAdventure.
  ///
  /// In vi, this message translates to:
  /// **'Trải nghiệm'**
  String get vibeLabelAdventure;

  /// No description provided for @vibeLabelCasual.
  ///
  /// In vi, this message translates to:
  /// **'Đời thường'**
  String get vibeLabelCasual;

  /// No description provided for @vibeLabelChill.
  ///
  /// In vi, this message translates to:
  /// **'Chill'**
  String get vibeLabelChill;

  /// No description provided for @savedPlansTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kế Hoạch Hẹn Hò Đã Lưu'**
  String get savedPlansTitle;

  /// No description provided for @savedPlansEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa lưu kế hoạch hẹn hò nào.'**
  String get savedPlansEmptyTitle;

  /// No description provided for @savedPlansEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Hãy lên lịch và tạo kế hoạch mới nhé, hệ thống sẽ tự động lưu lại ở đây!'**
  String get savedPlansEmptyBody;

  /// No description provided for @savedPlansDateLine.
  ///
  /// In vi, this message translates to:
  /// **'Ngày: {details}'**
  String savedPlansDateLine(String details);

  /// No description provided for @savedPlansAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã nhận lời'**
  String get savedPlansAccepted;

  /// No description provided for @savedPlansInviteSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lời mời'**
  String get savedPlansInviteSent;

  /// No description provided for @savedPlansStageCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} chặng'**
  String savedPlansStageCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
