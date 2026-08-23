// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InstrumentsTable extends Instruments
    with TableInfo<$InstrumentsTable, DbInstrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _internalIdMeta = const VerificationMeta(
    'internalId',
  );
  @override
  late final GeneratedColumn<String> internalId = GeneratedColumn<String>(
    'internal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exchangeMeta = const VerificationMeta(
    'exchange',
  );
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
    'exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _micMeta = const VerificationMeta('mic');
  @override
  late final GeneratedColumn<String> mic = GeneratedColumn<String>(
    'mic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    internalId,
    symbol,
    name,
    currencyCode,
    exchange,
    mic,
    isin,
    country,
    sector,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbInstrument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('internal_id')) {
      context.handle(
        _internalIdMeta,
        internalId.isAcceptableOrUnknown(data['internal_id']!, _internalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_internalIdMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('exchange')) {
      context.handle(
        _exchangeMeta,
        exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta),
      );
    }
    if (data.containsKey('mic')) {
      context.handle(
        _micMeta,
        mic.isAcceptableOrUnknown(data['mic']!, _micMeta),
      );
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {internalId};
  @override
  DbInstrument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbInstrument(
      internalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}internal_id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      exchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange'],
      ),
      mic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mic'],
      ),
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
    );
  }

  @override
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }
}

class DbInstrument extends DataClass implements Insertable<DbInstrument> {
  /// Stable app-internal identifier, never a bare ticker.
  final String internalId;

  /// Primary ticker symbol.
  final String symbol;

  /// Company or fund name.
  final String name;

  /// ISO 4217 code the instrument trades in.
  final String currencyCode;

  /// Exchange name or code.
  final String? exchange;

  /// ISO 10383 Market Identifier Code.
  final String? mic;

  /// ISO 6166 identifier.
  final String? isin;

  /// ISO 3166-1 alpha-2 country of domicile.
  final String? country;

  /// Sector classification, for concentration analysis.
  final String? sector;
  const DbInstrument({
    required this.internalId,
    required this.symbol,
    required this.name,
    required this.currencyCode,
    this.exchange,
    this.mic,
    this.isin,
    this.country,
    this.sector,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['internal_id'] = Variable<String>(internalId);
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || exchange != null) {
      map['exchange'] = Variable<String>(exchange);
    }
    if (!nullToAbsent || mic != null) {
      map['mic'] = Variable<String>(mic);
    }
    if (!nullToAbsent || isin != null) {
      map['isin'] = Variable<String>(isin);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      internalId: Value(internalId),
      symbol: Value(symbol),
      name: Value(name),
      currencyCode: Value(currencyCode),
      exchange: exchange == null && nullToAbsent
          ? const Value.absent()
          : Value(exchange),
      mic: mic == null && nullToAbsent ? const Value.absent() : Value(mic),
      isin: isin == null && nullToAbsent ? const Value.absent() : Value(isin),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      sector: sector == null && nullToAbsent
          ? const Value.absent()
          : Value(sector),
    );
  }

