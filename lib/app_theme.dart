import 'package:flutter/material.dart';

class AppColors {
  // Base
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF0A0A0A);

  // Brand
  static const primary = black;
  static const primaryMuted = Color(0xFF4D4D4D);
  static const primaryDark = Color(0xFF2D2D3A);
  static const onPrimary = white;

  // Background / surfaces
  static const background = white;
  static const backgroundSoft = Color(0xFFF8F8F8);
  static const backgroundAlt = Color(0xFFFAFAFA);
  static const surface = white;
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const separator = surfaceMuted;
  static const surfaceSearch = Color(0xFFF3F3F5);
  static const surfaceSubtle = Color(0xFFF9FAFB);
  static const surfacePill = Color(0xFFF0F0F0);
  static const surfaceChip = Color(0xFFD9D9D9);
  static const surfaceFrostStart = Color(0x80F3F4F6);
  static const surfaceFrostEnd = Color(0x80E5E7EB);
  static const surfaceSelected = Color(0x0D0A0A0A);
  static const surfaceCard = Color(0xFFF8F9FA);
  static const surfaceCardBorder = Color(0xFFF8FAFC);

  // Borders / outline
  static const border = Color(0xFFF1F5F9);
  static const outline = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFD1D5DC);

  // Text
  static const textPrimary = Color(0xFF0F172B);
  static const textHeading = Color(0xFF101828);
  static const textSecondary = Color(0xFF6A7282);
  static const textSecondaryAlt = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF99A1AF);
  static const textMutedLight = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF4A5565);
  static const textBody = Color(0xFF374151);
  static const textEmphasis = Color(0xFF314158);
  static const textEmphasisAlt = Color(0xFF364153);
  static const textDisabled = borderStrong;

  // Status / accents
  static const accent = Color(0xFF4F39F6);
  static const info = Color(0xFF2B7FFF);
  static const warning = Color(0xFFFDC700);
  static const warningSoft = Color(0xFFFFD6A8);
  static const warningStrong = Color(0xFFFFB020);
  static const warningSurface = Color(0xFFFFF9E6);
  static const success = Color(0xFF05DF72);
  static const successStrong = Color(0xFF00C950);
  static const successText = Color(0xFF008236);
  static const orange = Color(0xFFFF6900);
  static const error = Color(0xFFFB2C36);
  static const errorContainer = Color(0xFFFFE5E5);
  static const errorText = Color(0xFFC10007);
  static const errorSoft = Color(0xFFFFE2E2);
  static const destructive = Color(0xFFFF0C15);
  static const danger = Color(0xFFE7000B);
  static const redSubtle = Color(0xFFFEF2F2);
  static const redSoft = Color(0xFFFEE2E2);
  static const dangerSoft = redSubtle;

  // Overlays / glass
  static const overlayDark = Color(0x33000000);
  static const overlayDark40 = Color(0x66000000);
  static const overlayDark60 = Color(0x99000000);
  static const glassLight = Color(0xE6FFFFFF);
  static const glassMuted = Color(0xE6EEEEEE);
  static const glassSheet = Color(0x80FFFFFF);
  static const keyboardSurface = Color(0xFFD1D5DB);

  // Misc / brand
  static const statusBarDark = Color(0xFF1E2939);
  static const avatarPurple = Color(0xFFAD46FF);
  static const googleBlue = Color(0xFF4285F4);
  static const googleRed = Color(0xFFEA4335);
  static const googleYellow = Color(0xFFFBBC05);
  static const googleGreen = Color(0xFF34A853);

  // Macro colors
  static const macroProtein = error;
  static const macroCarbs = Color(0xFFFE9A00);
  static const macroCarbsStrong = warningStrong;
  static const macroFats = info;

  // Reports / charts
  static const reportRed = Color(0xFFEF4444);
  static const reportPurple = Color(0xFF8B5CF6);
  static const reportBlue = Color(0xFF3B82F6);

  // Accent palettes used in Ask AI / charts
  static const violet = Color(0xFF6366F1);
  static const violetStrong = Color(0xFF7C3AED);
  static const violetDark = reportPurple;
  static const amber = Color(0xFFFBBF24);
  static const redStrong = reportRed;
  static const redStrongDark = Color(0xFFDC2626);
  static const exerciseOrange = Color(0xFFF97316);
  static const exerciseOrangeDark = Color(0xFFEA580C);
  static const exerciseCyan = Color(0xFF06B6D4);
  static const exerciseCyanDark = Color(0xFF0891B2);
  static const greenStrong = Color(0xFF10B981);
  static const greenStrongDark = Color(0xFF059669);
  static const greenSubtle = Color(0xFFD1FAE5);
  static const greenSoft = Color(0xFFA7F3D0);
  static const yellowStrong = Color(0xFFF59E0B);
  static const yellowStrongDark = Color(0xFFD97706);
  static const yellowSubtle = Color(0xFFFEF3C7);
  static const yellowSoft = Color(0xFFFDE68A);

  // Match badges
  static const matchYellowBg = Color(0xFFFEF9C2);
  static const matchYellowText = Color(0xFFA65F00);
  static const matchGreenBg = Color(0xFFDCFCE7);
  static const matchRedBg = errorSoft;

  // Legacy aliases
  static const primarySoft = textPrimary;
  static const indicatorInactive = Color(0xFFD1D1C8);
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 56;
  static const double mega = 72;
  static const double screen = l;
  static const double edge = m;
}

