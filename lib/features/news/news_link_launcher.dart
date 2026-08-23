import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an original publisher page outside the app.
abstract interface class NewsLinkLauncher {
  /// Returns whether the platform accepted [uri].
  Future<bool> open(Uri uri);
}

/// Android/Linux implementation backed by the operating-system browser.
final class PlatformNewsLinkLauncher implements NewsLinkLauncher {
  @override
  Future<bool> open(Uri uri) {
    if (!uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return Future<bool>.value(false);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Injectable platform boundary, overridden by widget tests.
final Provider<NewsLinkLauncher> newsLinkLauncherProvider =
    Provider<NewsLinkLauncher>((Ref ref) => PlatformNewsLinkLauncher());
