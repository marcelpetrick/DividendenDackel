import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'language_preference.dart';

/// Offline application translations keyed by canonical English source copy.
final class AppLocalizations {
  /// Creates translations for [locale].
  const AppLocalizations(this.locale);

  /// Active locale.
  final Locale locale;

  /// Languages supported by the complete application catalog.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('hr'),
  ];

  /// Delegate installed on both onboarding and routed app trees.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Reads the catalog from [context].
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('en'));

  /// Translates canonical English [source], including dynamic values.
  String text(String source) {
    if (locale.languageCode == 'en' || source.trim().isEmpty) return source;
    final _Translation? exact =
        _messages[source] ??
        _longMessages[source] ??
        _formMessages[source] ??
        _onboardingMessages[source] ??
        _patternMessages[source] ??
        _screenMessages[source];
    if (exact != null) return _select(exact, source);

    return _substitutePhrases(source);
  }

  /// Translates a message [pattern] and fills its `{name}` placeholders.
  ///
  /// The pattern is what the catalog is keyed by, so `'{count} more
  /// activities'` is one translatable message whatever `count` happens to be.
  /// Interpolating first and translating afterwards cannot work: the assembled
  /// string never matches a catalog entry, so it fell through to the phrase
  /// table and came back half English.
  ///
  /// Values are substituted after translation and are never themselves
  /// translated -- they are amounts, dates, codes and user content. Translate
  /// a value at the call site if it is application copy.
  String format(String pattern, Map<String, Object?> values) {
    final String translated = text(pattern);
    if (values.isEmpty) return translated;
    final StringBuffer output = StringBuffer();
    int index = 0;
    while (index < translated.length) {
      final int open = translated.indexOf('{', index);
      if (open < 0) {
        output.write(translated.substring(index));
        break;
      }
      final int close = translated.indexOf('}', open + 1);
      if (close < 0) {
        output.write(translated.substring(index));
        break;
      }
      final String name = translated.substring(open + 1, close);
      if (!values.containsKey(name)) {
        // An unknown placeholder is a catalog bug, not user input. Leave it
        // visible rather than silently dropping part of the message.
        output.write(translated.substring(index, close + 1));
        index = close + 1;
        continue;
      }
      output
        ..write(translated.substring(index, open))
        ..write(values[name]);
      index = close + 1;
    }
    return output.toString();
  }

  /// Applies the phrase table to [source] in a single left-to-right pass.
  ///
  /// Two rules keep the result from corrupting words, both of which a plain
  /// `replaceAll` over every phrase in turn got wrong:
  ///
  ///   * **Translated text is never re-examined.** Each match advances past the
  ///     source it consumed, so one phrase's output cannot be matched by the
  ///     next. Replacing in turn meant `dividend -> Dividende` was then hit by
  ///     `Dividend -> Dividende`, and `ex-dividend` came out `ex-Dividendee`.
  ///   * **A phrase that starts or ends in a letter needs a word boundary.**
  ///     Otherwise `net -> netto` fires inside unrelated words and `internet`
  ///     becomes `internetto`.
  ///
  /// Longest phrases are tried first so `holdings` wins over `holding`.
  String _substitutePhrases(String source) {
    final StringBuffer output = StringBuffer();
    int index = 0;
    while (index < source.length) {
      final MapEntry<String, _Translation>? match = _matchAt(source, index);
      if (match == null) {
        output.write(source[index]);
        index += 1;
        continue;
      }
      output.write(_select(match.value, match.key));
      index += match.key.length;
    }
    return output.toString();
  }

  /// The longest phrase that starts at [index] and respects word boundaries.
  static MapEntry<String, _Translation>? _matchAt(String source, int index) {
    for (final MapEntry<String, _Translation> phrase in _phrasesByLength) {
      final String key = phrase.key;
      if (!source.startsWith(key, index)) continue;
      if (_isLetter(key.codeUnitAt(0)) &&
          index > 0 &&
          _isLetter(source.codeUnitAt(index - 1))) {
        continue;
      }
      final int end = index + key.length;
      if (_isLetter(key.codeUnitAt(key.length - 1)) &&
          end < source.length &&
          _isLetter(source.codeUnitAt(end))) {
        continue;
      }
      return phrase;
    }
    return null;
  }

  /// Latin letters, which is what the English phrase keys are built from.
  static bool _isLetter(int unit) =>
      (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);

  /// Returns the translation for the active language, or the canonical English
  /// [source] when the language is not one this catalog carries.
  ///
  /// The previous default returned German, so an unsupported locale silently
  /// rendered a German app rather than the source language.
  String _select(_Translation translation, String source) =>
      switch (locale.languageCode) {
        'de' => translation.de,
        'hr' => translation.hr,
        _ => source,
      };
}

/// Phrase table ordered longest key first, built once rather than per call.
final List<MapEntry<String, _Translation>> _phrasesByLength =
    _phrases.entries.toList()..sort(
      (
        MapEntry<String, _Translation> left,
        MapEntry<String, _Translation> right,
      ) => right.key.length.compareTo(left.key.length),
    );

/// Convenient translation for non-Text properties such as tooltips.
extension AppLocalizationContext on BuildContext {
  /// Translates [source] in the current live locale.
  String tr(String source) => AppLocalizations.of(this).text(source);

  /// Translates message [pattern] and fills its `{name}` placeholders.
  String trFormat(String pattern, Map<String, Object?> values) =>
      AppLocalizations.of(this).format(pattern, values);
}