class AppRadii {
  static const double xs = 8;
  static const double sm1 = 10;
  static const double sm = 12;
  static const double sm2 = 14;
  static const double md = 16;
  static const double md2 = 18;
  static const double lg2 = 20;
  static const double lg = 24;
  static const double lg3 = 28;
  static const double xl = 32;
  static const double xxl = 42;
  static const double pill = 999;
}

class AppSizes {
  static const double buttonHeight = 57.5;
  static const double buttonHeightCompact = 56;
  static const double buttonHeightSm = 52;
  static const double buttonHeightXs = 36;
  static const double buttonHeightXxs = 32;
  static const double minTap = 48;
  static const double topBarHeight = 56;
  static const double mealTopBarHeight = 42;
  static const double editTopBarHeight = 80;
  static const double bottomNavHeight = 64;
  static const double backButtonSize = 40;
  static const double askAiTopBarHeight = 80;
  static const double askAiActionHeight = 54.5;
  static const double askAiInputHeight = 142;
  static const double askAiCalendarDay = 40.84;
  static const double askAiCalendarDaySelected = 42.88;
  static const double matchBadgeHeight = 21;
  static const double chipHeight = 40;
  static const double actionRowHeight = 28;
  static const double ingredientRowHeight = 80;
  static const double ingredientRowAlertHeight = 100;
  static const double alertCardHeight = 80;
  static const double editFormRowHeight = 37;
  static const double datePickerCell = 48;
  static const double datePickerCellSelected = 50;
  static const double iconButtonSm = 32;
  static const double stepIndicatorHeight = 4;
  static const double badgeHeight = 30;
  static const double streakPillHeight = 34;
  static const double iconSm = 16;
  static const double iconXs = 14;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 40;
  static const double cardIconLg = 48;
  static const double legendDot = 10;
  static const double macroDot = 8;
  static const double macroDotSm = 6;
  static const double navItemHeight = 48;
  static const double fabSize = 64;
  static const double fabIconSize = 32;
  static const double progressBarHeight = 8;
  static const double calendarStripHeight = 78;
  static const double borderThick = 2;
  static const double optionCardHeight = buttonHeight;
  static const double optionCardHeightLarge = 72;
  static const double workoutCardHeight = 100;
  static const double sliderTrackHeight = 6;
  static const double sliderThumbRadius = 12;
  static const double sliderTickSize = 4;
  static const double dividerThin = 1;
  static const double ringSize = 128;
  static const double ringStroke = 8;
  static const double ringSizeSmall = 100;
  static const double summaryRingSize = 125;
  static const double macroRingSize = 64;
  static const double widgetRingSize = 112;
  static const double macroRingStroke = 6;
  static const double progressRingStroke = 3;
  static const double progressSegmentSm = 48;
  static const double progressSegmentMd = 64;
  static const double progressSegmentLg = 80;
  static const double goalBarWidth = 64;
  static const double rulerHeight = 104;
  static const double rulerHighlightWidth = 96;
  static const double rulerHighlightHeight = 72;
  static const double rulerTickSpacing = 5;
  static const double rulerMajorTick = 32;
  static const double rulerMidTick = 20;
  static const double rulerMinorTick = 12;
  static const double pickerHeight = 200;
  static const double dobPickerHeight = 240;
  static const double pickerItemHeight = 40;
  static const double pickerHighlightRadius = 10;
  static const double toggleHeight = 32;
  static const double toggleWidth = 56;
  static const double toggleHeightSm = 31;
  static const double toggleWidthSm = 51;
  static const double toggleKnobSm = 27;
  static const double inputHeightSm = 53;
  static const double inputHeightMd = 56;
  static const double inputHeightLg = 64;
  static const double customDietFieldHeight = 256;
  static const double calorieBurnImageSize = 384;
  static const double infoCardWidth = 210;
  static const double infoCardHeight = 150;
  static const double macroCardHeight = 160;
  static const double mealCardHeight = 132;
  static const double mealImageSize = 90;
  static const double mealHeroHeight = 249;
  static const double macroCardSize = 125.34;
  static const double caloriesCardHeight = 136;
  static const double actionSheetWidth = 220;
  static const double emptyStateHeight = 168;
  static const double emptyStateIconSize = 64;
  static const double progressStatCardHeight = 210;
  static const double profileHeaderHeight = 96;
  static const double widgetRowHeight = 160;
  static const double dateCircleSize = 40;
  static const double dateCircleBorder = progressRingStroke;
  static const double listRowHeight = 67;
  static const double searchBarHeight = 48;
  static const double selectMealSegmentHeight = 33;
  static const double selectMealSegmentIndicator = 2;
  static const double selectMealActionTileWidth = 86.5;
  static const double selectMealActionTileHeight = 75;
  static const double selectMealCardHeight = mealImageSize;
  static const double selectMealCardImageSize = mealImageSize;
  static const double selectMealIngredientRowHeight = 70;
  static const double macroIconSize = 52;
  static const double goalRowHeight = 72;
  static const double reportIllustrationSize = 300;
  static const double reportCardWidth = 192;
  static const double reportCardHeight = 224;
  static const double reportPlaceholderHeight = 32;
  static const double amountFieldWidth = 151;
  static const double dateChipHeight = 36;
  static const double feedbackInputHeight = 150;
  static const double quickActionTileWidth = mealImageSize;
  static const double quickActionTileHeight = 76;
  static const double streakIconSize = 64;
  static const double streakDotSize = 12;
  static const double chartLabelWidth = 32;
  static const double segmentedHeight = 40;
  static const double bmiBarHeight = 10;
  static const double bmiMarkerWidth = 2;
  static const double bmiMarkerHeight = 20;
  static const double quickActionIconSize = 28;
  static const double avatarSize = 64;
  static const double settingsDividerIndent = 52;
  static const double rolloverHeaderHeight = 46;
  static const double scanIndicatorDot = 6;
  static const double scanIndicatorGap = 6;
  static const double scanStatusBarHeight = 44;
  static const double scanTopButtonSize = 40;
  static const double scanTopIconSize = 20;
  static const double scanCornerSize = 64;
  static const double scanCornerStroke = 3.233;
  static const double scanCornerRadius = 24;
  static const double scanZoomPillWidth = 84;
  static const double scanZoomPillHeight = 32;
  static const double scanZoomButtonWidth = 40;
  static const double scanZoomButtonHeight = 28;
  static const double scanModeButtonWidth = 120;
  static const double scanModeButtonHeight = 69;
  static const double scanModeIconSize = 24;
  static const double scanBottomBarHeight = 214;
  static const double scanShutterSize = 64;
  static const double scanShutterRingSize = 56;
  static const double scanShutterRingStroke = scanCornerStroke;
  static const double scanAuxButtonSize = 48;
  static const double scanPreviewImageWidth = 390;
  static const double scanPreviewImageHeight = 520;
  static const double scanInputHeight = 58.15;
  static const double scanTextAreaHeight = 82.15;
  static const double scanAnalyzeButtonHeight = 56;
  static const double voiceTopHandleWidth = 48;
  static const double voiceTopHandleHeight = 4;
  static const double voiceToggleWidth = 51;
  static const double voiceToggleHeight = 28;
  static const double voiceToggleKnob = 24;
  static const double voiceMicSize = 80;
  static const double voiceMicIcon = 36;
  static const double voiceAnalyzeHeight = 54;
  static const double voiceTextAreaHeight = askAiInputHeight;
  static const double exerciseSearchHeight = 54;
  static const double exerciseCardHeight = 110;
  static const double exerciseOptionCardHeight = 140;
  static const double exerciseStatCardHeight = 164;
  static const double exerciseInputHeight = scanInputHeight;
}

