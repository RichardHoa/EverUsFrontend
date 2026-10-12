// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get flowStartComment1 => 'Ready to go? 💪';

  @override
  String get flowStartComment2 => 'Let\'s make memories!';

  @override
  String get flowStartComment3 => 'Time to shine! ✨';

  @override
  String get flowStartComment4 => 'Adventure awaits! 🌟';

  @override
  String get flowCompleteComment1 => 'You two are amazing! 💕';

  @override
  String get flowCompleteComment2 => 'So much love! 🥰';

  @override
  String get flowCompleteComment3 => 'The most perfect couple on Earth! 👑';

  @override
  String get flowCompleteComment4 => 'What a beautiful moment! 🌸';

  @override
  String get flowPhotoUploadComingSoon =>
      'This photo upload feature is currently being developed!';

  @override
  String get flowNiceJob => 'Nice job! 🎯';

  @override
  String flowLevelComingUp(int level) {
    return 'Level $level coming up!';
  }

  @override
  String get flowKeepGoing => 'Keep going! 🚀';

  @override
  String get flowWeDidIt => 'We did it! 🎉';

  @override
  String get flowUnlockTitle => 'Unlock more levels! 💖';

  @override
  String get flowUnlockBody =>
      'To continue your date adventure and unlock the next levels, please log in or create an account.';

  @override
  String get flowLoginOrSignUp => 'Log in / Sign up';

  @override
  String get flowIntroTitle => 'Adventure Awaits';

  @override
  String get flowSecretLabel => 'Secret to keep in mind:';

  @override
  String get flowDuration => 'Duration';

  @override
  String get flowLevels => 'Levels';

  @override
  String get flowCheckIns => 'Check-ins';

  @override
  String get flowBegin => 'Begin Journey';

  @override
  String flowLevelProgress(int current, int total) {
    return 'Level $current/$total';
  }

  @override
  String flowLevelUpper(int level) {
    return 'LEVEL $level';
  }

  @override
  String get flowPhotoPermission => 'Camera / Gallery access';

  @override
  String get flowUploadPhoto => 'Tap to upload a photo';

  @override
  String get flowFinish => 'Finish! 🎉';

  @override
  String get flowNextLevel => 'Next level';

  @override
  String flowLevel(int level) {
    return 'Level $level';
  }

  @override
  String get flowReturnHome => 'Return Home';

  @override
  String get matcherStageTalking => 'Talking';

  @override
  String get matcherStage1to3 => '1–3 months';

  @override
  String get matcherStage3to6 => '3–6 months';

  @override
  String get matcherStageOver6 => 'Over 6 months';

  @override
  String get matcherHeaderTag => 'DATE IDEAS';

  @override
  String get matcherHeaderBody =>
      'Tell us your vibe as a couple — we\'ll find the date ideas that suit you best.';

  @override
  String get matcherHowItWorksTitle => 'How it works';

  @override
  String get matcherHowItWorksBody =>
      'Adjust your preferences across 5 dimensions. The algorithm finds the ideas that suit you both best.';

  @override
  String get matcherAlgorithmTitle => 'The algorithm';

  @override
  String get matcherAlgorithmBody =>
      'Least squares finds the closest match in the space of ideas.';

  @override
  String get matcherResultsTitle => 'Your results';

  @override
  String get matcherResultsBody =>
      'Get a ranked list of ideas, a breakdown by dimension and compatibility scores.';

  @override
  String get matcherAdjustYours => 'Adjust your preferences';

  @override
  String get dimensionRomance => 'Romance';

  @override
  String get dimensionAdventure => 'Adventure';

  @override
  String get dimensionCreative => 'Creativity';

  @override
  String get dimensionIndoor => 'Indoor';

  @override
  String get dimensionEnergy => 'Energy';

  @override
  String get matcherAddPartner => 'Add your partner\'s preferences';

  @override
  String get matcherBudgetTitle => '💸 Budget range';

  @override
  String get matcherBudgetMin => 'Minimum (VND)';

  @override
  String get matcherBudgetMax => 'Maximum (VND)';

  @override
  String get matcherStageTitle => '💑 Relationship stage';

  @override
  String get matcherCoupleModeNote =>
      'Couple mode: we\'ll find the date ideas that best fit both of your preferences using least squares.';

  @override
  String get matcherCta => '✨ Find the perfect date idea';

  @override
  String get spiderTitle => 'Idea Compatibility Analysis';

  @override
  String get spiderSubtitle => 'Idea vs Your Preferences';

  @override
  String get spiderLegendIdea => 'Idea profile';

  @override
  String get spiderLegendIdeaDesc => 'Idea level';

  @override
  String get spiderLegendYou => 'Your preferences';

  @override
  String get spiderLegendYouDesc => 'Desired level';

  @override
  String get spiderLegendIdeal => 'Ideal match';

  @override
  String get spiderLegendIdealDesc => 'A perfect 10';

  @override
  String get spiderTapHint =>
      'Tap the icons to see the compatibility percentage';

  @override
  String get spiderMetricIdea => 'Idea';

  @override
  String get spiderMetricPreference => 'Preference';

  @override
  String get spiderMetricMatch => 'Match';

  @override
  String get dashboardTitle => 'Compatibility results';

  @override
  String get dashboardCompatibility => 'Compatibility';

  @override
  String get dashboardBudget => 'Budget';

  @override
  String get dashboardLevels => 'Levels';

  @override
  String dashboardActivityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '1 activity',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStartNow => 'Start now! ';

  @override
  String get dashboardYourPreferences => 'Your preferences';

  @override
  String dashboardAllIdeas(int count) {
    return 'All ideas ($count total)';
  }

  @override
  String get challengeNoMatchResult => 'No match result found.';

  @override
  String get challengeNoActivitySelected => 'No activity selected.';

  @override
  String get challengeActivityNotFound => 'Selected activity not found.';

  @override
  String get errorAuthFailed => 'Authentication failed';

  @override
  String get errorAuthInvalidResponse =>
      'Invalid response format from authentication server';

  @override
  String get errorAuthConnection =>
      'Failed to connect to backend server. Please try again later!';

  @override
  String get errorGoogleTokens =>
      'Failed to retrieve Google authentication tokens.';

  @override
  String errorGoogleSignIn(String error) {
    return 'Google Sign-In failed: $error';
  }

  @override
  String get errorAddressNotFound =>
      'Couldn\'t find this address. Try entering more detail!';

  @override
  String get errorLocationUnavailable =>
      'Can\'t access your location. Please enter your address!';

  @override
  String get errorPlannerConnection =>
      'Can\'t reach the EverUs server. Please try again!';

  @override
  String errorPlanFailed(int status) {
    return 'Couldn\'t create the plan (error $status). Please try again!';
  }

  @override
  String get plannerDefaultDateType => 'Date Plan';

  @override
  String get inviteCreateTitle => 'Create a Date Invitation';

  @override
  String get inviteReadyTitle => 'Your Invitation Is Ready! 🎉';

  @override
  String get inviteSenderLabel => 'What you call yourself (Sender)';

  @override
  String get inviteReceiverLabel => 'What you call your partner (Receiver)';

  @override
  String get inviteDateLabel => 'Date';

  @override
  String get inviteTimeLabel => 'Meeting time';

  @override
  String get inviteLocationLabel => 'Meeting place / Area';

  @override
  String get invitePickupLabel => 'Who picks up whom? 🚗';

  @override
  String get inviteBodyLabel => 'Invitation text (feel free to edit):';

  @override
  String get inviteCreating => 'Creating invitation...';

  @override
  String get inviteSubmit => 'Confirm & Create Invitation 💖';

  @override
  String get inviteLinkReady => 'Your Invitation Link Is Ready!';

  @override
  String get inviteLinkInstructions =>
      'Copy the link below and send it to your partner. It opens a romantic web page with its own background music:';

  @override
  String get inviteCopied => 'Copied!';

  @override
  String get inviteBackToItinerary => 'Back to Date Itinerary';

  @override
  String get inviteCreateFailed => 'Couldn\'t create the invitation.';

  @override
  String commonError(String error) {
    return 'Error: $error';
  }

  @override
  String get mascotGreeting => 'Hi there! Tap me! 💖';

  @override
  String get mascotComment1 => 'Where should we go today? 🤔';

  @override
  String get mascotComment2 => 'Love you so much! ♥';

  @override
  String get mascotComment3 => 'Let\'s plan a date! I\'m ready! 🚀';

  @override
  String get mascotComment4 => 'Let\'s make lots of memories together! 🥳';

  @override
  String get mascotComment5 => 'You two look so good together! 💑';

  @override
  String get mascotComment6 => 'Keep tapping me, I love it! 🥰';

  @override
  String get miniLoveCounterHeading => 'WE\'VE BEEN TOGETHER';

  @override
  String get miniLoveCounterDays => 'days';

  @override
  String get featurePlanDate => 'Plan a Date';

  @override
  String get featureReflection => 'Reflect on\nOur Relationship';

  @override
  String get optionsDialogSubtitle => 'Choose what you\'d like to do together';

  @override
  String get optionsPlanTitle => 'Plan a date';

  @override
  String get optionsPlanSubtitle => 'Build a detailed itinerary for your date';

  @override
  String get optionsChallengeTitle => 'Date challenge';

  @override
  String get optionsChallengeSubtitle => 'Discover fun ideas & challenges';

  @override
  String get commonClose => 'Close';

  @override
  String get loginSignUpSuccess => 'Account created! Welcome to EverUs!';

  @override
  String loginSignOutFailed(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String get loginAnswersSaved => 'Your answers have been saved!';

  @override
  String get loginTagline => 'connect with your other half';

  @override
  String get loginProfileTitle => 'Your profile';

  @override
  String get loginDefaultName => 'Your love';

  @override
  String get loginSignUpTitle => 'Sign up';

  @override
  String get loginSignInTitle => 'Log in';

  @override
  String get loginNameHint => 'your name';

  @override
  String get loginNameRequired => 'Please enter your name';

  @override
  String get loginEmailHint => 'email address';

  @override
  String get loginEmailRequired => 'Please enter your email';

  @override
  String get loginEmailInvalid => 'Please enter a valid email';

  @override
  String get loginPasswordHint => 'password';

  @override
  String get loginPasswordRequired => 'Please enter your password';

  @override
  String get loginPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginSignUpButton => 'Sign Up';

  @override
  String get loginSignInButton => 'Log In';

  @override
  String get loginOr => 'or';

  @override
  String get loginHaveAccount => 'Already have an account? ';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSkipAsGuest => 'Skip & continue setup ➔';

  @override
  String get profileEditAnswers => 'Edit my answers';

  @override
  String get profileSignOut => 'Log out';

  @override
  String get googleContinue => 'Continue with Google';

  @override
  String get gentleLoginTitle => 'Login required 💖';

  @override
  String get gentleLoginBody =>
      'This feature needs you to log in so your info syncs between the two of you. Would you like to log in now?';

  @override
  String get commonLater => 'Later';

  @override
  String get loveUploadPhoto => 'Upload a photo';

  @override
  String get loveGallery => 'Gallery';

  @override
  String get loveCamera => 'Camera';

  @override
  String get loveAnniversaryRequired => 'Please pick your anniversary date.';

  @override
  String get loveSaved => 'Anniversary saved! 💖';

  @override
  String get loveFinishSetup => 'Please finish setting up to continue! 💖';

  @override
  String get loveTogetherHeading => 'WE\'VE BEEN TOGETHER FOR';

  @override
  String get loveDaysUpper => 'DAYS';

  @override
  String get loveHideDetails => 'Hide details';

  @override
  String get loveShowDetails => 'Show details (Hours/Minutes/Seconds)';

  @override
  String get loveUnitDays => 'Days';

  @override
  String get loveUnitHours => 'Hours';

  @override
  String get loveUnitMinutes => 'Minutes';

  @override
  String get loveUnitSeconds => 'Seconds';

  @override
  String get lovePickDate => 'Pick a date';

  @override
  String get loveSetupTitle => 'Create Your Love Counter';

  @override
  String get loveSetupSubtitle =>
      'Record your milestone. All data stays 100% private on your phone.';

  @override
  String get loveYou => 'You';

  @override
  String get loveAnniversaryLabel => 'Anniversary';

  @override
  String get loveYourName => 'Your name';

  @override
  String get lovePartnerNameRequired => 'Please enter your partner\'s name';

  @override
  String get lovePartnerName => 'Your partner\'s name';

  @override
  String get loveSave => 'Save & Start Counting';

  @override
  String get loveAddPhoto => 'Add photo';

  @override
  String get notificationsLoginRequired =>
      'Please log in to see notifications.';

  @override
  String notificationsLoadFailed(int status) {
    return 'Couldn\'t load notifications ($status).';
  }

  @override
  String get notificationsPlanLoadFailed => 'Couldn\'t load this date plan.';

  @override
  String notificationsPlanLoadError(String error) {
    return 'Error loading plan: $error';
  }

  @override
  String get notificationsTitle => 'Date Notifications';

  @override
  String get notificationsEmptyTitle =>
      'You don\'t have any notifications yet.';

  @override
  String get notificationsEmptyBody =>
      'Activity from your partner will show up here.';

  @override
  String get notificationsDefaultTitle => 'Notification';

  @override
  String notificationsAcceptedAt(String time) {
    return 'Accepted at: $time';
  }

  @override
  String get notificationsViewItinerary => 'View itinerary';

  @override
  String get notificationsMarkRead => 'Mark as read';

  @override
  String get pushInviteAcceptedTitle => 'Invitation accepted! 🎉';

  @override
  String pushInviteAcceptedBody(String name) {
    return '$name accepted your date invitation.';
  }

  @override
  String get pushChannelName => 'EverUs invitations';

  @override
  String get pushChannelDescription =>
      'Notifies you when your partner accepts an invitation';

  @override
  String get inviteModalDefaultPartner => 'Your partner';

  @override
  String get inviteModalTitle => 'Invitation Accepted! 🎉';

  @override
  String get inviteModalMessage =>
      ' accepted your romantic date invitation. Get ready for your date! 💕';

  @override
  String get inviteModalDate => 'Date';

  @override
  String get inviteModalTime => 'Time';

  @override
  String get inviteModalLocation => 'Place';

  @override
  String get inviteModalPickup => 'Pickup';

  @override
  String get inviteModalViewItinerary => 'View Itinerary ➔';

  @override
  String get notificationViewPlan => 'View plan ➔';

  @override
  String get distanceNear => 'Near';

  @override
  String get distanceNearHint => 'under 5km';

  @override
  String get distanceFar => 'Far';

  @override
  String get distanceFarHint => '5 - 15 km';

  @override
  String get distanceRandom => 'Surprise me';

  @override
  String get distanceRandomHint => 'Let EverUs pick';

  @override
  String get plannerNoPlacesTitle => 'No Places Found';

  @override
  String get plannerItineraryTitle => 'Date Itinerary';

  @override
  String get plannerTitle => 'Design a Date';

  @override
  String get plannerAddressRequired => 'Please enter your address!';

  @override
  String get plannerLocationRequired =>
      'Please allow location access or enter your address!';

  @override
  String plannerMinBudget(String amount) {
    return 'The minimum budget is $amount VND per person.';
  }

  @override
  String get plannerLoadingTitle => 'Loading plan...';

  @override
  String get plannerLoadingBody =>
      'Fetching the latest info for your date... 💕';

  @override
  String get plannerErrorTitle => 'Couldn\'t create a plan';

  @override
  String get plannerRetry => 'TRY AGAIN';

  @override
  String get plannerBackToEdit => 'Back to editing';

  @override
  String get plannerGenerating => 'EverUs is planning your route...';

  @override
  String get vibeCasual => 'Casual';

  @override
  String get vibeCasualDescription => 'afternoon tea, strolls\n& simple joys';

  @override
  String get vibeRomantic => 'Romantic';

  @override
  String get vibeRomanticDescription =>
      'candlelight, sunsets\n& sweet connection';

  @override
  String get vibeAdventure => 'Adventure';

  @override
  String get vibeAdventureDescription =>
      'games, discovery\n& adventures together';

  @override
  String get plannerVibeTitle => 'Date vibe';

  @override
  String get plannerDateLabel => 'Date';

  @override
  String get plannerTimeLabel => 'Time';

  @override
  String get plannerTimeTo => 'to';

  @override
  String get plannerNextDay => '(next day)';

  @override
  String get plannerMinDuration =>
      'Your date needs to be at least 1 hour long!';

  @override
  String get plannerLocating => 'Finding your location...';

  @override
  String get plannerAddressHint =>
      'Enter a starting address, e.g. 45 Le Loi, D1';

  @override
  String get plannerAddressSearch => 'Search';

  @override
  String get plannerNoLocation => 'We don\'t have your location yet';

  @override
  String get commonRetry => 'Retry';

  @override
  String get plannerDistanceTitle => 'Distance';

  @override
  String get plannerTransportTitle => 'Transportation';

  @override
  String get plannerBudgetTitle => 'Max budget per person';

  @override
  String get plannerBudgetHint => 'Enter an amount';

  @override
  String get plannerHistoryLink => 'View past ideas';

  @override
  String get plannerSubmit => 'START PLANNING';

  @override
  String get transportWalking => 'Walking';

  @override
  String get transportMotorbike => 'Motorbike';

  @override
  String get transportTaxi => 'Taxi';

  @override
  String calendarMonthWithYear(String month, String year) {
    return '$month $year';
  }

  @override
  String get calendarWeekdays => 'SU,MO,TU,WE,TH,FR,SA';

  @override
  String get questionnaireSaveFailed =>
      'Couldn\'t save your answers. Please try again!';

  @override
  String get questionnairePrevious => 'Previous question';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get questionnaireSkip => 'Skip';

  @override
  String get questionnaireSaveChanges => 'Save changes';

  @override
  String get questionnaireFinish => 'Finish & Start';

  @override
  String get commonContinue => 'Continue';

  @override
  String get questionnaireSkipAll => 'Skip all & start exploring ➔';

  @override
  String get questionnaireMultiSelect => 'You can pick more than one';

  @override
  String get resultsNearYou => 'Near you';

  @override
  String shareHeader(String dateType, String emoji) {
    return '✨ DATE PLAN: $dateType $emoji ✨';
  }

  @override
  String shareDate(String date) {
    return '📅 Date: $date';
  }

  @override
  String shareTotalDuration(int minutes, String hours) {
    return '⏱️ Total duration: $minutes min (~$hours h)';
  }

  @override
  String shareBudget(String budget) {
    return '💰 Budget: $budget / person';
  }

  @override
  String shareArea(String area) {
    return '📍 Area: $area';
  }

  @override
  String shareTransport(String transport) {
    return '🏍️ Transport: $transport';
  }

  @override
  String sharePurpose(String purpose) {
    return '🎯 Date goal: $purpose';
  }

  @override
  String shareStage(int num, String title) {
    return '📍 Stop $num: $title';
  }

  @override
  String shareStageTime(String start, String end, int minutes) {
    return '⏰ Time: $start - $end ($minutes min)';
  }

  @override
  String shareStagePurpose(String purpose) {
    return '🎯 Goal: $purpose';
  }

  @override
  String shareStageCategory(String category) {
    return '🍴 Category: $category';
  }

  @override
  String sharePlace(String place) {
    return '📍 Place: $place';
  }

  @override
  String shareAddress(String address) {
    return '   Address: $address';
  }

  @override
  String get shareTasks => '✨ Suggested activities:';

  @override
  String get shareTips => '💡 Tips:';

  @override
  String get shareFooter => '👉 Create your own date plan on the EverUs app!';

  @override
  String get shareCopied => '📋 Itinerary copied to clipboard!';

  @override
  String resultsDurationBadge(int minutes, String hours) {
    return '$minutes min (~${hours}h)';
  }

  @override
  String get resultsStagesTitle => 'DETAILED ITINERARY';

  @override
  String get resultsOpenFullMap => 'OPEN FULL ROUTE MAP';

  @override
  String get resultsRegenerate => 'Regenerate';

  @override
  String resultsRegenerateFailed(String error) {
    return 'Couldn\'t regenerate the plan: $error';
  }

  @override
  String get resultsCopy => 'Copy';

  @override
  String get resultsHistory => 'History';

  @override
  String get resultsCentralArea => 'City center';

  @override
  String resultsHours(String hours) {
    return '$hours hours';
  }

  @override
  String get resultsInviteAccepted => 'Invitation accepted!';

  @override
  String get resultsInviteAcceptedBody =>
      'Your partner has agreed to join this date.';

  @override
  String get resultsResendInvite => 'VIEW / RESEND DATE INVITATION';

  @override
  String get resultsSendInvite => 'SEND DATE INVITATION';

  @override
  String get resultsPurposeTitle => 'Date Goal';

  @override
  String get resultsStagePurpose => 'Purpose';

  @override
  String get resultsStageCategory => 'Category';

  @override
  String get resultsStageDuration => 'Duration';

  @override
  String resultsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get resultsSuggestedTasks => 'Suggested activities';

  @override
  String get resultsSuggestedPlaces => 'Suggested places';

  @override
  String get resultsHideBackups => 'Hide backup options';

  @override
  String resultsShowBackups(int count) {
    return 'Show backup options ($count)';
  }

  @override
  String get resultsTipsTitle => 'Tips for You Two';

  @override
  String get resultsUnlike => 'Remove like';

  @override
  String get resultsLike => 'Like this place';

  @override
  String get resultsUndislike => 'Remove dislike';

  @override
  String get resultsDislike => 'Dislike this place';

  @override
  String get resultsBackupBadge => 'BACKUP OPTION';

  @override
  String get resultsDefaultAddress => 'City center, Ho Chi Minh City';

  @override
  String resultsPriceRange(String range) {
    return 'Price range: $range';
  }

  @override
  String resultsRating(String rating, int count) {
    return 'Rated $rating/5 ($count reviews)';
  }

  @override
  String get resultsViewOnMap => 'View on map';

  @override
  String get resultsMakePrimary => 'Make primary';

  @override
  String resultsTransit(String transport, String km, int minutes) {
    return '$transport: ~ $km km (~$minutes min)';
  }

  @override
  String get resultsDateTypeSuggestion => 'DATE TYPE SUGGESTION';

  @override
  String get savedPlansLoginRequired =>
      'Please log in to see your saved plans.';

  @override
  String savedPlansLoadFailed(int status) {
    return 'Couldn\'t load plans from the server ($status).';
  }

  @override
  String get errorServerConnection =>
      'Something went wrong connecting to the server.';

  @override
  String get savedPlansDeleted => 'Plan deleted 💖';

  @override
  String savedPlansDeleteFailed(int status) {
    return 'Delete failed: $status';
  }

  @override
  String get savedPlansDeleteConnectionError =>
      'Something went wrong while deleting the plan.';

  @override
  String get savedPlansConfirmDeleteTitle => 'Confirm delete';

  @override
  String get savedPlansConfirmDeleteBody =>
      'Are you sure you want to delete this date plan? This can\'t be undone.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get vibeLabelRomantic => 'Romantic';

  @override
  String get vibeLabelFun => 'Lively';

  @override
  String get vibeLabelAdventure => 'Adventure';

  @override
  String get vibeLabelCasual => 'Casual';

  @override
  String get vibeLabelChill => 'Chill';

  @override
  String get savedPlansTitle => 'Saved Date Plans';

  @override
  String get savedPlansEmptyTitle => 'You haven\'t saved any date plans yet.';

  @override
  String get savedPlansEmptyBody =>
      'Plan a new date and it will be saved here automatically!';

  @override
  String savedPlansDateLine(String details) {
    return 'Date: $details';
  }

  @override
  String get savedPlansAccepted => 'Accepted';

  @override
  String get savedPlansInviteSent => 'Invite sent';

  @override
  String savedPlansStageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }
}
