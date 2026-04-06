import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

/// A global notifier for app locale so we can switch languages on the fly
final ValueNotifier<Locale> appLocaleNotifier = ValueNotifier<Locale>(const Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  // Load saved language if available, default to en
  final savedLang = StorageService.selectedLanguage;
  if (savedLang != null) {
    appLocaleNotifier.value = Locale(savedLang);
  }

  runApp(const AlsaifMedicalApp());
}

class AlsaifMedicalApp extends StatelessWidget {
  const AlsaifMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, child) {
        final isArabic = locale.languageCode == 'ar';
        
        return MaterialApp.router(
          title: 'Alsaif Medical Center',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(isArabic: isArabic),
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
