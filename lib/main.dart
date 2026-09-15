import 'package:dividendendackel/app/app.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        removeProviderDataProvider.overrideWith(
          (Ref ref) => (String providerId) async {
            final failure =
                (await ref
                        .read(marketDataRepositoryProvider)
                        .removeQuotesFromSource(providerId))
                    .failureOrNull;
            if (failure != null) {
              throw failure;
            }
          },
        ),
      ],
      child: const DividendenDackelApp(),
    ),
  );
}
