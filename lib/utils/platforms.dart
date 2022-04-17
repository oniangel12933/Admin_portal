// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Project imports:
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/ui/pref_state.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

import 'package:invoiceninja_flutter/utils/web_stub.dart'
    if (dart.library.html) 'package:invoiceninja_flutter/utils/web.dart';

// TODO remove this function
bool supportsInlineBrowser() => !isDesktopOS();

bool isDesktopOS() => isMacOS() || isWindows() || isLinux();

bool isMobileOS() => isAndroid() || isIOS();

bool isApple() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isIOS || Platform.isMacOS;
}

bool isMacOS() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isMacOS;
}

bool isWindows() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isWindows;
}

bool isLinux() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isLinux;
}

bool isAndroid() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isAndroid;
}

bool isIOS() {
  if (kIsWeb) {
    return false;
  }

  return Platform.isIOS;
}

String getMapURL(BuildContext context) => isAndroid()
    ? 'https://maps.google.com/?q='
    : 'http://maps.apple.com/?address=';

String getLegacyAppURL(BuildContext context) => isAndroid()
    ? 'https://play.google.com/store/apps/details?id=com.invoiceninja.invoiceninja'
    : 'https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1220337560&mt=8';

String getPdfRequirements(BuildContext context) {
  final localization = AppLocalization.of(context);
  if (isMobile(context)) {
    final version = isAndroid() ? 'Android 5.0+' : 'iOS 11.0+';
    return localization.pdfMinRequirements.replaceFirst(':version', version);
  } else {
    return '';
  }
}

String getPlatformLetter() {
  if (kIsWeb) {
    return 'C';
  } else {
    if (Platform.isIOS) {
      return 'I';
    } else if (Platform.isAndroid) {
      return 'A';
    } else if (Platform.isWindows) {
      return 'W';
    } else if (Platform.isLinux) {
      return 'L';
    } else if (Platform.isMacOS) {
      return 'M';
    } else if (Platform.isFuchsia) {
      return 'F';
    }
  }

  return 'U';
}

String getPlatformName() {
  if (kIsWeb) {
    return 'Web';
  } else {
    if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isFuchsia) {
      return 'Fuchsia';
    }
  }

  return 'Unknown';
}

String getNativePlatform() {
  String userAgent = WebUtils.getHtmlValue('user-agent') ?? '';
  userAgent = userAgent.toLowerCase();

  if (userAgent.contains('ipad') ||
      userAgent.contains('ipod') ||
      userAgent.contains('iphone')) {
    return kPlatformiPhone;
  } else if (userAgent.contains('android')) {
    return kPlatformAndroid;
  } else if (userAgent.contains('win')) {
    return kPlatformWindows;
  } else if (userAgent.contains('mac')) {
    return kPlatformMacOS;
  } else if (userAgent.contains('linux')) {
    return kPlatformLinux;
  } else {
    return '';
  }
}

String getNativeAppUrl(String platform) {
  switch (platform) {
    case kPlatformAndroid:
      return kGoogleStoreUrl;
    case kPlatformiPhone:
      return kAppleStoreUrl;
    case kPlatformWindows:
      return kWindowsUrl;
    case kPlatformMacOS:
      return kMacOSUrl;
    case kPlatformLinux:
      return kLinuxUrl;
  }

  return '';
}

IconData getNativeAppIcon(String platform) {
  switch (platform) {
    case kPlatformAndroid:
      return Icons.android;
    case kPlatformiPhone:
      return MdiIcons.apple;
    case kPlatformWindows:
      return MdiIcons.microsoft;
    case kPlatformMacOS:
      return MdiIcons.apple;
    case kPlatformLinux:
      return MdiIcons.linux;
  }

  return null;
}

String getPlatform(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android';

String getRateAppURL(BuildContext context) {
  if (kIsWeb) {
    return kCapterralUrl;
  }

  switch (Theme.of(context).platform) {
    case TargetPlatform.android:
      return kGoogleStoreUrl;
    case TargetPlatform.iOS:
      return kAppleStoreUrl;
    case TargetPlatform.macOS:
      return kMacOSUrl;
    case TargetPlatform.windows:
      return kWindowsUrl;
    default:
      return kCapterralUrl;
  }
}

AppLayout calculateLayout(BuildContext context) {
  final size = MediaQuery.of(context).size.width;

  if (size < kMobileLayoutWidth) {
    return AppLayout.mobile;
  } else {
    return AppLayout.desktop;
  }
}

AppLayout getLayout(BuildContext context) =>
    StoreProvider.of<AppState>(context).state.prefState.appLayout ??
    AppLayout.mobile;

bool isMobile(BuildContext context) => getLayout(context) == AppLayout.mobile;

bool isNotMobile(BuildContext context) => !isMobile(context);

bool isDesktop(BuildContext context) => getLayout(context) == AppLayout.desktop;

bool isNotDesktop(BuildContext context) => !isDesktop(context);

bool isDarkMode(BuildContext context) =>
    StoreProvider.of<AppState>(context).state.prefState.enableDarkMode;

bool isSelfHosted(BuildContext context) =>
    StoreProvider.of<AppState>(context).state.isSelfHosted;

bool isHosted(BuildContext context) =>
    StoreProvider.of<AppState>(context).state.isHosted;

bool isPaidAccount(BuildContext context) =>
    StoreProvider.of<AppState>(context).state.isPaidAccount;
