// Unit testy nad Riverpod notifiery. Běží headless (`flutter test`), bez zařízení
// a bez nativních pluginů — notifiery se čtou přes `ProviderContainer`, závislosti
// se injektují přes override (databázové/pluginové notifiery se testují na zařízení
// v `integration_test/riverpod_migration_test.dart`).

import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/state/export_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Notifiery s čistým synchronním stavem (bez závislostí) — nejjednodušší kontrakt.
  group('SelectedDateNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('výchozí stav je dnešek normalizovaný na půlnoc', () {
      final date = container.read(selectedDateProvider);
      expect(date.hour, 0);
      expect(date.minute, 0);
      expect(date.second, 0);
      expect(date.millisecond, 0);
    });

    test('setSelectedDate normalizuje čas na půlnoc', () {
      container.read(selectedDateProvider.notifier).setSelectedDate(DateTime(2026, 3, 14, 17, 42, 9));
      expect(container.read(selectedDateProvider), DateTime(2026, 3, 14));
    });
  });

  group('MainScreenNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('výchozí tab je Dashboard (index 0), sheet skrytý, bez scroll triggeru', () {
      final state = container.read(mainScreenProvider);
      expect(state.selectedIndex, 0);
      expect(state.isCalendarSheetVisible, false);
      expect(state.scrollToEnergy, false);
    });

    test('changeTab přepne aktivní tab', () {
      container.read(mainScreenProvider.notifier).changeTab(2);
      expect(container.read(mainScreenProvider).selectedIndex, 2);
    });

    test('showProgressTabAndScrollToEnergy přepne na Progress a nastaví scroll trigger', () {
      container.read(mainScreenProvider.notifier).showProgressTabAndScrollToEnergy();
      final state = container.read(mainScreenProvider);
      expect(state.selectedIndex, 1);
      expect(state.scrollToEnergy, true);
    });

    test('setCalendarSheetVisible přepíná viditelnost bez ovlivnění tabu', () {
      container.read(mainScreenProvider.notifier).changeTab(1);
      container.read(mainScreenProvider.notifier).setCalendarSheetVisible(true);
      final state = container.read(mainScreenProvider);
      expect(state.isCalendarSheetVisible, true);
      expect(state.selectedIndex, 1);
    });
  });

  group('AiServiceManagerNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('výchozí provider je OpenAI', () {
      expect(container.read(aiServiceManagerProvider), AiServiceProviderType.openAI);
      final notifier = container.read(aiServiceManagerProvider.notifier);
      expect(notifier.currentProviderCode, 'openai');
      expect(notifier.currentModelCode, 'gpt-5.4');
    });

    test('switchService přepne na Gemini a promítne se do kódů providera/modelu', () {
      final notifier = container.read(aiServiceManagerProvider.notifier);
      notifier.switchService(AiServiceProviderType.gemini);
      expect(container.read(aiServiceManagerProvider), AiServiceProviderType.gemini);
      expect(notifier.currentProviderCode, 'gemini');
      expect(notifier.currentModelCode, 'gemini-default');
    });
  });

  group('ExportNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('výchozí rozsah je posledních 7 dní a bez zprávy', () {
      final state = container.read(exportProvider);
      expect(state.selectedRange, ExportDateRange.last7);
      expect(state.isExporting, false);
      expect(state.message, isNull);
    });

    test('selectRange změní vybraný rozsah', () {
      container.read(exportProvider.notifier).selectRange(ExportDateRange.allTime);
      expect(container.read(exportProvider).selectedRange, ExportDateRange.allTime);
    });

    test('setCustomDates uloží vlastní rozsah', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 31);
      container.read(exportProvider.notifier).setCustomDates(start, end);
      final state = container.read(exportProvider);
      expect(state.customStart, start);
      expect(state.customEnd, end);
    });
  });

  // Notifier se závislostí na službě — dependency se injektuje přes override.
  // SharedPreferences se pro headless běh mockuje přes setMockInitialValues.
  group('SessionNotifier', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('výchozí stav je prázdný profil (build bez načtení z prefs)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(sessionProvider);
      expect(state.onboardingComplete, false);
      expect(state.themeMode, ThemeMode.system);
      expect(state.bmr, isNull);
    });

    test('onAppInit načte uložené hodnoty z SharedPreferences do stavu', () async {
      SharedPreferences.setMockInitialValues({onboardingCompleteKey: true, profileHeightCmKey: 180.0, profileWeightKgKey: 75.0, profileSexKey: ProfileSex.male.code});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).onAppInit();

      final state = container.read(sessionProvider);
      expect(state.onboardingComplete, true);
      expect(state.heightCm, 180.0);
      expect(state.weightKg, 75.0);
      expect(state.sex, ProfileSex.male);
    });

    test('BMR se dopočítá, když jsou k dispozici všechny vstupy, jinak je null', () async {
      SharedPreferences.setMockInitialValues({
        profileHeightCmKey: 180.0,
        profileWeightKgKey: 75.0,
        profileSexKey: ProfileSex.male.code,
        profileDobKey: DateTime(1995, 6, 15).millisecondsSinceEpoch,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(sessionProvider.notifier);

      await notifier.onAppInit();
      expect(container.read(sessionProvider).bmr, isNotNull);
      expect(container.read(sessionProvider).bmr, greaterThan(0));

      // Odebrání výšky musí BMR vynulovat (chybí povinný vstup).
      await notifier.setHeightCm(null);
      expect(container.read(sessionProvider).bmr, isNull);
    });
  });
}
