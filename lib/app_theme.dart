import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppColors {
  // Base
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF0A0A0A);

  // Grey scale
  static const white1 = Color(0xFFFFFFFF);
  static const greyLight3 = Color(0xFFE8E8EA);
  static const grey4 = Color(0xFFA8A8B1);

  // Brand
  static const primary = black;
  static const primaryMuted = Color(0xFF4D4D4D);
  static const primaryDark = Color(0xFF2D2D3A);
  static const onPrimary = white;

  // Background / surfaces
  static const surfacePill = Color(0xFFF0F0F0);
  static const background = surfacePill;
  static const surface = Color(0xFFFAFAFA);
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const separator = surfaceMuted;
  static const surfaceChip = Color(0xFFD9D9D9);
  static const surfaceFrostStart = Color(0x80F3F4F6);
  static const surfaceFrostEnd = Color(0x80E5E7EB);
  static const surfaceSelected = Color(0x0D0A0A0A);

  // Borders / outline
  static const outline = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFD1D5DC);

  // Text
  static const textPrimary = Color(0xFF0A0A0A);
  static const textHeading = Color(0xFF101828);
  static const textSecondary = Color(0xFF6A7282);
  static const textTertiary = Color(0xFF99A1AF);
  static const textMutedLight = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF4A5565);
  static const textEmphasis = Color(0xFF314158);
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
  static const accentColor = Color(0xFFDA0027);
  static const error = accentColor;
  static const errorContainer = Color(0xFFFFE5E5);
  static const errorText = accentColor;

  // Mesh
  static const meshBase = Color(0xFFF0F0F0);

  // Overlays / glass
  static const overlayDark = Color(0x33000000);
  static const overlayDark40 = Color(0x66000000);
  static const overlayDark60 = Color(0x99000000);
  static const glassLight = Color(0xE6FFFFFF);
  static const glassMuted = Color(0xE6EEEEEE);
  static const glassSheet = Color(0x80FFFFFF);
  static const keyboardSurface = Color(0xFFD1D5DB);

  static const glassBorder = Color(0xFFFFFFFF);
  static const glassBackground = Color(0xD0FFFFFF);

  // Misc / brand
  static const statusBarDark = Color(0xFF1E2939);

  // Macro colors
  static const macroProtein = error;
  static const macroCarbs = Color(0xFFFE9A00);
  static const macroFats = info;

  // Accent palettes used in Ask AI / charts
  static const violet = Color(0xFF6366F1);
  static const violetStrong = Color(0xFF7C3AED);
  static const violetDark = Color(0xFF8B5CF6);
  static const amber = Color(0xFFFBBF24);
  static const redStrong = Color(0xFFEF4444);
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
  static const matchRedBg = errorContainer;

  // Dark calendar
  static const calendarDarkBg = Color(0xFF1C1C1E);
  static const calendarDarkSurface = Color(0xFF2C2C2E);
  static const calendarDarkWeekend = Color(0xFF48484A);
  static const calendarDarkMuted = Color(0xFF8E8E93);
}

class AppIcons {
  static const IconData protein = Icons.fitness_center_rounded;
  static const IconData carbs = Icons.spa_rounded;
  static const IconData fats = Icons.opacity_rounded;
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
  static const double screen = m;
  static const double edge = m;
  static const double bottom = m;
  static const double safeAreaTop = 64;
}

class AppRadii {
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 42;
  static const double pill = 999;
}

