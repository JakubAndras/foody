import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingDobScreen extends StatefulWidget {
  const OnboardingDobScreen({super.key, required this.onNext, required this.onBack, required this.step, required this.totalSteps});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;

  @override
  State<OnboardingDobScreen> createState() => _OnboardingDobScreenState();
}

class _OnboardingDobScreenState extends State<OnboardingDobScreen> {
  static final DateTime _defaultDate = DateTime(2000, 1, 15);
  static final DateTime _minimumDate = DateTime(DateTime.now().year - 100);
  static final DateTime _maximumDate = DateTime.now();

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = SessionManager.to.dateOfBirth.value ?? _defaultDate;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: tr(LocaleKeys.common_continue_btn),
        onPressed: () async {
          await SessionManager.to.setDateOfBirth(_selectedDate);
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_dob_title), style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(tr(LocaleKeys.onboarding_gender_subtitle), style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          SizedBox(
            height: AppSizes.dobPickerHeight,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: AppTextStyles.h4.copyWith(color: AppColors.black, fontWeight: FontWeight.w400, fontSize: 20),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: _minimumDate,
                maximumDate: _maximumDate,
                backgroundColor: Colors.transparent,
                onDateTimeChanged: (DateTime date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
