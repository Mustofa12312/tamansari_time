import '../../domain/entities/prayer_time.dart';

class PrayerTimeModel extends PrayerTime {
  const PrayerTimeModel({
    required super.imsak,
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.date,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimeModel(
      imsak: DateTime.parse(json['imsak'] as String),
      fajr: DateTime.parse(json['fajr'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      dhuhr: DateTime.parse(json['dhuhr'] as String),
      asr: DateTime.parse(json['asr'] as String),
      maghrib: DateTime.parse(json['maghrib'] as String),
      isha: DateTime.parse(json['isha'] as String),
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'imsak': imsak.toIso8601String(),
        'fajr': fajr.toIso8601String(),
        'sunrise': sunrise.toIso8601String(),
        'dhuhr': dhuhr.toIso8601String(),
        'asr': asr.toIso8601String(),
        'maghrib': maghrib.toIso8601String(),
        'isha': isha.toIso8601String(),
        'date': date.toIso8601String(),
      };

  factory PrayerTimeModel.fromEntity(PrayerTime entity) {
    return PrayerTimeModel(
      imsak: entity.imsak,
      fajr: entity.fajr,
      sunrise: entity.sunrise,
      dhuhr: entity.dhuhr,
      asr: entity.asr,
      maghrib: entity.maghrib,
      isha: entity.isha,
      date: entity.date,
    );
  }
}