class AppSizes {
  static const double buttonHeight = 56;
  static const double buttonHeightSm = 52;
  static const double buttonHeightXs = 36;
  static const double buttonHeightXxs = 32;
  static const double minTap = 48;
  static const double topBarHeight = 56;
  static const double bottomNavHeight = 64;
  static const double backButtonSize = 40;
  static const double askAiActionHeight = 54.5;
  static const double askAiInputHeight = 142;
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
  static const double streakPillHeight = 40;
  static const double streakPillMinWidth = 56;
  static const double streakPillMinWidthTripleDigit = 72;
  static const double iconSm = 16;
  static const double iconXs = 14;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 40;
  static const double iconTabBar = 32;
  static const double cardIconLg = 48;
  static const double legendDot = 10;
  static const double macroDot = 8;
  static const double macroDotSm = 6;
  static const double navItemHeight = 56;
  static const double fabSize = 64;
  static const double progressBarHeight = 8;
  static const double calendarStripHeight = 78;
  static const double borderThick = 2;
  static const double optionCardHeightLarge = 72;
  static const double workoutCardHeight = 100;
  static const double sliderTrackHeight = 6;
  static const double sliderThumbRadius = 12;
  static const double sliderTickSize = 4;
  static const double dividerThin = 1;
  static const double ringSize = 128;
  static const double ringStroke = 8;
  static const double ringSizeSmall = 100;
  static const double summaryRingSize = 142;
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
  static const double toggleWidthSm = 51;
  static const double toggleKnobSm = 27;
  static const double inputHeightLg = 64;
  static const double customDietFieldHeight = 256;
  static const double calorieBurnImageSize = 384;
  static const double infoCardWidth = 210;
  static const double macroCardHeight = 160;
  static const double mealCardHeight = 110;
  static const double mealImageSize = 90;
  static const double exerciseImageSize = 94;
  static const double mealDashboardImageSize = 94;
  static const double mealHeroHeight = 300;
  static const double macroCardSize = 125.34;
  static const double caloriesCardHeight = 136;
  static const double actionSheetWidth = 220;
  static const double emptyStateHeight = 168;
  static const double emptyStateIconSize = 64;
  static const double progressStatCardHeight = 210;
  static const double profileHeaderHeight = 96;
  static const double dateCircleSize = 40;
  static const double listRowHeight = 67;
  static const double searchBarHeight = 48;
  static const double selectMealActionTileHeight = 75;
  static const double selectMealIngredientRowHeight = 70;
  static const double macroIconSize = 52;
  static const double goalRowHeight = 72;
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
  static const double scanTopButtonSize = 44;
  static const double scanIconSize = 24;
  static const double scanCornerSize = 64;
  static const double scanCornerStroke = 3.233;
  static const double scanCornerRadius = 24;
  static const double scanZoomPillWidth = 84;
  static const double scanZoomPillHeight = 32;
  static const double scanZoomButtonWidth = 40;
  static const double scanZoomButtonHeight = 28;
  static const double scanModeButtonWidth = 120;
  static const double scanModeButtonHeight = 69;
  static const double scanBottomBarHeight = 214;
  static const double scanShutterSize = 64;
  static const double scanShutterRingSize = 56;
  static const double scanAuxButtonSize = 48;
  static const double scanPreviewImageWidth = 390;
  static const double scanPreviewImageHeight = 520;
  static const double scanInputHeight = 58.15;
  static const double scanTextAreaHeight = 82.15;
  static const double scanAnalyzeButtonHeight = 56;
  static const double voiceToggleWidth = 51;
  static const double voiceToggleHeight = 28;
  static const double voiceToggleKnob = 24;
  static const double voiceMicSize = 80;
  static const double voiceMicIcon = 36;
  static const double voiceAnalyzeHeight = 54;
  static const double exerciseSearchHeight = 54;
  static const double exerciseCardHeight = 110;
  static const double exerciseOptionCardHeight = 140;
  static const double exerciseStatCardHeight = 164;
}

class AppOpacities {
  static const double disabled = 0.25;
  static const double half = 0.5;
  static const double soft = 0.75;
  static const double medium = 0.8;
}

class AppGradients {
  static const LinearGradient primary = darkDiagonal;
  static const LinearGradient justBlack = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, AppColors.primary]);
  static const LinearGradient darkLinear = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, AppColors.primaryMuted]);
  static const LinearGradient darkDiagonal = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D0D0D), Color(0xFF1D1D1D)], stops: [0, 1.0]);

  static const LinearGradient askAiPrimary = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.violet, AppColors.violetDark]);

  static const LinearGradient voiceFrostedSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.surfaceFrostStart, AppColors.surfaceFrostEnd],
  );

  static const LinearGradient exerciseCalories = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.exerciseOrange, AppColors.redStrong]);

  static const LinearGradient exerciseCaloriesAlt = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.exerciseOrange, AppColors.exerciseOrangeDark],
  );

  static const LinearGradient exerciseDuration = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.exerciseCyan, AppColors.exerciseCyanDark],
  );

  static const LinearGradient askAiExample = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.amber, AppColors.yellowStrong]);

  static const LinearGradient askAiDanger = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.redStrong, AppColors.redStrongDark]);

  static const LinearGradient askAiSuccess = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.greenStrong, AppColors.greenStrongDark]);

  static const LinearGradient askAiWarning = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.yellowStrong, AppColors.yellowStrongDark]);

  static const LinearGradient askAiDangerSurface = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)]);

  static const LinearGradient askAiSuccessSurface = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.greenSubtle, AppColors.greenSoft]);

  static const LinearGradient askAiWarningSurface = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.yellowSubtle, AppColors.yellowSoft]);

  static const LinearGradient bmi = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.info,
      AppColors.info,
      AppColors.success,
      AppColors.success,
      AppColors.warning,
      AppColors.warning,
      AppColors.error,
      AppColors.error,
    ],
    stops: [0.0, 0.15, 0.25, 0.50, 0.60, 0.75, 0.85, 1.0],
  );

  static const LinearGradient loading = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFFFF6B6B), Color(0xFFC084FC), Color(0xFF60A5FA)]);

  static const LinearGradient scanPlaceholder = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DC)]);

  static const LinearGradient scanCameraSurface = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.surfaceMuted, AppColors.outline]);
}

