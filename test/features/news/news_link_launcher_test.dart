import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('platform launcher rejects non-web schemes before dispatch', () async {
    final PlatformNewsLinkLauncher launcher = PlatformNewsLinkLauncher();

    expect(await launcher.open(Uri.parse('file:///private/article')), isFalse);
    expect(await launcher.open(Uri.parse('javascript:alert(1)')), isFalse);
  });
}