class AppOpacities {
  static const double disabled = 0.25;
  static const double half = 0.5;
  static const double macroDot = 0.7;
  static const double macroTextSoft = 0.75;
  static const double macroTextStrong = 0.8;
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primary,
      AppColors.primaryMuted,
    ],
  );

  static const LinearGradient askAiPrimary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.violet,
      AppColors.violetDark,
    ],
  );

  static const LinearGradient voiceAnalyze = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.violet,
      AppColors.violetDark,
    ],
  );

  static const LinearGradient voiceFrostedSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceFrostStart,
      AppColors.surfaceFrostEnd,
    ],
  );

  static const LinearGradient exerciseCalories = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.exerciseOrange,
      AppColors.redStrong,
    ],
  );

  static const LinearGradient exerciseCaloriesAlt = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.exerciseOrange,
      AppColors.exerciseOrangeDark,
    ],
  );

  static const LinearGradient exerciseDuration = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.exerciseCyan,
      AppColors.exerciseCyanDark,
    ],
  );

  static const LinearGradient askAiExample = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.amber,
      AppColors.yellowStrong,
    ],
  );

  static const LinearGradient askAiDanger = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.redStrong,
      AppColors.redStrongDark,
    ],
  );

  static const LinearGradient askAiSuccess = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.greenStrong,
      AppColors.greenStrongDark,
    ],
  );

  static const LinearGradient askAiWarning = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.yellowStrong,
      AppColors.yellowStrongDark,
    ],
  );

  static const LinearGradient askAiDangerSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.redSubtle,
      AppColors.redSoft,
    ],
  );

  static const LinearGradient askAiSuccessSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.greenSubtle,
      AppColors.greenSoft,
    ],
  );

  static const LinearGradient askAiWarningSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.yellowSubtle,
      AppColors.yellowSoft,
    ],
  );

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      AppColors.surfaceSubtle,
    ],
    stops: [0, 1],
  );

  static const LinearGradient bmi = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.info,
      AppColors.warning,
      AppColors.error,
    ],
  );

  static const LinearGradient loading = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFC084FC),
      Color(0xFF60A5FA),
    ],
  );

  static const LinearGradient scanAnalyze = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.violet,
      AppColors.violetDark,
    ],
  );

  static const LinearGradient scanPlaceholder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE5E7EB),
      Color(0xFFD1D5DC),
    ],
  );

  static const LinearGradient scanCameraSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceMuted,
      AppColors.outline,
    ],
  );
}