class AppQuickAction {
  /// Switch between quick action sheet styles:
  /// - false: glass sheet background, white option cards (v1)
  /// - true: transparent sheet background, glass option cards (v2)
  static const bool useGlassCards = false;
}

class AppBorders {
  /// Single variable to control card borders across Dashboard, Progress, and Profile screens.
  /// Change this to adjust all screen card borders from one place (set to null to remove them).
  static final BoxBorder? screenCard = Border.all(color: AppColors.outline);
}

class AppShadows {
  /// Single variable to control card shadows across Dashboard, Progress, and Profile screens.
  /// Change this to adjust all screen card shadows from one place (set to [] to remove them).
  static const List<BoxShadow> screenCard = [];

  static const List<BoxShadow> cardSubtle = [BoxShadow(offset: Offset(0, 2), blurRadius: 20, color: Color(0x05000000))];

  static const List<BoxShadow> cardSoft = [BoxShadow(offset: Offset(0, 2), blurRadius: 20, color: Color(0x0A000000))];

  static const List<BoxShadow> control = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: Color(0x1A000000)),
    BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x1A000000)),
  ];

  static const List<BoxShadow> card = [BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x1A000000))];

  static const List<BoxShadow> button = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 15, color: Color(0x1A000000)),
    BoxShadow(offset: Offset(0, 4), blurRadius: 6, color: Color(0x1A000000)),
  ];

  static const List<BoxShadow> modal = [BoxShadow(offset: Offset(0, 25), blurRadius: 50, spreadRadius: -12, color: Color(0x40000000))];

  static const List<BoxShadow> sheet = [
    BoxShadow(offset: Offset(0, 20), blurRadius: 25, spreadRadius: -5, color: Color(0x1A000000)),
    BoxShadow(offset: Offset(0, 8), blurRadius: 10, spreadRadius: -6, color: Color(0x1A000000)),
  ];

  static const List<BoxShadow> calendarDay = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 6, color: Color(0x1A000000)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x1A000000)),
  ];

  static const List<BoxShadow> previewImage = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 15, spreadRadius: -3, color: Color(0x1A000000)),
    BoxShadow(offset: Offset(0, 4), blurRadius: 6, spreadRadius: -4, color: Color(0x1A000000)),
  ];
}

class AppGlass {
  static final standard = LiquidGlassSettings(thickness: 25, blur: 2, glassColor: Colors.white.withValues(alpha: 0.65), lightIntensity: 1.5);
}

class AppTextStyles {
  static const displayXL = TextStyle(fontSize: 80, height: 1.0, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const displayL = TextStyle(fontSize: 40, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const h1 = TextStyle(fontSize: 34, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const h2 = TextStyle(fontSize: 28, height: 1.25, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const h3 = TextStyle(fontSize: 24, height: 1.333, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const h4 = TextStyle(fontSize: 20, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const weightValue = TextStyle(fontSize: 36, height: 1.11, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const title = TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const stat48 = TextStyle(fontSize: 48, height: 1.0, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const title17 = TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const title18 = TextStyle(fontSize: 18, height: 1.556, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const body16 = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const body16Regular = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const body15 = TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const body14 = TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const body14Regular = TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const label12 = TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily);

  static const body14Relaxed = TextStyle(fontSize: 14, height: 1.625, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: AppTheme.fontFamily);

  static const body13 = TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: AppTheme.fontFamily);

  static const caption12 = TextStyle(fontSize: 12, height: 1.33, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: AppTheme.fontFamily);

  static const label11 = TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: AppTheme.fontFamily, letterSpacing: 0.34);

  static const badge14 = TextStyle(fontSize: 14, height: 1.18, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: AppTheme.fontFamily, letterSpacing: 0.0645);

  static const label10 = TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary, fontFamily: AppTheme.fontFamily, letterSpacing: 0.12);

  static const label9 = TextStyle(fontSize: 9, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontFamily: AppTheme.fontFamily, letterSpacing: 0.17);

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
  static const transitionDuration = Duration(milliseconds: 200);
}