final class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLanguage.values.any(
    (AppLanguage language) => language.code == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

final class _Translation {
  const _Translation(this.de, this.hr);

  final String de;
  final String hr;
}

const Map<String, _Translation> _messages = <String, _Translation>{
  'About': _Translation('Über', 'O aplikaciji'),
  'Activities to apply': _Translation(
    'Anzuwendende Aktivitäten',
    'Aktivnosti za primjenu',
  ),
  'Activity ledger': _Translation('Aktivitätsjournal', 'Dnevnik aktivnosti'),
  'Add holding': _Translation('Position hinzufügen', 'Dodaj poziciju'),
  'Add instrument': _Translation('Wertpapier hinzufügen', 'Dodaj instrument'),
  'Add key': _Translation('Schlüssel hinzufügen', 'Dodaj ključ'),
  'Add to watchlist': _Translation(
    'Zur Watchlist hinzufügen',
    'Dodaj na popis praćenja',
  ),
  'Agenda': _Translation('Agenda', 'Dnevni red'),
  'All events': _Translation('Alle Ereignisse', 'Svi događaji'),
  'All instruments': _Translation('Alle Wertpapiere', 'Svi instrumenti'),
  'All portfolios': _Translation('Alle Portfolios', 'Svi portfelji'),
  'All portfolios (consolidated)': _Translation(
    'Alle Portfolios (konsolidiert)',
    'Svi portfelji (konsolidirano)',
  ),
  'All tracked and displayed amounts are EUR.': _Translation(
    'Alle erfassten und angezeigten Beträge sind in EUR.',
    'Svi praćeni i prikazani iznosi su u EUR.',
  ),
  'Annual': _Translation('Jährlich', 'Godišnje'),
  'Allowance already used': _Translation(
    'Bereits genutzter Freibetrag',
    'Već iskorištena olakšica',
  ),
  'Annual savings allowance': _Translation(
    'Jährlicher Sparerpauschbetrag',
    'Godišnja porezna olakšica',
  ),
  'Annual share': _Translation('Jahresanteil', 'Godišnji udio'),
  'App': _Translation('App', 'Aplikacija'),
  'Appearance': _Translation('Darstellung', 'Izgled'),
  'Apply': _Translation('Anwenden', 'Primijeni'),
  'Assessment': _Translation('Bewertung', 'Procjena'),
  'Available evidence contains material risks.': _Translation(
    'Die verfügbaren Daten enthalten wesentliche Risiken.',
    'Dostupni podaci sadrže značajne rizike.',
  ),
  'Available evidence is broadly strong.': _Translation(
    'Die verfügbaren Daten sind insgesamt stark.',
    'Dostupni podaci uglavnom su snažni.',
  ),
  'Available evidence is mixed.': _Translation(
    'Die verfügbaren Daten sind gemischt.',
    'Dostupni podaci su mješoviti.',
  ),
  'Back': _Translation('Zurück', 'Natrag'),
  'Back to results': _Translation(
    'Zurück zu den Ergebnissen',
    'Natrag na rezultate',
  ),
  'Balance sheet': _Translation('Bilanz', 'Bilanca'),
  'Bear case': _Translation('Negativszenario', 'Negativni scenarij'),
  'Benchmark comparison unavailable: no like-for-like historical benchmark series is configured.':
      _Translation(
        'Benchmark-Vergleich nicht verfügbar: Es ist keine vergleichbare historische Benchmark-Reihe konfiguriert.',
        'Usporedba s referentnim indeksom nije dostupna: nije postavljen usporediv povijesni niz.',
      ),
  'Bull case': _Translation('Positivszenario', 'Pozitivni scenarij'),
  'Bull case and bear case': _Translation(
    'Positiv- und Negativszenario',
    'Pozitivni i negativni scenarij',
  ),
  'Calculating…': _Translation('Berechnung…', 'Izračun…'),
  'Calendar export could not be saved.': _Translation(
    'Der Kalenderexport konnte nicht gespeichert werden.',
    'Izvoz kalendara nije moguće spremiti.',
  ),
  'Calendar': _Translation('Kalender', 'Kalendar'),
  'Cancel': _Translation('Abbrechen', 'Odustani'),
  'Cancelled': _Translation('Abgebrochen', 'Otkazano'),
  'Cash amount': _Translation('Barbetrag', 'Novčani iznos'),
  'Cash-flow detail': _Translation('Cashflow-Details', 'Detalji novčanog toka'),
  'Changes since last refresh': _Translation(
    'Änderungen seit der letzten Aktualisierung',
    'Promjene od zadnjeg osvježavanja',
  ),
  'Choose': _Translation('Auswählen', 'Odaberi'),
  'Choose CSV file': _Translation(
    'CSV-Datei auswählen',
    'Odaberi CSV datoteku',
  ),
  'Church tax': _Translation('Kirchensteuer', 'Crkveni porez'),
  'Clear portfolio': _Translation('Portfolio leeren', 'Isprazni portfelj'),
  'Close': _Translation('Schließen', 'Zatvori'),
  'Completed': _Translation('Abgeschlossen', 'Dovršeno'),
  'Confirmed': _Translation('Bestätigt', 'Potvrđeno'),
  'Connected': _Translation('Verbunden', 'Povezano'),
  'Could not load the saved language. Using English.': _Translation(
    'Die gespeicherte Sprache konnte nicht geladen werden. Englisch wird verwendet.',
    'Spremljeni jezik nije moguće učitati. Koristi se engleski.',
  ),
  'Could not open the original publisher page.': _Translation(
    'Die Originalseite des Herausgebers konnte nicht geöffnet werden.',
    'Izvornu stranicu izdavača nije moguće otvoriti.',
  ),
  'Could not open the original source.': _Translation(
    'Die Originalquelle konnte nicht geöffnet werden.',
    'Izvorni izvor nije moguće otvoriti.',
  ),
  'Countries': _Translation('Länder', 'Države'),
  'Create portfolio': _Translation('Portfolio erstellen', 'Izradi portfelj'),
  'Cumulative income': _Translation('Kumulierte Erträge', 'Kumulativni prihod'),
  'Currencies': _Translation('Währungen', 'Valute'),
  'Currency': _Translation('Währung', 'Valuta'),
  'Currency & exchange rates': _Translation(
    'Währung und Wechselkurse',
    'Valuta i tečajevi',
  ),
  'Currency exposure': _Translation('Währungsrisiko', 'Valutna izloženost'),
  'Current activity': _Translation(
    'Aktuelle Aktivität',
    'Trenutačna aktivnost',
  ),
  'Current portfolio': _Translation(
    'Aktuelles Portfolio',
    'Trenutačni portfelj',
  ),
  'Current watchlist': _Translation(
    'Aktuelle Watchlist',
    'Trenutačni popis praćenja',
  ),
  'Dark': _Translation('Dunkel', 'Tamno'),
  'Data': _Translation('Daten', 'Podaci'),
  'Data sources': _Translation('Datenquellen', 'Izvori podataka'),
  'Data status': _Translation('Datenstatus', 'Stanje podataka'),
  'Day change': _Translation('Tagesänderung', 'Dnevna promjena'),
  'Degraded': _Translation('Beeinträchtigt', 'Otežano'),
  'Delete portfolio': _Translation('Portfolio löschen', 'Izbriši portfelj'),
  'Deposit': _Translation('Einzahlung', 'Uplata'),
  'Disabled': _Translation('Deaktiviert', 'Isključeno'),
  'Display currency': _Translation('Anzeigewährung', 'Valuta prikaza'),
  'Dividend': _Translation('Dividende', 'Dividenda'),
  'Dividend history': _Translation('Dividendenhistorie', 'Povijest dividendi'),
  'Dividend quality': _Translation('Dividendenqualität', 'Kvaliteta dividende'),
  'Dividend tax estimate': _Translation(
    'Dividenden-Steuerschätzung',
    'Procjena poreza na dividendu',
  ),
  'Dividends': _Translation('Dividenden', 'Dividende'),
  'Done': _Translation('Fertig', 'Gotovo'),
  'E Estimated': _Translation('S Geschätzt', 'P Procijenjeno'),
  'Earnings': _Translation('Ergebnisse', 'Poslovni rezultati'),
  'Edit': _Translation('Bearbeiten', 'Uredi'),
  'Estimated': _Translation('Geschätzt', 'Procijenjeno'),
  'Event risk': _Translation('Ereignisrisiko', 'Rizik događaja'),
  'Ex-date': _Translation('Ex-Tag', 'Ex-datum'),
  'Ex-dividend': _Translation('Ex-Dividende', 'Bez dividende'),
  'Expected': _Translation('Erwartet', 'Očekivano'),
  'Expected dividends': _Translation(
    'Erwartete Dividenden',
    'Očekivane dividende',
  ),
  'Export': _Translation('Exportieren', 'Izvezi'),
  'Export calendar': _Translation('Kalender exportieren', 'Izvezi kalendar'),
  'Fee': _Translation('Gebühr', 'Naknada'),
  'Filing': _Translation('Unternehmensmeldung', 'Regulatorna objava'),
  'Forward gross yield': _Translation(
    'Brutto-Terminrendite',
    'Budući bruto prinos',
  ),
  'Free cash flow': _Translation('Freier Cashflow', 'Slobodni novčani tok'),
  'Fri': _Translation('Fr', 'Pet'),
  'Fundamentals': _Translation('Fundamentaldaten', 'Fundamentalni podaci'),
  'General': _Translation('Allgemein', 'Općenito'),
  'Go to Today': _Translation('Zu Heute', 'Idi na Danas'),
  'Gross and net (estimated)': _Translation(
    'Brutto und Netto (geschätzt)',
    'Bruto i neto (procijenjeno)',
  ),
  'Growth': _Translation('Wachstum', 'Rast'),
  'Guidance': _Translation('Prognose', 'Smjernice'),
  'Held gross': _Translation('Gehalten, brutto', 'Držano bruto'),
  'Holdings': _Translation('Positionen', 'Pozicije'),
  'How this was estimated': _Translation(
    'Wie dies geschätzt wurde',
    'Kako je procijenjeno',
  ),
  'Idle': _Translation('Inaktiv', 'Neaktivno'),
  'Import activities': _Translation(
    'Aktivitäten importieren',
    'Uvezi aktivnosti',
  ),
  'Import CSV': _Translation('CSV importieren', 'Uvezi CSV'),
  'Import history': _Translation('Importhistorie', 'Povijest uvoza'),
  'Important only': _Translation('Nur wichtige', 'Samo važno'),
  'Income forecast': _Translation('Ertragsprognose', 'Prognoza prihoda'),
  'Instrument': _Translation('Wertpapier', 'Instrument'),
  'Instrument metadata is unavailable.': _Translation(
    'Wertpapier-Stammdaten sind nicht verfügbar.',
    'Metapodaci instrumenta nisu dostupni.',
  ),
  'Jan': _Translation('Jan', 'Sij'),
  'Feb': _Translation('Feb', 'Velj'),
  'Mar': _Translation('Mär', 'Ožu'),
  'Apr': _Translation('Apr', 'Tra'),
  'May': _Translation('Mai', 'Svi'),
  'Jun': _Translation('Jun', 'Lip'),
  'Jul': _Translation('Jul', 'Srp'),
  'Aug': _Translation('Aug', 'Kol'),
  'Sep': _Translation('Sep', 'Ruj'),
  'Oct': _Translation('Okt', 'Lis'),
  'Nov': _Translation('Nov', 'Stu'),
  'Dec': _Translation('Dez', 'Pro'),
  'Joint': _Translation('Gemeinsam', 'Zajednički'),
  'Language': _Translation('Sprache', 'Jezik'),
  'Language changed, but could not be saved for next time.': _Translation(
    'Die Sprache wurde geändert, konnte aber nicht für den nächsten Start gespeichert werden.',
    'Jezik je promijenjen, ali ga nije moguće spremiti za sljedeće pokretanje.',
  ),
  'Licence': _Translation('Lizenz', 'Licenca'),
  'Light': _Translation('Hell', 'Svijetlo'),
  'Loading…': _Translation('Laden…', 'Učitavanje…'),
  'Manage': _Translation('Verwalten', 'Upravljaj'),
  'Manage portfolios': _Translation(
    'Portfolios verwalten',
    'Upravljaj portfeljima',
  ),
  'Match this device': _Translation(
    'An dieses Gerät anpassen',
    'Uskladi s ovim uređajem',
  ),
  'Mon': _Translation('Mo', 'Pon'),
  'Month': _Translation('Monat', 'Mjesec'),
  'Monthly': _Translation('Monatlich', 'Mjesečno'),
  'Native': _Translation('Originalwährung', 'Izvorno'),
  'Negative': _Translation('Negativ', 'Negativno'),
  'Net (estimated)': _Translation('Netto (geschätzt)', 'Neto (procijenjeno)'),
  'Never': _Translation('Nie', 'Nikad'),
  'New portfolio': _Translation('Neues Portfolio', 'Novi portfelj'),
  'News and filings': _Translation(
    'Nachrichten und Meldungen',
    'Vijesti i objave',
  ),
  'Next': _Translation('Weiter', 'Dalje'),
  'Next 3 days': _Translation('Nächste 3 Tage', 'Sljedeća 3 dana'),
  'No activities recorded yet.': _Translation(
    'Noch keine Aktivitäten erfasst.',
    'Još nema zabilježenih aktivnosti.',
  ),
  'No dividend events': _Translation(
    'Keine Dividendenereignisse',
    'Nema dividendnih događaja',
  ),
  'No holdings yet. Add an instrument to start tracking its value and dividends.':
      _Translation(
        'Noch keine Positionen. Fügen Sie ein Wertpapier hinzu, um Wert und Dividenden zu verfolgen.',
        'Još nema pozicija. Dodajte instrument kako biste pratili vrijednost i dividende.',
      ),
  'No exchange rate needed': _Translation(
    'Kein Wechselkurs erforderlich',
    'Tečaj nije potreban',
  ),
  'No operating-system notifications.': _Translation(
    'Keine Betriebssystem-Benachrichtigungen.',
    'Nema obavijesti operacijskog sustava.',
  ),
  'No payments expected this month.': _Translation(
    'Diesen Monat werden keine Zahlungen erwartet.',
    'Ovaj mjesec nema očekivanih isplata.',
  ),
  'No price yet': _Translation('Noch kein Kurs', 'Još nema cijene'),
  'No priced value': _Translation(
    'Kein bewerteter Betrag',
    'Nema procijenjene vrijednosti',
  ),
  'None': _Translation('Keine', 'Nijedno'),
  'Not available': _Translation('Nicht verfügbar', 'Nije dostupno'),
  'Not confirmed': _Translation('Nicht bestätigt', 'Nije potvrđeno'),
  'Notes (optional)': _Translation(
    'Notizen (optional)',
    'Bilješke (neobavezno)',
  ),
  'Notifications': _Translation('Benachrichtigungen', 'Obavijesti'),
  'Offline': _Translation('Offline', 'Izvan mreže'),
  'On watchlist': _Translation('Auf der Watchlist', 'Na popisu praćenja'),
  'Open': _Translation('Öffnen', 'Otvori'),
  'Opening balance': _Translation('Anfangsbestand', 'Početno stanje'),
  'Overview': _Translation('Übersicht', 'Pregled'),
  'Paid': _Translation('Bezahlt', 'Plaćeno'),
  'Payment': _Translation('Zahlung', 'Isplata'),
  'Payment date': _Translation('Zahlungsdatum', 'Datum isplate'),
  'Payout table': _Translation('Zahlungstabelle', 'Tablica isplata'),
  'Performance': _Translation('Performance', 'Uspješnost'),
  'Personal portfolio': _Translation(
    'Persönliches Portfolio',
    'Osobni portfelj',
  ),
  'Portfolio': _Translation('Portfolio', 'Portfelj'),
  'Portfolio list could not be loaded.': _Translation(
    'Die Portfolioliste konnte nicht geladen werden.',
    'Popis portfelja nije moguće učitati.',
  ),
  'Portfolio today': _Translation('Portfolio heute', 'Portfelj danas'),
  'Portfolio events': _Translation('Portfolioereignisse', 'Događaji portfelja'),
  'Portfolio health': _Translation('Portfoliozustand', 'Zdravlje portfelja'),
  'Positive': _Translation('Positiv', 'Pozitivno'),
  'Previous period': _Translation('Vorheriger Zeitraum', 'Prethodno razdoblje'),
  'Price overview': _Translation('Kursübersicht', 'Pregled cijene'),
  'Profile': _Translation('Profil', 'Profil'),
  'Purchase': _Translation('Kauf', 'Kupnja'),
  'Quality': _Translation('Qualität', 'Kvaliteta'),
  'Quantity': _Translation('Anzahl', 'Količina'),
  'Quarter': _Translation('Quartal', 'Tromjesečje'),
  'Quarterly': _Translation('Quartalsweise', 'Tromjesečno'),
  'Rate limited': _Translation('Rate begrenzt', 'Ograničena učestalost'),
  'Recent activity': _Translation('Letzte Aktivitäten', 'Nedavne aktivnosti'),
  'Record': _Translation('Erfassen', 'Zabilježi'),
  'Record activity': _Translation('Aktivität erfassen', 'Zabilježi aktivnost'),
  'Refresh': _Translation('Aktualisieren', 'Osvježi'),
  'Refresh data': _Translation('Daten aktualisieren', 'Osvježi podatke'),
  'Remove': _Translation('Entfernen', 'Ukloni'),
  'Remove key': _Translation('Schlüssel entfernen', 'Ukloni ključ'),
  'Rename portfolio': _Translation(
    'Portfolio umbenennen',
    'Preimenuj portfelj',
  ),
  'Reported': _Translation('Gemeldet', 'Prijavljeno'),
  'Research': _Translation('Analyse', 'Istraživanje'),
  'Research context only — not a recommendation.': _Translation(
    'Nur Analysekontext – keine Empfehlung.',
    'Samo kontekst istraživanja – nije preporuka.',
  ),
  'Research score': _Translation('Analysebewertung', 'Ocjena istraživanja'),
  'Retry': _Translation('Erneut versuchen', 'Pokušaj ponovno'),
  'Reversal': _Translation('Storno', 'Storno'),
  'Reverse': _Translation('Stornieren', 'Storniraj'),
  'Reverse activity?': _Translation(
    'Aktivität stornieren?',
    'Stornirati aktivnost?',
  ),
  'Review': _Translation('Prüfen', 'Pregledaj'),
  'Sale': _Translation('Verkauf', 'Prodaja'),
  'Sat': _Translation('Sa', 'Sub'),
  'Save': _Translation('Speichern', 'Spremi'),
  'Save securely': _Translation('Sicher speichern', 'Sigurno spremi'),
  'Search': _Translation('Suchen', 'Pretraži'),
  'Search local data and enabled providers.': _Translation(
    'Lokale Daten und aktivierte Anbieter durchsuchen.',
    'Pretraži lokalne podatke i omogućene pružatelje.',
  ),
  'Select one portfolio': _Translation(
    'Ein Portfolio auswählen',
    'Odaberite jedan portfelj',
  ),
  'Settings': _Translation('Einstellungen', 'Postavke'),
  'Simulate investment': _Translation(
    'Investition simulieren',
    'Simuliraj ulaganje',
  ),
  'Single': _Translation('Einzeln', 'Pojedinačno'),
  'Sun': _Translation('So', 'Ned'),
  'System': _Translation('System', 'Sustav'),
  'Tax': _Translation('Steuer', 'Porez'),
  'Tax residence': _Translation('Steuerwohnsitz', 'Porezna rezidentnost'),
  'TTM year over year': _Translation(
    'Letzte zwölf Monate im Jahresvergleich',
    'Posljednjih dvanaest mjeseci u odnosu na prethodnu godinu',
  ),
  'Thu': _Translation('Do', 'Čet'),
  'This month': _Translation('Dieser Monat', 'Ovaj mjesec'),
  'Today': _Translation('Heute', 'Danas'),
  'Today matters': _Translation('Heute wichtig', 'Važno danas'),
  'Total': _Translation('Gesamt', 'Ukupno'),
  'Trailing 12 months': _Translation(
    'Letzte 12 Monate',
    'Posljednjih 12 mjeseci',
  ),
  'Try again': _Translation('Erneut versuchen', 'Pokušaj ponovno'),
  'Tue': _Translation('Di', 'Uto'),
  'Unavailable': _Translation('Nicht verfügbar', 'Nedostupno'),
  'Unconfirmed': _Translation('Unbestätigt', 'Nepotvrđeno'),
  'Undo': _Translation('Rückgängig', 'Poništi'),
  'Undo import': _Translation('Import rückgängig', 'Poništi uvoz'),
  'Unknown': _Translation('Unbekannt', 'Nepoznato'),
  'Unknown instrument': _Translation(
    'Unbekanntes Wertpapier',
    'Nepoznat instrument',
  ),
  'US dividend history, company facts and filings': _Translation(
    'US-Dividendenhistorie, Unternehmensdaten und Meldungen',
    'Povijest američkih dividendi, podaci o tvrtkama i objave',
  ),
  'Daily reference exchange rates': _Translation(
    'Tägliche Referenzwechselkurse',
    'Dnevni referentni tečajevi',
  ),
  'Optional quotes, calendars and fundamentals': _Translation(
    'Optionale Kurse, Kalender und Fundamentaldaten',
    'Neobavezne cijene, kalendari i fundamentalni podaci',
  ),
  'Optional news, calendars and market data': _Translation(
    'Optionale Nachrichten, Kalender und Marktdaten',
    'Neobavezne vijesti, kalendari i tržišni podaci',
  ),
  'Optional fundamentals and market data': _Translation(
    'Optionale Fundamentaldaten und Marktdaten',
    'Neobavezni fundamentalni i tržišni podaci',
  ),
  'Valuation': _Translation('Bewertung', 'Vrednovanje'),
  'Version unavailable': _Translation(
    'Version nicht verfügbar',
    'Verzija nije dostupna',
  ),
  'Watchlist': _Translation('Watchlist', 'Popis praćenja'),
  'Wed': _Translation('Mi', 'Sri'),
  'Weekends': _Translation('Wochenenden', 'Vikendi'),
  'Withdrawal': _Translation('Auszahlung', 'Isplata'),
  'Year': _Translation('Jahr', 'Godina'),
};

const Map<String, _Translation> _longMessages = <String, _Translation>{
  'Baseline saved on this device. Changes will appear after the next data refresh.':
      _Translation(
        'Der Ausgangsstand wurde auf diesem Gerät gespeichert. Änderungen erscheinen nach der nächsten Datenaktualisierung.',
        'Početno stanje spremljeno je na ovom uređaju. Promjene će se prikazati nakon sljedećeg osvježavanja podataka.',
      ),
  'Conditions from the scoring model, not forecasts.': _Translation(
    'Bedingungen aus dem Bewertungsmodell, keine Prognosen.',
    'Uvjeti iz modela ocjenjivanja, a ne prognoze.',
  ),
  'Consolidated is a read-only combined view. Select one portfolio to add, edit, remove, record or import data. Tax estimates are not combined across portfolio boundaries.':
      _Translation(
        'Die konsolidierte Ansicht ist schreibgeschützt. Wählen Sie ein Portfolio, um Daten hinzuzufügen, zu bearbeiten, zu entfernen, zu erfassen oder zu importieren. Steuerschätzungen werden nicht portfolioübergreifend zusammengeführt.',
        'Konsolidirani prikaz namijenjen je samo čitanju. Odaberite jedan portfelj za dodavanje, uređivanje, uklanjanje, bilježenje ili uvoz podataka. Porezne procjene ne spajaju se između portfelja.',
      ),
  'Controls the default savings allowance': _Translation(
    'Steuert den standardmäßigen Sparerpauschbetrag',
    'Određuje zadanu poreznu olakšicu',
  ),
  'Could not update the local comparison. Current portfolio and dividend data remain available above.':
      _Translation(
        'Der lokale Vergleich konnte nicht aktualisiert werden. Die aktuellen Portfolio- und Dividendendaten bleiben oben verfügbar.',
        'Lokalnu usporedbu nije moguće ažurirati. Trenutačni podaci o portfelju i dividendama ostaju dostupni iznad.',
      ),
  'Disabled, important-only or all factual portfolio events': _Translation(
    'Deaktiviert, nur wichtige oder alle sachlichen Portfolioereignisse',
    'Isključeno, samo važno ili svi činjenični događaji portfelja',
  ),
  'Display currency, ECB rate dates, sources and staleness': _Translation(
    'Anzeigewährung, EZB-Kursdaten, Quellen und Aktualität',
    'Valuta prikaza, datumi tečaja ESB-a, izvori i zastarjelost',
  ),
  'Duplicates are skipped using stable imported row identities.': _Translation(
    'Duplikate werden anhand stabiler Identitäten importierter Zeilen übersprungen.',
    'Duplikati se preskaču pomoću stabilnih identiteta uvezenih redaka.',
  ),
  'Each portfolio keeps its own holdings, watchlist and immutable activity history. Clearing or deleting is never automatic.':
      _Translation(
        'Jedes Portfolio behält eigene Positionen, eine eigene Watchlist und eine unveränderliche Aktivitätshistorie. Leeren oder Löschen erfolgt nie automatisch.',
        'Svaki portfelj zadržava vlastite pozicije, popis praćenja i nepromjenjivu povijest aktivnosti. Pražnjenje ili brisanje nikad nije automatsko.',
      ),
  'Estimate only—not tax advice or broker reconciliation. The model currently supports German tax residence and individual shares.':
      _Translation(
        'Nur eine Schätzung – keine Steuerberatung oder Brokerabstimmung. Das Modell unterstützt derzeit den deutschen Steuerwohnsitz und Einzelaktien.',
        'Samo procjena – nije porezni savjet ni usklađivanje s brokerom. Model trenutačno podržava njemačku poreznu rezidentnost i pojedinačne dionice.',
      ),
  'Evidence summaries, not predictions or instructions.': _Translation(
    'Zusammenfassungen der Daten, keine Vorhersagen oder Anweisungen.',
    'Sažeci podataka, a ne predviđanja ili upute.',
  ),
  'Expected is gross provider data using the shares held on each payment date. Actual is gross dividend cash entered or imported.':
      _Translation(
        'Erwartet sind Bruttodaten des Anbieters mit den am jeweiligen Zahlungstag gehaltenen Anteilen. Tatsächlich ist der erfasste oder importierte Brutto-Dividendenbetrag.',
        'Očekivano su bruto podaci pružatelja prema broju dionica na svaki datum isplate. Stvarno je uneseni ili uvezeni bruto novčani iznos dividende.',
      ),
  'Headlines and source links only. Articles and filings remain with their publishers.':
      _Translation(
        'Nur Überschriften und Quellenlinks. Artikel und Meldungen verbleiben bei ihren Herausgebern.',
        'Samo naslovi i poveznice na izvore. Članci i objave ostaju kod izdavača.',
      ),
  'Loading cached portfolio values…': _Translation(
    'Gespeicherte Portfoliowerte werden geladen…',
    'Učitavanje spremljenih vrijednosti portfelja…',
  ),
  'Native amounts stay visible; this controls converted totals.': _Translation(
    'Beträge in Originalwährung bleiben sichtbar; dies steuert die umgerechneten Summen.',
    'Izvorni iznosi ostaju vidljivi; ovo određuje preračunate ukupne iznose.',
  ),
  'Native columns: Date, Type, Symbol or ISIN, Quantity, Unit Price, Amount, Currency, Fees, Taxes, External ID, Notes. Portfolio Performance transactions and Interactive Brokers Flex exports are detected automatically.':
      _Translation(
        'Native Spalten: Datum, Typ, Symbol oder ISIN, Anzahl, Stückpreis, Betrag, Währung, Gebühren, Steuern, externe ID, Notizen. Transaktionen aus Portfolio Performance und Interactive-Brokers-Flex-Exporte werden automatisch erkannt.',
        'Izvorni stupci: datum, vrsta, simbol ili ISIN, količina, jedinična cijena, iznos, valuta, naknade, porezi, vanjski ID, bilješke. Transakcije iz Portfolio Performancea i Interactive Brokers Flex izvozi prepoznaju se automatski.',
      ),
  'Needs dated EUR FX': _Translation(
    'Benötigt datierten EUR-Wechselkurs',
    'Potreban je datirani tečaj za EUR',
  ),
  'Net (estimated) calculating…': _Translation(
    'Netto (geschätzt) wird berechnet…',
    'Izračun neto iznosa (procjena)…',
  ),
  'No cached quotes. Holdings and the dividend schedule below still work offline.':
      _Translation(
        'Keine gespeicherten Kurse. Positionen und der Dividendenplan unten funktionieren weiterhin offline.',
        'Nema spremljenih cijena. Pozicije i raspored dividendi u nastavku i dalje rade izvan mreže.',
      ),
  'No cached rate. Refresh when online.': _Translation(
    'Kein gespeicherter Kurs. Aktualisieren Sie bei bestehender Internetverbindung.',
    'Nema spremljenog tečaja. Osvježite kada ste povezani.',
  ),
  'No dividend events on this day.': _Translation(
    'An diesem Tag gibt es keine Dividendenereignisse.',
    'Na ovaj dan nema dividendnih događaja.',
  ),
  'No earnings or company events are currently known.': _Translation(
    'Derzeit sind keine Ergebnis- oder Unternehmensereignisse bekannt.',
    'Trenutačno nema poznatih objava rezultata ni događaja tvrtke.',
  ),
  'No projected income to chart.': _Translation(
    'Keine prognostizierten Erträge für das Diagramm.',
    'Nema prognoziranog prihoda za grafikon.',
  ),
  'No relevant portfolio events or headlines are cached.': _Translation(
    'Keine relevanten Portfolioereignisse oder Überschriften gespeichert.',
    'Nema spremljenih relevantnih događaja portfelja ni naslova.',
  ),
  'Not enough cached evidence': _Translation(
    'Nicht genügend gespeicherte Daten',
    'Nema dovoljno spremljenih podataka',
  ),
  'Notifications describe scheduled events. They never tell you to buy, sell or act urgently.':
      _Translation(
        'Benachrichtigungen beschreiben geplante Ereignisse. Sie fordern niemals zum Kaufen, Verkaufen oder dringenden Handeln auf.',
        'Obavijesti opisuju planirane događaje. Nikad vas ne upućuju na kupnju, prodaju ili hitno djelovanje.',
      ),
  'One EUR equals the shown amount. Conversion uses the newest rate on or before the valuation date; rates older than 7 days are stale.':
      _Translation(
        'Ein EUR entspricht dem angezeigten Betrag. Die Umrechnung verwendet den neuesten Kurs am oder vor dem Bewertungstag; Kurse über 7 Tage gelten als veraltet.',
        'Jedan EUR odgovara prikazanom iznosu. Preračun koristi najnoviji tečaj na datum vrednovanja ili prije njega; tečajevi stariji od 7 dana smatraju se zastarjelima.',
      ),
  'Per-portfolio gross/net assumptions, allowance and withholding': _Translation(
    'Portfolioeigene Brutto-/Netto-Annahmen, Freibetrag und Quellensteuer',
    'Bruto/neto pretpostavke, olakšica i porez po odbitku za svaki portfelj',
  ),
  'Previous-close change unavailable': _Translation(
    'Änderung zum Vortag nicht verfügbar',
    'Promjena u odnosu na prethodno zatvaranje nije dostupna',
  ),
  'Purchases · sales · dividends · taxes · fees · net invested': _Translation(
    'Käufe · Verkäufe · Dividenden · Steuern · Gebühren · netto investiert',
    'Kupnje · prodaje · dividende · porezi · naknade · neto uloženo',
  ),
  'Purchases, sales and actual cash flows stay on this device. Corrections append reversals; history is never silently rewritten.':
      _Translation(
        'Käufe, Verkäufe und tatsächliche Cashflows bleiben auf diesem Gerät. Korrekturen fügen Stornos hinzu; die Historie wird nie unbemerkt überschrieben.',
        'Kupnje, prodaje i stvarni novčani tokovi ostaju na ovom uređaju. Ispravci dodaju storna; povijest se nikad potajno ne prepisuje.',
      ),
  'Record a valued purchase or cache a position quote to start performance coverage.':
      _Translation(
        'Erfassen Sie einen bewerteten Kauf oder speichern Sie einen Positionskurs, um die Performance-Abdeckung zu starten.',
        'Zabilježite kupnju s vrijednošću ili spremite cijenu pozicije kako biste započeli praćenje uspješnosti.',
      ),
  'Reversal rows will be appended for every activity in the batch. The audit trail remains intact.':
      _Translation(
        'Für jede Aktivität im Stapel werden Stornozeilen angefügt. Die Prüfspur bleibt erhalten.',
        'Za svaku aktivnost u skupu dodat će se redak storna. Revizijski trag ostaje sačuvan.',
      ),
  'Security-only total return. Purchases and opening balances are capital in; sales and actual dividends are capital out; taxes and fees are costs. Cash deposits and withdrawals are shown but excluded because this app does not value a cash balance.':
      _Translation(
        'Gesamtrendite nur für Wertpapiere. Käufe und Anfangsbestände sind Kapitalzuflüsse; Verkäufe und tatsächliche Dividenden Kapitalabflüsse; Steuern und Gebühren sind Kosten. Ein- und Auszahlungen werden angezeigt, aber ausgeschlossen, da die App keinen Barbestand bewertet.',
        'Ukupni prinos samo za vrijednosne papire. Kupnje i početna stanja ulaz su kapitala; prodaje i stvarne dividende izlaz; porezi i naknade troškovi su. Uplate i isplate prikazuju se, ali su isključene jer aplikacija ne vrednuje novčani saldo.',
      ),
  'Some event sources are unavailable. Cached events remain visible below.':
      _Translation(
        'Einige Ereignisquellen sind nicht verfügbar. Gespeicherte Ereignisse bleiben unten sichtbar.',
        'Neki izvori događaja nisu dostupni. Spremljeni događaji ostaju vidljivi u nastavku.',
      ),
  'Some saved data is unavailable': _Translation(
    'Einige gespeicherte Daten sind nicht verfügbar',
    'Neki spremljeni podaci nisu dostupni',
  ),
  'Some sources could not be refreshed. Cached items remain visible below.':
      _Translation(
        'Einige Quellen konnten nicht aktualisiert werden. Gespeicherte Einträge bleiben unten sichtbar.',
        'Neke izvore nije moguće osvježiti. Spremljene stavke ostaju vidljive u nastavku.',
      ),
  'The app works without an API key. Optional keys are stored only on this device.':
      _Translation(
        'Die App funktioniert ohne API-Schlüssel. Optionale Schlüssel werden nur auf diesem Gerät gespeichert.',
        'Aplikacija radi bez API ključa. Neobavezni ključevi spremaju se samo na ovom uređaju.',
      ),
  'The file is read locally and is never uploaded or retained. Nothing changes until you review this preview and choose Apply.':
      _Translation(
        'Die Datei wird lokal gelesen und weder hochgeladen noch aufbewahrt. Es ändert sich nichts, bis Sie diese Vorschau geprüft und Anwenden gewählt haben.',
        'Datoteka se čita lokalno i nikad se ne prenosi ni zadržava. Ništa se ne mijenja dok ne pregledate ovaj prikaz i odaberete Primijeni.',
      ),
  'The original row remains in the audit trail. A reversal will be added and its economic effect removed.':
      _Translation(
        'Die ursprüngliche Zeile bleibt in der Prüfspur. Ein Storno wird hinzugefügt und ihre wirtschaftliche Wirkung aufgehoben.',
        'Izvorni redak ostaje u revizijskom tragu. Dodat će se storno i ukloniti njegov ekonomski učinak.',
      ),
  'The provider will be disabled. You can add a new key later.': _Translation(
    'Der Anbieter wird deaktiviert. Sie können später einen neuen Schlüssel hinzufügen.',
    'Pružatelj će biti isključen. Novi ključ možete dodati poslije.',
  ),
  'Undo this import?': _Translation(
    'Diesen Import rückgängig machen?',
    'Poništiti ovaj uvoz?',
  ),
};

const Map<String, _Translation> _formMessages = <String, _Translation>{
  'Activity type': _Translation('Aktivitätstyp', 'Vrsta aktivnosti'),
  'API key': _Translation('API-Schlüssel', 'API ključ'),
  'Average purchase price (optional)': _Translation(
    'Durchschnittlicher Kaufpreis (optional)',
    'Prosječna kupovna cijena (neobavezno)',
  ),
  'Clear purchase date': _Translation(
    'Kaufdatum löschen',
    'Izbriši datum kupnje',
  ),
  'Enter 0 or a positive amount': _Translation(
    'Geben Sie 0 oder einen positiven Betrag ein',
    'Unesite 0 ili pozitivan iznos',
  ),
  'Enter an amount greater than zero.': _Translation(
    'Geben Sie einen Betrag größer als null ein.',
    'Unesite iznos veći od nule.',
  ),
  'Fractional shares are supported.': _Translation(
    'Bruchteile von Anteilen werden unterstützt.',
    'Podržane su djelomične dionice.',
  ),
  'Hide API key': _Translation('API-Schlüssel ausblenden', 'Sakrij API ključ'),
  'Loading company events': _Translation(
    'Unternehmensereignisse werden geladen',
    'Učitavanje događaja tvrtke',
  ),
  'Loading data-source settings': _Translation(
    'Datenquellen-Einstellungen werden geladen',
    'Učitavanje postavki izvora podataka',
  ),
  'Loading dividend history': _Translation(
    'Dividendenhistorie wird geladen',
    'Učitavanje povijesti dividendi',
  ),
  'Loading events': _Translation(
    'Ereignisse werden geladen',
    'Učitavanje događaja',
  ),
  'Loading first-run settings': _Translation(
    'Ersteinrichtungs-Einstellungen werden geladen',
    'Učitavanje početnih postavki',
  ),
  'Loading news and filings': _Translation(
    'Nachrichten und Meldungen werden geladen',
    'Učitavanje vijesti i objava',
  ),
  'Loading price': _Translation('Kurs wird geladen', 'Učitavanje cijene'),
  'Loading saved data': _Translation(
    'Gespeicherte Daten werden geladen',
    'Učitavanje spremljenih podataka',
  ),
  'Loading score history': _Translation(
    'Bewertungshistorie wird geladen',
    'Učitavanje povijesti ocjena',
  ),
  'Next period': _Translation('Nächster Zeitraum', 'Sljedeće razdoblje'),
  'Open filing source': _Translation(
    'Quelle der Meldung öffnen',
    'Otvori izvor objave',
  ),
  'Open original': _Translation('Original öffnen', 'Otvori izvornik'),
  'Open research details': _Translation(
    'Analysedetails öffnen',
    'Otvori detalje istraživanja',
  ),
  'Portfolio name': _Translation('Portfolioname', 'Naziv portfelja'),
  'Price per share (optional)': _Translation(
    'Preis je Anteil (optional)',
    'Cijena po dionici (neobavezno)',
  ),
  'Refresh ECB exchange rates': _Translation(
    'EZB-Wechselkurse aktualisieren',
    'Osvježi tečajeve ESB-a',
  ),
  'Remove from watchlist': _Translation(
    'Von der Watchlist entfernen',
    'Ukloni s popisa praćenja',
  ),
  'Reverse activity': _Translation(
    'Aktivität stornieren',
    'Storniraj aktivnost',
  ),
  'Saving language': _Translation(
    'Sprache wird gespeichert',
    'Spremanje jezika',
  ),
  'Saving notification settings': _Translation(
    'Benachrichtigungseinstellungen werden gespeichert',
    'Spremanje postavki obavijesti',
  ),
  'Saving theme': _Translation('Design wird gespeichert', 'Spremanje teme'),
  'Show API key': _Translation('API-Schlüssel anzeigen', 'Prikaži API ključ'),
  'Showing': _Translation('Anzeige', 'Prikaz'),
  'Symbol, company name or ISIN': _Translation(
    'Symbol, Unternehmensname oder ISIN',
    'Simbol, naziv tvrtke ili ISIN',
  ),
};

const Map<String, _Translation> _onboardingMessages = <String, _Translation>{
  'Your portfolio stays on this device': _Translation(
    'Ihr Portfolio bleibt auf diesem Gerät',
    'Vaš portfelj ostaje na ovom uređaju',
  ),
  'DividendenDackel reads from a local database first. Saved holdings, calendar events, forecasts and research remain useful offline.':
      _Translation(
        'DividendenDackel liest zuerst aus einer lokalen Datenbank. Gespeicherte Positionen, Kalenderereignisse, Prognosen und Analysen bleiben offline nutzbar.',
        'DividendenDackel najprije čita lokalnu bazu podataka. Spremljene pozicije, kalendarski događaji, prognoze i istraživanja ostaju korisni izvan mreže.',
      ),
  'Follow only what matters to you': _Translation(
    'Verfolgen Sie nur, was Ihnen wichtig ist',
    'Pratite samo ono što vam je važno',
  ),
  'Add shares you own or place companies on the watchlist from Portfolio. Today and Calendar then focus on those instruments.':
      _Translation(
        'Fügen Sie eigene Aktien hinzu oder setzen Sie Unternehmen im Portfolio auf die Watchlist. Heute und Kalender konzentrieren sich dann auf diese Wertpapiere.',
        'Dodajte dionice koje posjedujete ili stavite tvrtke na popis praćenja iz Portfelja. Danas i Kalendar zatim se usredotočuju na te instrumente.',
      ),
  'Facts keep their context': _Translation(
    'Fakten behalten ihren Kontext',
    'Činjenice zadržavaju svoj kontekst',
  ),
  'Sources and “Last updated” ages stay visible. Confirmed and estimated dividends are labelled separately, and every forecast is a scenario—not a promise.':
      _Translation(
        'Quellen und das Alter „Zuletzt aktualisiert“ bleiben sichtbar. Bestätigte und geschätzte Dividenden sind getrennt gekennzeichnet, und jede Prognose ist ein Szenario – kein Versprechen.',
        'Izvori i vrijeme „Zadnje ažuriranje” ostaju vidljivi. Potvrđene i procijenjene dividende označene su zasebno, a svaka prognoza je scenarij, a ne obećanje.',
      ),
  'Could not save completion. Try again.': _Translation(
    'Der Abschluss konnte nicht gespeichert werden. Versuchen Sie es erneut.',
    'Dovršetak nije moguće spremiti. Pokušajte ponovno.',
  ),
};

/// Ordered phrase fragments cover interpolated amounts, names and counts.
/// Screen copy that had no entry, so it rendered English in a translated app.
const Map<String, _Translation> _screenMessages = <String, _Translation>{
  'Author': _Translation('Autor', 'Autor'),
  'Finished and merged, not yet in a published build.': _Translation(
    'Fertiggestellt und übernommen, aber noch nicht in einer veröffentlichten Version.',
    'Dovršeno i uključeno, ali još nije u objavljenoj verziji.',
  ),
  'GNU General Public License v3.0 or later (GPL-3.0-or-later). The source code is available, and you may use, study, share and modify it under those terms.':
      _Translation(
        'GNU General Public License v3.0 oder höher (GPL-3.0-or-later). Der Quelltext ist verfügbar, und Sie dürfen ihn zu diesen Bedingungen verwenden, untersuchen, weitergeben und verändern.',
        'GNU General Public License v3.0 ili novija (GPL-3.0-or-later). Izvorni kod je dostupan te ga smijete koristiti, proučavati, dijeliti i mijenjati pod tim uvjetima.',
      ),
  'Ideas for features and reports of anything wrong are genuinely wanted — a mistaken number matters most of all. Write to the author, or open an issue in the project repository.':
      _Translation(
        'Ideen für Funktionen und Hinweise auf Fehler sind ausdrücklich willkommen — eine falsche Zahl zählt dabei am meisten. Schreiben Sie dem Autor oder eröffnen Sie ein Issue im Projekt-Repository.',
        'Ideje za značajke i prijave pogrešaka izričito su dobrodošle — pogrešan broj je najvažniji od svega. Pišite autoru ili otvorite prijavu u repozitoriju projekta.',
      ),
  'In development': _Translation('In Entwicklung', 'U razvoju'),
  'No release notes are available.': _Translation(
    'Es sind keine Versionshinweise verfügbar.',
    'Nema dostupnih bilješki o izdanju.',
  ),
  'Release notes': _Translation('Versionshinweise', 'Bilješke o izdanju'),
  'Report a problem or request a feature': _Translation(
    'Problem melden oder Funktion vorschlagen',
    'Prijavi problem ili predloži značajku',
  ),
  'This app is being built in the open and changes often. Features are still arriving and rough edges are expected.':
      _Translation(
        'Diese App entsteht offen und ändert sich häufig. Es kommen noch Funktionen hinzu, und Ecken und Kanten sind zu erwarten.',
        'Ova se aplikacija razvija javno i često se mijenja. Značajke još pristižu, a grube rubove treba očekivati.',
      ),
  'Under active development': _Translation(
    'Wird aktiv weiterentwickelt',
    'U aktivnom razvoju',
  ),
  'What changed': _Translation('Was sich geändert hat', 'Što se promijenilo'),
  'No matching instrument found. Search covers the bundled reference list and any instrument already saved on this device. Listings outside it need a data source that can look them up.':
      _Translation(
        'Kein passendes Wertpapier gefunden. Die Suche umfasst die mitgelieferte Referenzliste und alle bereits auf diesem Gerät gespeicherten Wertpapiere. Andere Notierungen benötigen eine Datenquelle, die sie nachschlagen kann.',
        'Nije pronađen odgovarajući instrument. Pretraga obuhvaća priloženi referentni popis i sve instrumente već spremljene na ovom uređaju. Ostale kotacije zahtijevaju izvor podataka koji ih može pronaći.',
      ),
  'Active requests': _Translation('Aktive Anfragen', 'Aktivni zahtjevi'),
  'Add a holding to see portfolio value, day change, allocation, yield and the next dividend.':
      _Translation(
        'Fügen Sie eine Position hinzu, um Portfoliowert, Tagesveränderung, Anteil, Rendite und die nächste Dividende zu sehen.',
        'Dodajte poziciju kako biste vidjeli vrijednost portfelja, dnevnu promjenu, udio, prinos i sljedeću dividendu.',
      ),
  'Added annual gross dividend': _Translation(
    'Zusätzliche jährliche Bruttodividende',
    'Dodana godišnja bruto dividenda',
  ),
  'Additional fractional shares': _Translation(
    'Zusätzliche Bruchteilsaktien',
    'Dodatni djelomični udjeli',
  ),
  'Also ex-dates, tomorrow’s earnings and company events.': _Translation(
    'Außerdem Ex-Tage, morgige Ergebnisse und Unternehmensereignisse.',
    'Također ex-datumi, sutrašnji rezultati i korporativni događaji.',
  ),
  'Android asks for notification permission only after you enable a mode. Linux desktop notification servers cannot schedule in the background, so due events are reconciled when the app starts, resumes or refreshes. The operating system may still suppress delivery.':
      _Translation(
        'Android fragt die Benachrichtigungsberechtigung erst ab, wenn Sie einen Modus aktivieren. Linux-Desktop-Benachrichtigungsdienste können nicht im Hintergrund planen, daher werden fällige Ereignisse beim Start, bei der Rückkehr oder beim Aktualisieren abgeglichen. Das Betriebssystem kann die Zustellung dennoch unterdrücken.',
        'Android traži dopuštenje za obavijesti tek nakon što uključite način rada. Linux poslužitelji obavijesti ne mogu zakazivati u pozadini, pa se dospjeli događaji usklađuju pri pokretanju, nastavku ili osvježavanju aplikacije. Operacijski sustav ipak može spriječiti isporuku.',
      ),
  'Average added gross per month': _Translation(
    'Durchschnittlicher Bruttozuwachs pro Monat',
    'Prosječni bruto dodatak mjesečno',
  ),
  'CSV transactions': _Translation('CSV-Transaktionen', 'CSV transakcije'),
  'Cache hit rate': _Translation(
    'Cache-Trefferquote',
    'Stopa pogodaka predmemorije',
  ),
  'Cached quotes are needed before value concentration can be calculated.':
      _Translation(
        'Für die Berechnung der Wertkonzentration werden gespeicherte Kurse benötigt.',
        'Za izračun koncentracije vrijednosti potrebne su spremljene cijene.',
      ),
  'Comparing refresh changes': _Translation(
    'Änderungen der Aktualisierung werden verglichen',
    'Uspoređivanje promjena osvježavanja',
  ),
  'Computing research score': _Translation(
    'Analysewert wird berechnet',
    'Izračun ocjene analize',
  ),
  'Converted portfolio value': _Translation(
    'Umgerechneter Portfoliowert',
    'Preračunata vrijednost portfelja',
  ),
  'Converted value is partial because at least one holding has no cached quote.':
      _Translation(
        'Der umgerechnete Wert ist unvollständig, weil mindestens eine Position keinen gespeicherten Kurs hat.',
        'Preračunata vrijednost je djelomična jer barem jedna pozicija nema spremljenu cijenu.',
      ),
  'Currently showing the bundled sample dataset. It is illustrative and is not real market data.':
      _Translation(
        'Derzeit wird der mitgelieferte Beispieldatensatz angezeigt. Er dient der Veranschaulichung und ist keine echte Marktdatenquelle.',
        'Trenutačno je prikazan priloženi skup uzoraka. Služi za ilustraciju i nije stvarni tržišni podatak.',
      ),
  'Data unavailable': _Translation(
    'Daten nicht verfügbar',
    'Podaci nisu dostupni',
  ),
  'Dividend payment expected today': _Translation(
    'Dividendenzahlung heute erwartet',
    'Isplata dividende očekuje se danas',
  ),
  'DividendenDackel': _Translation('DividendenDackel', 'DividendenDackel'),
  'ECB reference rates': _Translation(
    'EZB-Referenzkurse',
    'Referentni tečajevi ESB-a',
  ),
  'Edit a country to override its rates. Treaty paperwork and broker handling cannot be detected automatically.':
      _Translation(
        'Bearbeiten Sie ein Land, um dessen Sätze zu überschreiben. Abkommensunterlagen und die Handhabung durch den Broker können nicht automatisch erkannt werden.',
        'Uredite državu kako biste promijenili njezine stope. Dokumentacija ugovora i postupanje brokera ne mogu se automatski prepoznati.',
      ),
  'Estimate—not tax advice.': _Translation(
    'Schätzung – keine Steuerberatung.',
    'Procjena – nije porezni savjet.',
  ),
  'Ex-dividend date tomorrow': _Translation(
    'Ex-Dividenden-Tag morgen',
    'Ex-dividendni datum sutra',
  ),
  'Expected dividend income': _Translation(
    'Erwartete Dividendenerträge',
    'Očekivani prihod od dividendi',
  ),
  'Expected vs actually recorded this year': _Translation(
    'Erwartet gegenüber tatsächlich erfasst in diesem Jahr',
    'Očekivano u odnosu na stvarno zabilježeno ove godine',
  ),
  'GPLv3 or later.': _Translation('GPLv3 oder höher.', 'GPLv3 ili novija.'),
  'Germany': _Translation('Deutschland', 'Njemačka'),
  'Gross and estimated net are never combined. Forecast events are included and marked. Estimate—not tax advice.':
      _Translation(
        'Brutto und geschätztes Netto werden nie vermischt. Prognostizierte Ereignisse sind enthalten und gekennzeichnet. Schätzung – keine Steuerberatung.',
        'Bruto i procijenjeni neto nikada se ne miješaju. Prognozirani događaji uključeni su i označeni. Procjena – nije porezni savjet.',
      ),
  'Gross and estimated-net income using today’s holding quantities. Estimates are rule-based, not guaranteed. “Paid” means the confirmed payment date has passed; actual cash entered or imported in the activity ledger is reconciled separately on Portfolio.':
      _Translation(
        'Brutto- und geschätzte Nettoerträge auf Basis der heutigen Positionsmengen. Schätzungen sind regelbasiert und nicht garantiert. „Gezahlt“ bedeutet, dass das bestätigte Zahlungsdatum vergangen ist; tatsächlich im Aktivitätsjournal erfasste oder importierte Beträge werden separat im Portfolio abgeglichen.',
        'Bruto i procijenjeni neto prihod prema današnjim količinama pozicija. Procjene se temelje na pravilima i nisu zajamčene. „Isplaćeno“ znači da je potvrđeni datum isplate prošao; stvarni iznosi uneseni ili uvezeni u dnevnik aktivnosti usklađuju se zasebno u Portfelju.',
      ),
  'Keyless sources work without setup. Optional provider keys stay in this device\'s secure credential store and are never bundled with the app.':
      _Translation(
        'Schlüssellose Quellen funktionieren ohne Einrichtung. Optionale Anbieterschlüssel verbleiben im sicheren Anmeldedatenspeicher dieses Geräts und werden nie mit der App ausgeliefert.',
        'Izvori bez ključa rade bez postavljanja. Neobavezni ključevi pružatelja ostaju u sigurnoj pohrani vjerodajnica ovog uređaja i nikada se ne isporučuju s aplikacijom.',
      ),
  'Last request': _Translation('Letzte Anfrage', 'Zadnji zahtjev'),
  'Live health and locally retained request statistics. Portfolio values and credentials are never included.':
      _Translation(
        'Aktueller Zustand und lokal gespeicherte Anfragestatistiken. Portfoliowerte und Anmeldedaten sind nie enthalten.',
        'Trenutačno stanje i lokalno spremljena statistika zahtjeva. Vrijednosti portfelja i vjerodajnice nikada nisu uključene.',
      ),
  'Native totals remain above. Converted figures use exact cached daily rates and are rounded only for display.':
      _Translation(
        'Die Summen in Ursprungswährung stehen oben. Umgerechnete Zahlen verwenden exakte gespeicherte Tageskurse und werden nur für die Anzeige gerundet.',
        'Ukupni iznosi u izvornoj valuti su iznad. Preračunate brojke koriste točne spremljene dnevne tečajeve i zaokružuju se samo za prikaz.',
      ),
  'Net figures are estimates, not tax advice. Payments without dated EUR FX or source-country data remain explicitly unavailable.':
      _Translation(
        'Nettozahlen sind Schätzungen, keine Steuerberatung. Zahlungen ohne datierten EUR-Wechselkurs oder Quellenlanddaten bleiben ausdrücklich nicht verfügbar.',
        'Neto brojke su procjene, a ne porezni savjet. Isplate bez datiranog EUR tečaja ili podataka o državi izvora ostaju izrijekom nedostupne.',
      ),
  'New forward gross yield': _Translation(
    'Neue erwartete Bruttorendite',
    'Novi očekivani bruto prinos',
  ),
  'Next 365 days': _Translation('Nächste 365 Tage', 'Sljedećih 365 dana'),
  'Next 365 days gross': _Translation(
    'Nächste 365 Tage brutto',
    'Sljedećih 365 dana bruto',
  ),
  'Next dividend not known yet.': _Translation(
    'Nächste Dividende noch nicht bekannt.',
    'Sljedeća dividenda još nije poznata.',
  ),
  'No held payments': _Translation(
    'Keine Zahlungen aus Beständen',
    'Nema isplata iz pozicija',
  ),
  'No watchlist entries yet.': _Translation(
    'Noch keine Watchlist-Einträge.',
    'Još nema stavki na popisu praćenja.',
  ),
  'Open month': _Translation('Monat öffnen', 'Otvori mjesec'),
  'Payments and earnings today, plus material filings.': _Translation(
    'Zahlungen und Ergebnisse heute, dazu wesentliche Meldungen.',
    'Isplate i rezultati danas, uz značajne prijave.',
  ),
  'Portfolio scope': _Translation('Portfolio-Auswahl', 'Opseg portfelja'),
  'Positions': _Translation('Positionen', 'Pozicije'),
  'Provider availability and licensing are documented before an adapter is enabled. Sample data remains available offline.':
      _Translation(
        'Verfügbarkeit und Lizenzbedingungen eines Anbieters werden dokumentiert, bevor ein Adapter aktiviert wird. Beispieldaten bleiben offline verfügbar.',
        'Dostupnost i licenciranje pružatelja dokumentiraju se prije uključivanja adaptera. Uzorci podataka ostaju dostupni izvan mreže.',
      ),
  'Rejected rows': _Translation('Abgelehnte Zeilen', 'Odbijeni redci'),
  'Remove holding?': _Translation('Position entfernen?', 'Ukloniti poziciju?'),
  'Remove watchlist entry?': _Translation(
    'Watchlist-Eintrag entfernen?',
    'Ukloniti stavku s popisa praćenja?',
  ),
  'Research-score history': _Translation(
    'Verlauf des Analysewerts',
    'Povijest ocjene analize',
  ),
  'Sample data': _Translation('Beispieldaten', 'Uzorci podataka'),
  'Saved exchange-rate data could not be read. Native amounts remain available; converted values are unavailable.':
      _Translation(
        'Gespeicherte Wechselkursdaten konnten nicht gelesen werden. Beträge in Ursprungswährung bleiben verfügbar; umgerechnete Werte sind nicht verfügbar.',
        'Spremljeni podaci o tečaju nisu se mogli pročitati. Iznosi u izvornoj valuti ostaju dostupni; preračunate vrijednosti nisu dostupne.',
      ),
  'Scenario only—not a recommendation. Fractional shares are shown; broker rules, fees, taxes, price movement and dividend changes are not modelled.':
      _Translation(
        'Nur ein Szenario – keine Empfehlung. Bruchteilsaktien werden angezeigt; Broker-Regeln, Gebühren, Steuern, Kursbewegungen und Dividendenänderungen sind nicht modelliert.',
        'Samo scenarij – nije preporuka. Prikazani su djelomični udjeli; pravila brokera, naknade, porezi, kretanje cijena i promjene dividendi nisu modelirani.',
      ),
  'Scope': _Translation('Bereich', 'Opseg'),
  'Sectors': _Translation('Sektoren', 'Sektori'),
  'Select one portfolio before editing tax assumptions. Tax allowances and estimated net income are never combined across portfolio boundaries.':
      _Translation(
        'Wählen Sie ein Portfolio, bevor Sie Steuerannahmen bearbeiten. Freibeträge und geschätzte Nettoerträge werden nie portfolioübergreifend zusammengeführt.',
        'Odaberite jedan portfelj prije uređivanja poreznih pretpostavki. Porezni odbici i procijenjeni neto prihod nikada se ne spajaju između portfelja.',
      ),
  'Some saved portfolio details are unavailable. Calendar events that could be read remain visible.':
      _Translation(
        'Einige gespeicherte Portfoliodetails sind nicht verfügbar. Lesbare Kalenderereignisse bleiben sichtbar.',
        'Neki spremljeni podaci portfelja nisu dostupni. Događaji kalendara koji su pročitani ostaju vidljivi.',
      ),
  'Source: Frankfurter API restricted to provider=ECB. These are daily reference rates, not executable broker prices.':
      _Translation(
        'Quelle: Frankfurter-API, beschränkt auf provider=ECB. Dies sind tägliche Referenzkurse, keine handelbaren Brokerpreise.',
        'Izvor: Frankfurter API ograničen na provider=ECB. Ovo su dnevni referentni tečajevi, a ne izvršive brokerske cijene.',
      ),
  'TTWROR · time-weighted': _Translation(
    'TTWROR · zeitgewichtet',
    'TTWROR · vremenski ponderiran',
  ),
  'The dachshund that fetches your dividends.': _Translation(
    'Der Dackel, der Ihre Dividenden apportiert.',
    'Jazavčar koji donosi vaše dividende.',
  ),
  'The final portfolio cannot be deleted': _Translation(
    'Das letzte Portfolio kann nicht gelöscht werden',
    'Posljednji portfelj ne može se izbrisati',
  ),
  'Unpriced holdings and currencies without a dated FX rate are excluded, not treated as zero.':
      _Translation(
        'Positionen ohne Kurs und Währungen ohne datierten Wechselkurs werden ausgeschlossen, nicht als null behandelt.',
        'Pozicije bez cijene i valute bez datiranog tečaja isključene su, a ne tretirane kao nula.',
      ),
  'Upcoming company events · 30 days': _Translation(
    'Bevorstehende Unternehmensereignisse · 30 Tage',
    'Nadolazeći korporativni događaji · 30 dana',
  ),
  'Upcoming events and earnings': _Translation(
    'Bevorstehende Ereignisse und Ergebnisse',
    'Nadolazeći događaji i rezultati',
  ),
  'What would change the assessment?': _Translation(
    'Was würde die Einschätzung ändern?',
    'Što bi promijenilo procjenu?',
  ),
  'XIRR · money-weighted': _Translation(
    'XIRR · geldgewichtet',
    'XIRR · novčano ponderiran',
  ),
  'currency': _Translation('Währung', 'valuta'),
  'day change unavailable': _Translation(
    'Tagesveränderung nicht verfügbar',
    'dnevna promjena nije dostupna',
  ),
  'iCalendar file': _Translation('iCalendar-Datei', 'iCalendar datoteka'),
  'investment': _Translation('Investition', 'ulaganje'),
  'none': _Translation('keine', 'nema'),
  'saved data': _Translation('gespeicherte Daten', 'spremljeni podaci'),
  '● Confirmed upcoming': _Translation(
    '● Bevorstehend, bestätigt',
    '● Nadolazeće, potvrđeno',
  ),
  '✓ Paid': _Translation('✓ Gezahlt', '✓ Isplaćeno'),
};

/// Messages that carry runtime values, keyed by their pattern.
///
/// Keyed by the pattern rather than the assembled string, so one entry
/// covers every value the placeholders can take.
const Map<String, _Translation> _patternMessages = <String, _Translation>{
  'Additional investment ({code})': _Translation(
    'Zusätzliche Investition ({code})',
    'Dodatno ulaganje ({code})',
  ),
  'Allocation in {code}': _Translation('Anteil in {code}', 'Udio u {code}'),
  'Applies to: {scope}': _Translation(
    'Gilt für: {scope}',
    'Primjenjuje se na: {scope}',
  ),
  'Basis: cached price {price} and next-365-day gross dividends of {perShare} per current share.':
      _Translation(
        'Grundlage: gespeicherter Kurs {price} und Brutto-Dividenden der nächsten 365 Tage von {perShare} je aktueller Aktie.',
        'Osnova: spremljena cijena {price} i bruto dividende sljedećih 365 dana od {perShare} po trenutnoj dionici.',
      ),
  'Clear {name}': _Translation('{name} leeren', 'Isprazni {name}'),
  'Clear {name}?': _Translation('{name} leeren?', 'Isprazniti {name}?'),
  'Compared with {time}.': _Translation(
    'Verglichen mit {time}.',
    'U usporedbi s {time}.',
  ),
  'Cumulative income chart for {label} in {code}. Exact monthly values are in the payout table below.':
      _Translation(
        'Diagramm der kumulierten Erträge für {label} in {code}. Genaue Monatswerte stehen in der Auszahlungstabelle unten.',
        'Grafikon kumulativnog prihoda za {label} u {code}. Točne mjesečne vrijednosti nalaze se u tablici isplata ispod.',
      ),
  'Current covered value: {value}': _Translation(
    'Aktuell erfasster Wert: {value}',
    'Trenutačno pokrivena vrijednost: {value}',
  ),
  'Current covered value: {value} · incomplete': _Translation(
    'Aktuell erfasster Wert: {value} · unvollständig',
    'Trenutačno pokrivena vrijednost: {value} · nepotpuno',
  ),
  'Delete {name}': _Translation('{name} löschen', 'Izbriši {name}'),
  'Delete {name}?': _Translation('{name} löschen?', 'Izbrisati {name}?'),
  'Dividend income in {currencies} is excluded because no dated FX rate is cached.':
      _Translation(
        'Dividendenerträge in {currencies} sind ausgeschlossen, weil kein datierter Wechselkurs gespeichert ist.',
        'Prihod od dividendi u {currencies} isključen je jer nije spremljen datirani tečaj.',
      ),
  'Dividend status: {status}': _Translation(
    'Dividendenstatus: {status}',
    'Status dividende: {status}',
  ),
  'E Estimated {amount}': _Translation(
    'E Geschätzt {amount}',
    'E Procijenjeno {amount}',
  ),
  'Earnings · {date}': _Translation(
    'Ergebnisse · {date}',
    'Poslovni rezultati · {date}',
  ),
  'Edit {country} rates': _Translation(
    'Sätze für {country} bearbeiten',
    'Uredi stope za {country}',
  ),
  'Edit {name}': _Translation('{name} bearbeiten', 'Uredi {name}'),
  'Ex-date: {date}': _Translation('Ex-Tag: {date}', 'Ex-datum: {date}'),
  'Ex-dividend {date} · Payment date not yet confirmed.': _Translation(
    'Ex-Dividende {date} · Zahlungsdatum noch nicht bestätigt.',
    'Ex-dividenda {date} · Datum isplate još nije potvrđen.',
  ),
  'Expected {expected} · Actual {actual}': _Translation(
    'Erwartet {expected} · Tatsächlich {actual}',
    'Očekivano {expected} · Stvarno {actual}',
  ),
  'FX {sources} {date}{stale}': _Translation(
    'FX {sources} {date}{stale}',
    'FX {sources} {date}{stale}',
  ),
  'Gross {amount}': _Translation('Brutto {amount}', 'Bruto {amount}'),
  'Last error: {message}': _Translation(
    'Letzter Fehler: {message}',
    'Zadnja pogreška: {message}',
  ),
  'Last updated {age}{progress}{failure}': _Translation(
    'Zuletzt aktualisiert {age}{progress}{failure}',
    'Zadnje ažuriranje {age}{progress}{failure}',
  ),
  'Line {line}': _Translation('Zeile {line}', 'Redak {line}'),
  'Net (estimated) {amount}': _Translation(
    'Netto (geschätzt) {amount}',
    'Neto (procijenjeno) {amount}',
  ),
  'New weight in {code} holdings': _Translation(
    'Neue Gewichtung in {code}-Positionen',
    'Nova težina u {code} pozicijama',
  ),
  'New {form} filing': _Translation(
    'Neue {form}-Meldung',
    'Nova {form} prijava',
  ),
  'Next dividend {date}': _Translation(
    'Nächste Dividende {date}',
    'Sljedeća dividenda {date}',
  ),
  'Observed {time}': _Translation('Beobachtet {time}', 'Zabilježeno {time}'),
  'Payment {date}': _Translation('Zahlung {date}', 'Isplata {date}'),
  'Payment: {date}': _Translation('Zahlung: {date}', 'Isplata: {date}'),
  'Purchases {purchases} · Sales {sales} · Dividends {dividends} · Taxes {taxes} · Fees {fees}\nDeposits {deposits} · Withdrawals {withdrawals} · Net invested {netInvested}':
      _Translation(
        'Käufe {purchases} · Verkäufe {sales} · Dividenden {dividends} · Steuern {taxes} · Gebühren {fees}\nEinzahlungen {deposits} · Auszahlungen {withdrawals} · Netto investiert {netInvested}',
        'Kupnje {purchases} · Prodaje {sales} · Dividende {dividends} · Porezi {taxes} · Naknade {fees}\nUplate {deposits} · Isplate {withdrawals} · Neto uloženo {netInvested}',
      ),
  'Purchases {purchases} · Sales {sales} · Dividends {dividends} · Taxes {taxes} · Fees {fees}\nDeposits {deposits} · Withdrawals {withdrawals} · Net invested {netInvested} · incomplete activity values':
      _Translation(
        'Käufe {purchases} · Verkäufe {sales} · Dividenden {dividends} · Steuern {taxes} · Gebühren {fees}\nEinzahlungen {deposits} · Auszahlungen {withdrawals} · Netto investiert {netInvested} · unvollständige Aktivitätswerte',
        'Kupnje {purchases} · Prodaje {sales} · Dividende {dividends} · Porezi {taxes} · Naknade {fees}\nUplate {deposits} · Isplate {withdrawals} · Neto uloženo {netInvested} · nepotpune vrijednosti aktivnosti',
      ),
  'Refresh failed: {error} Cached values remain visible.': _Translation(
    'Aktualisierung fehlgeschlagen: {error} Gespeicherte Werte bleiben sichtbar.',
    'Osvježavanje nije uspjelo: {error} Spremljene vrijednosti ostaju vidljive.',
  ),
  'Relevance score {score} out of 100': _Translation(
    'Relevanzwert {score} von 100',
    'Ocjena važnosti {score} od 100',
  ),
  'Remove {source} key?': _Translation(
    'Schlüssel für {source} entfernen?',
    'Ukloniti ključ za {source}?',
  ),
  'Rename {name}': _Translation('{name} umbenennen', 'Preimenuj {name}'),
  'Reported period ended {date}': _Translation(
    'Berichtszeitraum endete {date}',
    'Izvještajno razdoblje završilo {date}',
  ),
  'Research score {score} out of 100': _Translation(
    'Analysewert {score} von 100',
    'Ocjena analize {score} od 100',
  ),
  'Research {name}, {symbol}': _Translation(
    'Analyse {name}, {symbol}',
    'Analiza {name}, {symbol}',
  ),
  'Retry available: {time}': _Translation(
    'Erneuter Versuch möglich: {time}',
    'Ponovni pokušaj moguć: {time}',
  ),
  'Show {count} more': _Translation(
    '{count} weitere anzeigen',
    'Prikaži još {count}',
  ),
  'Simulate {name}': _Translation('{name} simulieren', 'Simuliraj {name}'),
  'Step {current} of {total}': _Translation(
    'Schritt {current} von {total}',
    'Korak {current} od {total}',
  ),
  'Table v{version} · {date}\n{source}': _Translation(
    'Tabelle v{version} · {date}\n{source}',
    'Tablica v{version} · {date}\n{source}',
  ),
  'Top {count} positions: {share} of covered value': _Translation(
    'Top {count} Positionen: {share} des erfassten Werts',
    'Najvećih {count} pozicija: {share} pokrivene vrijednosti',
  ),
  'Treaty forms filed for {country}': _Translation(
    'Abkommensformulare für {country} eingereicht',
    'Obrasci ugovora podneseni za {country}',
  ),
  'Value coverage: {priced} of {total} holdings': _Translation(
    'Wertabdeckung: {priced} von {total} Positionen',
    'Pokrivenost vrijednosti: {priced} od {total} pozicija',
  ),
  'Why: {reasons}': _Translation('Warum: {reasons}', 'Zašto: {reasons}'),
  'With forms {withForms} · statutory {statutory} · credit cap {cap}':
      _Translation(
        'Mit Formularen {withForms} · gesetzlich {statutory} · Anrechnungsgrenze {cap}',
        'S obrascima {withForms} · zakonski {statutory} · gornja granica odbitka {cap}',
      ),
  'attempt {count}': _Translation('Versuch {count}', 'pokušaj {count}'),
  'in {count} days': _Translation('in {count} Tagen', 'za {count} dana'),
  'retry {time}': _Translation('erneut {time}', 'ponovno {time}'),
  '{amount} / share': _Translation('{amount} / Aktie', '{amount} / dionici'),
  '{change} since previous close': _Translation(
    '{change} seit dem vorherigen Schlusskurs',
    '{change} od prethodnog zatvaranja',
  ),
  '{change} today': _Translation('{change} heute', '{change} danas'),
  '{code} display view': _Translation(
    'Anzeigeansicht in {code}',
    'Prikaz u {code}',
  ),
  '{code} portfolio': _Translation('Portfolio in {code}', 'Portfelj u {code}'),
  '{code} return': _Translation('Rendite in {code}', 'Prinos u {code}'),
  '{code} selected. Amounts stay in their native currency until a dated FX rate is available.':
      _Translation(
        '{code} ausgewählt. Beträge bleiben in ihrer Ursprungswährung, bis ein datierter Wechselkurs verfügbar ist.',
        '{code} odabrano. Iznosi ostaju u izvornoj valuti dok ne bude dostupan datirani tečaj.',
      ),
  '{code} {grouping} detail': _Translation(
    'Detail {grouping} in {code}',
    'Detalji {grouping} u {code}',
  ),
  '{code}: {total}, paid {paid}, confirmed {confirmed}, estimated {estimated}':
      _Translation(
        '{code}: {total}, gezahlt {paid}, bestätigt {confirmed}, geschätzt {estimated}',
        '{code}: {total}, isplaćeno {paid}, potvrđeno {confirmed}, procijenjeno {estimated}',
      ),
  '{country} · not modelled': _Translation(
    '{country} · nicht modelliert',
    '{country} · nije modelirano',
  ),
  '{count} activities': _Translation(
    '{count} Aktivitäten',
    '{count} aktivnosti',
  ),
  '{count} activities imported.': _Translation(
    '{count} Aktivitäten importiert.',
    'Uvezeno {count} aktivnosti.',
  ),
  '{count} activities reversed.': _Translation(
    '{count} Aktivitäten rückgängig gemacht.',
    'Poništeno {count} aktivnosti.',
  ),
  '{count} company event(s)': _Translation(
    '{count} Unternehmensereignis(se)',
    '{count} korporativnih događaja',
  ),
  '{count} d ago': _Translation('vor {count} T', 'prije {count} d'),
  '{count} dividend events exported locally.': _Translation(
    '{count} Dividendenereignisse lokal exportiert.',
    'Lokalno izvezeno {count} događaja dividendi.',
  ),
  '{count} dividend-outlook change(s)': _Translation(
    '{count} Änderung(en) des Dividendenausblicks',
    '{count} promjena izgleda dividende',
  ),
  '{count} earnings event(s)': _Translation(
    '{count} Ergebnistermin(e)',
    '{count} objava rezultata',
  ),
  '{count} ex-dividend date(s)': _Translation(
    '{count} Ex-Dividenden-Termin(e)',
    '{count} ex-dividendnih datuma',
  ),
  '{count} h ago': _Translation('vor {count} Std.', 'prije {count} h'),
  '{count} holding change(s)': _Translation(
    '{count} Positionsänderung(en)',
    '{count} promjena pozicija',
  ),
  '{count} holdings': _Translation('{count} Positionen', '{count} pozicija'),
  '{count} min ago': _Translation('vor {count} Min.', 'prije {count} min'),
  '{count} more activities': _Translation(
    '{count} weitere Aktivitäten',
    '{count} dodatnih aktivnosti',
  ),
  '{count} need a payment date, EUR FX, or country data': _Translation(
    '{count} benötigen ein Zahlungsdatum, einen EUR-Wechselkurs oder Länderdaten',
    '{count} treba datum isplate, EUR tečaj ili podatke o državi',
  ),
  '{count} payment': _Translation('{count} Zahlung', '{count} isplata'),
  '{count} payment date(s)': _Translation(
    '{count} Zahlungstermin(e)',
    '{count} datuma isplate',
  ),
  '{count} payment(s) need FX/country data': _Translation(
    '{count} Zahlung(en) benötigen Wechselkurs-/Länderdaten',
    '{count} isplata treba podatke o tečaju/državi',
  ),
  '{count} payments': _Translation('{count} Zahlungen', '{count} isplata'),
  '{count} quote change(s)': _Translation(
    '{count} Kursänderung(en)',
    '{count} promjena cijena',
  ),
  '{count} relevant event(s) in the next 3 days': _Translation(
    '{count} relevante(s) Ereignis(se) in den nächsten 3 Tagen',
    '{count} važnih događaja u sljedeća 3 dana',
  ),
  '{date} · {count} event': _Translation(
    '{date} · {count} Ereignis',
    '{date} · {count} događaj',
  ),
  '{date} · {count} events': _Translation(
    '{date} · {count} Ereignisse',
    '{date} · {count} događaja',
  ),
  '{date}, {count} dividend events': _Translation(
    '{date}, {count} Dividendenereignisse',
    '{date}, {count} događaja dividendi',
  ),
  '{evidence} available.': _Translation(
    '{evidence} verfügbar.',
    '{evidence} dostupno.',
  ),
  '{evidence} — unavailable from configured sources.': _Translation(
    '{evidence} — bei den eingerichteten Quellen nicht verfügbar.',
    '{evidence} — nije dostupno iz postavljenih izvora.',
  ),
  '{format} · {ready} ready · {duplicates} duplicates · {rejected} rejected':
      _Translation(
        '{format} · {ready} bereit · {duplicates} Duplikate · {rejected} abgelehnt',
        '{format} · {ready} spremno · {duplicates} duplikata · {rejected} odbijeno',
      ),
  '{label} (Alt+{index})': _Translation(
    '{label} (Alt+{index})',
    '{label} (Alt+{index})',
  ),
  '{name} filed {form} today.': _Translation(
    '{name} hat heute {form} eingereicht.',
    '{name} je danas podnio {form}.',
  ),
  '{name} is scheduled to report today; timing is {timing}.': _Translation(
    '{name} legt heute Zahlen vor; Zeitpunkt: {timing}.',
    '{name} danas objavljuje rezultate; vrijeme: {timing}.',
  ),
  '{name} is scheduled to report tomorrow; timing is {timing}.': _Translation(
    '{name} legt morgen Zahlen vor; Zeitpunkt: {timing}.',
    '{name} sutra objavljuje rezultate; vrijeme: {timing}.',
  ),
  '{name} updated.': _Translation('{name} aktualisiert.', '{name} ažuriran.'),
  '{net}': _Translation('{net}', '{net}'),
  '{net} + {count} unavailable': _Translation(
    '{net} + {count} nicht verfügbar',
    '{net} + {count} nedostupno',
  ),
  '{priced} of {total} holdings priced': _Translation(
    '{priced} von {total} Positionen bewertet',
    '{priced} od {total} pozicija vrednovano',
  ),
  '{source} API key': _Translation(
    '{source} API-Schlüssel',
    '{source} API ključ',
  ),
  '{symbol} · {quantity} shares': _Translation(
    '{symbol} · {quantity} Aktien',
    '{symbol} · {quantity} dionica',
  ),
  '{total} priced holdings': _Translation(
    '{total} bewertete Positionen',
    '{total} vrednovanih pozicija',
  ),
  '{years} completed reported year(s) · {withoutCut} year(s) without a cut':
      _Translation(
        '{years} abgeschlossene(s) Berichtsjahr(e) · {withoutCut} Jahr(e) ohne Kürzung',
        '{years} završenih izvještajnih godina · {withoutCut} godina bez smanjenja',
      ),
  '{year} forecast': _Translation('Prognose {year}', 'Prognoza za {year}'),
  '• {limitation}': _Translation('• {limitation}', '• {limitation}'),
  '● Confirmed {amount}': _Translation(
    '● Bestätigt {amount}',
    '● Potvrđeno {amount}',
  ),
  '✓ Paid {amount}': _Translation('✓ Gezahlt {amount}', '✓ Isplaćeno {amount}'),
};

const Map<String, _Translation> _phrases = <String, _Translation>{
  'January': _Translation('Januar', 'siječanj'),
  'February': _Translation('Februar', 'veljača'),
  'March': _Translation('März', 'ožujak'),
  'April': _Translation('April', 'travanj'),
  'May': _Translation('Mai', 'svibanj'),
  'June': _Translation('Juni', 'lipanj'),
  'July': _Translation('Juli', 'srpanj'),
  'August': _Translation('August', 'kolovoz'),
  'September': _Translation('September', 'rujan'),
  'October': _Translation('Oktober', 'listopad'),
  'November': _Translation('November', 'studeni'),
  'December': _Translation('Dezember', 'prosinac'),
  ' since previous close': _Translation(
    ' seit dem vorherigen Schlusskurs',
    ' od prethodnog zatvaranja',
  ),
  ' more activities': _Translation(
    ' weitere Aktivitäten',
    ' dodatnih aktivnosti',
  ),
  ' dividend-outlook change(s)': _Translation(
    ' Änderung(en) des Dividendenausblicks',
    ' promjena izgleda dividende',
  ),
  ' holding change(s)': _Translation(
    ' Positionsänderung(en)',
    ' promjena pozicija',
  ),
  ' quote change(s)': _Translation(' Kursänderung(en)', ' promjena cijena'),
  ' payment(s) need FX/country data': _Translation(
    ' Zahlung(en) benötigen Wechselkurs-/Länderdaten',
    ' isplata zahtijeva podatke o tečaju/državi',
  ),
  ' API key': _Translation(' API-Schlüssel', ' API ključ'),
  'Applies to: ': _Translation('Gilt für: ', 'Primjenjuje se na: '),
  'Earnings · ': _Translation('Ergebnisse · ', 'Rezultati · '),
  'Edit ': _Translation('Bearbeiten: ', 'Uredi: '),
  'Ex-date: ': _Translation('Ex-Tag: ', 'Ex-datum: '),
  'Gross ': _Translation('Brutto ', 'Bruto '),
  'Line ': _Translation('Zeile ', 'Redak '),
  'Loading dividend data…': _Translation(
    'Dividendendaten werden geladen…',
    'Učitavanje podataka o dividendama…',
  ),
  'Net estimated': _Translation('Netto geschätzt', 'Neto procijenjeno'),
  'Observed ': _Translation('Beobachtet ', 'Zabilježeno '),
  'Payment: ': _Translation('Zahlung: ', 'Isplata: '),
  'purchase': _Translation('Kauf', 'kupnja'),
  'sale': _Translation('Verkauf', 'prodaja'),
  'deposit': _Translation('Einzahlung', 'uplata'),
  'withdrawal': _Translation('Auszahlung', 'isplata'),
  'fee': _Translation('Gebühr', 'naknada'),
  'tax': _Translation('Steuer', 'porez'),
  'Remove ': _Translation('Entfernen: ', 'Ukloni: '),
  'Confirmed upcoming': _Translation(
    'Bevorstehend, bestätigt',
    'Nadolazeće, potvrđeno',
  ),
  'Loading ': _Translation('Lade ', 'Učitavanje '),
  'Saving ': _Translation('Speichere ', 'Spremanje '),
  'Could not load ': _Translation(
    'Konnte nicht laden: ',
    'Nije moguće učitati: ',
  ),
  'Could not save ': _Translation(
    'Konnte nicht speichern: ',
    'Nije moguće spremiti: ',
  ),
  ' unavailable': _Translation(' nicht verfügbar', ' nije dostupno'),
  ' unavailable.': _Translation(' nicht verfügbar.', ' nije dostupno.'),
  'No ': _Translation('Keine ', 'Nema '),
  'Current ': _Translation('Aktuell: ', 'Trenutačno: '),
  'Expected ': _Translation('Erwartet: ', 'Očekivano: '),
  'Estimated ': _Translation('Geschätzt: ', 'Procijenjeno: '),
  'Confirmed ': _Translation('Bestätigt: ', 'Potvrđeno: '),
  'Version ': _Translation('Version ', 'Verzija '),
  'Source: ': _Translation('Quelle: ', 'Izvor: '),
  'Last updated ': _Translation('Zuletzt aktualisiert ', 'Zadnje ažuriranje '),
  'Next dividend': _Translation('Nächste Dividende', 'Sljedeća dividenda'),
  'portfolio': _Translation('Portfolio', 'portfelj'),
  'Portfolio': _Translation('Portfolio', 'Portfelj'),
  'dividend': _Translation('Dividende', 'dividenda'),
  'Dividend': _Translation('Dividende', 'Dividenda'),
  'payments': _Translation('Zahlungen', 'isplate'),
  'payment': _Translation('Zahlung', 'isplata'),
  'holdings': _Translation('Positionen', 'pozicije'),
  'holding': _Translation('Position', 'pozicija'),
  'watchlist': _Translation('Watchlist', 'popis praćenja'),
  'activities': _Translation('Aktivitäten', 'aktivnosti'),
  'activity': _Translation('Aktivität', 'aktivnost'),
  'income': _Translation('Erträge', 'prihod'),
  'value': _Translation('Wert', 'vrijednost'),
  'price': _Translation('Kurs', 'cijena'),
  'gross': _Translation('brutto', 'bruto'),
  'net': _Translation('netto', 'neto'),
  'estimated': _Translation('geschätzt', 'procijenjeno'),
  'confirmed': _Translation('bestätigt', 'potvrđeno'),
  'current': _Translation('aktuell', 'trenutačno'),
  'today': _Translation('heute', 'danas'),
  'tomorrow': _Translation('morgen', 'sutra'),
  'days': _Translation('Tage', 'dana'),
  'months': _Translation('Monate', 'mjeseci'),
  'years': _Translation('Jahre', 'godine'),
  'available': _Translation('verfügbar', 'dostupno'),
  'incomplete': _Translation('unvollständig', 'nepotpuno'),
  'stale': _Translation('veraltet', 'zastarjelo'),
  'refreshing': _Translation('wird aktualisiert', 'osvježavanje'),
};