class AppShadows {
  static const List<BoxShadow> cardSubtle = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 20,
      color: Color(0x05000000),
    ),
  ];

  static const List<BoxShadow> cardLite = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 10,
      color: Color(0x05000000),
    ),
  ];

  static const List<BoxShadow> cardSoft = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 20,
      color: Color(0x0A000000),
    ),
  ];

  static const List<BoxShadow> control = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> cardSmall = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> navBar = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 30,
      color: Color(0x14000000),
    ),
  ];

  static const List<BoxShadow> fab = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15,
      color: Color(0x330F172B),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      color: Color(0x330F172B),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
      color: Color(0x40000000),
    ),
  ];

  static const List<BoxShadow> sheet = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -6,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> sliderKnob = [
    BoxShadow(
      offset: Offset(0, 0.5),
      blurRadius: 4,
      color: Color(0x1F000000),
    ),
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 13,
      color: Color(0x1F000000),
    ),
  ];

  static const List<BoxShadow> calendarDay = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> cameraControl = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> previewImage = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
      color: Color(0x1A000000),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
      color: Color(0x1A000000),
    ),
  ];
}

class AppTextStyles {
  static const displayXL = TextStyle(
    fontSize: 80,
    height: 1.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const displayL = TextStyle(
    fontSize: 40,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const h1 = TextStyle(
    fontSize: 34,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const h1Tight = TextStyle(
    fontSize: 34,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const h3 = TextStyle(
    fontSize: 24,
    height: 1.333,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const h4 = TextStyle(
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const scanTitle = TextStyle(
    fontSize: 28,
    height: 1.214,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
  );

  static const scanHeading20 = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
  );

  static const h1Alt = TextStyle(
    fontSize: 32,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const headline36 = TextStyle(
    fontSize: 36,
    height: 1.11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const title24 = TextStyle(
    fontSize: 24,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const weightValue = TextStyle(
    fontSize: 36,
    height: 1.11,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const bmiValue = TextStyle(
    fontSize: 32,
    height: 1.5,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const title = TextStyle(
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const stat48 = TextStyle(
    fontSize: 48,
    height: 1.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const title17 = TextStyle(
    fontSize: 17,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const title18 = TextStyle(
    fontSize: 18,
    height: 1.556,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const title18Tight = TextStyle(
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const selectMealTitle = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.3125,
  );

  static const selectMealSectionTitle = TextStyle(
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.4395,
  );

  static const selectMealSegmentLabel = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.1504,
  );

  static const selectMealMealTitle = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const selectMealMacro = TextStyle(
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
  );

  static const selectMealKcalValue = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const selectMealKcalLabel = TextStyle(
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: AppTheme.fontFamily,
  );

  static const selectMealIngredientTitle = TextStyle(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.2344,
  );

  static const selectMealIngredientSubtitle = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.0762,
  );

  static const selectMealQuickActionLabel = TextStyle(
    fontSize: 11,
    height: 1.25,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.0645,
  );

  static const selectMealPickerItem = TextStyle(
    fontSize: 16,
    height: 1.75,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.4492,
  );

  static const navTitle18 = TextStyle(
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.4395,
  );

  static const sectionHeader16 = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.3125,
  );

  static const formLabel16 = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.3125,
  );

  static const formValue16 = formLabel16;

  static const macroDotLabel11 = TextStyle(
    fontSize: 11,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.0645,
  );

  static const kcalValue18 = title;

  static const kcalLabel12 = selectMealKcalLabel;

  static const button18 = TextStyle(
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const label18 = TextStyle(
    fontSize: 18,
    height: 1.167,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body16 = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body16Regular = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const inputPlaceholder16 = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: -0.4316,
  );

  static const body17 = TextStyle(
    fontSize: 17,
    height: 1.412,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body15 = TextStyle(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body14 = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body14Regular = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const label12 = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body14Tall = body14;

  static const body14Relaxed = TextStyle(
    fontSize: 14,
    height: 1.625,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
  );

  static const body13 = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
  );

  static const caption12 = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
  );

  static const label11 = TextStyle(
    fontSize: 11,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.34,
  );

  static const badge14 = TextStyle(
    fontSize: 14,
    height: 1.18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.0645,
  );

  static const label10 = TextStyle(
    fontSize: 10,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.12,
  );

  static const label9 = TextStyle(
    fontSize: 9,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.17,
  );

  static const labelUpper = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
    letterSpacing: 0.2488,
  );
}

class AppTheme {
  static const String fontFamily = 'Ubuntu';

  static final ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
  );

  static const accentColor = AppColors.primary;
  static const okColor = Color(0xFF83B528);

  // Text on light surfaces (legacy tokens used in ThemeData)
  static const onLightColor = Color(0x26010101); // 15%

  // Accent a CatTwo -> barvy "ON" jsou vždy stejné
  static const onAccentColor = AppColors.white;
  static const onAccentSecondaryColor = Color(0xBFFFFFFF); // 75%
  static const onAccentDisabledColor = AppColors.glassSheet; // 50%
  static const onAccentLightColor = Color(0x26FFFFFF); // 15%
  static const onAccentExtraLightColor = Color(0x14FFFFFF); // 8%

  static const transitionDuration = Duration(milliseconds: 200);
}

const MaterialColor primarySwatch = MaterialColor(
  0xFFDA0027,
  <int, Color>{
    50: Color(0xFFDA0027),
    100: Color(0xFFDA0027),
    200: Color(0xFFDA0027),
    300: Color(0xFFDA0027),
    400: Color(0xFFDA0027),
    500: Color(0xFFDA0027),
    600: Color(0xFFDA0027),
    700: Color(0xFFDA0027),
    800: Color(0xFFDA0027),
    900: Color(0xFFDA0027),
  },
);
