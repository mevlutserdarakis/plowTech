import 'dart:convert';
import 'settings_model.dart';

class KarsilastirmaKaydi {
  final String id;
  String ad;
  final DateTime tarih;

  // Girdiler
  final double arEn;
  final double arBo;
  final double v1Kmh;
  final double mig;

  // Sonuçlar
  final double skpEtkinlik;
  final double dkpEtkinlik;
  final double skpKapasite;
  final double dkpKapasite;

  // Kayıt anındaki ayar snapshot'ı
  final List<AyarItem> ayarSnapshot;

  KarsilastirmaKaydi({
    required this.id,
    required this.ad,
    required this.tarih,
    required this.arEn,
    required this.arBo,
    required this.v1Kmh,
    required this.mig,
    required this.skpEtkinlik,
    required this.dkpEtkinlik,
    required this.skpKapasite,
    required this.dkpKapasite,
    required this.ayarSnapshot,
  });

  /// Kayıt anındaki ayarlarla yeni bir OlcumDegerleri oluşturur.
  OlcumDegerleri snapshotOlcumDegerleri() {
    final od = OlcumDegerleri();
    od.ayarListesi = ayarSnapshot.map((e) => e.kopya()).toList();
    return od;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'tarih': tarih.toIso8601String(),
        'arEn': arEn,
        'arBo': arBo,
        'v1Kmh': v1Kmh,
        'mig': mig,
        'skpEtkinlik': skpEtkinlik,
        'dkpEtkinlik': dkpEtkinlik,
        'skpKapasite': skpKapasite,
        'dkpKapasite': dkpKapasite,
        'ayarSnapshot': ayarSnapshot
            .map((e) => {'ad': e.ad, 'deger': e.deger, 'tip': e.tip.name})
            .toList(),
      };

  factory KarsilastirmaKaydi.fromJson(Map<String, dynamic> json) {
    List<AyarItem> snapshot = [];
    if (json['ayarSnapshot'] != null) {
      snapshot = (json['ayarSnapshot'] as List).map((e) {
        return AyarItem(
          ad: e['ad'],
          deger: (e['deger'] as num).toDouble(),
          tip: PullukTipi.values.firstWhere((t) => t.name == e['tip']),
        );
      }).toList();
    }

    return KarsilastirmaKaydi(
      id: json['id'],
      ad: json['ad'],
      tarih: DateTime.parse(json['tarih']),
      arEn: (json['arEn'] as num).toDouble(),
      arBo: (json['arBo'] as num).toDouble(),
      v1Kmh: (json['v1Kmh'] as num).toDouble(),
      mig: (json['mig'] as num).toDouble(),
      skpEtkinlik: (json['skpEtkinlik'] as num).toDouble(),
      dkpEtkinlik: (json['dkpEtkinlik'] as num).toDouble(),
      skpKapasite: (json['skpKapasite'] as num).toDouble(),
      dkpKapasite: (json['dkpKapasite'] as num).toDouble(),
      ayarSnapshot: snapshot,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory KarsilastirmaKaydi.fromJsonString(String source) =>
      KarsilastirmaKaydi.fromJson(jsonDecode(source));
}