  factory DbInstrument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbInstrument(
      internalId: serializer.fromJson<String>(json['internalId']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      exchange: serializer.fromJson<String?>(json['exchange']),
      mic: serializer.fromJson<String?>(json['mic']),
      isin: serializer.fromJson<String?>(json['isin']),
      country: serializer.fromJson<String?>(json['country']),
      sector: serializer.fromJson<String?>(json['sector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'internalId': serializer.toJson<String>(internalId),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'exchange': serializer.toJson<String?>(exchange),
      'mic': serializer.toJson<String?>(mic),
      'isin': serializer.toJson<String?>(isin),
      'country': serializer.toJson<String?>(country),
      'sector': serializer.toJson<String?>(sector),
    };
  }

  DbInstrument copyWith({
    String? internalId,
    String? symbol,
    String? name,
    String? currencyCode,
    Value<String?> exchange = const Value.absent(),
    Value<String?> mic = const Value.absent(),
    Value<String?> isin = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> sector = const Value.absent(),
  }) => DbInstrument(
    internalId: internalId ?? this.internalId,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    currencyCode: currencyCode ?? this.currencyCode,
    exchange: exchange.present ? exchange.value : this.exchange,
    mic: mic.present ? mic.value : this.mic,
    isin: isin.present ? isin.value : this.isin,
    country: country.present ? country.value : this.country,
    sector: sector.present ? sector.value : this.sector,
  );
  DbInstrument copyWithCompanion(InstrumentsCompanion data) {
    return DbInstrument(
      internalId: data.internalId.present
          ? data.internalId.value
          : this.internalId,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      mic: data.mic.present ? data.mic.value : this.mic,
      isin: data.isin.present ? data.isin.value : this.isin,
      country: data.country.present ? data.country.value : this.country,
      sector: data.sector.present ? data.sector.value : this.sector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbInstrument(')
          ..write('internalId: $internalId, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchange: $exchange, ')
          ..write('mic: $mic, ')
          ..write('isin: $isin, ')
          ..write('country: $country, ')
          ..write('sector: $sector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    internalId,
    symbol,
    name,
    currencyCode,
    exchange,
    mic,
    isin,
    country,
    sector,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbInstrument &&
          other.internalId == this.internalId &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.currencyCode == this.currencyCode &&
          other.exchange == this.exchange &&
          other.mic == this.mic &&
          other.isin == this.isin &&
          other.country == this.country &&
          other.sector == this.sector);
}

class InstrumentsCompanion extends UpdateCompanion<DbInstrument> {
  final Value<String> internalId;
  final Value<String> symbol;
  final Value<String> name;
  final Value<String> currencyCode;
  final Value<String?> exchange;
  final Value<String?> mic;
  final Value<String?> isin;
  final Value<String?> country;
  final Value<String?> sector;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.internalId = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.exchange = const Value.absent(),
    this.mic = const Value.absent(),
    this.isin = const Value.absent(),
    this.country = const Value.absent(),
    this.sector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    required String internalId,
    required String symbol,
    required String name,
    required String currencyCode,
    this.exchange = const Value.absent(),
    this.mic = const Value.absent(),
    this.isin = const Value.absent(),
    this.country = const Value.absent(),
    this.sector = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : internalId = Value(internalId),
       symbol = Value(symbol),
       name = Value(name),
       currencyCode = Value(currencyCode);
  static Insertable<DbInstrument> custom({
    Expression<String>? internalId,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? currencyCode,
    Expression<String>? exchange,
    Expression<String>? mic,
    Expression<String>? isin,
    Expression<String>? country,
    Expression<String>? sector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (internalId != null) 'internal_id': internalId,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (exchange != null) 'exchange': exchange,
      if (mic != null) 'mic': mic,
      if (isin != null) 'isin': isin,
      if (country != null) 'country': country,
      if (sector != null) 'sector': sector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith({
    Value<String>? internalId,
    Value<String>? symbol,
    Value<String>? name,
    Value<String>? currencyCode,
    Value<String?>? exchange,
    Value<String?>? mic,
    Value<String?>? isin,
    Value<String?>? country,
    Value<String?>? sector,
    Value<int>? rowid,
  }) {
    return InstrumentsCompanion(
      internalId: internalId ?? this.internalId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      exchange: exchange ?? this.exchange,
      mic: mic ?? this.mic,
      isin: isin ?? this.isin,
      country: country ?? this.country,
      sector: sector ?? this.sector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (internalId.present) {
      map['internal_id'] = Variable<String>(internalId.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
    }
    if (mic.present) {
      map['mic'] = Variable<String>(mic.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentsCompanion(')
          ..write('internalId: $internalId, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchange: $exchange, ')
          ..write('mic: $mic, ')
          ..write('isin: $isin, ')
          ..write('country: $country, ')
          ..write('sector: $sector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderMappingsTable extends ProviderMappings
    with TableInfo<$ProviderMappingsTable, DbProviderMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerInstrumentIdMeta =
      const VerificationMeta('providerInstrumentId');
  @override
  late final GeneratedColumn<String> providerInstrumentId =
      GeneratedColumn<String>(
        'provider_instrument_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    instrumentId,
    providerId,
    symbol,
    providerInstrumentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbProviderMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('provider_instrument_id')) {
      context.handle(
        _providerInstrumentIdMeta,
        providerInstrumentId.isAcceptableOrUnknown(
          data['provider_instrument_id']!,
          _providerInstrumentIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentId, providerId};
  @override
  DbProviderMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProviderMapping(
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      providerInstrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_instrument_id'],
      ),
    );
  }

  @override
  $ProviderMappingsTable createAlias(String alias) {
    return $ProviderMappingsTable(attachedDatabase, alias);
  }
}

class DbProviderMapping extends DataClass
    implements Insertable<DbProviderMapping> {
  /// The instrument this mapping belongs to.
  final String instrumentId;

  /// Provider identifier, e.g. `fmp`.
  final String providerId;

  /// The symbol that provider expects.
  final String symbol;

  /// The provider's own opaque identifier.
  final String? providerInstrumentId;
  const DbProviderMapping({
    required this.instrumentId,
    required this.providerId,
    required this.symbol,
    this.providerInstrumentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instrument_id'] = Variable<String>(instrumentId);
    map['provider_id'] = Variable<String>(providerId);
    map['symbol'] = Variable<String>(symbol);
    if (!nullToAbsent || providerInstrumentId != null) {
      map['provider_instrument_id'] = Variable<String>(providerInstrumentId);
    }
    return map;
  }

  ProviderMappingsCompanion toCompanion(bool nullToAbsent) {
    return ProviderMappingsCompanion(
      instrumentId: Value(instrumentId),
      providerId: Value(providerId),
      symbol: Value(symbol),
      providerInstrumentId: providerInstrumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerInstrumentId),
    );
  }

  factory DbProviderMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProviderMapping(
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      symbol: serializer.fromJson<String>(json['symbol']),
      providerInstrumentId: serializer.fromJson<String?>(
        json['providerInstrumentId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instrumentId': serializer.toJson<String>(instrumentId),
      'providerId': serializer.toJson<String>(providerId),
      'symbol': serializer.toJson<String>(symbol),
      'providerInstrumentId': serializer.toJson<String?>(providerInstrumentId),
    };
  }

  DbProviderMapping copyWith({
    String? instrumentId,
    String? providerId,
    String? symbol,
    Value<String?> providerInstrumentId = const Value.absent(),
  }) => DbProviderMapping(
    instrumentId: instrumentId ?? this.instrumentId,
    providerId: providerId ?? this.providerId,
    symbol: symbol ?? this.symbol,
    providerInstrumentId: providerInstrumentId.present
        ? providerInstrumentId.value
        : this.providerInstrumentId,
  );
  DbProviderMapping copyWithCompanion(ProviderMappingsCompanion data) {
    return DbProviderMapping(
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      providerInstrumentId: data.providerInstrumentId.present
          ? data.providerInstrumentId.value
          : this.providerInstrumentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProviderMapping(')
          ..write('instrumentId: $instrumentId, ')
          ..write('providerId: $providerId, ')
          ..write('symbol: $symbol, ')
          ..write('providerInstrumentId: $providerInstrumentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(instrumentId, providerId, symbol, providerInstrumentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProviderMapping &&
          other.instrumentId == this.instrumentId &&
          other.providerId == this.providerId &&
          other.symbol == this.symbol &&
          other.providerInstrumentId == this.providerInstrumentId);
}

class ProviderMappingsCompanion extends UpdateCompanion<DbProviderMapping> {
  final Value<String> instrumentId;
  final Value<String> providerId;
  final Value<String> symbol;
  final Value<String?> providerInstrumentId;
  final Value<int> rowid;
  const ProviderMappingsCompanion({
    this.instrumentId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.symbol = const Value.absent(),
    this.providerInstrumentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderMappingsCompanion.insert({
    required String instrumentId,
    required String providerId,
    required String symbol,
    this.providerInstrumentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : instrumentId = Value(instrumentId),
       providerId = Value(providerId),
       symbol = Value(symbol);
  static Insertable<DbProviderMapping> custom({
    Expression<String>? instrumentId,
    Expression<String>? providerId,
    Expression<String>? symbol,
    Expression<String>? providerInstrumentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (providerId != null) 'provider_id': providerId,
      if (symbol != null) 'symbol': symbol,
      if (providerInstrumentId != null)
        'provider_instrument_id': providerInstrumentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderMappingsCompanion copyWith({
    Value<String>? instrumentId,
    Value<String>? providerId,
    Value<String>? symbol,
    Value<String?>? providerInstrumentId,
    Value<int>? rowid,
  }) {
    return ProviderMappingsCompanion(
      instrumentId: instrumentId ?? this.instrumentId,
      providerId: providerId ?? this.providerId,
      symbol: symbol ?? this.symbol,
      providerInstrumentId: providerInstrumentId ?? this.providerInstrumentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (providerInstrumentId.present) {
      map['provider_instrument_id'] = Variable<String>(
        providerInstrumentId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderMappingsCompanion(')
          ..write('instrumentId: $instrumentId, ')
          ..write('providerId: $providerId, ')
          ..write('symbol: $symbol, ')
          ..write('providerInstrumentId: $providerInstrumentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTable extends Holdings
    with TableInfo<$HoldingsTable, DbHolding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($HoldingsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($HoldingsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averagePriceAmountMeta =
      const VerificationMeta('averagePriceAmount');
  @override
  late final GeneratedColumn<String> averagePriceAmount =
      GeneratedColumn<String>(
        'average_price_amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _averagePriceCurrencyMeta =
      const VerificationMeta('averagePriceCurrency');
  @override
  late final GeneratedColumn<String> averagePriceCurrency =
      GeneratedColumn<String>(
        'average_price_currency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    quantity,
    averagePriceAmount,
    averagePriceCurrency,
    purchaseDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbHolding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('average_price_amount')) {
      context.handle(
        _averagePriceAmountMeta,
        averagePriceAmount.isAcceptableOrUnknown(
          data['average_price_amount']!,
          _averagePriceAmountMeta,
        ),
      );
    }
    if (data.containsKey('average_price_currency')) {
      context.handle(
        _averagePriceCurrencyMeta,
        averagePriceCurrency.isAcceptableOrUnknown(
          data['average_price_currency']!,
          _averagePriceCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbHolding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbHolding(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $HoldingsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $HoldingsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      averagePriceAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}average_price_amount'],
      ),
      averagePriceCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}average_price_currency'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $HoldingsTable createAlias(String alias) {
    return $HoldingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
}

class DbHolding extends DataClass implements Insertable<DbHolding> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Surrogate key, so the same instrument could later hold several lots.
  final int id;

  /// The instrument held.
  final String instrumentId;

  /// Share count as an exact decimal string. Never a floating-point number.
  final String quantity;

  /// Average price paid per share, as an exact decimal string.
  final String? averagePriceAmount;

  /// Currency of [averagePriceAmount].
  final String? averagePriceCurrency;

  /// When the position was opened.
  final DateTime? purchaseDate;

  /// Free-form user note.
  final String? notes;
  const DbHolding({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.instrumentId,
    required this.quantity,
    this.averagePriceAmount,
    this.averagePriceCurrency,
    this.purchaseDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $HoldingsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $HoldingsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<int>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['quantity'] = Variable<String>(quantity);
    if (!nullToAbsent || averagePriceAmount != null) {
      map['average_price_amount'] = Variable<String>(averagePriceAmount);
    }
    if (!nullToAbsent || averagePriceCurrency != null) {
      map['average_price_currency'] = Variable<String>(averagePriceCurrency);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  HoldingsCompanion toCompanion(bool nullToAbsent) {
    return HoldingsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      instrumentId: Value(instrumentId),
      quantity: Value(quantity),
      averagePriceAmount: averagePriceAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(averagePriceAmount),
      averagePriceCurrency: averagePriceCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(averagePriceCurrency),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DbHolding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbHolding(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $HoldingsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $HoldingsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<int>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      quantity: serializer.fromJson<String>(json['quantity']),
      averagePriceAmount: serializer.fromJson<String?>(
        json['averagePriceAmount'],
      ),
      averagePriceCurrency: serializer.fromJson<String?>(
        json['averagePriceCurrency'],
      ),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $HoldingsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $HoldingsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<int>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'quantity': serializer.toJson<String>(quantity),
      'averagePriceAmount': serializer.toJson<String?>(averagePriceAmount),
      'averagePriceCurrency': serializer.toJson<String?>(averagePriceCurrency),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DbHolding copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    int? id,
    String? instrumentId,
    String? quantity,
    Value<String?> averagePriceAmount = const Value.absent(),
    Value<String?> averagePriceCurrency = const Value.absent(),
    Value<DateTime?> purchaseDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => DbHolding(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    quantity: quantity ?? this.quantity,
    averagePriceAmount: averagePriceAmount.present
        ? averagePriceAmount.value
        : this.averagePriceAmount,
    averagePriceCurrency: averagePriceCurrency.present
        ? averagePriceCurrency.value
        : this.averagePriceCurrency,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    notes: notes.present ? notes.value : this.notes,
  );
  DbHolding copyWithCompanion(HoldingsCompanion data) {
    return DbHolding(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      averagePriceAmount: data.averagePriceAmount.present
          ? data.averagePriceAmount.value
          : this.averagePriceAmount,
      averagePriceCurrency: data.averagePriceCurrency.present
          ? data.averagePriceCurrency.value
          : this.averagePriceCurrency,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbHolding(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('quantity: $quantity, ')
          ..write('averagePriceAmount: $averagePriceAmount, ')
          ..write('averagePriceCurrency: $averagePriceCurrency, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    quantity,
    averagePriceAmount,
    averagePriceCurrency,
    purchaseDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbHolding &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.quantity == this.quantity &&
          other.averagePriceAmount == this.averagePriceAmount &&
          other.averagePriceCurrency == this.averagePriceCurrency &&
          other.purchaseDate == this.purchaseDate &&
          other.notes == this.notes);
}

class HoldingsCompanion extends UpdateCompanion<DbHolding> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<int> id;
  final Value<String> instrumentId;
  final Value<String> quantity;
  final Value<String?> averagePriceAmount;
  final Value<String?> averagePriceCurrency;
  final Value<DateTime?> purchaseDate;
  final Value<String?> notes;
  const HoldingsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.averagePriceAmount = const Value.absent(),
    this.averagePriceCurrency = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
  });
  HoldingsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    required String instrumentId,
    required String quantity,
    this.averagePriceAmount = const Value.absent(),
    this.averagePriceCurrency = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       instrumentId = Value(instrumentId),
       quantity = Value(quantity);
  static Insertable<DbHolding> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<int>? id,
    Expression<String>? instrumentId,
    Expression<String>? quantity,
    Expression<String>? averagePriceAmount,
    Expression<String>? averagePriceCurrency,
    Expression<DateTime>? purchaseDate,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (quantity != null) 'quantity': quantity,
      if (averagePriceAmount != null)
        'average_price_amount': averagePriceAmount,
      if (averagePriceCurrency != null)
        'average_price_currency': averagePriceCurrency,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (notes != null) 'notes': notes,
    });
  }

  HoldingsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<int>? id,
    Value<String>? instrumentId,
    Value<String>? quantity,
    Value<String?>? averagePriceAmount,
    Value<String?>? averagePriceCurrency,
    Value<DateTime?>? purchaseDate,
    Value<String?>? notes,
  }) {
    return HoldingsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      quantity: quantity ?? this.quantity,
      averagePriceAmount: averagePriceAmount ?? this.averagePriceAmount,
      averagePriceCurrency: averagePriceCurrency ?? this.averagePriceCurrency,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $HoldingsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $HoldingsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (averagePriceAmount.present) {
      map['average_price_amount'] = Variable<String>(averagePriceAmount.value);
    }
    if (averagePriceCurrency.present) {
      map['average_price_currency'] = Variable<String>(
        averagePriceCurrency.value,
      );
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('quantity: $quantity, ')
          ..write('averagePriceAmount: $averagePriceAmount, ')
          ..write('averagePriceCurrency: $averagePriceCurrency, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $WatchlistEntriesTable extends WatchlistEntries
    with TableInfo<$WatchlistEntriesTable, DbWatchlistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($WatchlistEntriesTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($WatchlistEntriesTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id)',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    instrumentId,
    addedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbWatchlistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentId};
  @override
  DbWatchlistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbWatchlistEntry(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $WatchlistEntriesTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $WatchlistEntriesTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $WatchlistEntriesTable createAlias(String alias) {
    return $WatchlistEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
}

class DbWatchlistEntry extends DataClass
    implements Insertable<DbWatchlistEntry> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// The instrument followed.
  final String instrumentId;

  /// When the user added it.
  final DateTime addedAt;

  /// Free-form user note.
  final String? notes;
  const DbWatchlistEntry({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.instrumentId,
    required this.addedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $WatchlistEntriesTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $WatchlistEntriesTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['instrument_id'] = Variable<String>(instrumentId);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WatchlistEntriesCompanion toCompanion(bool nullToAbsent) {
    return WatchlistEntriesCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      instrumentId: Value(instrumentId),
      addedAt: Value(addedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DbWatchlistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbWatchlistEntry(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $WatchlistEntriesTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $WatchlistEntriesTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $WatchlistEntriesTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $WatchlistEntriesTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DbWatchlistEntry copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? instrumentId,
    DateTime? addedAt,
    Value<String?> notes = const Value.absent(),
  }) => DbWatchlistEntry(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    instrumentId: instrumentId ?? this.instrumentId,
    addedAt: addedAt ?? this.addedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  DbWatchlistEntry copyWithCompanion(WatchlistEntriesCompanion data) {
    return DbWatchlistEntry(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbWatchlistEntry(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('addedAt: $addedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    instrumentId,
    addedAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbWatchlistEntry &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.instrumentId == this.instrumentId &&
          other.addedAt == this.addedAt &&
          other.notes == this.notes);
}

class WatchlistEntriesCompanion extends UpdateCompanion<DbWatchlistEntry> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> instrumentId;
  final Value<DateTime> addedAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const WatchlistEntriesCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistEntriesCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String instrumentId,
    required DateTime addedAt,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       instrumentId = Value(instrumentId),
       addedAt = Value(addedAt);
  static Insertable<DbWatchlistEntry> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? instrumentId,
    Expression<DateTime>? addedAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (addedAt != null) 'added_at': addedAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistEntriesCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? instrumentId,
    Value<DateTime>? addedAt,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return WatchlistEntriesCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      instrumentId: instrumentId ?? this.instrumentId,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $WatchlistEntriesTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $WatchlistEntriesTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistEntriesCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('addedAt: $addedAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, DbQuote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($QuotesTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($QuotesTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _priceAmountMeta = const VerificationMeta(
    'priceAmount',
  );
  @override
  late final GeneratedColumn<String> priceAmount = GeneratedColumn<String>(
    'price_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceCurrencyMeta = const VerificationMeta(
    'priceCurrency',
  );
  @override
  late final GeneratedColumn<String> priceCurrency = GeneratedColumn<String>(
    'price_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousCloseAmountMeta =
      const VerificationMeta('previousCloseAmount');
  @override
  late final GeneratedColumn<String> previousCloseAmount =
      GeneratedColumn<String>(
        'previous_close_amount',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    instrumentId,
    priceAmount,
    priceCurrency,
    previousCloseAmount,
    asOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQuote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('price_amount')) {
      context.handle(
        _priceAmountMeta,
        priceAmount.isAcceptableOrUnknown(
          data['price_amount']!,
          _priceAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceAmountMeta);
    }
    if (data.containsKey('price_currency')) {
      context.handle(
        _priceCurrencyMeta,
        priceCurrency.isAcceptableOrUnknown(
          data['price_currency']!,
          _priceCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceCurrencyMeta);
    }
    if (data.containsKey('previous_close_amount')) {
      context.handle(
        _previousCloseAmountMeta,
        previousCloseAmount.isAcceptableOrUnknown(
          data['previous_close_amount']!,
          _previousCloseAmountMeta,
        ),
      );
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    } else if (isInserting) {
      context.missing(_asOfMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentId};
  @override
  DbQuote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQuote(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $QuotesTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $QuotesTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      priceAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_amount'],
      )!,
      priceCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_currency'],
      )!,
      previousCloseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_close_amount'],
      ),
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
}

class DbQuote extends DataClass implements Insertable<DbQuote> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// The quoted instrument.
  final String instrumentId;

  /// Last known price as an exact decimal string.
  final String priceAmount;

  /// Currency of the price.
  final String priceCurrency;

  /// Previous session close, when reported.
  final String? previousCloseAmount;

  /// When the price was observed.
  final DateTime asOf;
  const DbQuote({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.instrumentId,
    required this.priceAmount,
    required this.priceCurrency,
    this.previousCloseAmount,
    required this.asOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $QuotesTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $QuotesTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['instrument_id'] = Variable<String>(instrumentId);
    map['price_amount'] = Variable<String>(priceAmount);
    map['price_currency'] = Variable<String>(priceCurrency);
    if (!nullToAbsent || previousCloseAmount != null) {
      map['previous_close_amount'] = Variable<String>(previousCloseAmount);
    }
    map['as_of'] = Variable<DateTime>(asOf);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      instrumentId: Value(instrumentId),
      priceAmount: Value(priceAmount),
      priceCurrency: Value(priceCurrency),
      previousCloseAmount: previousCloseAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(previousCloseAmount),
      asOf: Value(asOf),
    );
  }

  factory DbQuote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQuote(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $QuotesTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $QuotesTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      priceAmount: serializer.fromJson<String>(json['priceAmount']),
      priceCurrency: serializer.fromJson<String>(json['priceCurrency']),
      previousCloseAmount: serializer.fromJson<String?>(
        json['previousCloseAmount'],
      ),
      asOf: serializer.fromJson<DateTime>(json['asOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $QuotesTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $QuotesTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'priceAmount': serializer.toJson<String>(priceAmount),
      'priceCurrency': serializer.toJson<String>(priceCurrency),
      'previousCloseAmount': serializer.toJson<String?>(previousCloseAmount),
      'asOf': serializer.toJson<DateTime>(asOf),
    };
  }

  DbQuote copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? instrumentId,
    String? priceAmount,
    String? priceCurrency,
    Value<String?> previousCloseAmount = const Value.absent(),
    DateTime? asOf,
  }) => DbQuote(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    instrumentId: instrumentId ?? this.instrumentId,
    priceAmount: priceAmount ?? this.priceAmount,
    priceCurrency: priceCurrency ?? this.priceCurrency,
    previousCloseAmount: previousCloseAmount.present
        ? previousCloseAmount.value
        : this.previousCloseAmount,
    asOf: asOf ?? this.asOf,
  );
  DbQuote copyWithCompanion(QuotesCompanion data) {
    return DbQuote(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      priceAmount: data.priceAmount.present
          ? data.priceAmount.value
          : this.priceAmount,
      priceCurrency: data.priceCurrency.present
          ? data.priceCurrency.value
          : this.priceCurrency,
      previousCloseAmount: data.previousCloseAmount.present
          ? data.previousCloseAmount.value
          : this.previousCloseAmount,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQuote(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('priceCurrency: $priceCurrency, ')
          ..write('previousCloseAmount: $previousCloseAmount, ')
          ..write('asOf: $asOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    instrumentId,
    priceAmount,
    priceCurrency,
    previousCloseAmount,
    asOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQuote &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.instrumentId == this.instrumentId &&
          other.priceAmount == this.priceAmount &&
          other.priceCurrency == this.priceCurrency &&
          other.previousCloseAmount == this.previousCloseAmount &&
          other.asOf == this.asOf);
}

class QuotesCompanion extends UpdateCompanion<DbQuote> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> instrumentId;
  final Value<String> priceAmount;
  final Value<String> priceCurrency;
  final Value<String?> previousCloseAmount;
  final Value<DateTime> asOf;
  final Value<int> rowid;
  const QuotesCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.priceAmount = const Value.absent(),
    this.priceCurrency = const Value.absent(),
    this.previousCloseAmount = const Value.absent(),
    this.asOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuotesCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String instrumentId,
    required String priceAmount,
    required String priceCurrency,
    this.previousCloseAmount = const Value.absent(),
    required DateTime asOf,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       instrumentId = Value(instrumentId),
       priceAmount = Value(priceAmount),
       priceCurrency = Value(priceCurrency),
       asOf = Value(asOf);
  static Insertable<DbQuote> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? instrumentId,
    Expression<String>? priceAmount,
    Expression<String>? priceCurrency,
    Expression<String>? previousCloseAmount,
    Expression<DateTime>? asOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (priceAmount != null) 'price_amount': priceAmount,
      if (priceCurrency != null) 'price_currency': priceCurrency,
      if (previousCloseAmount != null)
        'previous_close_amount': previousCloseAmount,
      if (asOf != null) 'as_of': asOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuotesCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? instrumentId,
    Value<String>? priceAmount,
    Value<String>? priceCurrency,
    Value<String?>? previousCloseAmount,
    Value<DateTime>? asOf,
    Value<int>? rowid,
  }) {
    return QuotesCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      instrumentId: instrumentId ?? this.instrumentId,
      priceAmount: priceAmount ?? this.priceAmount,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      previousCloseAmount: previousCloseAmount ?? this.previousCloseAmount,
      asOf: asOf ?? this.asOf,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $QuotesTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $QuotesTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (priceAmount.present) {
      map['price_amount'] = Variable<String>(priceAmount.value);
    }
    if (priceCurrency.present) {
      map['price_currency'] = Variable<String>(priceCurrency.value);
    }
    if (previousCloseAmount.present) {
      map['previous_close_amount'] = Variable<String>(
        previousCloseAmount.value,
      );
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('priceCurrency: $priceCurrency, ')
          ..write('previousCloseAmount: $previousCloseAmount, ')
          ..write('asOf: $asOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FxRatesTable extends FxRates with TableInfo<$FxRatesTable, DbFxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($FxRatesTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($FxRatesTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCurrencyMeta = const VerificationMeta(
    'quoteCurrency',
  );
  @override
  late final GeneratedColumn<String> quoteCurrency = GeneratedColumn<String>(
    'quote_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    baseCurrency,
    quoteCurrency,
    rate,
    observedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbFxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('quote_currency')) {
      context.handle(
        _quoteCurrencyMeta,
        quoteCurrency.isAcceptableOrUnknown(
          data['quote_currency']!,
          _quoteCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quoteCurrencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    baseCurrency,
    quoteCurrency,
    observedAt,
  };
  @override
  DbFxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFxRate(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $FxRatesTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $FxRatesTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      quoteCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_currency'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate'],
      )!,
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
    );
  }

  @override
  $FxRatesTable createAlias(String alias) {
    return $FxRatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
}

class DbFxRate extends DataClass implements Insertable<DbFxRate> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Currency one unit is converted from.
  final String baseCurrency;

  /// Currency the quoted amount is denominated in.
  final String quoteCurrency;

  /// Exact decimal units of quote currency for one base unit.
  final String rate;

  /// Reference-rate date.
  final DateTime observedAt;
  const DbFxRate({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.observedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $FxRatesTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $FxRatesTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['base_currency'] = Variable<String>(baseCurrency);
    map['quote_currency'] = Variable<String>(quoteCurrency);
    map['rate'] = Variable<String>(rate);
    map['observed_at'] = Variable<DateTime>(observedAt);
    return map;
  }

  FxRatesCompanion toCompanion(bool nullToAbsent) {
    return FxRatesCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      baseCurrency: Value(baseCurrency),
      quoteCurrency: Value(quoteCurrency),
      rate: Value(rate),
      observedAt: Value(observedAt),
    );
  }

  factory DbFxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFxRate(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $FxRatesTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $FxRatesTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      quoteCurrency: serializer.fromJson<String>(json['quoteCurrency']),
      rate: serializer.fromJson<String>(json['rate']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $FxRatesTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $FxRatesTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'quoteCurrency': serializer.toJson<String>(quoteCurrency),
      'rate': serializer.toJson<String>(rate),
      'observedAt': serializer.toJson<DateTime>(observedAt),
    };
  }

  DbFxRate copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? baseCurrency,
    String? quoteCurrency,
    String? rate,
    DateTime? observedAt,
  }) => DbFxRate(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    quoteCurrency: quoteCurrency ?? this.quoteCurrency,
    rate: rate ?? this.rate,
    observedAt: observedAt ?? this.observedAt,
  );
  DbFxRate copyWithCompanion(FxRatesCompanion data) {
    return DbFxRate(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      quoteCurrency: data.quoteCurrency.present
          ? data.quoteCurrency.value
          : this.quoteCurrency,
      rate: data.rate.present ? data.rate.value : this.rate,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFxRate(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rate: $rate, ')
          ..write('observedAt: $observedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    baseCurrency,
    quoteCurrency,
    rate,
    observedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFxRate &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.baseCurrency == this.baseCurrency &&
          other.quoteCurrency == this.quoteCurrency &&
          other.rate == this.rate &&
          other.observedAt == this.observedAt);
}

class FxRatesCompanion extends UpdateCompanion<DbFxRate> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> baseCurrency;
  final Value<String> quoteCurrency;
  final Value<String> rate;
  final Value<DateTime> observedAt;
  final Value<int> rowid;
  const FxRatesCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.quoteCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FxRatesCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String baseCurrency,
    required String quoteCurrency,
    required String rate,
    required DateTime observedAt,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       baseCurrency = Value(baseCurrency),
       quoteCurrency = Value(quoteCurrency),
       rate = Value(rate),
       observedAt = Value(observedAt);
  static Insertable<DbFxRate> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? baseCurrency,
    Expression<String>? quoteCurrency,
    Expression<String>? rate,
    Expression<DateTime>? observedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (quoteCurrency != null) 'quote_currency': quoteCurrency,
      if (rate != null) 'rate': rate,
      if (observedAt != null) 'observed_at': observedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FxRatesCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? baseCurrency,
    Value<String>? quoteCurrency,
    Value<String>? rate,
    Value<DateTime>? observedAt,
    Value<int>? rowid,
  }) {
    return FxRatesCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      rate: rate ?? this.rate,
      observedAt: observedAt ?? this.observedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $FxRatesTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $FxRatesTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (quoteCurrency.present) {
      map['quote_currency'] = Variable<String>(quoteCurrency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rate: $rate, ')
          ..write('observedAt: $observedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DividendEventsTable extends DividendEvents
    with TableInfo<$DividendEventsTable, DbDividendEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DividendEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($DividendEventsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($DividendEventsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountPerShareMeta = const VerificationMeta(
    'amountPerShare',
  );
  @override
  late final GeneratedColumn<String> amountPerShare = GeneratedColumn<String>(
    'amount_per_share',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCurrencyMeta = const VerificationMeta(
    'amountCurrency',
  );
  @override
  late final GeneratedColumn<String> amountCurrency = GeneratedColumn<String>(
    'amount_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DividendStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DividendStatus>($DividendEventsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<DividendFrequency, String>
  frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  ).withConverter<DividendFrequency>($DividendEventsTable.$converterfrequency);
  static const VerificationMeta _exDateMeta = const VerificationMeta('exDate');
  @override
  late final GeneratedColumn<DateTime> exDate = GeneratedColumn<DateTime>(
    'ex_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _declarationDateMeta = const VerificationMeta(
    'declarationDate',
  );
  @override
  late final GeneratedColumn<DateTime> declarationDate =
      GeneratedColumn<DateTime>(
        'declaration_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportedPeriodStartMeta =
      const VerificationMeta('reportedPeriodStart');
  @override
  late final GeneratedColumn<DateTime> reportedPeriodStart =
      GeneratedColumn<DateTime>(
        'reported_period_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reportedPeriodEndMeta = const VerificationMeta(
    'reportedPeriodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> reportedPeriodEnd =
      GeneratedColumn<DateTime>(
        'reported_period_end',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    amountPerShare,
    amountCurrency,
    status,
    frequency,
    exDate,
    paymentDate,
    declarationDate,
    recordDate,
    reportedPeriodStart,
    reportedPeriodEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dividend_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDividendEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('amount_per_share')) {
      context.handle(
        _amountPerShareMeta,
        amountPerShare.isAcceptableOrUnknown(
          data['amount_per_share']!,
          _amountPerShareMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPerShareMeta);
    }
    if (data.containsKey('amount_currency')) {
      context.handle(
        _amountCurrencyMeta,
        amountCurrency.isAcceptableOrUnknown(
          data['amount_currency']!,
          _amountCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCurrencyMeta);
    }
    if (data.containsKey('ex_date')) {
      context.handle(
        _exDateMeta,
        exDate.isAcceptableOrUnknown(data['ex_date']!, _exDateMeta),
      );
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('declaration_date')) {
      context.handle(
        _declarationDateMeta,
        declarationDate.isAcceptableOrUnknown(
          data['declaration_date']!,
          _declarationDateMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    }
    if (data.containsKey('reported_period_start')) {
      context.handle(
        _reportedPeriodStartMeta,
        reportedPeriodStart.isAcceptableOrUnknown(
          data['reported_period_start']!,
          _reportedPeriodStartMeta,
        ),
      );
    }
    if (data.containsKey('reported_period_end')) {
      context.handle(
        _reportedPeriodEndMeta,
        reportedPeriodEnd.isAcceptableOrUnknown(
          data['reported_period_end']!,
          _reportedPeriodEndMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDividendEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDividendEvent(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $DividendEventsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $DividendEventsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      amountPerShare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_per_share'],
      )!,
      amountCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_currency'],
      )!,
      status: $DividendEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      frequency: $DividendEventsTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      exDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ex_date'],
      ),
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      ),
      declarationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}declaration_date'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      ),
      reportedPeriodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reported_period_start'],
      ),
      reportedPeriodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reported_period_end'],
      ),
    );
  }

  @override
  $DividendEventsTable createAlias(String alias) {
    return $DividendEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
  static JsonTypeConverter2<DividendStatus, String, String> $converterstatus =
      const EnumNameConverter<DividendStatus>(DividendStatus.values);
  static JsonTypeConverter2<DividendFrequency, String, String>
  $converterfrequency = const EnumNameConverter<DividendFrequency>(
    DividendFrequency.values,
  );
}

class DbDividendEvent extends DataClass implements Insertable<DbDividendEvent> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Deterministic identifier, so re-fetching updates rather than duplicates.
  final String id;

  /// The paying instrument.
  final String instrumentId;

  /// Gross dividend per share as an exact decimal string.
  final String amountPerShare;

  /// Currency of the dividend.
  final String amountCurrency;

  /// How certain this payment is (Vision.md §9.4).
  final DividendStatus status;

  /// The payment schedule this event belongs to.
  final DividendFrequency frequency;

  /// Entitlement date. Nullable: not every provider reports it.
  final DateTime? exDate;

  /// Expected or confirmed payout date. Nullable by design, so
  /// "Payment date not yet confirmed" is representable (Vision.md §79).
  final DateTime? paymentDate;

  /// When the company announced the dividend.
  final DateTime? declarationDate;

  /// Shareholder-of-record date.
  final DateTime? recordDate;

  /// Provider reporting-period start; not an event date.
  final DateTime? reportedPeriodStart;

  /// Provider reporting-period end; not an event date.
  final DateTime? reportedPeriodEnd;
  const DbDividendEvent({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.instrumentId,
    required this.amountPerShare,
    required this.amountCurrency,
    required this.status,
    required this.frequency,
    this.exDate,
    this.paymentDate,
    this.declarationDate,
    this.recordDate,
    this.reportedPeriodStart,
    this.reportedPeriodEnd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $DividendEventsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $DividendEventsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<String>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['amount_per_share'] = Variable<String>(amountPerShare);
    map['amount_currency'] = Variable<String>(amountCurrency);
    {
      map['status'] = Variable<String>(
        $DividendEventsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['frequency'] = Variable<String>(
        $DividendEventsTable.$converterfrequency.toSql(frequency),
      );
    }
    if (!nullToAbsent || exDate != null) {
      map['ex_date'] = Variable<DateTime>(exDate);
    }
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    if (!nullToAbsent || declarationDate != null) {
      map['declaration_date'] = Variable<DateTime>(declarationDate);
    }
    if (!nullToAbsent || recordDate != null) {
      map['record_date'] = Variable<DateTime>(recordDate);
    }
    if (!nullToAbsent || reportedPeriodStart != null) {
      map['reported_period_start'] = Variable<DateTime>(reportedPeriodStart);
    }
    if (!nullToAbsent || reportedPeriodEnd != null) {
      map['reported_period_end'] = Variable<DateTime>(reportedPeriodEnd);
    }
    return map;
  }

  DividendEventsCompanion toCompanion(bool nullToAbsent) {
    return DividendEventsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      instrumentId: Value(instrumentId),
      amountPerShare: Value(amountPerShare),
      amountCurrency: Value(amountCurrency),
      status: Value(status),
      frequency: Value(frequency),
      exDate: exDate == null && nullToAbsent
          ? const Value.absent()
          : Value(exDate),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      declarationDate: declarationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(declarationDate),
      recordDate: recordDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recordDate),
      reportedPeriodStart: reportedPeriodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedPeriodStart),
      reportedPeriodEnd: reportedPeriodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedPeriodEnd),
    );
  }

  factory DbDividendEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDividendEvent(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $DividendEventsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $DividendEventsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<String>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      amountPerShare: serializer.fromJson<String>(json['amountPerShare']),
      amountCurrency: serializer.fromJson<String>(json['amountCurrency']),
      status: $DividendEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      frequency: $DividendEventsTable.$converterfrequency.fromJson(
        serializer.fromJson<String>(json['frequency']),
      ),
      exDate: serializer.fromJson<DateTime?>(json['exDate']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      declarationDate: serializer.fromJson<DateTime?>(json['declarationDate']),
      recordDate: serializer.fromJson<DateTime?>(json['recordDate']),
      reportedPeriodStart: serializer.fromJson<DateTime?>(
        json['reportedPeriodStart'],
      ),
      reportedPeriodEnd: serializer.fromJson<DateTime?>(
        json['reportedPeriodEnd'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $DividendEventsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $DividendEventsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<String>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'amountPerShare': serializer.toJson<String>(amountPerShare),
      'amountCurrency': serializer.toJson<String>(amountCurrency),
      'status': serializer.toJson<String>(
        $DividendEventsTable.$converterstatus.toJson(status),
      ),
      'frequency': serializer.toJson<String>(
        $DividendEventsTable.$converterfrequency.toJson(frequency),
      ),
      'exDate': serializer.toJson<DateTime?>(exDate),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'declarationDate': serializer.toJson<DateTime?>(declarationDate),
      'recordDate': serializer.toJson<DateTime?>(recordDate),
      'reportedPeriodStart': serializer.toJson<DateTime?>(reportedPeriodStart),
      'reportedPeriodEnd': serializer.toJson<DateTime?>(reportedPeriodEnd),
    };
  }

  DbDividendEvent copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? id,
    String? instrumentId,
    String? amountPerShare,
    String? amountCurrency,
    DividendStatus? status,
    DividendFrequency? frequency,
    Value<DateTime?> exDate = const Value.absent(),
    Value<DateTime?> paymentDate = const Value.absent(),
    Value<DateTime?> declarationDate = const Value.absent(),
    Value<DateTime?> recordDate = const Value.absent(),
    Value<DateTime?> reportedPeriodStart = const Value.absent(),
    Value<DateTime?> reportedPeriodEnd = const Value.absent(),
  }) => DbDividendEvent(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    amountPerShare: amountPerShare ?? this.amountPerShare,
    amountCurrency: amountCurrency ?? this.amountCurrency,
    status: status ?? this.status,
    frequency: frequency ?? this.frequency,
    exDate: exDate.present ? exDate.value : this.exDate,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    declarationDate: declarationDate.present
        ? declarationDate.value
        : this.declarationDate,
    recordDate: recordDate.present ? recordDate.value : this.recordDate,
    reportedPeriodStart: reportedPeriodStart.present
        ? reportedPeriodStart.value
        : this.reportedPeriodStart,
    reportedPeriodEnd: reportedPeriodEnd.present
        ? reportedPeriodEnd.value
        : this.reportedPeriodEnd,
  );
  DbDividendEvent copyWithCompanion(DividendEventsCompanion data) {
    return DbDividendEvent(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      amountPerShare: data.amountPerShare.present
          ? data.amountPerShare.value
          : this.amountPerShare,
      amountCurrency: data.amountCurrency.present
          ? data.amountCurrency.value
          : this.amountCurrency,
      status: data.status.present ? data.status.value : this.status,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      exDate: data.exDate.present ? data.exDate.value : this.exDate,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      declarationDate: data.declarationDate.present
          ? data.declarationDate.value
          : this.declarationDate,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      reportedPeriodStart: data.reportedPeriodStart.present
          ? data.reportedPeriodStart.value
          : this.reportedPeriodStart,
      reportedPeriodEnd: data.reportedPeriodEnd.present
          ? data.reportedPeriodEnd.value
          : this.reportedPeriodEnd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDividendEvent(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('amountPerShare: $amountPerShare, ')
          ..write('amountCurrency: $amountCurrency, ')
          ..write('status: $status, ')
          ..write('frequency: $frequency, ')
          ..write('exDate: $exDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('declarationDate: $declarationDate, ')
          ..write('recordDate: $recordDate, ')
          ..write('reportedPeriodStart: $reportedPeriodStart, ')
          ..write('reportedPeriodEnd: $reportedPeriodEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    amountPerShare,
    amountCurrency,
    status,
    frequency,
    exDate,
    paymentDate,
    declarationDate,
    recordDate,
    reportedPeriodStart,
    reportedPeriodEnd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDividendEvent &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.amountPerShare == this.amountPerShare &&
          other.amountCurrency == this.amountCurrency &&
          other.status == this.status &&
          other.frequency == this.frequency &&
          other.exDate == this.exDate &&
          other.paymentDate == this.paymentDate &&
          other.declarationDate == this.declarationDate &&
          other.recordDate == this.recordDate &&
          other.reportedPeriodStart == this.reportedPeriodStart &&
          other.reportedPeriodEnd == this.reportedPeriodEnd);
}

class DividendEventsCompanion extends UpdateCompanion<DbDividendEvent> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> id;
  final Value<String> instrumentId;
  final Value<String> amountPerShare;
  final Value<String> amountCurrency;
  final Value<DividendStatus> status;
  final Value<DividendFrequency> frequency;
  final Value<DateTime?> exDate;
  final Value<DateTime?> paymentDate;
  final Value<DateTime?> declarationDate;
  final Value<DateTime?> recordDate;
  final Value<DateTime?> reportedPeriodStart;
  final Value<DateTime?> reportedPeriodEnd;
  final Value<int> rowid;
  const DividendEventsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.amountPerShare = const Value.absent(),
    this.amountCurrency = const Value.absent(),
    this.status = const Value.absent(),
    this.frequency = const Value.absent(),
    this.exDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.declarationDate = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.reportedPeriodStart = const Value.absent(),
    this.reportedPeriodEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DividendEventsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String id,
    required String instrumentId,
    required String amountPerShare,
    required String amountCurrency,
    required DividendStatus status,
    this.frequency = const Value.absent(),
    this.exDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.declarationDate = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.reportedPeriodStart = const Value.absent(),
    this.reportedPeriodEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       id = Value(id),
       instrumentId = Value(instrumentId),
       amountPerShare = Value(amountPerShare),
       amountCurrency = Value(amountCurrency),
       status = Value(status);
  static Insertable<DbDividendEvent> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? id,
    Expression<String>? instrumentId,
    Expression<String>? amountPerShare,
    Expression<String>? amountCurrency,
    Expression<String>? status,
    Expression<String>? frequency,
    Expression<DateTime>? exDate,
    Expression<DateTime>? paymentDate,
    Expression<DateTime>? declarationDate,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? reportedPeriodStart,
    Expression<DateTime>? reportedPeriodEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (amountPerShare != null) 'amount_per_share': amountPerShare,
      if (amountCurrency != null) 'amount_currency': amountCurrency,
      if (status != null) 'status': status,
      if (frequency != null) 'frequency': frequency,
      if (exDate != null) 'ex_date': exDate,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (declarationDate != null) 'declaration_date': declarationDate,
      if (recordDate != null) 'record_date': recordDate,
      if (reportedPeriodStart != null)
        'reported_period_start': reportedPeriodStart,
      if (reportedPeriodEnd != null) 'reported_period_end': reportedPeriodEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DividendEventsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? id,
    Value<String>? instrumentId,
    Value<String>? amountPerShare,
    Value<String>? amountCurrency,
    Value<DividendStatus>? status,
    Value<DividendFrequency>? frequency,
    Value<DateTime?>? exDate,
    Value<DateTime?>? paymentDate,
    Value<DateTime?>? declarationDate,
    Value<DateTime?>? recordDate,
    Value<DateTime?>? reportedPeriodStart,
    Value<DateTime?>? reportedPeriodEnd,
    Value<int>? rowid,
  }) {
    return DividendEventsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      amountPerShare: amountPerShare ?? this.amountPerShare,
      amountCurrency: amountCurrency ?? this.amountCurrency,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      exDate: exDate ?? this.exDate,
      paymentDate: paymentDate ?? this.paymentDate,
      declarationDate: declarationDate ?? this.declarationDate,
      recordDate: recordDate ?? this.recordDate,
      reportedPeriodStart: reportedPeriodStart ?? this.reportedPeriodStart,
      reportedPeriodEnd: reportedPeriodEnd ?? this.reportedPeriodEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $DividendEventsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $DividendEventsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (amountPerShare.present) {
      map['amount_per_share'] = Variable<String>(amountPerShare.value);
    }
    if (amountCurrency.present) {
      map['amount_currency'] = Variable<String>(amountCurrency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DividendEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(
        $DividendEventsTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (exDate.present) {
      map['ex_date'] = Variable<DateTime>(exDate.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (declarationDate.present) {
      map['declaration_date'] = Variable<DateTime>(declarationDate.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (reportedPeriodStart.present) {
      map['reported_period_start'] = Variable<DateTime>(
        reportedPeriodStart.value,
      );
    }
    if (reportedPeriodEnd.present) {
      map['reported_period_end'] = Variable<DateTime>(reportedPeriodEnd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DividendEventsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('amountPerShare: $amountPerShare, ')
          ..write('amountCurrency: $amountCurrency, ')
          ..write('status: $status, ')
          ..write('frequency: $frequency, ')
          ..write('exDate: $exDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('declarationDate: $declarationDate, ')
          ..write('recordDate: $recordDate, ')
          ..write('reportedPeriodStart: $reportedPeriodStart, ')
          ..write('reportedPeriodEnd: $reportedPeriodEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EarningsEventsTable extends EarningsEvents
    with TableInfo<$EarningsEventsTable, DbEarningsEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarningsEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($EarningsEventsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($EarningsEventsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EarningsStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EarningsStatus>($EarningsEventsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<EarningsTiming, String> timing =
      GeneratedColumn<String>(
        'timing',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('unspecified'),
      ).withConverter<EarningsTiming>($EarningsEventsTable.$convertertiming);
  static const VerificationMeta _fiscalPeriodMeta = const VerificationMeta(
    'fiscalPeriod',
  );
  @override
  late final GeneratedColumn<String> fiscalPeriod = GeneratedColumn<String>(
    'fiscal_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epsEstimateMeta = const VerificationMeta(
    'epsEstimate',
  );
  @override
  late final GeneratedColumn<String> epsEstimate = GeneratedColumn<String>(
    'eps_estimate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epsActualMeta = const VerificationMeta(
    'epsActual',
  );
  @override
  late final GeneratedColumn<String> epsActual = GeneratedColumn<String>(
    'eps_actual',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revenueEstimateMeta = const VerificationMeta(
    'revenueEstimate',
  );
  @override
  late final GeneratedColumn<String> revenueEstimate = GeneratedColumn<String>(
    'revenue_estimate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revenueActualMeta = const VerificationMeta(
    'revenueActual',
  );
  @override
  late final GeneratedColumn<String> revenueActual = GeneratedColumn<String>(
    'revenue_actual',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _figuresCurrencyMeta = const VerificationMeta(
    'figuresCurrency',
  );
  @override
  late final GeneratedColumn<String> figuresCurrency = GeneratedColumn<String>(
    'figures_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    scheduledFor,
    status,
    timing,
    fiscalPeriod,
    epsEstimate,
    epsActual,
    revenueEstimate,
    revenueActual,
    figuresCurrency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earnings_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbEarningsEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('fiscal_period')) {
      context.handle(
        _fiscalPeriodMeta,
        fiscalPeriod.isAcceptableOrUnknown(
          data['fiscal_period']!,
          _fiscalPeriodMeta,
        ),
      );
    }
    if (data.containsKey('eps_estimate')) {
      context.handle(
        _epsEstimateMeta,
        epsEstimate.isAcceptableOrUnknown(
          data['eps_estimate']!,
          _epsEstimateMeta,
        ),
      );
    }
    if (data.containsKey('eps_actual')) {
      context.handle(
        _epsActualMeta,
        epsActual.isAcceptableOrUnknown(data['eps_actual']!, _epsActualMeta),
      );
    }
    if (data.containsKey('revenue_estimate')) {
      context.handle(
        _revenueEstimateMeta,
        revenueEstimate.isAcceptableOrUnknown(
          data['revenue_estimate']!,
          _revenueEstimateMeta,
        ),
      );
    }
    if (data.containsKey('revenue_actual')) {
      context.handle(
        _revenueActualMeta,
        revenueActual.isAcceptableOrUnknown(
          data['revenue_actual']!,
          _revenueActualMeta,
        ),
      );
    }
    if (data.containsKey('figures_currency')) {
      context.handle(
        _figuresCurrencyMeta,
        figuresCurrency.isAcceptableOrUnknown(
          data['figures_currency']!,
          _figuresCurrencyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbEarningsEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbEarningsEvent(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $EarningsEventsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $EarningsEventsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
      status: $EarningsEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      timing: $EarningsEventsTable.$convertertiming.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}timing'],
        )!,
      ),
      fiscalPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_period'],
      ),
      epsEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eps_estimate'],
      ),
      epsActual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eps_actual'],
      ),
      revenueEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revenue_estimate'],
      ),
      revenueActual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revenue_actual'],
      ),
      figuresCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}figures_currency'],
      ),
    );
  }

  @override
  $EarningsEventsTable createAlias(String alias) {
    return $EarningsEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
  static JsonTypeConverter2<EarningsStatus, String, String> $converterstatus =
      const EnumNameConverter<EarningsStatus>(EarningsStatus.values);
  static JsonTypeConverter2<EarningsTiming, String, String> $convertertiming =
      const EnumNameConverter<EarningsTiming>(EarningsTiming.values);
}

class DbEarningsEvent extends DataClass implements Insertable<DbEarningsEvent> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Deterministic identifier.
  final String id;

  /// The reporting instrument.
  final String instrumentId;

  /// Date of the release.
  final DateTime scheduledFor;

  /// How firm the date is.
  final EarningsStatus status;

  /// When during the day the release happens.
  final EarningsTiming timing;

  /// Fiscal period label, e.g. `Q2 2026`.
  final String? fiscalPeriod;

  /// Consensus earnings per share.
  final String? epsEstimate;

  /// Reported earnings per share.
  final String? epsActual;

  /// Consensus revenue.
  final String? revenueEstimate;

  /// Reported revenue.
  final String? revenueActual;

  /// Currency of the EPS and revenue figures.
  final String? figuresCurrency;
  const DbEarningsEvent({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.instrumentId,
    required this.scheduledFor,
    required this.status,
    required this.timing,
    this.fiscalPeriod,
    this.epsEstimate,
    this.epsActual,
    this.revenueEstimate,
    this.revenueActual,
    this.figuresCurrency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $EarningsEventsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $EarningsEventsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<String>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    {
      map['status'] = Variable<String>(
        $EarningsEventsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['timing'] = Variable<String>(
        $EarningsEventsTable.$convertertiming.toSql(timing),
      );
    }
    if (!nullToAbsent || fiscalPeriod != null) {
      map['fiscal_period'] = Variable<String>(fiscalPeriod);
    }
    if (!nullToAbsent || epsEstimate != null) {
      map['eps_estimate'] = Variable<String>(epsEstimate);
    }
    if (!nullToAbsent || epsActual != null) {
      map['eps_actual'] = Variable<String>(epsActual);
    }
    if (!nullToAbsent || revenueEstimate != null) {
      map['revenue_estimate'] = Variable<String>(revenueEstimate);
    }
    if (!nullToAbsent || revenueActual != null) {
      map['revenue_actual'] = Variable<String>(revenueActual);
    }
    if (!nullToAbsent || figuresCurrency != null) {
      map['figures_currency'] = Variable<String>(figuresCurrency);
    }
    return map;
  }

  EarningsEventsCompanion toCompanion(bool nullToAbsent) {
    return EarningsEventsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      instrumentId: Value(instrumentId),
      scheduledFor: Value(scheduledFor),
      status: Value(status),
      timing: Value(timing),
      fiscalPeriod: fiscalPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(fiscalPeriod),
      epsEstimate: epsEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(epsEstimate),
      epsActual: epsActual == null && nullToAbsent
          ? const Value.absent()
          : Value(epsActual),
      revenueEstimate: revenueEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(revenueEstimate),
      revenueActual: revenueActual == null && nullToAbsent
          ? const Value.absent()
          : Value(revenueActual),
      figuresCurrency: figuresCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(figuresCurrency),
    );
  }

  factory DbEarningsEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbEarningsEvent(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $EarningsEventsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $EarningsEventsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<String>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      status: $EarningsEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      timing: $EarningsEventsTable.$convertertiming.fromJson(
        serializer.fromJson<String>(json['timing']),
      ),
      fiscalPeriod: serializer.fromJson<String?>(json['fiscalPeriod']),
      epsEstimate: serializer.fromJson<String?>(json['epsEstimate']),
      epsActual: serializer.fromJson<String?>(json['epsActual']),
      revenueEstimate: serializer.fromJson<String?>(json['revenueEstimate']),
      revenueActual: serializer.fromJson<String?>(json['revenueActual']),
      figuresCurrency: serializer.fromJson<String?>(json['figuresCurrency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $EarningsEventsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $EarningsEventsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<String>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'status': serializer.toJson<String>(
        $EarningsEventsTable.$converterstatus.toJson(status),
      ),
      'timing': serializer.toJson<String>(
        $EarningsEventsTable.$convertertiming.toJson(timing),
      ),
      'fiscalPeriod': serializer.toJson<String?>(fiscalPeriod),
      'epsEstimate': serializer.toJson<String?>(epsEstimate),
      'epsActual': serializer.toJson<String?>(epsActual),
      'revenueEstimate': serializer.toJson<String?>(revenueEstimate),
      'revenueActual': serializer.toJson<String?>(revenueActual),
      'figuresCurrency': serializer.toJson<String?>(figuresCurrency),
    };
  }

  DbEarningsEvent copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? id,
    String? instrumentId,
    DateTime? scheduledFor,
    EarningsStatus? status,
    EarningsTiming? timing,
    Value<String?> fiscalPeriod = const Value.absent(),
    Value<String?> epsEstimate = const Value.absent(),
    Value<String?> epsActual = const Value.absent(),
    Value<String?> revenueEstimate = const Value.absent(),
    Value<String?> revenueActual = const Value.absent(),
    Value<String?> figuresCurrency = const Value.absent(),
  }) => DbEarningsEvent(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    status: status ?? this.status,
    timing: timing ?? this.timing,
    fiscalPeriod: fiscalPeriod.present ? fiscalPeriod.value : this.fiscalPeriod,
    epsEstimate: epsEstimate.present ? epsEstimate.value : this.epsEstimate,
    epsActual: epsActual.present ? epsActual.value : this.epsActual,
    revenueEstimate: revenueEstimate.present
        ? revenueEstimate.value
        : this.revenueEstimate,
    revenueActual: revenueActual.present
        ? revenueActual.value
        : this.revenueActual,
    figuresCurrency: figuresCurrency.present
        ? figuresCurrency.value
        : this.figuresCurrency,
  );
  DbEarningsEvent copyWithCompanion(EarningsEventsCompanion data) {
    return DbEarningsEvent(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      status: data.status.present ? data.status.value : this.status,
      timing: data.timing.present ? data.timing.value : this.timing,
      fiscalPeriod: data.fiscalPeriod.present
          ? data.fiscalPeriod.value
          : this.fiscalPeriod,
      epsEstimate: data.epsEstimate.present
          ? data.epsEstimate.value
          : this.epsEstimate,
      epsActual: data.epsActual.present ? data.epsActual.value : this.epsActual,
      revenueEstimate: data.revenueEstimate.present
          ? data.revenueEstimate.value
          : this.revenueEstimate,
      revenueActual: data.revenueActual.present
          ? data.revenueActual.value
          : this.revenueActual,
      figuresCurrency: data.figuresCurrency.present
          ? data.figuresCurrency.value
          : this.figuresCurrency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbEarningsEvent(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('status: $status, ')
          ..write('timing: $timing, ')
          ..write('fiscalPeriod: $fiscalPeriod, ')
          ..write('epsEstimate: $epsEstimate, ')
          ..write('epsActual: $epsActual, ')
          ..write('revenueEstimate: $revenueEstimate, ')
          ..write('revenueActual: $revenueActual, ')
          ..write('figuresCurrency: $figuresCurrency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    scheduledFor,
    status,
    timing,
    fiscalPeriod,
    epsEstimate,
    epsActual,
    revenueEstimate,
    revenueActual,
    figuresCurrency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbEarningsEvent &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.scheduledFor == this.scheduledFor &&
          other.status == this.status &&
          other.timing == this.timing &&
          other.fiscalPeriod == this.fiscalPeriod &&
          other.epsEstimate == this.epsEstimate &&
          other.epsActual == this.epsActual &&
          other.revenueEstimate == this.revenueEstimate &&
          other.revenueActual == this.revenueActual &&
          other.figuresCurrency == this.figuresCurrency);
}

class EarningsEventsCompanion extends UpdateCompanion<DbEarningsEvent> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> id;
  final Value<String> instrumentId;
  final Value<DateTime> scheduledFor;
  final Value<EarningsStatus> status;
  final Value<EarningsTiming> timing;
  final Value<String?> fiscalPeriod;
  final Value<String?> epsEstimate;
  final Value<String?> epsActual;
  final Value<String?> revenueEstimate;
  final Value<String?> revenueActual;
  final Value<String?> figuresCurrency;
  final Value<int> rowid;
  const EarningsEventsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.status = const Value.absent(),
    this.timing = const Value.absent(),
    this.fiscalPeriod = const Value.absent(),
    this.epsEstimate = const Value.absent(),
    this.epsActual = const Value.absent(),
    this.revenueEstimate = const Value.absent(),
    this.revenueActual = const Value.absent(),
    this.figuresCurrency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EarningsEventsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String id,
    required String instrumentId,
    required DateTime scheduledFor,
    required EarningsStatus status,
    this.timing = const Value.absent(),
    this.fiscalPeriod = const Value.absent(),
    this.epsEstimate = const Value.absent(),
    this.epsActual = const Value.absent(),
    this.revenueEstimate = const Value.absent(),
    this.revenueActual = const Value.absent(),
    this.figuresCurrency = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       id = Value(id),
       instrumentId = Value(instrumentId),
       scheduledFor = Value(scheduledFor),
       status = Value(status);
  static Insertable<DbEarningsEvent> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? id,
    Expression<String>? instrumentId,
    Expression<DateTime>? scheduledFor,
    Expression<String>? status,
    Expression<String>? timing,
    Expression<String>? fiscalPeriod,
    Expression<String>? epsEstimate,
    Expression<String>? epsActual,
    Expression<String>? revenueEstimate,
    Expression<String>? revenueActual,
    Expression<String>? figuresCurrency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (status != null) 'status': status,
      if (timing != null) 'timing': timing,
      if (fiscalPeriod != null) 'fiscal_period': fiscalPeriod,
      if (epsEstimate != null) 'eps_estimate': epsEstimate,
      if (epsActual != null) 'eps_actual': epsActual,
      if (revenueEstimate != null) 'revenue_estimate': revenueEstimate,
      if (revenueActual != null) 'revenue_actual': revenueActual,
      if (figuresCurrency != null) 'figures_currency': figuresCurrency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EarningsEventsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? id,
    Value<String>? instrumentId,
    Value<DateTime>? scheduledFor,
    Value<EarningsStatus>? status,
    Value<EarningsTiming>? timing,
    Value<String?>? fiscalPeriod,
    Value<String?>? epsEstimate,
    Value<String?>? epsActual,
    Value<String?>? revenueEstimate,
    Value<String?>? revenueActual,
    Value<String?>? figuresCurrency,
    Value<int>? rowid,
  }) {
    return EarningsEventsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      status: status ?? this.status,
      timing: timing ?? this.timing,
      fiscalPeriod: fiscalPeriod ?? this.fiscalPeriod,
      epsEstimate: epsEstimate ?? this.epsEstimate,
      epsActual: epsActual ?? this.epsActual,
      revenueEstimate: revenueEstimate ?? this.revenueEstimate,
      revenueActual: revenueActual ?? this.revenueActual,
      figuresCurrency: figuresCurrency ?? this.figuresCurrency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $EarningsEventsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $EarningsEventsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $EarningsEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (timing.present) {
      map['timing'] = Variable<String>(
        $EarningsEventsTable.$convertertiming.toSql(timing.value),
      );
    }
    if (fiscalPeriod.present) {
      map['fiscal_period'] = Variable<String>(fiscalPeriod.value);
    }
    if (epsEstimate.present) {
      map['eps_estimate'] = Variable<String>(epsEstimate.value);
    }
    if (epsActual.present) {
      map['eps_actual'] = Variable<String>(epsActual.value);
    }
    if (revenueEstimate.present) {
      map['revenue_estimate'] = Variable<String>(revenueEstimate.value);
    }
    if (revenueActual.present) {
      map['revenue_actual'] = Variable<String>(revenueActual.value);
    }
    if (figuresCurrency.present) {
      map['figures_currency'] = Variable<String>(figuresCurrency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarningsEventsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('status: $status, ')
          ..write('timing: $timing, ')
          ..write('fiscalPeriod: $fiscalPeriod, ')
          ..write('epsEstimate: $epsEstimate, ')
          ..write('epsActual: $epsActual, ')
          ..write('revenueEstimate: $revenueEstimate, ')
          ..write('revenueActual: $revenueActual, ')
          ..write('figuresCurrency: $figuresCurrency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CorporateEventsTable extends CorporateEvents
    with TableInfo<$CorporateEventsTable, DbCorporateEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CorporateEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($CorporateEventsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($CorporateEventsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CorporateEventType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CorporateEventType>($CorporateEventsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<CorporateEventStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CorporateEventStatus>($CorporateEventsTable.$converterstatus);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    scheduledFor,
    type,
    status,
    title,
    url,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'corporate_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCorporateEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCorporateEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCorporateEvent(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $CorporateEventsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $CorporateEventsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
      type: $CorporateEventsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $CorporateEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
    );
  }

  @override
  $CorporateEventsTable createAlias(String alias) {
    return $CorporateEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
  static JsonTypeConverter2<CorporateEventType, String, String> $convertertype =
      const EnumNameConverter<CorporateEventType>(CorporateEventType.values);
  static JsonTypeConverter2<CorporateEventStatus, String, String>
  $converterstatus = const EnumNameConverter<CorporateEventStatus>(
    CorporateEventStatus.values,
  );
}

class DbCorporateEvent extends DataClass
    implements Insertable<DbCorporateEvent> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Stable provider or locally generated identifier.
  final String id;

  /// The company instrument.
  final String instrumentId;

  /// Calendar date or timestamp supplied by the source.
  final DateTime scheduledFor;

  /// Normalized category.
  final CorporateEventType type;

  /// Date certainty and lifecycle state.
  final CorporateEventStatus status;

  /// Human-readable source label.
  final String title;

  /// Optional original source page.
  final String? url;
  const DbCorporateEvent({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.instrumentId,
    required this.scheduledFor,
    required this.type,
    required this.status,
    required this.title,
    this.url,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $CorporateEventsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $CorporateEventsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<String>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    {
      map['type'] = Variable<String>(
        $CorporateEventsTable.$convertertype.toSql(type),
      );
    }
    {
      map['status'] = Variable<String>(
        $CorporateEventsTable.$converterstatus.toSql(status),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  CorporateEventsCompanion toCompanion(bool nullToAbsent) {
    return CorporateEventsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      instrumentId: Value(instrumentId),
      scheduledFor: Value(scheduledFor),
      type: Value(type),
      status: Value(status),
      title: Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory DbCorporateEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCorporateEvent(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $CorporateEventsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $CorporateEventsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<String>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      type: $CorporateEventsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      status: $CorporateEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $CorporateEventsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $CorporateEventsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<String>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'type': serializer.toJson<String>(
        $CorporateEventsTable.$convertertype.toJson(type),
      ),
      'status': serializer.toJson<String>(
        $CorporateEventsTable.$converterstatus.toJson(status),
      ),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String?>(url),
    };
  }

  DbCorporateEvent copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? id,
    String? instrumentId,
    DateTime? scheduledFor,
    CorporateEventType? type,
    CorporateEventStatus? status,
    String? title,
    Value<String?> url = const Value.absent(),
  }) => DbCorporateEvent(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    type: type ?? this.type,
    status: status ?? this.status,
    title: title ?? this.title,
    url: url.present ? url.value : this.url,
  );
  DbCorporateEvent copyWithCompanion(CorporateEventsCompanion data) {
    return DbCorporateEvent(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCorporateEvent(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    scheduledFor,
    type,
    status,
    title,
    url,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCorporateEvent &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.scheduledFor == this.scheduledFor &&
          other.type == this.type &&
          other.status == this.status &&
          other.title == this.title &&
          other.url == this.url);
}

class CorporateEventsCompanion extends UpdateCompanion<DbCorporateEvent> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> id;
  final Value<String> instrumentId;
  final Value<DateTime> scheduledFor;
  final Value<CorporateEventType> type;
  final Value<CorporateEventStatus> status;
  final Value<String> title;
  final Value<String?> url;
  final Value<int> rowid;
  const CorporateEventsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CorporateEventsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String id,
    required String instrumentId,
    required DateTime scheduledFor,
    required CorporateEventType type,
    required CorporateEventStatus status,
    required String title,
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       id = Value(id),
       instrumentId = Value(instrumentId),
       scheduledFor = Value(scheduledFor),
       type = Value(type),
       status = Value(status),
       title = Value(title);
  static Insertable<DbCorporateEvent> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? id,
    Expression<String>? instrumentId,
    Expression<DateTime>? scheduledFor,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? title,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CorporateEventsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? id,
    Value<String>? instrumentId,
    Value<DateTime>? scheduledFor,
    Value<CorporateEventType>? type,
    Value<CorporateEventStatus>? status,
    Value<String>? title,
    Value<String?>? url,
    Value<int>? rowid,
  }) {
    return CorporateEventsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $CorporateEventsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $CorporateEventsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $CorporateEventsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CorporateEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CorporateEventsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NewsItemsTable extends NewsItems
    with TableInfo<$NewsItemsTable, DbNewsItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewsItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($NewsItemsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($NewsItemsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headlineMeta = const VerificationMeta(
    'headline',
  );
  @override
  late final GeneratedColumn<String> headline = GeneratedColumn<String>(
    'headline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NewsCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('general'),
      ).withConverter<NewsCategory>($NewsItemsTable.$convertercategory);
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relevanceMeta = const VerificationMeta(
    'relevance',
  );
  @override
  late final GeneratedColumn<double> relevance = GeneratedColumn<double>(
    'relevance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    headline,
    sourceName,
    publishedAt,
    url,
    category,
    summary,
    relevance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'news_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbNewsItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('headline')) {
      context.handle(
        _headlineMeta,
        headline.isAcceptableOrUnknown(data['headline']!, _headlineMeta),
      );
    } else if (isInserting) {
      context.missing(_headlineMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('relevance')) {
      context.handle(
        _relevanceMeta,
        relevance.isAcceptableOrUnknown(data['relevance']!, _relevanceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbNewsItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbNewsItem(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $NewsItemsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $NewsItemsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      headline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headline'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      category: $NewsItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      relevance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}relevance'],
      ),
    );
  }

  @override
  $NewsItemsTable createAlias(String alias) {
    return $NewsItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
  static JsonTypeConverter2<NewsCategory, String, String> $convertercategory =
      const EnumNameConverter<NewsCategory>(NewsCategory.values);
}

class DbNewsItem extends DataClass implements Insertable<DbNewsItem> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Deterministic identifier, used to deduplicate across providers.
  final String id;

  /// The headline as published.
  final String headline;

  /// Publication name.
  final String sourceName;

  /// When it was published.
  final DateTime publishedAt;

  /// Link to the original article. The app never stores article bodies.
  final String url;

  /// What the item is about.
  final NewsCategory category;

  /// Short provider-supplied summary.
  final String? summary;

  /// Relevance to the portfolio, assigned by ranking (Vision.md §17).
  final double? relevance;
  const DbNewsItem({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.headline,
    required this.sourceName,
    required this.publishedAt,
    required this.url,
    required this.category,
    this.summary,
    this.relevance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $NewsItemsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $NewsItemsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<String>(id);
    map['headline'] = Variable<String>(headline);
    map['source_name'] = Variable<String>(sourceName);
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['url'] = Variable<String>(url);
    {
      map['category'] = Variable<String>(
        $NewsItemsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || relevance != null) {
      map['relevance'] = Variable<double>(relevance);
    }
    return map;
  }

  NewsItemsCompanion toCompanion(bool nullToAbsent) {
    return NewsItemsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      headline: Value(headline),
      sourceName: Value(sourceName),
      publishedAt: Value(publishedAt),
      url: Value(url),
      category: Value(category),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      relevance: relevance == null && nullToAbsent
          ? const Value.absent()
          : Value(relevance),
    );
  }

  factory DbNewsItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbNewsItem(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $NewsItemsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $NewsItemsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<String>(json['id']),
      headline: serializer.fromJson<String>(json['headline']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      url: serializer.fromJson<String>(json['url']),
      category: $NewsItemsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      summary: serializer.fromJson<String?>(json['summary']),
      relevance: serializer.fromJson<double?>(json['relevance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $NewsItemsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $NewsItemsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<String>(id),
      'headline': serializer.toJson<String>(headline),
      'sourceName': serializer.toJson<String>(sourceName),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'url': serializer.toJson<String>(url),
      'category': serializer.toJson<String>(
        $NewsItemsTable.$convertercategory.toJson(category),
      ),
      'summary': serializer.toJson<String?>(summary),
      'relevance': serializer.toJson<double?>(relevance),
    };
  }

  DbNewsItem copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? id,
    String? headline,
    String? sourceName,
    DateTime? publishedAt,
    String? url,
    NewsCategory? category,
    Value<String?> summary = const Value.absent(),
    Value<double?> relevance = const Value.absent(),
  }) => DbNewsItem(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    headline: headline ?? this.headline,
    sourceName: sourceName ?? this.sourceName,
    publishedAt: publishedAt ?? this.publishedAt,
    url: url ?? this.url,
    category: category ?? this.category,
    summary: summary.present ? summary.value : this.summary,
    relevance: relevance.present ? relevance.value : this.relevance,
  );
  DbNewsItem copyWithCompanion(NewsItemsCompanion data) {
    return DbNewsItem(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      headline: data.headline.present ? data.headline.value : this.headline,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      url: data.url.present ? data.url.value : this.url,
      category: data.category.present ? data.category.value : this.category,
      summary: data.summary.present ? data.summary.value : this.summary,
      relevance: data.relevance.present ? data.relevance.value : this.relevance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbNewsItem(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('headline: $headline, ')
          ..write('sourceName: $sourceName, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('url: $url, ')
          ..write('category: $category, ')
          ..write('summary: $summary, ')
          ..write('relevance: $relevance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    headline,
    sourceName,
    publishedAt,
    url,
    category,
    summary,
    relevance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbNewsItem &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.headline == this.headline &&
          other.sourceName == this.sourceName &&
          other.publishedAt == this.publishedAt &&
          other.url == this.url &&
          other.category == this.category &&
          other.summary == this.summary &&
          other.relevance == this.relevance);
}

class NewsItemsCompanion extends UpdateCompanion<DbNewsItem> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> id;
  final Value<String> headline;
  final Value<String> sourceName;
  final Value<DateTime> publishedAt;
  final Value<String> url;
  final Value<NewsCategory> category;
  final Value<String?> summary;
  final Value<double?> relevance;
  final Value<int> rowid;
  const NewsItemsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.headline = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.url = const Value.absent(),
    this.category = const Value.absent(),
    this.summary = const Value.absent(),
    this.relevance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NewsItemsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String id,
    required String headline,
    required String sourceName,
    required DateTime publishedAt,
    required String url,
    this.category = const Value.absent(),
    this.summary = const Value.absent(),
    this.relevance = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       id = Value(id),
       headline = Value(headline),
       sourceName = Value(sourceName),
       publishedAt = Value(publishedAt),
       url = Value(url);
  static Insertable<DbNewsItem> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? id,
    Expression<String>? headline,
    Expression<String>? sourceName,
    Expression<DateTime>? publishedAt,
    Expression<String>? url,
    Expression<String>? category,
    Expression<String>? summary,
    Expression<double>? relevance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (headline != null) 'headline': headline,
      if (sourceName != null) 'source_name': sourceName,
      if (publishedAt != null) 'published_at': publishedAt,
      if (url != null) 'url': url,
      if (category != null) 'category': category,
      if (summary != null) 'summary': summary,
      if (relevance != null) 'relevance': relevance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NewsItemsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? id,
    Value<String>? headline,
    Value<String>? sourceName,
    Value<DateTime>? publishedAt,
    Value<String>? url,
    Value<NewsCategory>? category,
    Value<String?>? summary,
    Value<double?>? relevance,
    Value<int>? rowid,
  }) {
    return NewsItemsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      headline: headline ?? this.headline,
      sourceName: sourceName ?? this.sourceName,
      publishedAt: publishedAt ?? this.publishedAt,
      url: url ?? this.url,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      relevance: relevance ?? this.relevance,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $NewsItemsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $NewsItemsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (headline.present) {
      map['headline'] = Variable<String>(headline.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $NewsItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (relevance.present) {
      map['relevance'] = Variable<double>(relevance.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewsItemsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('headline: $headline, ')
          ..write('sourceName: $sourceName, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('url: $url, ')
          ..write('category: $category, ')
          ..write('summary: $summary, ')
          ..write('relevance: $relevance, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NewsInstrumentLinksTable extends NewsInstrumentLinks
    with TableInfo<$NewsInstrumentLinksTable, DbNewsInstrumentLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewsInstrumentLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _newsIdMeta = const VerificationMeta('newsId');
  @override
  late final GeneratedColumn<String> newsId = GeneratedColumn<String>(
    'news_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES news_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [newsId, instrumentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'news_instrument_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbNewsInstrumentLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('news_id')) {
      context.handle(
        _newsIdMeta,
        newsId.isAcceptableOrUnknown(data['news_id']!, _newsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_newsIdMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {newsId, instrumentId};
  @override
  DbNewsInstrumentLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbNewsInstrumentLink(
      newsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}news_id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
    );
  }

  @override
  $NewsInstrumentLinksTable createAlias(String alias) {
    return $NewsInstrumentLinksTable(attachedDatabase, alias);
  }
}

class DbNewsInstrumentLink extends DataClass
    implements Insertable<DbNewsInstrumentLink> {
  /// The news item.
  final String newsId;

  /// The instrument it concerns.
  final String instrumentId;
  const DbNewsInstrumentLink({
    required this.newsId,
    required this.instrumentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['news_id'] = Variable<String>(newsId);
    map['instrument_id'] = Variable<String>(instrumentId);
    return map;
  }

  NewsInstrumentLinksCompanion toCompanion(bool nullToAbsent) {
    return NewsInstrumentLinksCompanion(
      newsId: Value(newsId),
      instrumentId: Value(instrumentId),
    );
  }

  factory DbNewsInstrumentLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbNewsInstrumentLink(
      newsId: serializer.fromJson<String>(json['newsId']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'newsId': serializer.toJson<String>(newsId),
      'instrumentId': serializer.toJson<String>(instrumentId),
    };
  }

  DbNewsInstrumentLink copyWith({String? newsId, String? instrumentId}) =>
      DbNewsInstrumentLink(
        newsId: newsId ?? this.newsId,
        instrumentId: instrumentId ?? this.instrumentId,
      );
  DbNewsInstrumentLink copyWithCompanion(NewsInstrumentLinksCompanion data) {
    return DbNewsInstrumentLink(
      newsId: data.newsId.present ? data.newsId.value : this.newsId,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbNewsInstrumentLink(')
          ..write('newsId: $newsId, ')
          ..write('instrumentId: $instrumentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(newsId, instrumentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbNewsInstrumentLink &&
          other.newsId == this.newsId &&
          other.instrumentId == this.instrumentId);
}

class NewsInstrumentLinksCompanion
    extends UpdateCompanion<DbNewsInstrumentLink> {
  final Value<String> newsId;
  final Value<String> instrumentId;
  final Value<int> rowid;
  const NewsInstrumentLinksCompanion({
    this.newsId = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NewsInstrumentLinksCompanion.insert({
    required String newsId,
    required String instrumentId,
    this.rowid = const Value.absent(),
  }) : newsId = Value(newsId),
       instrumentId = Value(instrumentId);
  static Insertable<DbNewsInstrumentLink> custom({
    Expression<String>? newsId,
    Expression<String>? instrumentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (newsId != null) 'news_id': newsId,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NewsInstrumentLinksCompanion copyWith({
    Value<String>? newsId,
    Value<String>? instrumentId,
    Value<int>? rowid,
  }) {
    return NewsInstrumentLinksCompanion(
      newsId: newsId ?? this.newsId,
      instrumentId: instrumentId ?? this.instrumentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (newsId.present) {
      map['news_id'] = Variable<String>(newsId.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewsInstrumentLinksCompanion(')
          ..write('newsId: $newsId, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FilingsTable extends Filings with TableInfo<$FilingsTable, DbFiling> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($FilingsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($FilingsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _formTypeMeta = const VerificationMeta(
    'formType',
  );
  @override
  late final GeneratedColumn<String> formType = GeneratedColumn<String>(
    'form_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filedAtMeta = const VerificationMeta(
    'filedAt',
  );
  @override
  late final GeneratedColumn<DateTime> filedAt = GeneratedColumn<DateTime>(
    'filed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodOfReportMeta = const VerificationMeta(
    'periodOfReport',
  );
  @override
  late final GeneratedColumn<DateTime> periodOfReport =
      GeneratedColumn<DateTime>(
        'period_of_report',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    formType,
    filedAt,
    url,
    title,
    periodOfReport,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'filings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbFiling> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('form_type')) {
      context.handle(
        _formTypeMeta,
        formType.isAcceptableOrUnknown(data['form_type']!, _formTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_formTypeMeta);
    }
    if (data.containsKey('filed_at')) {
      context.handle(
        _filedAtMeta,
        filedAt.isAcceptableOrUnknown(data['filed_at']!, _filedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_filedAtMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('period_of_report')) {
      context.handle(
        _periodOfReportMeta,
        periodOfReport.isAcceptableOrUnknown(
          data['period_of_report']!,
          _periodOfReportMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbFiling map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFiling(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $FilingsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $FilingsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      formType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_type'],
      )!,
      filedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}filed_at'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      periodOfReport: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_of_report'],
      ),
    );
  }

  @override
  $FilingsTable createAlias(String alias) {
    return $FilingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
}

class DbFiling extends DataClass implements Insertable<DbFiling> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Accession number or equivalent.
  final String id;

  /// The filing company's instrument.
  final String instrumentId;

  /// Form type as published, e.g. `10-K`.
  final String formType;

  /// When it was filed.
  final DateTime filedAt;

  /// Link to the filing at its source.
  final String url;

  /// Human-readable description.
  final String? title;

  /// The period the filing reports on.
  final DateTime? periodOfReport;
  const DbFiling({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.instrumentId,
    required this.formType,
    required this.filedAt,
    required this.url,
    this.title,
    this.periodOfReport,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $FilingsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $FilingsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<String>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['form_type'] = Variable<String>(formType);
    map['filed_at'] = Variable<DateTime>(filedAt);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || periodOfReport != null) {
      map['period_of_report'] = Variable<DateTime>(periodOfReport);
    }
    return map;
  }

  FilingsCompanion toCompanion(bool nullToAbsent) {
    return FilingsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      instrumentId: Value(instrumentId),
      formType: Value(formType),
      filedAt: Value(filedAt),
      url: Value(url),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      periodOfReport: periodOfReport == null && nullToAbsent
          ? const Value.absent()
          : Value(periodOfReport),
    );
  }

  factory DbFiling.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFiling(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $FilingsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $FilingsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<String>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      formType: serializer.fromJson<String>(json['formType']),
      filedAt: serializer.fromJson<DateTime>(json['filedAt']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      periodOfReport: serializer.fromJson<DateTime?>(json['periodOfReport']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $FilingsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $FilingsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<String>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'formType': serializer.toJson<String>(formType),
      'filedAt': serializer.toJson<DateTime>(filedAt),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String?>(title),
      'periodOfReport': serializer.toJson<DateTime?>(periodOfReport),
    };
  }

  DbFiling copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    String? id,
    String? instrumentId,
    String? formType,
    DateTime? filedAt,
    String? url,
    Value<String?> title = const Value.absent(),
    Value<DateTime?> periodOfReport = const Value.absent(),
  }) => DbFiling(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    formType: formType ?? this.formType,
    filedAt: filedAt ?? this.filedAt,
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    periodOfReport: periodOfReport.present
        ? periodOfReport.value
        : this.periodOfReport,
  );
  DbFiling copyWithCompanion(FilingsCompanion data) {
    return DbFiling(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      formType: data.formType.present ? data.formType.value : this.formType,
      filedAt: data.filedAt.present ? data.filedAt.value : this.filedAt,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      periodOfReport: data.periodOfReport.present
          ? data.periodOfReport.value
          : this.periodOfReport,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFiling(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('formType: $formType, ')
          ..write('filedAt: $filedAt, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('periodOfReport: $periodOfReport')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    formType,
    filedAt,
    url,
    title,
    periodOfReport,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFiling &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.formType == this.formType &&
          other.filedAt == this.filedAt &&
          other.url == this.url &&
          other.title == this.title &&
          other.periodOfReport == this.periodOfReport);
}

class FilingsCompanion extends UpdateCompanion<DbFiling> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<String> id;
  final Value<String> instrumentId;
  final Value<String> formType;
  final Value<DateTime> filedAt;
  final Value<String> url;
  final Value<String?> title;
  final Value<DateTime?> periodOfReport;
  final Value<int> rowid;
  const FilingsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.formType = const Value.absent(),
    this.filedAt = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.periodOfReport = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FilingsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    required String id,
    required String instrumentId,
    required String formType,
    required DateTime filedAt,
    required String url,
    this.title = const Value.absent(),
    this.periodOfReport = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       id = Value(id),
       instrumentId = Value(instrumentId),
       formType = Value(formType),
       filedAt = Value(filedAt),
       url = Value(url);
  static Insertable<DbFiling> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<String>? id,
    Expression<String>? instrumentId,
    Expression<String>? formType,
    Expression<DateTime>? filedAt,
    Expression<String>? url,
    Expression<String>? title,
    Expression<DateTime>? periodOfReport,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (formType != null) 'form_type': formType,
      if (filedAt != null) 'filed_at': filedAt,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (periodOfReport != null) 'period_of_report': periodOfReport,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FilingsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<String>? id,
    Value<String>? instrumentId,
    Value<String>? formType,
    Value<DateTime>? filedAt,
    Value<String>? url,
    Value<String?>? title,
    Value<DateTime?>? periodOfReport,
    Value<int>? rowid,
  }) {
    return FilingsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      formType: formType ?? this.formType,
      filedAt: filedAt ?? this.filedAt,
      url: url ?? this.url,
      title: title ?? this.title,
      periodOfReport: periodOfReport ?? this.periodOfReport,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $FilingsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $FilingsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (formType.present) {
      map['form_type'] = Variable<String>(formType.value);
    }
    if (filedAt.present) {
      map['filed_at'] = Variable<DateTime>(filedAt.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (periodOfReport.present) {
      map['period_of_report'] = Variable<DateTime>(periodOfReport.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilingsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('formType: $formType, ')
          ..write('filedAt: $filedAt, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('periodOfReport: $periodOfReport, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchSnapshotsTable extends ResearchSnapshots
    with TableInfo<$ResearchSnapshotsTable, DbResearchSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CacheState, String> cacheState =
      GeneratedColumn<String>(
        'cache_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fresh'),
      ).withConverter<CacheState>($ResearchSnapshotsTable.$convertercacheState);
  @override
  late final GeneratedColumnWithTypeConverter<Confidence, String> confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('high'),
      ).withConverter<Confidence>($ResearchSnapshotsTable.$converterconfidence);
  static const VerificationMeta _reportedCurrencyMeta = const VerificationMeta(
    'reportedCurrency',
  );
  @override
  late final GeneratedColumn<String> reportedCurrency = GeneratedColumn<String>(
    'reported_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSymbolMeta = const VerificationMeta(
    'originalSymbol',
  );
  @override
  late final GeneratedColumn<String> originalSymbol = GeneratedColumn<String>(
    'original_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerExchangeMeta = const VerificationMeta(
    'providerExchange',
  );
  @override
  late final GeneratedColumn<String> providerExchange = GeneratedColumn<String>(
    'provider_exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<int> overallScore = GeneratedColumn<int>(
    'overall_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallSummaryMeta = const VerificationMeta(
    'overallSummary',
  );
  @override
  late final GeneratedColumn<String> overallSummary = GeneratedColumn<String>(
    'overall_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overallFactorsJsonMeta =
      const VerificationMeta('overallFactorsJson');
  @override
  late final GeneratedColumn<String> overallFactorsJson =
      GeneratedColumn<String>(
        'overall_factors_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dimensionsJsonMeta = const VerificationMeta(
    'dimensionsJson',
  );
  @override
  late final GeneratedColumn<String> dimensionsJson = GeneratedColumn<String>(
    'dimensions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    takenAt,
    overallScore,
    overallSummary,
    overallFactorsJson,
    dimensionsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbResearchSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('reported_currency')) {
      context.handle(
        _reportedCurrencyMeta,
        reportedCurrency.isAcceptableOrUnknown(
          data['reported_currency']!,
          _reportedCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('original_symbol')) {
      context.handle(
        _originalSymbolMeta,
        originalSymbol.isAcceptableOrUnknown(
          data['original_symbol']!,
          _originalSymbolMeta,
        ),
      );
    }
    if (data.containsKey('provider_exchange')) {
      context.handle(
        _providerExchangeMeta,
        providerExchange.isAcceptableOrUnknown(
          data['provider_exchange']!,
          _providerExchangeMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallScoreMeta);
    }
    if (data.containsKey('overall_summary')) {
      context.handle(
        _overallSummaryMeta,
        overallSummary.isAcceptableOrUnknown(
          data['overall_summary']!,
          _overallSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallSummaryMeta);
    }
    if (data.containsKey('overall_factors_json')) {
      context.handle(
        _overallFactorsJsonMeta,
        overallFactorsJson.isAcceptableOrUnknown(
          data['overall_factors_json']!,
          _overallFactorsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overallFactorsJsonMeta);
    }
    if (data.containsKey('dimensions_json')) {
      context.handle(
        _dimensionsJsonMeta,
        dimensionsJson.isAcceptableOrUnknown(
          data['dimensions_json']!,
          _dimensionsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbResearchSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbResearchSnapshot(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cacheState: $ResearchSnapshotsTable.$convertercacheState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cache_state'],
        )!,
      ),
      confidence: $ResearchSnapshotsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      reportedCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_currency'],
      ),
      originalSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_symbol'],
      ),
      providerExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_exchange'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overall_score'],
      )!,
      overallSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overall_summary'],
      )!,
      overallFactorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overall_factors_json'],
      )!,
      dimensionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimensions_json'],
      )!,
    );
  }

  @override
  $ResearchSnapshotsTable createAlias(String alias) {
    return $ResearchSnapshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CacheState, String, String> $convertercacheState =
      const EnumNameConverter<CacheState>(CacheState.values);
  static JsonTypeConverter2<Confidence, String, String> $converterconfidence =
      const EnumNameConverter<Confidence>(Confidence.values);
}

class DbResearchSnapshot extends DataClass
    implements Insertable<DbResearchSnapshot> {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  final String source;

  /// When the row was retrieved.
  final DateTime fetchedAt;

  /// When the content last changed, if the provider reports it.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// Currency the provider reported, before normalization.
  final String? reportedCurrency;

  /// Symbol the provider used.
  final String? originalSymbol;

  /// Exchange the provider attributed the row to.
  final String? providerExchange;

  /// Surrogate key; snapshots accumulate over time.
  final int id;

  /// The assessed instrument.
  final String instrumentId;

  /// When the assessment was computed.
  final DateTime takenAt;

  /// Combined score, 0 to 100.
  final int overallScore;

  /// One-line explanation shown to the user.
  final String overallSummary;

  /// Factors behind the overall score, as JSON.
  final String overallFactorsJson;

  /// Per-dimension assessments, as JSON. Absent dimensions are omitted rather
  /// than stored as zero.
  final String dimensionsJson;
  const DbResearchSnapshot({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    required this.cacheState,
    required this.confidence,
    this.reportedCurrency,
    this.originalSymbol,
    this.providerExchange,
    required this.id,
    required this.instrumentId,
    required this.takenAt,
    required this.overallScore,
    required this.overallSummary,
    required this.overallFactorsJson,
    required this.dimensionsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    {
      map['cache_state'] = Variable<String>(
        $ResearchSnapshotsTable.$convertercacheState.toSql(cacheState),
      );
    }
    {
      map['confidence'] = Variable<String>(
        $ResearchSnapshotsTable.$converterconfidence.toSql(confidence),
      );
    }
    if (!nullToAbsent || reportedCurrency != null) {
      map['reported_currency'] = Variable<String>(reportedCurrency);
    }
    if (!nullToAbsent || originalSymbol != null) {
      map['original_symbol'] = Variable<String>(originalSymbol);
    }
    if (!nullToAbsent || providerExchange != null) {
      map['provider_exchange'] = Variable<String>(providerExchange);
    }
    map['id'] = Variable<int>(id);
    map['instrument_id'] = Variable<String>(instrumentId);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['overall_score'] = Variable<int>(overallScore);
    map['overall_summary'] = Variable<String>(overallSummary);
    map['overall_factors_json'] = Variable<String>(overallFactorsJson);
    map['dimensions_json'] = Variable<String>(dimensionsJson);
    return map;
  }

  ResearchSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ResearchSnapshotsCompanion(
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      cacheState: Value(cacheState),
      confidence: Value(confidence),
      reportedCurrency: reportedCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(reportedCurrency),
      originalSymbol: originalSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSymbol),
      providerExchange: providerExchange == null && nullToAbsent
          ? const Value.absent()
          : Value(providerExchange),
      id: Value(id),
      instrumentId: Value(instrumentId),
      takenAt: Value(takenAt),
      overallScore: Value(overallScore),
      overallSummary: Value(overallSummary),
      overallFactorsJson: Value(overallFactorsJson),
      dimensionsJson: Value(dimensionsJson),
    );
  }

  factory DbResearchSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbResearchSnapshot(
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cacheState: $ResearchSnapshotsTable.$convertercacheState.fromJson(
        serializer.fromJson<String>(json['cacheState']),
      ),
      confidence: $ResearchSnapshotsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      reportedCurrency: serializer.fromJson<String?>(json['reportedCurrency']),
      originalSymbol: serializer.fromJson<String?>(json['originalSymbol']),
      providerExchange: serializer.fromJson<String?>(json['providerExchange']),
      id: serializer.fromJson<int>(json['id']),
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      overallScore: serializer.fromJson<int>(json['overallScore']),
      overallSummary: serializer.fromJson<String>(json['overallSummary']),
      overallFactorsJson: serializer.fromJson<String>(
        json['overallFactorsJson'],
      ),
      dimensionsJson: serializer.fromJson<String>(json['dimensionsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cacheState': serializer.toJson<String>(
        $ResearchSnapshotsTable.$convertercacheState.toJson(cacheState),
      ),
      'confidence': serializer.toJson<String>(
        $ResearchSnapshotsTable.$converterconfidence.toJson(confidence),
      ),
      'reportedCurrency': serializer.toJson<String?>(reportedCurrency),
      'originalSymbol': serializer.toJson<String?>(originalSymbol),
      'providerExchange': serializer.toJson<String?>(providerExchange),
      'id': serializer.toJson<int>(id),
      'instrumentId': serializer.toJson<String>(instrumentId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'overallScore': serializer.toJson<int>(overallScore),
      'overallSummary': serializer.toJson<String>(overallSummary),
      'overallFactorsJson': serializer.toJson<String>(overallFactorsJson),
      'dimensionsJson': serializer.toJson<String>(dimensionsJson),
    };
  }

  DbResearchSnapshot copyWith({
    String? source,
    DateTime? fetchedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    CacheState? cacheState,
    Confidence? confidence,
    Value<String?> reportedCurrency = const Value.absent(),
    Value<String?> originalSymbol = const Value.absent(),
    Value<String?> providerExchange = const Value.absent(),
    int? id,
    String? instrumentId,
    DateTime? takenAt,
    int? overallScore,
    String? overallSummary,
    String? overallFactorsJson,
    String? dimensionsJson,
  }) => DbResearchSnapshot(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency.present
        ? reportedCurrency.value
        : this.reportedCurrency,
    originalSymbol: originalSymbol.present
        ? originalSymbol.value
        : this.originalSymbol,
    providerExchange: providerExchange.present
        ? providerExchange.value
        : this.providerExchange,
    id: id ?? this.id,
    instrumentId: instrumentId ?? this.instrumentId,
    takenAt: takenAt ?? this.takenAt,
    overallScore: overallScore ?? this.overallScore,
    overallSummary: overallSummary ?? this.overallSummary,
    overallFactorsJson: overallFactorsJson ?? this.overallFactorsJson,
    dimensionsJson: dimensionsJson ?? this.dimensionsJson,
  );
  DbResearchSnapshot copyWithCompanion(ResearchSnapshotsCompanion data) {
    return DbResearchSnapshot(
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cacheState: data.cacheState.present
          ? data.cacheState.value
          : this.cacheState,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      reportedCurrency: data.reportedCurrency.present
          ? data.reportedCurrency.value
          : this.reportedCurrency,
      originalSymbol: data.originalSymbol.present
          ? data.originalSymbol.value
          : this.originalSymbol,
      providerExchange: data.providerExchange.present
          ? data.providerExchange.value
          : this.providerExchange,
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      overallSummary: data.overallSummary.present
          ? data.overallSummary.value
          : this.overallSummary,
      overallFactorsJson: data.overallFactorsJson.present
          ? data.overallFactorsJson.value
          : this.overallFactorsJson,
      dimensionsJson: data.dimensionsJson.present
          ? data.dimensionsJson.value
          : this.dimensionsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbResearchSnapshot(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('takenAt: $takenAt, ')
          ..write('overallScore: $overallScore, ')
          ..write('overallSummary: $overallSummary, ')
          ..write('overallFactorsJson: $overallFactorsJson, ')
          ..write('dimensionsJson: $dimensionsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    providerExchange,
    id,
    instrumentId,
    takenAt,
    overallScore,
    overallSummary,
    overallFactorsJson,
    dimensionsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbResearchSnapshot &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.updatedAt == this.updatedAt &&
          other.cacheState == this.cacheState &&
          other.confidence == this.confidence &&
          other.reportedCurrency == this.reportedCurrency &&
          other.originalSymbol == this.originalSymbol &&
          other.providerExchange == this.providerExchange &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.takenAt == this.takenAt &&
          other.overallScore == this.overallScore &&
          other.overallSummary == this.overallSummary &&
          other.overallFactorsJson == this.overallFactorsJson &&
          other.dimensionsJson == this.dimensionsJson);
}

class ResearchSnapshotsCompanion extends UpdateCompanion<DbResearchSnapshot> {
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> updatedAt;
  final Value<CacheState> cacheState;
  final Value<Confidence> confidence;
  final Value<String?> reportedCurrency;
  final Value<String?> originalSymbol;
  final Value<String?> providerExchange;
  final Value<int> id;
  final Value<String> instrumentId;
  final Value<DateTime> takenAt;
  final Value<int> overallScore;
  final Value<String> overallSummary;
  final Value<String> overallFactorsJson;
  final Value<String> dimensionsJson;
  const ResearchSnapshotsCompanion({
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.overallSummary = const Value.absent(),
    this.overallFactorsJson = const Value.absent(),
    this.dimensionsJson = const Value.absent(),
  });
  ResearchSnapshotsCompanion.insert({
    required String source,
    required DateTime fetchedAt,
    this.updatedAt = const Value.absent(),
    this.cacheState = const Value.absent(),
    this.confidence = const Value.absent(),
    this.reportedCurrency = const Value.absent(),
    this.originalSymbol = const Value.absent(),
    this.providerExchange = const Value.absent(),
    this.id = const Value.absent(),
    required String instrumentId,
    required DateTime takenAt,
    required int overallScore,
    required String overallSummary,
    required String overallFactorsJson,
    this.dimensionsJson = const Value.absent(),
  }) : source = Value(source),
       fetchedAt = Value(fetchedAt),
       instrumentId = Value(instrumentId),
       takenAt = Value(takenAt),
       overallScore = Value(overallScore),
       overallSummary = Value(overallSummary),
       overallFactorsJson = Value(overallFactorsJson);
  static Insertable<DbResearchSnapshot> custom({
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cacheState,
    Expression<String>? confidence,
    Expression<String>? reportedCurrency,
    Expression<String>? originalSymbol,
    Expression<String>? providerExchange,
    Expression<int>? id,
    Expression<String>? instrumentId,
    Expression<DateTime>? takenAt,
    Expression<int>? overallScore,
    Expression<String>? overallSummary,
    Expression<String>? overallFactorsJson,
    Expression<String>? dimensionsJson,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cacheState != null) 'cache_state': cacheState,
      if (confidence != null) 'confidence': confidence,
      if (reportedCurrency != null) 'reported_currency': reportedCurrency,
      if (originalSymbol != null) 'original_symbol': originalSymbol,
      if (providerExchange != null) 'provider_exchange': providerExchange,
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (takenAt != null) 'taken_at': takenAt,
      if (overallScore != null) 'overall_score': overallScore,
      if (overallSummary != null) 'overall_summary': overallSummary,
      if (overallFactorsJson != null)
        'overall_factors_json': overallFactorsJson,
      if (dimensionsJson != null) 'dimensions_json': dimensionsJson,
    });
  }

  ResearchSnapshotsCompanion copyWith({
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? updatedAt,
    Value<CacheState>? cacheState,
    Value<Confidence>? confidence,
    Value<String?>? reportedCurrency,
    Value<String?>? originalSymbol,
    Value<String?>? providerExchange,
    Value<int>? id,
    Value<String>? instrumentId,
    Value<DateTime>? takenAt,
    Value<int>? overallScore,
    Value<String>? overallSummary,
    Value<String>? overallFactorsJson,
    Value<String>? dimensionsJson,
  }) {
    return ResearchSnapshotsCompanion(
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cacheState: cacheState ?? this.cacheState,
      confidence: confidence ?? this.confidence,
      reportedCurrency: reportedCurrency ?? this.reportedCurrency,
      originalSymbol: originalSymbol ?? this.originalSymbol,
      providerExchange: providerExchange ?? this.providerExchange,
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      takenAt: takenAt ?? this.takenAt,
      overallScore: overallScore ?? this.overallScore,
      overallSummary: overallSummary ?? this.overallSummary,
      overallFactorsJson: overallFactorsJson ?? this.overallFactorsJson,
      dimensionsJson: dimensionsJson ?? this.dimensionsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cacheState.present) {
      map['cache_state'] = Variable<String>(
        $ResearchSnapshotsTable.$convertercacheState.toSql(cacheState.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $ResearchSnapshotsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (reportedCurrency.present) {
      map['reported_currency'] = Variable<String>(reportedCurrency.value);
    }
    if (originalSymbol.present) {
      map['original_symbol'] = Variable<String>(originalSymbol.value);
    }
    if (providerExchange.present) {
      map['provider_exchange'] = Variable<String>(providerExchange.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<int>(overallScore.value);
    }
    if (overallSummary.present) {
      map['overall_summary'] = Variable<String>(overallSummary.value);
    }
    if (overallFactorsJson.present) {
      map['overall_factors_json'] = Variable<String>(overallFactorsJson.value);
    }
    if (dimensionsJson.present) {
      map['dimensions_json'] = Variable<String>(dimensionsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchSnapshotsCompanion(')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cacheState: $cacheState, ')
          ..write('confidence: $confidence, ')
          ..write('reportedCurrency: $reportedCurrency, ')
          ..write('originalSymbol: $originalSymbol, ')
          ..write('providerExchange: $providerExchange, ')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('takenAt: $takenAt, ')
          ..write('overallScore: $overallScore, ')
          ..write('overallSummary: $overallSummary, ')
          ..write('overallFactorsJson: $overallFactorsJson, ')
          ..write('dimensionsJson: $dimensionsJson')
          ..write(')'))
        .toString();
  }
}

class $AlertRulesTable extends AlertRules
    with TableInfo<$AlertRulesTable, DbAlertRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES instruments (internal_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    instrumentId,
    kind,
    enabled,
    configJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbAlertRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAlertRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAlertRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
    );
  }

  @override
  $AlertRulesTable createAlias(String alias) {
    return $AlertRulesTable(attachedDatabase, alias);
  }
}

class DbAlertRule extends DataClass implements Insertable<DbAlertRule> {
  /// Surrogate key.
  final int id;

  /// The instrument this rule applies to, or null for all holdings.
  final String? instrumentId;

  /// Rule discriminator, e.g. `exDividendTomorrow`.
  final String kind;

  /// Whether the rule is active.
  final bool enabled;

  /// Rule-specific configuration, as JSON.
  final String configJson;
  const DbAlertRule({
    required this.id,
    this.instrumentId,
    required this.kind,
    required this.enabled,
    required this.configJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || instrumentId != null) {
      map['instrument_id'] = Variable<String>(instrumentId);
    }
    map['kind'] = Variable<String>(kind);
    map['enabled'] = Variable<bool>(enabled);
    map['config_json'] = Variable<String>(configJson);
    return map;
  }

  AlertRulesCompanion toCompanion(bool nullToAbsent) {
    return AlertRulesCompanion(
      id: Value(id),
      instrumentId: instrumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentId),
      kind: Value(kind),
      enabled: Value(enabled),
      configJson: Value(configJson),
    );
  }

  factory DbAlertRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAlertRule(
      id: serializer.fromJson<int>(json['id']),
      instrumentId: serializer.fromJson<String?>(json['instrumentId']),
      kind: serializer.fromJson<String>(json['kind']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      configJson: serializer.fromJson<String>(json['configJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'instrumentId': serializer.toJson<String?>(instrumentId),
      'kind': serializer.toJson<String>(kind),
      'enabled': serializer.toJson<bool>(enabled),
      'configJson': serializer.toJson<String>(configJson),
    };
  }

  DbAlertRule copyWith({
    int? id,
    Value<String?> instrumentId = const Value.absent(),
    String? kind,
    bool? enabled,
    String? configJson,
  }) => DbAlertRule(
    id: id ?? this.id,
    instrumentId: instrumentId.present ? instrumentId.value : this.instrumentId,
    kind: kind ?? this.kind,
    enabled: enabled ?? this.enabled,
    configJson: configJson ?? this.configJson,
  );
  DbAlertRule copyWithCompanion(AlertRulesCompanion data) {
    return DbAlertRule(
      id: data.id.present ? data.id.value : this.id,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAlertRule(')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('kind: $kind, ')
          ..write('enabled: $enabled, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, instrumentId, kind, enabled, configJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAlertRule &&
          other.id == this.id &&
          other.instrumentId == this.instrumentId &&
          other.kind == this.kind &&
          other.enabled == this.enabled &&
          other.configJson == this.configJson);
}

class AlertRulesCompanion extends UpdateCompanion<DbAlertRule> {
  final Value<int> id;
  final Value<String?> instrumentId;
  final Value<String> kind;
  final Value<bool> enabled;
  final Value<String> configJson;
  const AlertRulesCompanion({
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.enabled = const Value.absent(),
    this.configJson = const Value.absent(),
  });
  AlertRulesCompanion.insert({
    this.id = const Value.absent(),
    this.instrumentId = const Value.absent(),
    required String kind,
    this.enabled = const Value.absent(),
    this.configJson = const Value.absent(),
  }) : kind = Value(kind);
  static Insertable<DbAlertRule> custom({
    Expression<int>? id,
    Expression<String>? instrumentId,
    Expression<String>? kind,
    Expression<bool>? enabled,
    Expression<String>? configJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (kind != null) 'kind': kind,
      if (enabled != null) 'enabled': enabled,
      if (configJson != null) 'config_json': configJson,
    });
  }

  AlertRulesCompanion copyWith({
    Value<int>? id,
    Value<String?>? instrumentId,
    Value<String>? kind,
    Value<bool>? enabled,
    Value<String>? configJson,
  }) {
    return AlertRulesCompanion(
      id: id ?? this.id,
      instrumentId: instrumentId ?? this.instrumentId,
      kind: kind ?? this.kind,
      enabled: enabled ?? this.enabled,
      configJson: configJson ?? this.configJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertRulesCompanion(')
          ..write('id: $id, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('kind: $kind, ')
          ..write('enabled: $enabled, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }
}

class $ProviderStatesTable extends ProviderStates
    with TableInfo<$ProviderStatesTable, DbProviderState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<String> health = GeneratedColumn<String>(
    'health',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRequestAtMeta = const VerificationMeta(
    'lastRequestAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRequestAt =
      GeneratedColumn<DateTime>(
        'last_request_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rateLimitResetAtMeta = const VerificationMeta(
    'rateLimitResetAt',
  );
  @override
  late final GeneratedColumn<DateTime> rateLimitResetAt =
      GeneratedColumn<DateTime>(
        'rate_limit_reset_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCategoryMeta = const VerificationMeta(
    'lastErrorCategory',
  );
  @override
  late final GeneratedColumn<String> lastErrorCategory =
      GeneratedColumn<String>(
        'last_error_category',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorDetailMeta = const VerificationMeta(
    'lastErrorDetail',
  );
  @override
  late final GeneratedColumn<String> lastErrorDetail = GeneratedColumn<String>(
    'last_error_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cacheHitsMeta = const VerificationMeta(
    'cacheHits',
  );
  @override
  late final GeneratedColumn<int> cacheHits = GeneratedColumn<int>(
    'cache_hits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cacheMissesMeta = const VerificationMeta(
    'cacheMisses',
  );
  @override
  late final GeneratedColumn<int> cacheMisses = GeneratedColumn<int>(
    'cache_misses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    providerId,
    health,
    lastRequestAt,
    rateLimitResetAt,
    lastErrorCategory,
    lastErrorDetail,
    cacheHits,
    cacheMisses,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbProviderState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('health')) {
      context.handle(
        _healthMeta,
        health.isAcceptableOrUnknown(data['health']!, _healthMeta),
      );
    } else if (isInserting) {
      context.missing(_healthMeta);
    }
    if (data.containsKey('last_request_at')) {
      context.handle(
        _lastRequestAtMeta,
        lastRequestAt.isAcceptableOrUnknown(
          data['last_request_at']!,
          _lastRequestAtMeta,
        ),
      );
    }
    if (data.containsKey('rate_limit_reset_at')) {
      context.handle(
        _rateLimitResetAtMeta,
        rateLimitResetAt.isAcceptableOrUnknown(
          data['rate_limit_reset_at']!,
          _rateLimitResetAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_category')) {
      context.handle(
        _lastErrorCategoryMeta,
        lastErrorCategory.isAcceptableOrUnknown(
          data['last_error_category']!,
          _lastErrorCategoryMeta,
        ),
      );
    }
    if (data.containsKey('last_error_detail')) {
      context.handle(
        _lastErrorDetailMeta,
        lastErrorDetail.isAcceptableOrUnknown(
          data['last_error_detail']!,
          _lastErrorDetailMeta,
        ),
      );
    }
    if (data.containsKey('cache_hits')) {
      context.handle(
        _cacheHitsMeta,
        cacheHits.isAcceptableOrUnknown(data['cache_hits']!, _cacheHitsMeta),
      );
    }
    if (data.containsKey('cache_misses')) {
      context.handle(
        _cacheMissesMeta,
        cacheMisses.isAcceptableOrUnknown(
          data['cache_misses']!,
          _cacheMissesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId};
  @override
  DbProviderState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProviderState(
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      health: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health'],
      )!,
      lastRequestAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_request_at'],
      ),
      rateLimitResetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_limit_reset_at'],
      ),
      lastErrorCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_category'],
      ),
      lastErrorDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_detail'],
      ),
      cacheHits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_hits'],
      )!,
      cacheMisses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_misses'],
      )!,
    );
  }

  @override
  $ProviderStatesTable createAlias(String alias) {
    return $ProviderStatesTable(attachedDatabase, alias);
  }
}

class DbProviderState extends DataClass implements Insertable<DbProviderState> {
  /// Provider identifier.
  final String providerId;

  /// Current health, e.g. `healthy`, `rateLimited`, `offline`.
  final String health;

  /// When the provider was last called.
  final DateTime? lastRequestAt;

  /// When the provider accepts requests again.
  final DateTime? rateLimitResetAt;

  /// Category of the most recent failure.
  final String? lastErrorCategory;

  /// Privacy-safe, user-facing message for the most recent failure.
  /// Technical details and causes remain in the bounded developer log only.
  final String? lastErrorDetail;

  /// Requests served from cache, for the hit-rate display.
  final int cacheHits;

  /// Requests that reached the provider.
  final int cacheMisses;
  const DbProviderState({
    required this.providerId,
    required this.health,
    this.lastRequestAt,
    this.rateLimitResetAt,
    this.lastErrorCategory,
    this.lastErrorDetail,
    required this.cacheHits,
    required this.cacheMisses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider_id'] = Variable<String>(providerId);
    map['health'] = Variable<String>(health);
    if (!nullToAbsent || lastRequestAt != null) {
      map['last_request_at'] = Variable<DateTime>(lastRequestAt);
    }
    if (!nullToAbsent || rateLimitResetAt != null) {
      map['rate_limit_reset_at'] = Variable<DateTime>(rateLimitResetAt);
    }
    if (!nullToAbsent || lastErrorCategory != null) {
      map['last_error_category'] = Variable<String>(lastErrorCategory);
    }
    if (!nullToAbsent || lastErrorDetail != null) {
      map['last_error_detail'] = Variable<String>(lastErrorDetail);
    }
    map['cache_hits'] = Variable<int>(cacheHits);
    map['cache_misses'] = Variable<int>(cacheMisses);
    return map;
  }

  ProviderStatesCompanion toCompanion(bool nullToAbsent) {
    return ProviderStatesCompanion(
      providerId: Value(providerId),
      health: Value(health),
      lastRequestAt: lastRequestAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRequestAt),
      rateLimitResetAt: rateLimitResetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rateLimitResetAt),
      lastErrorCategory: lastErrorCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCategory),
      lastErrorDetail: lastErrorDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorDetail),
      cacheHits: Value(cacheHits),
      cacheMisses: Value(cacheMisses),
    );
  }

  factory DbProviderState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProviderState(
      providerId: serializer.fromJson<String>(json['providerId']),
      health: serializer.fromJson<String>(json['health']),
      lastRequestAt: serializer.fromJson<DateTime?>(json['lastRequestAt']),
      rateLimitResetAt: serializer.fromJson<DateTime?>(
        json['rateLimitResetAt'],
      ),
      lastErrorCategory: serializer.fromJson<String?>(
        json['lastErrorCategory'],
      ),
      lastErrorDetail: serializer.fromJson<String?>(json['lastErrorDetail']),
      cacheHits: serializer.fromJson<int>(json['cacheHits']),
      cacheMisses: serializer.fromJson<int>(json['cacheMisses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'providerId': serializer.toJson<String>(providerId),
      'health': serializer.toJson<String>(health),
      'lastRequestAt': serializer.toJson<DateTime?>(lastRequestAt),
      'rateLimitResetAt': serializer.toJson<DateTime?>(rateLimitResetAt),
      'lastErrorCategory': serializer.toJson<String?>(lastErrorCategory),
      'lastErrorDetail': serializer.toJson<String?>(lastErrorDetail),
      'cacheHits': serializer.toJson<int>(cacheHits),
      'cacheMisses': serializer.toJson<int>(cacheMisses),
    };
  }

  DbProviderState copyWith({
    String? providerId,
    String? health,
    Value<DateTime?> lastRequestAt = const Value.absent(),
    Value<DateTime?> rateLimitResetAt = const Value.absent(),
    Value<String?> lastErrorCategory = const Value.absent(),
    Value<String?> lastErrorDetail = const Value.absent(),
    int? cacheHits,
    int? cacheMisses,
  }) => DbProviderState(
    providerId: providerId ?? this.providerId,
    health: health ?? this.health,
    lastRequestAt: lastRequestAt.present
        ? lastRequestAt.value
        : this.lastRequestAt,
    rateLimitResetAt: rateLimitResetAt.present
        ? rateLimitResetAt.value
        : this.rateLimitResetAt,
    lastErrorCategory: lastErrorCategory.present
        ? lastErrorCategory.value
        : this.lastErrorCategory,
    lastErrorDetail: lastErrorDetail.present
        ? lastErrorDetail.value
        : this.lastErrorDetail,
    cacheHits: cacheHits ?? this.cacheHits,
    cacheMisses: cacheMisses ?? this.cacheMisses,
  );
  DbProviderState copyWithCompanion(ProviderStatesCompanion data) {
    return DbProviderState(
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      health: data.health.present ? data.health.value : this.health,
      lastRequestAt: data.lastRequestAt.present
          ? data.lastRequestAt.value
          : this.lastRequestAt,
      rateLimitResetAt: data.rateLimitResetAt.present
          ? data.rateLimitResetAt.value
          : this.rateLimitResetAt,
      lastErrorCategory: data.lastErrorCategory.present
          ? data.lastErrorCategory.value
          : this.lastErrorCategory,
      lastErrorDetail: data.lastErrorDetail.present
          ? data.lastErrorDetail.value
          : this.lastErrorDetail,
      cacheHits: data.cacheHits.present ? data.cacheHits.value : this.cacheHits,
      cacheMisses: data.cacheMisses.present
          ? data.cacheMisses.value
          : this.cacheMisses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProviderState(')
          ..write('providerId: $providerId, ')
          ..write('health: $health, ')
          ..write('lastRequestAt: $lastRequestAt, ')
          ..write('rateLimitResetAt: $rateLimitResetAt, ')
          ..write('lastErrorCategory: $lastErrorCategory, ')
          ..write('lastErrorDetail: $lastErrorDetail, ')
          ..write('cacheHits: $cacheHits, ')
          ..write('cacheMisses: $cacheMisses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    providerId,
    health,
    lastRequestAt,
    rateLimitResetAt,
    lastErrorCategory,
    lastErrorDetail,
    cacheHits,
    cacheMisses,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProviderState &&
          other.providerId == this.providerId &&
          other.health == this.health &&
          other.lastRequestAt == this.lastRequestAt &&
          other.rateLimitResetAt == this.rateLimitResetAt &&
          other.lastErrorCategory == this.lastErrorCategory &&
          other.lastErrorDetail == this.lastErrorDetail &&
          other.cacheHits == this.cacheHits &&
          other.cacheMisses == this.cacheMisses);
}

class ProviderStatesCompanion extends UpdateCompanion<DbProviderState> {
  final Value<String> providerId;
  final Value<String> health;
  final Value<DateTime?> lastRequestAt;
  final Value<DateTime?> rateLimitResetAt;
  final Value<String?> lastErrorCategory;
  final Value<String?> lastErrorDetail;
  final Value<int> cacheHits;
  final Value<int> cacheMisses;
  final Value<int> rowid;
  const ProviderStatesCompanion({
    this.providerId = const Value.absent(),
    this.health = const Value.absent(),
    this.lastRequestAt = const Value.absent(),
    this.rateLimitResetAt = const Value.absent(),
    this.lastErrorCategory = const Value.absent(),
    this.lastErrorDetail = const Value.absent(),
    this.cacheHits = const Value.absent(),
    this.cacheMisses = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderStatesCompanion.insert({
    required String providerId,
    required String health,
    this.lastRequestAt = const Value.absent(),
    this.rateLimitResetAt = const Value.absent(),
    this.lastErrorCategory = const Value.absent(),
    this.lastErrorDetail = const Value.absent(),
    this.cacheHits = const Value.absent(),
    this.cacheMisses = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : providerId = Value(providerId),
       health = Value(health);
  static Insertable<DbProviderState> custom({
    Expression<String>? providerId,
    Expression<String>? health,
    Expression<DateTime>? lastRequestAt,
    Expression<DateTime>? rateLimitResetAt,
    Expression<String>? lastErrorCategory,
    Expression<String>? lastErrorDetail,
    Expression<int>? cacheHits,
    Expression<int>? cacheMisses,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (providerId != null) 'provider_id': providerId,
      if (health != null) 'health': health,
      if (lastRequestAt != null) 'last_request_at': lastRequestAt,
      if (rateLimitResetAt != null) 'rate_limit_reset_at': rateLimitResetAt,
      if (lastErrorCategory != null) 'last_error_category': lastErrorCategory,
      if (lastErrorDetail != null) 'last_error_detail': lastErrorDetail,
      if (cacheHits != null) 'cache_hits': cacheHits,
      if (cacheMisses != null) 'cache_misses': cacheMisses,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderStatesCompanion copyWith({
    Value<String>? providerId,
    Value<String>? health,
    Value<DateTime?>? lastRequestAt,
    Value<DateTime?>? rateLimitResetAt,
    Value<String?>? lastErrorCategory,
    Value<String?>? lastErrorDetail,
    Value<int>? cacheHits,
    Value<int>? cacheMisses,
    Value<int>? rowid,
  }) {
    return ProviderStatesCompanion(
      providerId: providerId ?? this.providerId,
      health: health ?? this.health,
      lastRequestAt: lastRequestAt ?? this.lastRequestAt,
      rateLimitResetAt: rateLimitResetAt ?? this.rateLimitResetAt,
      lastErrorCategory: lastErrorCategory ?? this.lastErrorCategory,
      lastErrorDetail: lastErrorDetail ?? this.lastErrorDetail,
      cacheHits: cacheHits ?? this.cacheHits,
      cacheMisses: cacheMisses ?? this.cacheMisses,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (health.present) {
      map['health'] = Variable<String>(health.value);
    }
    if (lastRequestAt.present) {
      map['last_request_at'] = Variable<DateTime>(lastRequestAt.value);
    }
    if (rateLimitResetAt.present) {
      map['rate_limit_reset_at'] = Variable<DateTime>(rateLimitResetAt.value);
    }
    if (lastErrorCategory.present) {
      map['last_error_category'] = Variable<String>(lastErrorCategory.value);
    }
    if (lastErrorDetail.present) {
      map['last_error_detail'] = Variable<String>(lastErrorDetail.value);
    }
    if (cacheHits.present) {
      map['cache_hits'] = Variable<int>(cacheHits.value);
    }
    if (cacheMisses.present) {
      map['cache_misses'] = Variable<int>(cacheMisses.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderStatesCompanion(')
          ..write('providerId: $providerId, ')
          ..write('health: $health, ')
          ..write('lastRequestAt: $lastRequestAt, ')
          ..write('rateLimitResetAt: $rateLimitResetAt, ')
          ..write('lastErrorCategory: $lastErrorCategory, ')
          ..write('lastErrorDetail: $lastErrorDetail, ')
          ..write('cacheHits: $cacheHits, ')
          ..write('cacheMisses: $cacheMisses, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncJobsTable extends SyncJobs
    with TableInfo<$SyncJobsTable, DbSyncJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta(
    'instrumentId',
  );
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCategoryMeta = const VerificationMeta(
    'lastErrorCategory',
  );
  @override
  late final GeneratedColumn<String> lastErrorCategory =
      GeneratedColumn<String>(
        'last_error_category',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    instrumentId,
    priority,
    state,
    providerId,
    startedAt,
    finishedAt,
    attempts,
    lastErrorCategory,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('instrument_id')) {
      context.handle(
        _instrumentIdMeta,
        instrumentId.isAcceptableOrUnknown(
          data['instrument_id']!,
          _instrumentIdMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error_category')) {
      context.handle(
        _lastErrorCategoryMeta,
        lastErrorCategory.isAcceptableOrUnknown(
          data['last_error_category']!,
          _lastErrorCategoryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSyncJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      instrumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_id'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastErrorCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_category'],
      ),
    );
  }

  @override
  $SyncJobsTable createAlias(String alias) {
    return $SyncJobsTable(attachedDatabase, alias);
  }
}

class DbSyncJob extends DataClass implements Insertable<DbSyncJob> {
  /// Surrogate key.
  final int id;

  /// What is being fetched, e.g. `dividends`.
  final String kind;

  /// The instrument the job concerns, when it concerns one.
  final String? instrumentId;

  /// Scheduling priority: high, medium or low.
  final String priority;

  /// Lifecycle state, e.g. `queued`, `running`, `succeeded`, `failed`.
  final String state;

  /// Provider selected for the job.
  final String? providerId;

  /// When the job started.
  final DateTime? startedAt;

  /// When the job finished.
  final DateTime? finishedAt;

  /// How many attempts have been made.
  final int attempts;

  /// Category of the last failure.
  final String? lastErrorCategory;
  const DbSyncJob({
    required this.id,
    required this.kind,
    this.instrumentId,
    required this.priority,
    required this.state,
    this.providerId,
    this.startedAt,
    this.finishedAt,
    required this.attempts,
    this.lastErrorCategory,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || instrumentId != null) {
      map['instrument_id'] = Variable<String>(instrumentId);
    }
    map['priority'] = Variable<String>(priority);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<String>(providerId);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastErrorCategory != null) {
      map['last_error_category'] = Variable<String>(lastErrorCategory);
    }
    return map;
  }

  SyncJobsCompanion toCompanion(bool nullToAbsent) {
    return SyncJobsCompanion(
      id: Value(id),
      kind: Value(kind),
      instrumentId: instrumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(instrumentId),
      priority: Value(priority),
      state: Value(state),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      attempts: Value(attempts),
      lastErrorCategory: lastErrorCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCategory),
    );
  }

  factory DbSyncJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncJob(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      instrumentId: serializer.fromJson<String?>(json['instrumentId']),
      priority: serializer.fromJson<String>(json['priority']),
      state: serializer.fromJson<String>(json['state']),
      providerId: serializer.fromJson<String?>(json['providerId']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastErrorCategory: serializer.fromJson<String?>(
        json['lastErrorCategory'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'instrumentId': serializer.toJson<String?>(instrumentId),
      'priority': serializer.toJson<String>(priority),
      'state': serializer.toJson<String>(state),
      'providerId': serializer.toJson<String?>(providerId),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastErrorCategory': serializer.toJson<String?>(lastErrorCategory),
    };
  }

  DbSyncJob copyWith({
    int? id,
    String? kind,
    Value<String?> instrumentId = const Value.absent(),
    String? priority,
    String? state,
    Value<String?> providerId = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    int? attempts,
    Value<String?> lastErrorCategory = const Value.absent(),
  }) => DbSyncJob(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    instrumentId: instrumentId.present ? instrumentId.value : this.instrumentId,
    priority: priority ?? this.priority,
    state: state ?? this.state,
    providerId: providerId.present ? providerId.value : this.providerId,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    attempts: attempts ?? this.attempts,
    lastErrorCategory: lastErrorCategory.present
        ? lastErrorCategory.value
        : this.lastErrorCategory,
  );
  DbSyncJob copyWithCompanion(SyncJobsCompanion data) {
    return DbSyncJob(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      instrumentId: data.instrumentId.present
          ? data.instrumentId.value
          : this.instrumentId,
      priority: data.priority.present ? data.priority.value : this.priority,
      state: data.state.present ? data.state.value : this.state,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastErrorCategory: data.lastErrorCategory.present
          ? data.lastErrorCategory.value
          : this.lastErrorCategory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncJob(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('priority: $priority, ')
          ..write('state: $state, ')
          ..write('providerId: $providerId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCategory: $lastErrorCategory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    instrumentId,
    priority,
    state,
    providerId,
    startedAt,
    finishedAt,
    attempts,
    lastErrorCategory,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncJob &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.instrumentId == this.instrumentId &&
          other.priority == this.priority &&
          other.state == this.state &&
          other.providerId == this.providerId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.attempts == this.attempts &&
          other.lastErrorCategory == this.lastErrorCategory);
}

class SyncJobsCompanion extends UpdateCompanion<DbSyncJob> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String?> instrumentId;
  final Value<String> priority;
  final Value<String> state;
  final Value<String?> providerId;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> attempts;
  final Value<String?> lastErrorCategory;
  const SyncJobsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.instrumentId = const Value.absent(),
    this.priority = const Value.absent(),
    this.state = const Value.absent(),
    this.providerId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCategory = const Value.absent(),
  });
  SyncJobsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.instrumentId = const Value.absent(),
    required String priority,
    required String state,
    this.providerId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastErrorCategory = const Value.absent(),
  }) : kind = Value(kind),
       priority = Value(priority),
       state = Value(state);
  static Insertable<DbSyncJob> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? instrumentId,
    Expression<String>? priority,
    Expression<String>? state,
    Expression<String>? providerId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? attempts,
    Expression<String>? lastErrorCategory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (priority != null) 'priority': priority,
      if (state != null) 'state': state,
      if (providerId != null) 'provider_id': providerId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastErrorCategory != null) 'last_error_category': lastErrorCategory,
    });
  }

  SyncJobsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String?>? instrumentId,
    Value<String>? priority,
    Value<String>? state,
    Value<String?>? providerId,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? attempts,
    Value<String?>? lastErrorCategory,
  }) {
    return SyncJobsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      instrumentId: instrumentId ?? this.instrumentId,
      priority: priority ?? this.priority,
      state: state ?? this.state,
      providerId: providerId ?? this.providerId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      attempts: attempts ?? this.attempts,
      lastErrorCategory: lastErrorCategory ?? this.lastErrorCategory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastErrorCategory.present) {
      map['last_error_category'] = Variable<String>(lastErrorCategory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncJobsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('instrumentId: $instrumentId, ')
          ..write('priority: $priority, ')
          ..write('state: $state, ')
          ..write('providerId: $providerId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastErrorCategory: $lastErrorCategory')
          ..write(')'))
        .toString();
  }
}

class $SyncLogsTable extends SyncLogs
    with TableInfo<$SyncLogsTable, DbSyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _componentMeta = const VerificationMeta(
    'component',
  );
  @override
  late final GeneratedColumn<String> component = GeneratedColumn<String>(
    'component',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCategoryMeta = const VerificationMeta(
    'errorCategory',
  );
  @override
  late final GeneratedColumn<String> errorCategory = GeneratedColumn<String>(
    'error_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    level,
    component,
    provider,
    operation,
    message,
    durationMs,
    errorCategory,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSyncLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('component')) {
      context.handle(
        _componentMeta,
        component.isAcceptableOrUnknown(data['component']!, _componentMeta),
      );
    } else if (isInserting) {
      context.missing(_componentMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('error_category')) {
      context.handle(
        _errorCategoryMeta,
        errorCategory.isAcceptableOrUnknown(
          data['error_category']!,
          _errorCategoryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSyncLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      component: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      errorCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_category'],
      ),
    );
  }

  @override
  $SyncLogsTable createAlias(String alias) {
    return $SyncLogsTable(attachedDatabase, alias);
  }
}

class DbSyncLog extends DataClass implements Insertable<DbSyncLog> {
  /// Surrogate key.
  final int id;

  /// When the entry was written.
  final DateTime timestamp;

  /// Severity label.
  final String level;

  /// Emitting subsystem.
  final String component;

  /// Provider involved, when any.
  final String? provider;

  /// Logical operation.
  final String? operation;

  /// Human-readable message. Must never contain portfolio content.
  final String message;

  /// Measured duration in milliseconds.
  final int? durationMs;

  /// Category of the failure, when the entry describes one.
  final String? errorCategory;
  const DbSyncLog({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.component,
    this.provider,
    this.operation,
    required this.message,
    this.durationMs,
    this.errorCategory,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['level'] = Variable<String>(level);
    map['component'] = Variable<String>(component);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || operation != null) {
      map['operation'] = Variable<String>(operation);
    }
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || errorCategory != null) {
      map['error_category'] = Variable<String>(errorCategory);
    }
    return map;
  }

  SyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SyncLogsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      level: Value(level),
      component: Value(component),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      operation: operation == null && nullToAbsent
          ? const Value.absent()
          : Value(operation),
      message: Value(message),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      errorCategory: errorCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCategory),
    );
  }

  factory DbSyncLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSyncLog(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      level: serializer.fromJson<String>(json['level']),
      component: serializer.fromJson<String>(json['component']),
      provider: serializer.fromJson<String?>(json['provider']),
      operation: serializer.fromJson<String?>(json['operation']),
      message: serializer.fromJson<String>(json['message']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      errorCategory: serializer.fromJson<String?>(json['errorCategory']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'level': serializer.toJson<String>(level),
      'component': serializer.toJson<String>(component),
      'provider': serializer.toJson<String?>(provider),
      'operation': serializer.toJson<String?>(operation),
      'message': serializer.toJson<String>(message),
      'durationMs': serializer.toJson<int?>(durationMs),
      'errorCategory': serializer.toJson<String?>(errorCategory),
    };
  }

  DbSyncLog copyWith({
    int? id,
    DateTime? timestamp,
    String? level,
    String? component,
    Value<String?> provider = const Value.absent(),
    Value<String?> operation = const Value.absent(),
    String? message,
    Value<int?> durationMs = const Value.absent(),
    Value<String?> errorCategory = const Value.absent(),
  }) => DbSyncLog(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    level: level ?? this.level,
    component: component ?? this.component,
    provider: provider.present ? provider.value : this.provider,
    operation: operation.present ? operation.value : this.operation,
    message: message ?? this.message,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    errorCategory: errorCategory.present
        ? errorCategory.value
        : this.errorCategory,
  );
  DbSyncLog copyWithCompanion(SyncLogsCompanion data) {
    return DbSyncLog(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      level: data.level.present ? data.level.value : this.level,
      component: data.component.present ? data.component.value : this.component,
      provider: data.provider.present ? data.provider.value : this.provider,
      operation: data.operation.present ? data.operation.value : this.operation,
      message: data.message.present ? data.message.value : this.message,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      errorCategory: data.errorCategory.present
          ? data.errorCategory.value
          : this.errorCategory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSyncLog(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('level: $level, ')
          ..write('component: $component, ')
          ..write('provider: $provider, ')
          ..write('operation: $operation, ')
          ..write('message: $message, ')
          ..write('durationMs: $durationMs, ')
          ..write('errorCategory: $errorCategory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    level,
    component,
    provider,
    operation,
    message,
    durationMs,
    errorCategory,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSyncLog &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.level == this.level &&
          other.component == this.component &&
          other.provider == this.provider &&
          other.operation == this.operation &&
          other.message == this.message &&
          other.durationMs == this.durationMs &&
          other.errorCategory == this.errorCategory);
}

class SyncLogsCompanion extends UpdateCompanion<DbSyncLog> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<String> level;
  final Value<String> component;
  final Value<String?> provider;
  final Value<String?> operation;
  final Value<String> message;
  final Value<int?> durationMs;
  final Value<String?> errorCategory;
  const SyncLogsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.level = const Value.absent(),
    this.component = const Value.absent(),
    this.provider = const Value.absent(),
    this.operation = const Value.absent(),
    this.message = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.errorCategory = const Value.absent(),
  });
  SyncLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required String level,
    required String component,
    this.provider = const Value.absent(),
    this.operation = const Value.absent(),
    required String message,
    this.durationMs = const Value.absent(),
    this.errorCategory = const Value.absent(),
  }) : timestamp = Value(timestamp),
       level = Value(level),
       component = Value(component),
       message = Value(message);
  static Insertable<DbSyncLog> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? level,
    Expression<String>? component,
    Expression<String>? provider,
    Expression<String>? operation,
    Expression<String>? message,
    Expression<int>? durationMs,
    Expression<String>? errorCategory,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (level != null) 'level': level,
      if (component != null) 'component': component,
      if (provider != null) 'provider': provider,
      if (operation != null) 'operation': operation,
      if (message != null) 'message': message,
      if (durationMs != null) 'duration_ms': durationMs,
      if (errorCategory != null) 'error_category': errorCategory,
    });
  }

  SyncLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<String>? level,
    Value<String>? component,
    Value<String?>? provider,
    Value<String?>? operation,
    Value<String>? message,
    Value<int?>? durationMs,
    Value<String?>? errorCategory,
  }) {
    return SyncLogsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      component: component ?? this.component,
      provider: provider ?? this.provider,
      operation: operation ?? this.operation,
      message: message ?? this.message,
      durationMs: durationMs ?? this.durationMs,
      errorCategory: errorCategory ?? this.errorCategory,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (component.present) {
      map['component'] = Variable<String>(component.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (errorCategory.present) {
      map['error_category'] = Variable<String>(errorCategory.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('level: $level, ')
          ..write('component: $component, ')
          ..write('provider: $provider, ')
          ..write('operation: $operation, ')
          ..write('message: $message, ')
          ..write('durationMs: $durationMs, ')
          ..write('errorCategory: $errorCategory')
          ..write(')'))
        .toString();
  }
}

class $CacheMetadataTable extends CacheMetadata
    with TableInfo<$CacheMetadataTable, DbCacheMetadata> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    dataType,
    source,
    fetchedAt,
    expiresAt,
    etag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCacheMetadata> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  DbCacheMetadata map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCacheMetadata(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
    );
  }

  @override
  $CacheMetadataTable createAlias(String alias) {
    return $CacheMetadataTable(attachedDatabase, alias);
  }
}

class DbCacheMetadata extends DataClass implements Insertable<DbCacheMetadata> {
  /// Request key, e.g. `dividends:isin:DE0008404005`.
  final String cacheKey;

  /// Data type, which determines the cache lifetime.
  final String dataType;

  /// Provider that supplied the cached payload.
  final String source;

  /// When it was fetched.
  final DateTime fetchedAt;

  /// When it becomes stale.
  final DateTime expiresAt;

  /// Provider validator for conditional requests, when supplied.
  final String? etag;
  const DbCacheMetadata({
    required this.cacheKey,
    required this.dataType,
    required this.source,
    required this.fetchedAt,
    required this.expiresAt,
    this.etag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['data_type'] = Variable<String>(dataType);
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    return map;
  }

  CacheMetadataCompanion toCompanion(bool nullToAbsent) {
    return CacheMetadataCompanion(
      cacheKey: Value(cacheKey),
      dataType: Value(dataType),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      expiresAt: Value(expiresAt),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
    );
  }

  factory DbCacheMetadata.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCacheMetadata(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      dataType: serializer.fromJson<String>(json['dataType']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      etag: serializer.fromJson<String?>(json['etag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'dataType': serializer.toJson<String>(dataType),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'etag': serializer.toJson<String?>(etag),
    };
  }

  DbCacheMetadata copyWith({
    String? cacheKey,
    String? dataType,
    String? source,
    DateTime? fetchedAt,
    DateTime? expiresAt,
    Value<String?> etag = const Value.absent(),
  }) => DbCacheMetadata(
    cacheKey: cacheKey ?? this.cacheKey,
    dataType: dataType ?? this.dataType,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    etag: etag.present ? etag.value : this.etag,
  );
  DbCacheMetadata copyWithCompanion(CacheMetadataCompanion data) {
    return DbCacheMetadata(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      etag: data.etag.present ? data.etag.value : this.etag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCacheMetadata(')
          ..write('cacheKey: $cacheKey, ')
          ..write('dataType: $dataType, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('etag: $etag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cacheKey, dataType, source, fetchedAt, expiresAt, etag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCacheMetadata &&
          other.cacheKey == this.cacheKey &&
          other.dataType == this.dataType &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt &&
          other.etag == this.etag);
}

class CacheMetadataCompanion extends UpdateCompanion<DbCacheMetadata> {
  final Value<String> cacheKey;
  final Value<String> dataType;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> expiresAt;
  final Value<String?> etag;
  final Value<int> rowid;
  const CacheMetadataCompanion({
    this.cacheKey = const Value.absent(),
    this.dataType = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMetadataCompanion.insert({
    required String cacheKey,
    required String dataType,
    required String source,
    required DateTime fetchedAt,
    required DateTime expiresAt,
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       dataType = Value(dataType),
       source = Value(source),
       fetchedAt = Value(fetchedAt),
       expiresAt = Value(expiresAt);
  static Insertable<DbCacheMetadata> custom({
    Expression<String>? cacheKey,
    Expression<String>? dataType,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? etag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (dataType != null) 'data_type': dataType,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (etag != null) 'etag': etag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMetadataCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? dataType,
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? expiresAt,
    Value<String?>? etag,
    Value<int>? rowid,
  }) {
    return CacheMetadataCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      dataType: dataType ?? this.dataType,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      etag: etag ?? this.etag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('dataType: $dataType, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('etag: $etag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $ProviderMappingsTable providerMappings = $ProviderMappingsTable(
    this,
  );
  late final $HoldingsTable holdings = $HoldingsTable(this);
  late final $WatchlistEntriesTable watchlistEntries = $WatchlistEntriesTable(
    this,
  );
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $FxRatesTable fxRates = $FxRatesTable(this);
  late final $DividendEventsTable dividendEvents = $DividendEventsTable(this);
  late final $EarningsEventsTable earningsEvents = $EarningsEventsTable(this);
  late final $CorporateEventsTable corporateEvents = $CorporateEventsTable(
    this,
  );
  late final $NewsItemsTable newsItems = $NewsItemsTable(this);
  late final $NewsInstrumentLinksTable newsInstrumentLinks =
      $NewsInstrumentLinksTable(this);
  late final $FilingsTable filings = $FilingsTable(this);
  late final $ResearchSnapshotsTable researchSnapshots =
      $ResearchSnapshotsTable(this);
  late final $AlertRulesTable alertRules = $AlertRulesTable(this);
  late final $ProviderStatesTable providerStates = $ProviderStatesTable(this);
  late final $SyncJobsTable syncJobs = $SyncJobsTable(this);
  late final $SyncLogsTable syncLogs = $SyncLogsTable(this);
  late final $CacheMetadataTable cacheMetadata = $CacheMetadataTable(this);
  late final Index idxFxRateObservedAt = Index(
    'idx_fx_rate_observed_at',
    'CREATE INDEX idx_fx_rate_observed_at ON fx_rates (observed_at)',
  );
  late final Index idxDividendExDate = Index(
    'idx_dividend_ex_date',
    'CREATE INDEX idx_dividend_ex_date ON dividend_events (ex_date)',
  );
  late final Index idxDividendPaymentDate = Index(
    'idx_dividend_payment_date',
    'CREATE INDEX idx_dividend_payment_date ON dividend_events (payment_date)',
  );
  late final Index idxDividendInstrument = Index(
    'idx_dividend_instrument',
    'CREATE INDEX idx_dividend_instrument ON dividend_events (instrument_id)',
  );
  late final Index idxEarningsScheduled = Index(
    'idx_earnings_scheduled',
    'CREATE INDEX idx_earnings_scheduled ON earnings_events (scheduled_for)',
  );
  late final Index idxCorporateEventsScheduled = Index(
    'idx_corporate_events_scheduled',
    'CREATE INDEX idx_corporate_events_scheduled ON corporate_events (scheduled_for)',
  );
  late final Index idxNewsPublished = Index(
    'idx_news_published',
    'CREATE INDEX idx_news_published ON news_items (published_at)',
  );
  late final Index idxFilingFiledAt = Index(
    'idx_filing_filed_at',
    'CREATE INDEX idx_filing_filed_at ON filings (filed_at)',
  );
  late final Index idxResearchTakenAt = Index(
    'idx_research_taken_at',
    'CREATE INDEX idx_research_taken_at ON research_snapshots (taken_at)',
  );
  late final Index idxSyncLogTime = Index(
    'idx_sync_log_time',
    'CREATE INDEX idx_sync_log_time ON sync_logs (timestamp)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    instruments,
    providerMappings,
    holdings,
    watchlistEntries,
    quotes,
    fxRates,
    dividendEvents,
    earningsEvents,
    corporateEvents,
    newsItems,
    newsInstrumentLinks,
    filings,
    researchSnapshots,
    alertRules,
    providerStates,
    syncJobs,
    syncLogs,
    cacheMetadata,
    idxFxRateObservedAt,
    idxDividendExDate,
    idxDividendPaymentDate,
    idxDividendInstrument,
    idxEarningsScheduled,
    idxCorporateEventsScheduled,
    idxNewsPublished,
    idxFilingFiledAt,
    idxResearchTakenAt,
    idxSyncLogTime,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('provider_mappings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quotes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dividend_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('earnings_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('corporate_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'news_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('news_instrument_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('news_instrument_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('filings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('research_snapshots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'instruments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('alert_rules', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$InstrumentsTableCreateCompanionBuilder =
    InstrumentsCompanion Function({
      required String internalId,
      required String symbol,
      required String name,
      required String currencyCode,
      Value<String?> exchange,
      Value<String?> mic,
      Value<String?> isin,
      Value<String?> country,
      Value<String?> sector,
      Value<int> rowid,
    });
typedef $$InstrumentsTableUpdateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> internalId,
      Value<String> symbol,
      Value<String> name,
      Value<String> currencyCode,
      Value<String?> exchange,
      Value<String?> mic,
      Value<String?> isin,
      Value<String?> country,
      Value<String?> sector,
      Value<int> rowid,
    });

final class $$InstrumentsTableReferences
    extends BaseReferences<_$AppDatabase, $InstrumentsTable, DbInstrument> {
  $$InstrumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProviderMappingsTable, List<DbProviderMapping>>
  _providerMappingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.providerMappings,
    aliasName: 'instruments__internal_id__provider_mappings__instrument_id',
  );

  $$ProviderMappingsTableProcessedTableManager get providerMappingsRefs {
    final manager =
        $$ProviderMappingsTableTableManager($_db, $_db.providerMappings).filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _providerMappingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldingsTable, List<DbHolding>>
  _holdingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.holdings,
    aliasName: 'instruments__internal_id__holdings__instrument_id',
  );

  $$HoldingsTableProcessedTableManager get holdingsRefs {
    final manager = $$HoldingsTableTableManager($_db, $_db.holdings).filter(
      (f) => f.instrumentId.internalId.sqlEquals(
        $_itemColumn<String>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_holdingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WatchlistEntriesTable, List<DbWatchlistEntry>>
  _watchlistEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.watchlistEntries,
    aliasName: 'instruments__internal_id__watchlist_entries__instrument_id',
  );

  $$WatchlistEntriesTableProcessedTableManager get watchlistEntriesRefs {
    final manager =
        $$WatchlistEntriesTableTableManager($_db, $_db.watchlistEntries).filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _watchlistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<DbQuote>> _quotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: 'instruments__internal_id__quotes__instrument_id',
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager($_db, $_db.quotes).filter(
      (f) => f.instrumentId.internalId.sqlEquals(
        $_itemColumn<String>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DividendEventsTable, List<DbDividendEvent>>
  _dividendEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dividendEvents,
    aliasName: 'instruments__internal_id__dividend_events__instrument_id',
  );

  $$DividendEventsTableProcessedTableManager get dividendEventsRefs {
    final manager = $$DividendEventsTableTableManager($_db, $_db.dividendEvents)
        .filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_dividendEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EarningsEventsTable, List<DbEarningsEvent>>
  _earningsEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.earningsEvents,
    aliasName: 'instruments__internal_id__earnings_events__instrument_id',
  );

  $$EarningsEventsTableProcessedTableManager get earningsEventsRefs {
    final manager = $$EarningsEventsTableTableManager($_db, $_db.earningsEvents)
        .filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_earningsEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CorporateEventsTable, List<DbCorporateEvent>>
  _corporateEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.corporateEvents,
    aliasName: 'instruments__internal_id__corporate_events__instrument_id',
  );

  $$CorporateEventsTableProcessedTableManager get corporateEventsRefs {
    final manager =
        $$CorporateEventsTableTableManager($_db, $_db.corporateEvents).filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _corporateEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $NewsInstrumentLinksTable,
    List<DbNewsInstrumentLink>
  >
  _newsInstrumentLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.newsInstrumentLinks,
        aliasName:
            'instruments__internal_id__news_instrument_links__instrument_id',
      );

  $$NewsInstrumentLinksTableProcessedTableManager get newsInstrumentLinksRefs {
    final manager =
        $$NewsInstrumentLinksTableTableManager(
          $_db,
          $_db.newsInstrumentLinks,
        ).filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _newsInstrumentLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FilingsTable, List<DbFiling>> _filingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.filings,
    aliasName: 'instruments__internal_id__filings__instrument_id',
  );

  $$FilingsTableProcessedTableManager get filingsRefs {
    final manager = $$FilingsTableTableManager($_db, $_db.filings).filter(
      (f) => f.instrumentId.internalId.sqlEquals(
        $_itemColumn<String>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_filingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResearchSnapshotsTable, List<DbResearchSnapshot>>
  _researchSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.researchSnapshots,
        aliasName:
            'instruments__internal_id__research_snapshots__instrument_id',
      );

  $$ResearchSnapshotsTableProcessedTableManager get researchSnapshotsRefs {
    final manager =
        $$ResearchSnapshotsTableTableManager(
          $_db,
          $_db.researchSnapshots,
        ).filter(
          (f) => f.instrumentId.internalId.sqlEquals(
            $_itemColumn<String>('internal_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _researchSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AlertRulesTable, List<DbAlertRule>>
  _alertRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.alertRules,
    aliasName: 'instruments__internal_id__alert_rules__instrument_id',
  );

  $$AlertRulesTableProcessedTableManager get alertRulesRefs {
    final manager = $$AlertRulesTableTableManager($_db, $_db.alertRules).filter(
      (f) => f.instrumentId.internalId.sqlEquals(
        $_itemColumn<String>('internal_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_alertRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstrumentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mic => $composableBuilder(
    column: $table.mic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> providerMappingsRefs(
    Expression<bool> Function($$ProviderMappingsTableFilterComposer f) f,
  ) {
    final $$ProviderMappingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.providerMappings,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderMappingsTableFilterComposer(
            $db: $db,
            $table: $db.providerMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdingsRefs(
    Expression<bool> Function($$HoldingsTableFilterComposer f) f,
  ) {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> watchlistEntriesRefs(
    Expression<bool> Function($$WatchlistEntriesTableFilterComposer f) f,
  ) {
    final $$WatchlistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.watchlistEntries,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchlistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.watchlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dividendEventsRefs(
    Expression<bool> Function($$DividendEventsTableFilterComposer f) f,
  ) {
    final $$DividendEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.dividendEvents,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DividendEventsTableFilterComposer(
            $db: $db,
            $table: $db.dividendEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> earningsEventsRefs(
    Expression<bool> Function($$EarningsEventsTableFilterComposer f) f,
  ) {
    final $$EarningsEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.earningsEvents,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsEventsTableFilterComposer(
            $db: $db,
            $table: $db.earningsEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> corporateEventsRefs(
    Expression<bool> Function($$CorporateEventsTableFilterComposer f) f,
  ) {
    final $$CorporateEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.corporateEvents,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorporateEventsTableFilterComposer(
            $db: $db,
            $table: $db.corporateEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> newsInstrumentLinksRefs(
    Expression<bool> Function($$NewsInstrumentLinksTableFilterComposer f) f,
  ) {
    final $$NewsInstrumentLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.newsInstrumentLinks,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NewsInstrumentLinksTableFilterComposer(
            $db: $db,
            $table: $db.newsInstrumentLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> filingsRefs(
    Expression<bool> Function($$FilingsTableFilterComposer f) f,
  ) {
    final $$FilingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.filings,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FilingsTableFilterComposer(
            $db: $db,
            $table: $db.filings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> researchSnapshotsRefs(
    Expression<bool> Function($$ResearchSnapshotsTableFilterComposer f) f,
  ) {
    final $$ResearchSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.researchSnapshots,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResearchSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.researchSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> alertRulesRefs(
    Expression<bool> Function($$AlertRulesTableFilterComposer f) f,
  ) {
    final $$AlertRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.alertRules,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertRulesTableFilterComposer(
            $db: $db,
            $table: $db.alertRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstrumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mic => $composableBuilder(
    column: $table.mic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstrumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get internalId => $composableBuilder(
    column: $table.internalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<String> get mic =>
      $composableBuilder(column: $table.mic, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  Expression<T> providerMappingsRefs<T extends Object>(
    Expression<T> Function($$ProviderMappingsTableAnnotationComposer a) f,
  ) {
    final $$ProviderMappingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.providerMappings,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderMappingsTableAnnotationComposer(
            $db: $db,
            $table: $db.providerMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdingsRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> watchlistEntriesRefs<T extends Object>(
    Expression<T> Function($$WatchlistEntriesTableAnnotationComposer a) f,
  ) {
    final $$WatchlistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.watchlistEntries,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchlistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.watchlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dividendEventsRefs<T extends Object>(
    Expression<T> Function($$DividendEventsTableAnnotationComposer a) f,
  ) {
    final $$DividendEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.dividendEvents,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DividendEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.dividendEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> earningsEventsRefs<T extends Object>(
    Expression<T> Function($$EarningsEventsTableAnnotationComposer a) f,
  ) {
    final $$EarningsEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.earningsEvents,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarningsEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.earningsEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> corporateEventsRefs<T extends Object>(
    Expression<T> Function($$CorporateEventsTableAnnotationComposer a) f,
  ) {
    final $$CorporateEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.corporateEvents,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CorporateEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.corporateEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> newsInstrumentLinksRefs<T extends Object>(
    Expression<T> Function($$NewsInstrumentLinksTableAnnotationComposer a) f,
  ) {
    final $$NewsInstrumentLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.internalId,
          referencedTable: $db.newsInstrumentLinks,
          getReferencedColumn: (t) => t.instrumentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NewsInstrumentLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.newsInstrumentLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> filingsRefs<T extends Object>(
    Expression<T> Function($$FilingsTableAnnotationComposer a) f,
  ) {
    final $$FilingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.filings,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FilingsTableAnnotationComposer(
            $db: $db,
            $table: $db.filings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> researchSnapshotsRefs<T extends Object>(
    Expression<T> Function($$ResearchSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$ResearchSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.internalId,
          referencedTable: $db.researchSnapshots,
          getReferencedColumn: (t) => t.instrumentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ResearchSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.researchSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> alertRulesRefs<T extends Object>(
    Expression<T> Function($$AlertRulesTableAnnotationComposer a) f,
  ) {
    final $$AlertRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.internalId,
      referencedTable: $db.alertRules,
      getReferencedColumn: (t) => t.instrumentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlertRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.alertRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentsTable,
          DbInstrument,
          $$InstrumentsTableFilterComposer,
          $$InstrumentsTableOrderingComposer,
          $$InstrumentsTableAnnotationComposer,
          $$InstrumentsTableCreateCompanionBuilder,
          $$InstrumentsTableUpdateCompanionBuilder,
          (DbInstrument, $$InstrumentsTableReferences),
          DbInstrument,
          PrefetchHooks Function({
            bool providerMappingsRefs,
            bool holdingsRefs,
            bool watchlistEntriesRefs,
            bool quotesRefs,
            bool dividendEventsRefs,
            bool earningsEventsRefs,
            bool corporateEventsRefs,
            bool newsInstrumentLinksRefs,
            bool filingsRefs,
            bool researchSnapshotsRefs,
            bool alertRulesRefs,
          })
        > {
  $$InstrumentsTableTableManager(_$AppDatabase db, $InstrumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> internalId = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> exchange = const Value.absent(),
                Value<String?> mic = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion(
                internalId: internalId,
                symbol: symbol,
                name: name,
                currencyCode: currencyCode,
                exchange: exchange,
                mic: mic,
                isin: isin,
                country: country,
                sector: sector,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String internalId,
                required String symbol,
                required String name,
                required String currencyCode,
                Value<String?> exchange = const Value.absent(),
                Value<String?> mic = const Value.absent(),
                Value<String?> isin = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion.insert(
                internalId: internalId,
                symbol: symbol,
                name: name,
                currencyCode: currencyCode,
                exchange: exchange,
                mic: mic,
                isin: isin,
                country: country,
                sector: sector,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstrumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                providerMappingsRefs = false,
                holdingsRefs = false,
                watchlistEntriesRefs = false,
                quotesRefs = false,
                dividendEventsRefs = false,
                earningsEventsRefs = false,
                corporateEventsRefs = false,
                newsInstrumentLinksRefs = false,
                filingsRefs = false,
                researchSnapshotsRefs = false,
                alertRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (providerMappingsRefs) db.providerMappings,
                    if (holdingsRefs) db.holdings,
                    if (watchlistEntriesRefs) db.watchlistEntries,
                    if (quotesRefs) db.quotes,
                    if (dividendEventsRefs) db.dividendEvents,
                    if (earningsEventsRefs) db.earningsEvents,
                    if (corporateEventsRefs) db.corporateEvents,
                    if (newsInstrumentLinksRefs) db.newsInstrumentLinks,
                    if (filingsRefs) db.filings,
                    if (researchSnapshotsRefs) db.researchSnapshots,
                    if (alertRulesRefs) db.alertRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (providerMappingsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbProviderMapping
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._providerMappingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).providerMappingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (holdingsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbHolding
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._holdingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (watchlistEntriesRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbWatchlistEntry
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._watchlistEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).watchlistEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (quotesRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbQuote
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._quotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).quotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (dividendEventsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbDividendEvent
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._dividendEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).dividendEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (earningsEventsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbEarningsEvent
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._earningsEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).earningsEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (corporateEventsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbCorporateEvent
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._corporateEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).corporateEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (newsInstrumentLinksRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbNewsInstrumentLink
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._newsInstrumentLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).newsInstrumentLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (filingsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbFiling
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._filingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).filingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (researchSnapshotsRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbResearchSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._researchSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).researchSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                      if (alertRulesRefs)
                        await $_getPrefetchedData<
                          DbInstrument,
                          $InstrumentsTable,
                          DbAlertRule
                        >(
                          currentTable: table,
                          referencedTable: $$InstrumentsTableReferences
                              ._alertRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstrumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).alertRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.instrumentId == item.internalId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentsTable,
      DbInstrument,
      $$InstrumentsTableFilterComposer,
      $$InstrumentsTableOrderingComposer,
      $$InstrumentsTableAnnotationComposer,
      $$InstrumentsTableCreateCompanionBuilder,
      $$InstrumentsTableUpdateCompanionBuilder,
      (DbInstrument, $$InstrumentsTableReferences),
      DbInstrument,
      PrefetchHooks Function({
        bool providerMappingsRefs,
        bool holdingsRefs,
        bool watchlistEntriesRefs,
        bool quotesRefs,
        bool dividendEventsRefs,
        bool earningsEventsRefs,
        bool corporateEventsRefs,
        bool newsInstrumentLinksRefs,
        bool filingsRefs,
        bool researchSnapshotsRefs,
        bool alertRulesRefs,
      })
    >;
typedef $$ProviderMappingsTableCreateCompanionBuilder =
    ProviderMappingsCompanion Function({
      required String instrumentId,
      required String providerId,
      required String symbol,
      Value<String?> providerInstrumentId,
      Value<int> rowid,
    });
typedef $$ProviderMappingsTableUpdateCompanionBuilder =
    ProviderMappingsCompanion Function({
      Value<String> instrumentId,
      Value<String> providerId,
      Value<String> symbol,
      Value<String?> providerInstrumentId,
      Value<int> rowid,
    });

final class $$ProviderMappingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProviderMappingsTable,
          DbProviderMapping
        > {
  $$ProviderMappingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) =>
      db.instruments.createAlias(
        'provider_mappings__instrument_id__instruments__internal_id',
      );

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProviderMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderMappingsTable> {
  $$ProviderMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerInstrumentId => $composableBuilder(
    column: $table.providerInstrumentId,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderMappingsTable> {
  $$ProviderMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerInstrumentId => $composableBuilder(
    column: $table.providerInstrumentId,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderMappingsTable> {
  $$ProviderMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get providerInstrumentId => $composableBuilder(
    column: $table.providerInstrumentId,
    builder: (column) => column,
  );

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderMappingsTable,
          DbProviderMapping,
          $$ProviderMappingsTableFilterComposer,
          $$ProviderMappingsTableOrderingComposer,
          $$ProviderMappingsTableAnnotationComposer,
          $$ProviderMappingsTableCreateCompanionBuilder,
          $$ProviderMappingsTableUpdateCompanionBuilder,
          (DbProviderMapping, $$ProviderMappingsTableReferences),
          DbProviderMapping,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$ProviderMappingsTableTableManager(
    _$AppDatabase db,
    $ProviderMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instrumentId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String?> providerInstrumentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderMappingsCompanion(
                instrumentId: instrumentId,
                providerId: providerId,
                symbol: symbol,
                providerInstrumentId: providerInstrumentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instrumentId,
                required String providerId,
                required String symbol,
                Value<String?> providerInstrumentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderMappingsCompanion.insert(
                instrumentId: instrumentId,
                providerId: providerId,
                symbol: symbol,
                providerInstrumentId: providerInstrumentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProviderMappingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$ProviderMappingsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$ProviderMappingsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProviderMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderMappingsTable,
      DbProviderMapping,
      $$ProviderMappingsTableFilterComposer,
      $$ProviderMappingsTableOrderingComposer,
      $$ProviderMappingsTableAnnotationComposer,
      $$ProviderMappingsTableCreateCompanionBuilder,
      $$ProviderMappingsTableUpdateCompanionBuilder,
      (DbProviderMapping, $$ProviderMappingsTableReferences),
      DbProviderMapping,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$HoldingsTableCreateCompanionBuilder = HoldingsCompanion Function({
  required String source,
  required DateTime fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  Value<int> id,
  required String instrumentId,
  required String quantity,
  Value<String?> averagePriceAmount,
  Value<String?> averagePriceCurrency,
  Value<DateTime?> purchaseDate,
  Value<String?> notes,
});
typedef $$HoldingsTableUpdateCompanionBuilder = HoldingsCompanion Function({
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  Value<int> id,
  Value<String> instrumentId,
  Value<String> quantity,
  Value<String?> averagePriceAmount,
  Value<String?> averagePriceCurrency,
  Value<DateTime?> purchaseDate,
  Value<String?> notes,
});

final class $$HoldingsTableReferences
    extends BaseReferences<_$AppDatabase, $HoldingsTable, DbHolding> {
  $$HoldingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('holdings__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get averagePriceAmount => $composableBuilder(
    column: $table.averagePriceAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get averagePriceCurrency => $composableBuilder(
    column: $table.averagePriceCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get averagePriceAmount => $composableBuilder(
    column: $table.averagePriceAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get averagePriceCurrency => $composableBuilder(
    column: $table.averagePriceCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get averagePriceAmount => $composableBuilder(
    column: $table.averagePriceAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get averagePriceCurrency => $composableBuilder(
    column: $table.averagePriceCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingsTable,
          DbHolding,
          $$HoldingsTableFilterComposer,
          $$HoldingsTableOrderingComposer,
          $$HoldingsTableAnnotationComposer,
          $$HoldingsTableCreateCompanionBuilder,
          $$HoldingsTableUpdateCompanionBuilder,
          (DbHolding, $$HoldingsTableReferences),
          DbHolding,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$HoldingsTableTableManager(_$AppDatabase db, $HoldingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String?> averagePriceAmount = const Value.absent(),
                Value<String?> averagePriceCurrency = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => HoldingsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                quantity: quantity,
                averagePriceAmount: averagePriceAmount,
                averagePriceCurrency: averagePriceCurrency,
                purchaseDate: purchaseDate,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String instrumentId,
                required String quantity,
                Value<String?> averagePriceAmount = const Value.absent(),
                Value<String?> averagePriceCurrency = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => HoldingsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                quantity: quantity,
                averagePriceAmount: averagePriceAmount,
                averagePriceCurrency: averagePriceCurrency,
                purchaseDate: purchaseDate,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HoldingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$HoldingsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$HoldingsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingsTable,
      DbHolding,
      $$HoldingsTableFilterComposer,
      $$HoldingsTableOrderingComposer,
      $$HoldingsTableAnnotationComposer,
      $$HoldingsTableCreateCompanionBuilder,
      $$HoldingsTableUpdateCompanionBuilder,
      (DbHolding, $$HoldingsTableReferences),
      DbHolding,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$WatchlistEntriesTableCreateCompanionBuilder =
    WatchlistEntriesCompanion Function({
      required String source,
      required DateTime fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      required String instrumentId,
      required DateTime addedAt,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$WatchlistEntriesTableUpdateCompanionBuilder =
    WatchlistEntriesCompanion Function({
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      Value<String> instrumentId,
      Value<DateTime> addedAt,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$WatchlistEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WatchlistEntriesTable,
          DbWatchlistEntry
        > {
  $$WatchlistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) =>
      db.instruments.createAlias(
        'watchlist_entries__instrument_id__instruments__internal_id',
      );

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchlistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WatchlistEntriesTable> {
  $$WatchlistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchlistEntriesTable> {
  $$WatchlistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchlistEntriesTable> {
  $$WatchlistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchlistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchlistEntriesTable,
          DbWatchlistEntry,
          $$WatchlistEntriesTableFilterComposer,
          $$WatchlistEntriesTableOrderingComposer,
          $$WatchlistEntriesTableAnnotationComposer,
          $$WatchlistEntriesTableCreateCompanionBuilder,
          $$WatchlistEntriesTableUpdateCompanionBuilder,
          (DbWatchlistEntry, $$WatchlistEntriesTableReferences),
          DbWatchlistEntry,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$WatchlistEntriesTableTableManager(
    _$AppDatabase db,
    $WatchlistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchlistEntriesCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                instrumentId: instrumentId,
                addedAt: addedAt,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String instrumentId,
                required DateTime addedAt,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchlistEntriesCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                instrumentId: instrumentId,
                addedAt: addedAt,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WatchlistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$WatchlistEntriesTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$WatchlistEntriesTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WatchlistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchlistEntriesTable,
      DbWatchlistEntry,
      $$WatchlistEntriesTableFilterComposer,
      $$WatchlistEntriesTableOrderingComposer,
      $$WatchlistEntriesTableAnnotationComposer,
      $$WatchlistEntriesTableCreateCompanionBuilder,
      $$WatchlistEntriesTableUpdateCompanionBuilder,
      (DbWatchlistEntry, $$WatchlistEntriesTableReferences),
      DbWatchlistEntry,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$QuotesTableCreateCompanionBuilder = QuotesCompanion Function({
  required String source,
  required DateTime fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  required String instrumentId,
  required String priceAmount,
  required String priceCurrency,
  Value<String?> previousCloseAmount,
  required DateTime asOf,
  Value<int> rowid,
});
typedef $$QuotesTableUpdateCompanionBuilder = QuotesCompanion Function({
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  Value<String> instrumentId,
  Value<String> priceAmount,
  Value<String> priceCurrency,
  Value<String?> previousCloseAmount,
  Value<DateTime> asOf,
  Value<int> rowid,
});

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, DbQuote> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('quotes__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceAmount => $composableBuilder(
    column: $table.priceAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceCurrency => $composableBuilder(
    column: $table.priceCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousCloseAmount => $composableBuilder(
    column: $table.previousCloseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceAmount => $composableBuilder(
    column: $table.priceAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceCurrency => $composableBuilder(
    column: $table.priceCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousCloseAmount => $composableBuilder(
    column: $table.previousCloseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priceAmount => $composableBuilder(
    column: $table.priceAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priceCurrency => $composableBuilder(
    column: $table.priceCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousCloseAmount => $composableBuilder(
    column: $table.previousCloseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          DbQuote,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (DbQuote, $$QuotesTableReferences),
          DbQuote,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<String> priceAmount = const Value.absent(),
                Value<String> priceCurrency = const Value.absent(),
                Value<String?> previousCloseAmount = const Value.absent(),
                Value<DateTime> asOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                instrumentId: instrumentId,
                priceAmount: priceAmount,
                priceCurrency: priceCurrency,
                previousCloseAmount: previousCloseAmount,
                asOf: asOf,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String instrumentId,
                required String priceAmount,
                required String priceCurrency,
                Value<String?> previousCloseAmount = const Value.absent(),
                required DateTime asOf,
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                instrumentId: instrumentId,
                priceAmount: priceAmount,
                priceCurrency: priceCurrency,
                previousCloseAmount: previousCloseAmount,
                asOf: asOf,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$QuotesTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$QuotesTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      DbQuote,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (DbQuote, $$QuotesTableReferences),
      DbQuote,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$FxRatesTableCreateCompanionBuilder = FxRatesCompanion Function({
  required String source,
  required DateTime fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  required String baseCurrency,
  required String quoteCurrency,
  required String rate,
  required DateTime observedAt,
  Value<int> rowid,
});
typedef $$FxRatesTableUpdateCompanionBuilder = FxRatesCompanion Function({
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  Value<String> baseCurrency,
  Value<String> quoteCurrency,
  Value<String> rate,
  Value<DateTime> observedAt,
  Value<int> rowid,
});

class $$FxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );
}

class $$FxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FxRatesTable,
          DbFxRate,
          $$FxRatesTableFilterComposer,
          $$FxRatesTableOrderingComposer,
          $$FxRatesTableAnnotationComposer,
          $$FxRatesTableCreateCompanionBuilder,
          $$FxRatesTableUpdateCompanionBuilder,
          (DbFxRate, BaseReferences<_$AppDatabase, $FxRatesTable, DbFxRate>),
          DbFxRate,
          PrefetchHooks Function()
        > {
  $$FxRatesTableTableManager(_$AppDatabase db, $FxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> quoteCurrency = const Value.absent(),
                Value<String> rate = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FxRatesCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rate: rate,
                observedAt: observedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String baseCurrency,
                required String quoteCurrency,
                required String rate,
                required DateTime observedAt,
                Value<int> rowid = const Value.absent(),
              }) => FxRatesCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rate: rate,
                observedAt: observedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FxRatesTable,
      DbFxRate,
      $$FxRatesTableFilterComposer,
      $$FxRatesTableOrderingComposer,
      $$FxRatesTableAnnotationComposer,
      $$FxRatesTableCreateCompanionBuilder,
      $$FxRatesTableUpdateCompanionBuilder,
      (DbFxRate, BaseReferences<_$AppDatabase, $FxRatesTable, DbFxRate>),
      DbFxRate,
      PrefetchHooks Function()
    >;
typedef $$DividendEventsTableCreateCompanionBuilder =
    DividendEventsCompanion Function({
      required String source,
      required DateTime fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      required String id,
      required String instrumentId,
      required String amountPerShare,
      required String amountCurrency,
      required DividendStatus status,
      Value<DividendFrequency> frequency,
      Value<DateTime?> exDate,
      Value<DateTime?> paymentDate,
      Value<DateTime?> declarationDate,
      Value<DateTime?> recordDate,
      Value<DateTime?> reportedPeriodStart,
      Value<DateTime?> reportedPeriodEnd,
      Value<int> rowid,
    });
typedef $$DividendEventsTableUpdateCompanionBuilder =
    DividendEventsCompanion Function({
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      Value<String> id,
      Value<String> instrumentId,
      Value<String> amountPerShare,
      Value<String> amountCurrency,
      Value<DividendStatus> status,
      Value<DividendFrequency> frequency,
      Value<DateTime?> exDate,
      Value<DateTime?> paymentDate,
      Value<DateTime?> declarationDate,
      Value<DateTime?> recordDate,
      Value<DateTime?> reportedPeriodStart,
      Value<DateTime?> reportedPeriodEnd,
      Value<int> rowid,
    });

final class $$DividendEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DividendEventsTable, DbDividendEvent> {
  $$DividendEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('dividend_events__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DividendEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DividendEventsTable> {
  $$DividendEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountPerShare => $composableBuilder(
    column: $table.amountPerShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountCurrency => $composableBuilder(
    column: $table.amountCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DividendStatus, DividendStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DividendFrequency, DividendFrequency, String>
  get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get declarationDate => $composableBuilder(
    column: $table.declarationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reportedPeriodStart => $composableBuilder(
    column: $table.reportedPeriodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reportedPeriodEnd => $composableBuilder(
    column: $table.reportedPeriodEnd,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DividendEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DividendEventsTable> {
  $$DividendEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountPerShare => $composableBuilder(
    column: $table.amountPerShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountCurrency => $composableBuilder(
    column: $table.amountCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get declarationDate => $composableBuilder(
    column: $table.declarationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reportedPeriodStart => $composableBuilder(
    column: $table.reportedPeriodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reportedPeriodEnd => $composableBuilder(
    column: $table.reportedPeriodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DividendEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DividendEventsTable> {
  $$DividendEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get amountPerShare => $composableBuilder(
    column: $table.amountPerShare,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountCurrency => $composableBuilder(
    column: $table.amountCurrency,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DividendStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DividendFrequency, String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get exDate =>
      $composableBuilder(column: $table.exDate, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get declarationDate => $composableBuilder(
    column: $table.declarationDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reportedPeriodStart => $composableBuilder(
    column: $table.reportedPeriodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reportedPeriodEnd => $composableBuilder(
    column: $table.reportedPeriodEnd,
    builder: (column) => column,
  );

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DividendEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DividendEventsTable,
          DbDividendEvent,
          $$DividendEventsTableFilterComposer,
          $$DividendEventsTableOrderingComposer,
          $$DividendEventsTableAnnotationComposer,
          $$DividendEventsTableCreateCompanionBuilder,
          $$DividendEventsTableUpdateCompanionBuilder,
          (DbDividendEvent, $$DividendEventsTableReferences),
          DbDividendEvent,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$DividendEventsTableTableManager(
    _$AppDatabase db,
    $DividendEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DividendEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DividendEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DividendEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<String> amountPerShare = const Value.absent(),
                Value<String> amountCurrency = const Value.absent(),
                Value<DividendStatus> status = const Value.absent(),
                Value<DividendFrequency> frequency = const Value.absent(),
                Value<DateTime?> exDate = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<DateTime?> declarationDate = const Value.absent(),
                Value<DateTime?> recordDate = const Value.absent(),
                Value<DateTime?> reportedPeriodStart = const Value.absent(),
                Value<DateTime?> reportedPeriodEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DividendEventsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                amountPerShare: amountPerShare,
                amountCurrency: amountCurrency,
                status: status,
                frequency: frequency,
                exDate: exDate,
                paymentDate: paymentDate,
                declarationDate: declarationDate,
                recordDate: recordDate,
                reportedPeriodStart: reportedPeriodStart,
                reportedPeriodEnd: reportedPeriodEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String id,
                required String instrumentId,
                required String amountPerShare,
                required String amountCurrency,
                required DividendStatus status,
                Value<DividendFrequency> frequency = const Value.absent(),
                Value<DateTime?> exDate = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<DateTime?> declarationDate = const Value.absent(),
                Value<DateTime?> recordDate = const Value.absent(),
                Value<DateTime?> reportedPeriodStart = const Value.absent(),
                Value<DateTime?> reportedPeriodEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DividendEventsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                amountPerShare: amountPerShare,
                amountCurrency: amountCurrency,
                status: status,
                frequency: frequency,
                exDate: exDate,
                paymentDate: paymentDate,
                declarationDate: declarationDate,
                recordDate: recordDate,
                reportedPeriodStart: reportedPeriodStart,
                reportedPeriodEnd: reportedPeriodEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DividendEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$DividendEventsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$DividendEventsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DividendEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DividendEventsTable,
      DbDividendEvent,
      $$DividendEventsTableFilterComposer,
      $$DividendEventsTableOrderingComposer,
      $$DividendEventsTableAnnotationComposer,
      $$DividendEventsTableCreateCompanionBuilder,
      $$DividendEventsTableUpdateCompanionBuilder,
      (DbDividendEvent, $$DividendEventsTableReferences),
      DbDividendEvent,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$EarningsEventsTableCreateCompanionBuilder =
    EarningsEventsCompanion Function({
      required String source,
      required DateTime fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      required String id,
      required String instrumentId,
      required DateTime scheduledFor,
      required EarningsStatus status,
      Value<EarningsTiming> timing,
      Value<String?> fiscalPeriod,
      Value<String?> epsEstimate,
      Value<String?> epsActual,
      Value<String?> revenueEstimate,
      Value<String?> revenueActual,
      Value<String?> figuresCurrency,
      Value<int> rowid,
    });
typedef $$EarningsEventsTableUpdateCompanionBuilder =
    EarningsEventsCompanion Function({
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      Value<String> id,
      Value<String> instrumentId,
      Value<DateTime> scheduledFor,
      Value<EarningsStatus> status,
      Value<EarningsTiming> timing,
      Value<String?> fiscalPeriod,
      Value<String?> epsEstimate,
      Value<String?> epsActual,
      Value<String?> revenueEstimate,
      Value<String?> revenueActual,
      Value<String?> figuresCurrency,
      Value<int> rowid,
    });

final class $$EarningsEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $EarningsEventsTable, DbEarningsEvent> {
  $$EarningsEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('earnings_events__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EarningsEventsTableFilterComposer
    extends Composer<_$AppDatabase, $EarningsEventsTable> {
  $$EarningsEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EarningsStatus, EarningsStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<EarningsTiming, EarningsTiming, String>
  get timing => $composableBuilder(
    column: $table.timing,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get fiscalPeriod => $composableBuilder(
    column: $table.fiscalPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epsEstimate => $composableBuilder(
    column: $table.epsEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epsActual => $composableBuilder(
    column: $table.epsActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revenueEstimate => $composableBuilder(
    column: $table.revenueEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revenueActual => $composableBuilder(
    column: $table.revenueActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get figuresCurrency => $composableBuilder(
    column: $table.figuresCurrency,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarningsEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EarningsEventsTable> {
  $$EarningsEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timing => $composableBuilder(
    column: $table.timing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalPeriod => $composableBuilder(
    column: $table.fiscalPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epsEstimate => $composableBuilder(
    column: $table.epsEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epsActual => $composableBuilder(
    column: $table.epsActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revenueEstimate => $composableBuilder(
    column: $table.revenueEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revenueActual => $composableBuilder(
    column: $table.revenueActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get figuresCurrency => $composableBuilder(
    column: $table.figuresCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarningsEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarningsEventsTable> {
  $$EarningsEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EarningsStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EarningsTiming, String> get timing =>
      $composableBuilder(column: $table.timing, builder: (column) => column);

  GeneratedColumn<String> get fiscalPeriod => $composableBuilder(
    column: $table.fiscalPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epsEstimate => $composableBuilder(
    column: $table.epsEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epsActual =>
      $composableBuilder(column: $table.epsActual, builder: (column) => column);

  GeneratedColumn<String> get revenueEstimate => $composableBuilder(
    column: $table.revenueEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revenueActual => $composableBuilder(
    column: $table.revenueActual,
    builder: (column) => column,
  );

  GeneratedColumn<String> get figuresCurrency => $composableBuilder(
    column: $table.figuresCurrency,
    builder: (column) => column,
  );

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarningsEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EarningsEventsTable,
          DbEarningsEvent,
          $$EarningsEventsTableFilterComposer,
          $$EarningsEventsTableOrderingComposer,
          $$EarningsEventsTableAnnotationComposer,
          $$EarningsEventsTableCreateCompanionBuilder,
          $$EarningsEventsTableUpdateCompanionBuilder,
          (DbEarningsEvent, $$EarningsEventsTableReferences),
          DbEarningsEvent,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$EarningsEventsTableTableManager(
    _$AppDatabase db,
    $EarningsEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarningsEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarningsEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EarningsEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
                Value<EarningsStatus> status = const Value.absent(),
                Value<EarningsTiming> timing = const Value.absent(),
                Value<String?> fiscalPeriod = const Value.absent(),
                Value<String?> epsEstimate = const Value.absent(),
                Value<String?> epsActual = const Value.absent(),
                Value<String?> revenueEstimate = const Value.absent(),
                Value<String?> revenueActual = const Value.absent(),
                Value<String?> figuresCurrency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarningsEventsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                scheduledFor: scheduledFor,
                status: status,
                timing: timing,
                fiscalPeriod: fiscalPeriod,
                epsEstimate: epsEstimate,
                epsActual: epsActual,
                revenueEstimate: revenueEstimate,
                revenueActual: revenueActual,
                figuresCurrency: figuresCurrency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String id,
                required String instrumentId,
                required DateTime scheduledFor,
                required EarningsStatus status,
                Value<EarningsTiming> timing = const Value.absent(),
                Value<String?> fiscalPeriod = const Value.absent(),
                Value<String?> epsEstimate = const Value.absent(),
                Value<String?> epsActual = const Value.absent(),
                Value<String?> revenueEstimate = const Value.absent(),
                Value<String?> revenueActual = const Value.absent(),
                Value<String?> figuresCurrency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarningsEventsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                scheduledFor: scheduledFor,
                status: status,
                timing: timing,
                fiscalPeriod: fiscalPeriod,
                epsEstimate: epsEstimate,
                epsActual: epsActual,
                revenueEstimate: revenueEstimate,
                revenueActual: revenueActual,
                figuresCurrency: figuresCurrency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EarningsEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$EarningsEventsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$EarningsEventsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EarningsEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EarningsEventsTable,
      DbEarningsEvent,
      $$EarningsEventsTableFilterComposer,
      $$EarningsEventsTableOrderingComposer,
      $$EarningsEventsTableAnnotationComposer,
      $$EarningsEventsTableCreateCompanionBuilder,
      $$EarningsEventsTableUpdateCompanionBuilder,
      (DbEarningsEvent, $$EarningsEventsTableReferences),
      DbEarningsEvent,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$CorporateEventsTableCreateCompanionBuilder =
    CorporateEventsCompanion Function({
      required String source,
      required DateTime fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      required String id,
      required String instrumentId,
      required DateTime scheduledFor,
      required CorporateEventType type,
      required CorporateEventStatus status,
      required String title,
      Value<String?> url,
      Value<int> rowid,
    });
typedef $$CorporateEventsTableUpdateCompanionBuilder =
    CorporateEventsCompanion Function({
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      Value<String> id,
      Value<String> instrumentId,
      Value<DateTime> scheduledFor,
      Value<CorporateEventType> type,
      Value<CorporateEventStatus> status,
      Value<String> title,
      Value<String?> url,
      Value<int> rowid,
    });

final class $$CorporateEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CorporateEventsTable, DbCorporateEvent> {
  $$CorporateEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('corporate_events__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CorporateEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CorporateEventsTable> {
  $$CorporateEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CorporateEventType, CorporateEventType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    CorporateEventStatus,
    CorporateEventStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorporateEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CorporateEventsTable> {
  $$CorporateEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorporateEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CorporateEventsTable> {
  $$CorporateEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CorporateEventType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CorporateEventStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CorporateEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CorporateEventsTable,
          DbCorporateEvent,
          $$CorporateEventsTableFilterComposer,
          $$CorporateEventsTableOrderingComposer,
          $$CorporateEventsTableAnnotationComposer,
          $$CorporateEventsTableCreateCompanionBuilder,
          $$CorporateEventsTableUpdateCompanionBuilder,
          (DbCorporateEvent, $$CorporateEventsTableReferences),
          DbCorporateEvent,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$CorporateEventsTableTableManager(
    _$AppDatabase db,
    $CorporateEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CorporateEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CorporateEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CorporateEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
                Value<CorporateEventType> type = const Value.absent(),
                Value<CorporateEventStatus> status = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CorporateEventsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                scheduledFor: scheduledFor,
                type: type,
                status: status,
                title: title,
                url: url,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String id,
                required String instrumentId,
                required DateTime scheduledFor,
                required CorporateEventType type,
                required CorporateEventStatus status,
                required String title,
                Value<String?> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CorporateEventsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                scheduledFor: scheduledFor,
                type: type,
                status: status,
                title: title,
                url: url,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CorporateEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$CorporateEventsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$CorporateEventsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CorporateEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CorporateEventsTable,
      DbCorporateEvent,
      $$CorporateEventsTableFilterComposer,
      $$CorporateEventsTableOrderingComposer,
      $$CorporateEventsTableAnnotationComposer,
      $$CorporateEventsTableCreateCompanionBuilder,
      $$CorporateEventsTableUpdateCompanionBuilder,
      (DbCorporateEvent, $$CorporateEventsTableReferences),
      DbCorporateEvent,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$NewsItemsTableCreateCompanionBuilder = NewsItemsCompanion Function({
  required String source,
  required DateTime fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  required String id,
  required String headline,
  required String sourceName,
  required DateTime publishedAt,
  required String url,
  Value<NewsCategory> category,
  Value<String?> summary,
  Value<double?> relevance,
  Value<int> rowid,
});
typedef $$NewsItemsTableUpdateCompanionBuilder = NewsItemsCompanion Function({
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  Value<String> id,
  Value<String> headline,
  Value<String> sourceName,
  Value<DateTime> publishedAt,
  Value<String> url,
  Value<NewsCategory> category,
  Value<String?> summary,
  Value<double?> relevance,
  Value<int> rowid,
});

final class $$NewsItemsTableReferences
    extends BaseReferences<_$AppDatabase, $NewsItemsTable, DbNewsItem> {
  $$NewsItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $NewsInstrumentLinksTable,
    List<DbNewsInstrumentLink>
  >
  _newsInstrumentLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.newsInstrumentLinks,
        aliasName: 'news_items__id__news_instrument_links__news_id',
      );

  $$NewsInstrumentLinksTableProcessedTableManager get newsInstrumentLinksRefs {
    final manager = $$NewsInstrumentLinksTableTableManager(
      $_db,
      $_db.newsInstrumentLinks,
    ).filter((f) => f.newsId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _newsInstrumentLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NewsItemsTableFilterComposer
    extends Composer<_$AppDatabase, $NewsItemsTable> {
  $$NewsItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headline => $composableBuilder(
    column: $table.headline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NewsCategory, NewsCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get relevance => $composableBuilder(
    column: $table.relevance,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> newsInstrumentLinksRefs(
    Expression<bool> Function($$NewsInstrumentLinksTableFilterComposer f) f,
  ) {
    final $$NewsInstrumentLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.newsInstrumentLinks,
      getReferencedColumn: (t) => t.newsId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NewsInstrumentLinksTableFilterComposer(
            $db: $db,
            $table: $db.newsInstrumentLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NewsItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $NewsItemsTable> {
  $$NewsItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headline => $composableBuilder(
    column: $table.headline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get relevance => $composableBuilder(
    column: $table.relevance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NewsItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewsItemsTable> {
  $$NewsItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get headline =>
      $composableBuilder(column: $table.headline, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NewsCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<double> get relevance =>
      $composableBuilder(column: $table.relevance, builder: (column) => column);

  Expression<T> newsInstrumentLinksRefs<T extends Object>(
    Expression<T> Function($$NewsInstrumentLinksTableAnnotationComposer a) f,
  ) {
    final $$NewsInstrumentLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.newsInstrumentLinks,
          getReferencedColumn: (t) => t.newsId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NewsInstrumentLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.newsInstrumentLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$NewsItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NewsItemsTable,
          DbNewsItem,
          $$NewsItemsTableFilterComposer,
          $$NewsItemsTableOrderingComposer,
          $$NewsItemsTableAnnotationComposer,
          $$NewsItemsTableCreateCompanionBuilder,
          $$NewsItemsTableUpdateCompanionBuilder,
          (DbNewsItem, $$NewsItemsTableReferences),
          DbNewsItem,
          PrefetchHooks Function({bool newsInstrumentLinksRefs})
        > {
  $$NewsItemsTableTableManager(_$AppDatabase db, $NewsItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewsItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewsItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NewsItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> headline = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<NewsCategory> category = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<double?> relevance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsItemsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                headline: headline,
                sourceName: sourceName,
                publishedAt: publishedAt,
                url: url,
                category: category,
                summary: summary,
                relevance: relevance,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String id,
                required String headline,
                required String sourceName,
                required DateTime publishedAt,
                required String url,
                Value<NewsCategory> category = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<double?> relevance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsItemsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                headline: headline,
                sourceName: sourceName,
                publishedAt: publishedAt,
                url: url,
                category: category,
                summary: summary,
                relevance: relevance,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NewsItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({newsInstrumentLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (newsInstrumentLinksRefs) db.newsInstrumentLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (newsInstrumentLinksRefs)
                    await $_getPrefetchedData<
                      DbNewsItem,
                      $NewsItemsTable,
                      DbNewsInstrumentLink
                    >(
                      currentTable: table,
                      referencedTable: $$NewsItemsTableReferences
                          ._newsInstrumentLinksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NewsItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).newsInstrumentLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.newsId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NewsItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NewsItemsTable,
      DbNewsItem,
      $$NewsItemsTableFilterComposer,
      $$NewsItemsTableOrderingComposer,
      $$NewsItemsTableAnnotationComposer,
      $$NewsItemsTableCreateCompanionBuilder,
      $$NewsItemsTableUpdateCompanionBuilder,
      (DbNewsItem, $$NewsItemsTableReferences),
      DbNewsItem,
      PrefetchHooks Function({bool newsInstrumentLinksRefs})
    >;
typedef $$NewsInstrumentLinksTableCreateCompanionBuilder =
    NewsInstrumentLinksCompanion Function({
      required String newsId,
      required String instrumentId,
      Value<int> rowid,
    });
typedef $$NewsInstrumentLinksTableUpdateCompanionBuilder =
    NewsInstrumentLinksCompanion Function({
      Value<String> newsId,
      Value<String> instrumentId,
      Value<int> rowid,
    });

final class $$NewsInstrumentLinksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NewsInstrumentLinksTable,
          DbNewsInstrumentLink
        > {
  $$NewsInstrumentLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NewsItemsTable _newsIdTable(_$AppDatabase db) => db.newsItems
      .createAlias('news_instrument_links__news_id__news_items__id');

  $$NewsItemsTableProcessedTableManager get newsId {
    final $_column = $_itemColumn<String>('news_id')!;

    final manager = $$NewsItemsTableTableManager(
      $_db,
      $_db.newsItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_newsIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) =>
      db.instruments.createAlias(
        'news_instrument_links__instrument_id__instruments__internal_id',
      );

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NewsInstrumentLinksTableFilterComposer
    extends Composer<_$AppDatabase, $NewsInstrumentLinksTable> {
  $$NewsInstrumentLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NewsItemsTableFilterComposer get newsId {
    final $$NewsItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.newsId,
      referencedTable: $db.newsItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NewsItemsTableFilterComposer(
            $db: $db,
            $table: $db.newsItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NewsInstrumentLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $NewsInstrumentLinksTable> {
  $$NewsInstrumentLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NewsItemsTableOrderingComposer get newsId {
    final $$NewsItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.newsId,
      referencedTable: $db.newsItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NewsItemsTableOrderingComposer(
            $db: $db,
            $table: $db.newsItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NewsInstrumentLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewsInstrumentLinksTable> {
  $$NewsInstrumentLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NewsItemsTableAnnotationComposer get newsId {
    final $$NewsItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.newsId,
      referencedTable: $db.newsItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NewsItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.newsItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NewsInstrumentLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NewsInstrumentLinksTable,
          DbNewsInstrumentLink,
          $$NewsInstrumentLinksTableFilterComposer,
          $$NewsInstrumentLinksTableOrderingComposer,
          $$NewsInstrumentLinksTableAnnotationComposer,
          $$NewsInstrumentLinksTableCreateCompanionBuilder,
          $$NewsInstrumentLinksTableUpdateCompanionBuilder,
          (DbNewsInstrumentLink, $$NewsInstrumentLinksTableReferences),
          DbNewsInstrumentLink,
          PrefetchHooks Function({bool newsId, bool instrumentId})
        > {
  $$NewsInstrumentLinksTableTableManager(
    _$AppDatabase db,
    $NewsInstrumentLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewsInstrumentLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewsInstrumentLinksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NewsInstrumentLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> newsId = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsInstrumentLinksCompanion(
                newsId: newsId,
                instrumentId: instrumentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String newsId,
                required String instrumentId,
                Value<int> rowid = const Value.absent(),
              }) => NewsInstrumentLinksCompanion.insert(
                newsId: newsId,
                instrumentId: instrumentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NewsInstrumentLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({newsId = false, instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (newsId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.newsId,
                        referencedTable: $$NewsInstrumentLinksTableReferences
                            ._newsIdTable(db),
                        referencedColumn: $$NewsInstrumentLinksTableReferences
                            ._newsIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$NewsInstrumentLinksTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$NewsInstrumentLinksTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NewsInstrumentLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NewsInstrumentLinksTable,
      DbNewsInstrumentLink,
      $$NewsInstrumentLinksTableFilterComposer,
      $$NewsInstrumentLinksTableOrderingComposer,
      $$NewsInstrumentLinksTableAnnotationComposer,
      $$NewsInstrumentLinksTableCreateCompanionBuilder,
      $$NewsInstrumentLinksTableUpdateCompanionBuilder,
      (DbNewsInstrumentLink, $$NewsInstrumentLinksTableReferences),
      DbNewsInstrumentLink,
      PrefetchHooks Function({bool newsId, bool instrumentId})
    >;
typedef $$FilingsTableCreateCompanionBuilder = FilingsCompanion Function({
  required String source,
  required DateTime fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  required String id,
  required String instrumentId,
  required String formType,
  required DateTime filedAt,
  required String url,
  Value<String?> title,
  Value<DateTime?> periodOfReport,
  Value<int> rowid,
});
typedef $$FilingsTableUpdateCompanionBuilder = FilingsCompanion Function({
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
  Value<String> id,
  Value<String> instrumentId,
  Value<String> formType,
  Value<DateTime> filedAt,
  Value<String> url,
  Value<String?> title,
  Value<DateTime?> periodOfReport,
  Value<int> rowid,
});

final class $$FilingsTableReferences
    extends BaseReferences<_$AppDatabase, $FilingsTable, DbFiling> {
  $$FilingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('filings__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FilingsTableFilterComposer
    extends Composer<_$AppDatabase, $FilingsTable> {
  $$FilingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get filedAt => $composableBuilder(
    column: $table.filedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodOfReport => $composableBuilder(
    column: $table.periodOfReport,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FilingsTableOrderingComposer
    extends Composer<_$AppDatabase, $FilingsTable> {
  $$FilingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get filedAt => $composableBuilder(
    column: $table.filedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodOfReport => $composableBuilder(
    column: $table.periodOfReport,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FilingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FilingsTable> {
  $$FilingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formType =>
      $composableBuilder(column: $table.formType, builder: (column) => column);

  GeneratedColumn<DateTime> get filedAt =>
      $composableBuilder(column: $table.filedAt, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get periodOfReport => $composableBuilder(
    column: $table.periodOfReport,
    builder: (column) => column,
  );

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FilingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FilingsTable,
          DbFiling,
          $$FilingsTableFilterComposer,
          $$FilingsTableOrderingComposer,
          $$FilingsTableAnnotationComposer,
          $$FilingsTableCreateCompanionBuilder,
          $$FilingsTableUpdateCompanionBuilder,
          (DbFiling, $$FilingsTableReferences),
          DbFiling,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$FilingsTableTableManager(_$AppDatabase db, $FilingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<String> formType = const Value.absent(),
                Value<DateTime> filedAt = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime?> periodOfReport = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilingsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                formType: formType,
                filedAt: filedAt,
                url: url,
                title: title,
                periodOfReport: periodOfReport,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                required String id,
                required String instrumentId,
                required String formType,
                required DateTime filedAt,
                required String url,
                Value<String?> title = const Value.absent(),
                Value<DateTime?> periodOfReport = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilingsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                formType: formType,
                filedAt: filedAt,
                url: url,
                title: title,
                periodOfReport: periodOfReport,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FilingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$FilingsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$FilingsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FilingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FilingsTable,
      DbFiling,
      $$FilingsTableFilterComposer,
      $$FilingsTableOrderingComposer,
      $$FilingsTableAnnotationComposer,
      $$FilingsTableCreateCompanionBuilder,
      $$FilingsTableUpdateCompanionBuilder,
      (DbFiling, $$FilingsTableReferences),
      DbFiling,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$ResearchSnapshotsTableCreateCompanionBuilder =
    ResearchSnapshotsCompanion Function({
      required String source,
      required DateTime fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      Value<int> id,
      required String instrumentId,
      required DateTime takenAt,
      required int overallScore,
      required String overallSummary,
      required String overallFactorsJson,
      Value<String> dimensionsJson,
    });
typedef $$ResearchSnapshotsTableUpdateCompanionBuilder =
    ResearchSnapshotsCompanion Function({
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<DateTime?> updatedAt,
      Value<CacheState> cacheState,
      Value<Confidence> confidence,
      Value<String?> reportedCurrency,
      Value<String?> originalSymbol,
      Value<String?> providerExchange,
      Value<int> id,
      Value<String> instrumentId,
      Value<DateTime> takenAt,
      Value<int> overallScore,
      Value<String> overallSummary,
      Value<String> overallFactorsJson,
      Value<String> dimensionsJson,
    });

final class $$ResearchSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ResearchSnapshotsTable,
          DbResearchSnapshot
        > {
  $$ResearchSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) =>
      db.instruments.createAlias(
        'research_snapshots__instrument_id__instruments__internal_id',
      );

  $$InstrumentsTableProcessedTableManager get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id')!;

    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResearchSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ResearchSnapshotsTable> {
  $$ResearchSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CacheState, CacheState, String>
  get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Confidence, Confidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overallSummary => $composableBuilder(
    column: $table.overallSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overallFactorsJson => $composableBuilder(
    column: $table.overallFactorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimensionsJson => $composableBuilder(
    column: $table.dimensionsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResearchSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResearchSnapshotsTable> {
  $$ResearchSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheState => $composableBuilder(
    column: $table.cacheState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overallSummary => $composableBuilder(
    column: $table.overallSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overallFactorsJson => $composableBuilder(
    column: $table.overallFactorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimensionsJson => $composableBuilder(
    column: $table.dimensionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResearchSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResearchSnapshotsTable> {
  $$ResearchSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CacheState, String> get cacheState =>
      $composableBuilder(
        column: $table.cacheState,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Confidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reportedCurrency => $composableBuilder(
    column: $table.reportedCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalSymbol => $composableBuilder(
    column: $table.originalSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerExchange => $composableBuilder(
    column: $table.providerExchange,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overallSummary => $composableBuilder(
    column: $table.overallSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overallFactorsJson => $composableBuilder(
    column: $table.overallFactorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dimensionsJson => $composableBuilder(
    column: $table.dimensionsJson,
    builder: (column) => column,
  );

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResearchSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResearchSnapshotsTable,
          DbResearchSnapshot,
          $$ResearchSnapshotsTableFilterComposer,
          $$ResearchSnapshotsTableOrderingComposer,
          $$ResearchSnapshotsTableAnnotationComposer,
          $$ResearchSnapshotsTableCreateCompanionBuilder,
          $$ResearchSnapshotsTableUpdateCompanionBuilder,
          (DbResearchSnapshot, $$ResearchSnapshotsTableReferences),
          DbResearchSnapshot,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$ResearchSnapshotsTableTableManager(
    _$AppDatabase db,
    $ResearchSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResearchSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> instrumentId = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<int> overallScore = const Value.absent(),
                Value<String> overallSummary = const Value.absent(),
                Value<String> overallFactorsJson = const Value.absent(),
                Value<String> dimensionsJson = const Value.absent(),
              }) => ResearchSnapshotsCompanion(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                takenAt: takenAt,
                overallScore: overallScore,
                overallSummary: overallSummary,
                overallFactorsJson: overallFactorsJson,
                dimensionsJson: dimensionsJson,
              ),
          createCompanionCallback:
              ({
                required String source,
                required DateTime fetchedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<CacheState> cacheState = const Value.absent(),
                Value<Confidence> confidence = const Value.absent(),
                Value<String?> reportedCurrency = const Value.absent(),
                Value<String?> originalSymbol = const Value.absent(),
                Value<String?> providerExchange = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String instrumentId,
                required DateTime takenAt,
                required int overallScore,
                required String overallSummary,
                required String overallFactorsJson,
                Value<String> dimensionsJson = const Value.absent(),
              }) => ResearchSnapshotsCompanion.insert(
                source: source,
                fetchedAt: fetchedAt,
                updatedAt: updatedAt,
                cacheState: cacheState,
                confidence: confidence,
                reportedCurrency: reportedCurrency,
                originalSymbol: originalSymbol,
                providerExchange: providerExchange,
                id: id,
                instrumentId: instrumentId,
                takenAt: takenAt,
                overallScore: overallScore,
                overallSummary: overallSummary,
                overallFactorsJson: overallFactorsJson,
                dimensionsJson: dimensionsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResearchSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$ResearchSnapshotsTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$ResearchSnapshotsTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResearchSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResearchSnapshotsTable,
      DbResearchSnapshot,
      $$ResearchSnapshotsTableFilterComposer,
      $$ResearchSnapshotsTableOrderingComposer,
      $$ResearchSnapshotsTableAnnotationComposer,
      $$ResearchSnapshotsTableCreateCompanionBuilder,
      $$ResearchSnapshotsTableUpdateCompanionBuilder,
      (DbResearchSnapshot, $$ResearchSnapshotsTableReferences),
      DbResearchSnapshot,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$AlertRulesTableCreateCompanionBuilder = AlertRulesCompanion Function({
  Value<int> id,
  Value<String?> instrumentId,
  required String kind,
  Value<bool> enabled,
  Value<String> configJson,
});
typedef $$AlertRulesTableUpdateCompanionBuilder = AlertRulesCompanion Function({
  Value<int> id,
  Value<String?> instrumentId,
  Value<String> kind,
  Value<bool> enabled,
  Value<String> configJson,
});

final class $$AlertRulesTableReferences
    extends BaseReferences<_$AppDatabase, $AlertRulesTable, DbAlertRule> {
  $$AlertRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InstrumentsTable _instrumentIdTable(_$AppDatabase db) => db
      .instruments
      .createAlias('alert_rules__instrument_id__instruments__internal_id');

  $$InstrumentsTableProcessedTableManager? get instrumentId {
    final $_column = $_itemColumn<String>('instrument_id');
    if ($_column == null) return null;
    final manager = $$InstrumentsTableTableManager(
      $_db,
      $_db.instruments,
    ).filter((f) => f.internalId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instrumentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlertRulesTableFilterComposer
    extends Composer<_$AppDatabase, $AlertRulesTable> {
  $$AlertRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  $$InstrumentsTableFilterComposer get instrumentId {
    final $$InstrumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableFilterComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertRulesTable> {
  $$AlertRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$InstrumentsTableOrderingComposer get instrumentId {
    final $$InstrumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableOrderingComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertRulesTable> {
  $$AlertRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  $$InstrumentsTableAnnotationComposer get instrumentId {
    final $$InstrumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.instrumentId,
      referencedTable: $db.instruments,
      getReferencedColumn: (t) => t.internalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstrumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.instruments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlertRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertRulesTable,
          DbAlertRule,
          $$AlertRulesTableFilterComposer,
          $$AlertRulesTableOrderingComposer,
          $$AlertRulesTableAnnotationComposer,
          $$AlertRulesTableCreateCompanionBuilder,
          $$AlertRulesTableUpdateCompanionBuilder,
          (DbAlertRule, $$AlertRulesTableReferences),
          DbAlertRule,
          PrefetchHooks Function({bool instrumentId})
        > {
  $$AlertRulesTableTableManager(_$AppDatabase db, $AlertRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> instrumentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> configJson = const Value.absent(),
              }) => AlertRulesCompanion(
                id: id,
                instrumentId: instrumentId,
                kind: kind,
                enabled: enabled,
                configJson: configJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> instrumentId = const Value.absent(),
                required String kind,
                Value<bool> enabled = const Value.absent(),
                Value<String> configJson = const Value.absent(),
              }) => AlertRulesCompanion.insert(
                id: id,
                instrumentId: instrumentId,
                kind: kind,
                enabled: enabled,
                configJson: configJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlertRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({instrumentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (instrumentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.instrumentId,
                        referencedTable: $$AlertRulesTableReferences
                            ._instrumentIdTable(db),
                        referencedColumn: $$AlertRulesTableReferences
                            ._instrumentIdTable(db)
                            .internalId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlertRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertRulesTable,
      DbAlertRule,
      $$AlertRulesTableFilterComposer,
      $$AlertRulesTableOrderingComposer,
      $$AlertRulesTableAnnotationComposer,
      $$AlertRulesTableCreateCompanionBuilder,
      $$AlertRulesTableUpdateCompanionBuilder,
      (DbAlertRule, $$AlertRulesTableReferences),
      DbAlertRule,
      PrefetchHooks Function({bool instrumentId})
    >;
typedef $$ProviderStatesTableCreateCompanionBuilder =
    ProviderStatesCompanion Function({
      required String providerId,
      required String health,
      Value<DateTime?> lastRequestAt,
      Value<DateTime?> rateLimitResetAt,
      Value<String?> lastErrorCategory,
      Value<String?> lastErrorDetail,
      Value<int> cacheHits,
      Value<int> cacheMisses,
      Value<int> rowid,
    });
typedef $$ProviderStatesTableUpdateCompanionBuilder =
    ProviderStatesCompanion Function({
      Value<String> providerId,
      Value<String> health,
      Value<DateTime?> lastRequestAt,
      Value<DateTime?> rateLimitResetAt,
      Value<String?> lastErrorCategory,
      Value<String?> lastErrorDetail,
      Value<int> cacheHits,
      Value<int> cacheMisses,
      Value<int> rowid,
    });

class $$ProviderStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderStatesTable> {
  $$ProviderStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRequestAt => $composableBuilder(
    column: $table.lastRequestAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateLimitResetAt => $composableBuilder(
    column: $table.rateLimitResetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCategory => $composableBuilder(
    column: $table.lastErrorCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorDetail => $composableBuilder(
    column: $table.lastErrorDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheHits => $composableBuilder(
    column: $table.cacheHits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheMisses => $composableBuilder(
    column: $table.cacheMisses,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProviderStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderStatesTable> {
  $$ProviderStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get health => $composableBuilder(
    column: $table.health,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRequestAt => $composableBuilder(
    column: $table.lastRequestAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateLimitResetAt => $composableBuilder(
    column: $table.rateLimitResetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCategory => $composableBuilder(
    column: $table.lastErrorCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorDetail => $composableBuilder(
    column: $table.lastErrorDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheHits => $composableBuilder(
    column: $table.cacheHits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheMisses => $composableBuilder(
    column: $table.cacheMisses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProviderStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderStatesTable> {
  $$ProviderStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get health =>
      $composableBuilder(column: $table.health, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRequestAt => $composableBuilder(
    column: $table.lastRequestAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rateLimitResetAt => $composableBuilder(
    column: $table.rateLimitResetAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCategory => $composableBuilder(
    column: $table.lastErrorCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorDetail => $composableBuilder(
    column: $table.lastErrorDetail,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cacheHits =>
      $composableBuilder(column: $table.cacheHits, builder: (column) => column);

  GeneratedColumn<int> get cacheMisses => $composableBuilder(
    column: $table.cacheMisses,
    builder: (column) => column,
  );
}

class $$ProviderStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderStatesTable,
          DbProviderState,
          $$ProviderStatesTableFilterComposer,
          $$ProviderStatesTableOrderingComposer,
          $$ProviderStatesTableAnnotationComposer,
          $$ProviderStatesTableCreateCompanionBuilder,
          $$ProviderStatesTableUpdateCompanionBuilder,
          (
            DbProviderState,
            BaseReferences<
              _$AppDatabase,
              $ProviderStatesTable,
              DbProviderState
            >,
          ),
          DbProviderState,
          PrefetchHooks Function()
        > {
  $$ProviderStatesTableTableManager(
    _$AppDatabase db,
    $ProviderStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> providerId = const Value.absent(),
                Value<String> health = const Value.absent(),
                Value<DateTime?> lastRequestAt = const Value.absent(),
                Value<DateTime?> rateLimitResetAt = const Value.absent(),
                Value<String?> lastErrorCategory = const Value.absent(),
                Value<String?> lastErrorDetail = const Value.absent(),
                Value<int> cacheHits = const Value.absent(),
                Value<int> cacheMisses = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderStatesCompanion(
                providerId: providerId,
                health: health,
                lastRequestAt: lastRequestAt,
                rateLimitResetAt: rateLimitResetAt,
                lastErrorCategory: lastErrorCategory,
                lastErrorDetail: lastErrorDetail,
                cacheHits: cacheHits,
                cacheMisses: cacheMisses,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String providerId,
                required String health,
                Value<DateTime?> lastRequestAt = const Value.absent(),
                Value<DateTime?> rateLimitResetAt = const Value.absent(),
                Value<String?> lastErrorCategory = const Value.absent(),
                Value<String?> lastErrorDetail = const Value.absent(),
                Value<int> cacheHits = const Value.absent(),
                Value<int> cacheMisses = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderStatesCompanion.insert(
                providerId: providerId,
                health: health,
                lastRequestAt: lastRequestAt,
                rateLimitResetAt: rateLimitResetAt,
                lastErrorCategory: lastErrorCategory,
                lastErrorDetail: lastErrorDetail,
                cacheHits: cacheHits,
                cacheMisses: cacheMisses,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProviderStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderStatesTable,
      DbProviderState,
      $$ProviderStatesTableFilterComposer,
      $$ProviderStatesTableOrderingComposer,
      $$ProviderStatesTableAnnotationComposer,
      $$ProviderStatesTableCreateCompanionBuilder,
      $$ProviderStatesTableUpdateCompanionBuilder,
      (
        DbProviderState,
        BaseReferences<_$AppDatabase, $ProviderStatesTable, DbProviderState>,
      ),
      DbProviderState,
      PrefetchHooks Function()
    >;
typedef $$SyncJobsTableCreateCompanionBuilder = SyncJobsCompanion Function({
  Value<int> id,
  required String kind,
  Value<String?> instrumentId,
  required String priority,
  required String state,
  Value<String?> providerId,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<int> attempts,
  Value<String?> lastErrorCategory,
});
typedef $$SyncJobsTableUpdateCompanionBuilder = SyncJobsCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String?> instrumentId,
  Value<String> priority,
  Value<String> state,
  Value<String?> providerId,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<int> attempts,
  Value<String?> lastErrorCategory,
});

class $$SyncJobsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncJobsTable> {
  $$SyncJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCategory => $composableBuilder(
    column: $table.lastErrorCategory,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncJobsTable> {
  $$SyncJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCategory => $composableBuilder(
    column: $table.lastErrorCategory,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncJobsTable> {
  $$SyncJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get instrumentId => $composableBuilder(
    column: $table.instrumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastErrorCategory => $composableBuilder(
    column: $table.lastErrorCategory,
    builder: (column) => column,
  );
}

class $$SyncJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncJobsTable,
          DbSyncJob,
          $$SyncJobsTableFilterComposer,
          $$SyncJobsTableOrderingComposer,
          $$SyncJobsTableAnnotationComposer,
          $$SyncJobsTableCreateCompanionBuilder,
          $$SyncJobsTableUpdateCompanionBuilder,
          (DbSyncJob, BaseReferences<_$AppDatabase, $SyncJobsTable, DbSyncJob>),
          DbSyncJob,
          PrefetchHooks Function()
        > {
  $$SyncJobsTableTableManager(_$AppDatabase db, $SyncJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> instrumentId = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> providerId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCategory = const Value.absent(),
              }) => SyncJobsCompanion(
                id: id,
                kind: kind,
                instrumentId: instrumentId,
                priority: priority,
                state: state,
                providerId: providerId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                attempts: attempts,
                lastErrorCategory: lastErrorCategory,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<String?> instrumentId = const Value.absent(),
                required String priority,
                required String state,
                Value<String?> providerId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastErrorCategory = const Value.absent(),
              }) => SyncJobsCompanion.insert(
                id: id,
                kind: kind,
                instrumentId: instrumentId,
                priority: priority,
                state: state,
                providerId: providerId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                attempts: attempts,
                lastErrorCategory: lastErrorCategory,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncJobsTable,
      DbSyncJob,
      $$SyncJobsTableFilterComposer,
      $$SyncJobsTableOrderingComposer,
      $$SyncJobsTableAnnotationComposer,
      $$SyncJobsTableCreateCompanionBuilder,
      $$SyncJobsTableUpdateCompanionBuilder,
      (DbSyncJob, BaseReferences<_$AppDatabase, $SyncJobsTable, DbSyncJob>),
      DbSyncJob,
      PrefetchHooks Function()
    >;
typedef $$SyncLogsTableCreateCompanionBuilder = SyncLogsCompanion Function({
  Value<int> id,
  required DateTime timestamp,
  required String level,
  required String component,
  Value<String?> provider,
  Value<String?> operation,
  required String message,
  Value<int?> durationMs,
  Value<String?> errorCategory,
});
typedef $$SyncLogsTableUpdateCompanionBuilder = SyncLogsCompanion Function({
  Value<int> id,
  Value<DateTime> timestamp,
  Value<String> level,
  Value<String> component,
  Value<String?> provider,
  Value<String?> operation,
  Value<String> message,
  Value<int?> durationMs,
  Value<String?> errorCategory,
});

class $$SyncLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get component => $composableBuilder(
    column: $table.component,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCategory => $composableBuilder(
    column: $table.errorCategory,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get component => $composableBuilder(
    column: $table.component,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCategory => $composableBuilder(
    column: $table.errorCategory,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogsTable> {
  $$SyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get component =>
      $composableBuilder(column: $table.component, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCategory => $composableBuilder(
    column: $table.errorCategory,
    builder: (column) => column,
  );
}

class $$SyncLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogsTable,
          DbSyncLog,
          $$SyncLogsTableFilterComposer,
          $$SyncLogsTableOrderingComposer,
          $$SyncLogsTableAnnotationComposer,
          $$SyncLogsTableCreateCompanionBuilder,
          $$SyncLogsTableUpdateCompanionBuilder,
          (DbSyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, DbSyncLog>),
          DbSyncLog,
          PrefetchHooks Function()
        > {
  $$SyncLogsTableTableManager(_$AppDatabase db, $SyncLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> component = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> operation = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> errorCategory = const Value.absent(),
              }) => SyncLogsCompanion(
                id: id,
                timestamp: timestamp,
                level: level,
                component: component,
                provider: provider,
                operation: operation,
                message: message,
                durationMs: durationMs,
                errorCategory: errorCategory,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required String level,
                required String component,
                Value<String?> provider = const Value.absent(),
                Value<String?> operation = const Value.absent(),
                required String message,
                Value<int?> durationMs = const Value.absent(),
                Value<String?> errorCategory = const Value.absent(),
              }) => SyncLogsCompanion.insert(
                id: id,
                timestamp: timestamp,
                level: level,
                component: component,
                provider: provider,
                operation: operation,
                message: message,
                durationMs: durationMs,
                errorCategory: errorCategory,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogsTable,
      DbSyncLog,
      $$SyncLogsTableFilterComposer,
      $$SyncLogsTableOrderingComposer,
      $$SyncLogsTableAnnotationComposer,
      $$SyncLogsTableCreateCompanionBuilder,
      $$SyncLogsTableUpdateCompanionBuilder,
      (DbSyncLog, BaseReferences<_$AppDatabase, $SyncLogsTable, DbSyncLog>),
      DbSyncLog,
      PrefetchHooks Function()
    >;
typedef $$CacheMetadataTableCreateCompanionBuilder =
    CacheMetadataCompanion Function({
      required String cacheKey,
      required String dataType,
      required String source,
      required DateTime fetchedAt,
      required DateTime expiresAt,
      Value<String?> etag,
      Value<int> rowid,
    });
typedef $$CacheMetadataTableUpdateCompanionBuilder =
    CacheMetadataCompanion Function({
      Value<String> cacheKey,
      Value<String> dataType,
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<DateTime> expiresAt,
      Value<String?> etag,
      Value<int> rowid,
    });

class $$CacheMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);
}

class $$CacheMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMetadataTable,
          DbCacheMetadata,
          $$CacheMetadataTableFilterComposer,
          $$CacheMetadataTableOrderingComposer,
          $$CacheMetadataTableAnnotationComposer,
          $$CacheMetadataTableCreateCompanionBuilder,
          $$CacheMetadataTableUpdateCompanionBuilder,
          (
            DbCacheMetadata,
            BaseReferences<_$AppDatabase, $CacheMetadataTable, DbCacheMetadata>,
          ),
          DbCacheMetadata,
          PrefetchHooks Function()
        > {
  $$CacheMetadataTableTableManager(_$AppDatabase db, $CacheMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetadataCompanion(
                cacheKey: cacheKey,
                dataType: dataType,
                source: source,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                etag: etag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String dataType,
                required String source,
                required DateTime fetchedAt,
                required DateTime expiresAt,
                Value<String?> etag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetadataCompanion.insert(
                cacheKey: cacheKey,
                dataType: dataType,
                source: source,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                etag: etag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMetadataTable,
      DbCacheMetadata,
      $$CacheMetadataTableFilterComposer,
      $$CacheMetadataTableOrderingComposer,
      $$CacheMetadataTableAnnotationComposer,
      $$CacheMetadataTableCreateCompanionBuilder,
      $$CacheMetadataTableUpdateCompanionBuilder,
      (
        DbCacheMetadata,
        BaseReferences<_$AppDatabase, $CacheMetadataTable, DbCacheMetadata>,
      ),
      DbCacheMetadata,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db, _db.instruments);
  $$ProviderMappingsTableTableManager get providerMappings =>
      $$ProviderMappingsTableTableManager(_db, _db.providerMappings);
  $$HoldingsTableTableManager get holdings =>
      $$HoldingsTableTableManager(_db, _db.holdings);
  $$WatchlistEntriesTableTableManager get watchlistEntries =>
      $$WatchlistEntriesTableTableManager(_db, _db.watchlistEntries);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db, _db.fxRates);
  $$DividendEventsTableTableManager get dividendEvents =>
      $$DividendEventsTableTableManager(_db, _db.dividendEvents);
  $$EarningsEventsTableTableManager get earningsEvents =>
      $$EarningsEventsTableTableManager(_db, _db.earningsEvents);
  $$CorporateEventsTableTableManager get corporateEvents =>
      $$CorporateEventsTableTableManager(_db, _db.corporateEvents);
  $$NewsItemsTableTableManager get newsItems =>
      $$NewsItemsTableTableManager(_db, _db.newsItems);
  $$NewsInstrumentLinksTableTableManager get newsInstrumentLinks =>
      $$NewsInstrumentLinksTableTableManager(_db, _db.newsInstrumentLinks);
  $$FilingsTableTableManager get filings =>
      $$FilingsTableTableManager(_db, _db.filings);
  $$ResearchSnapshotsTableTableManager get researchSnapshots =>
      $$ResearchSnapshotsTableTableManager(_db, _db.researchSnapshots);
  $$AlertRulesTableTableManager get alertRules =>
      $$AlertRulesTableTableManager(_db, _db.alertRules);
  $$ProviderStatesTableTableManager get providerStates =>
      $$ProviderStatesTableTableManager(_db, _db.providerStates);
  $$SyncJobsTableTableManager get syncJobs =>
      $$SyncJobsTableTableManager(_db, _db.syncJobs);
  $$SyncLogsTableTableManager get syncLogs =>
      $$SyncLogsTableTableManager(_db, _db.syncLogs);
  $$CacheMetadataTableTableManager get cacheMetadata =>
      $$CacheMetadataTableTableManager(_db, _db.cacheMetadata);
}
