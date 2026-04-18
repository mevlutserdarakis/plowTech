import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class AyarDeposu {
  static const String _anahtar = 'operasyonel_ayarlar';

  Future<void> kaydet(List<AyarItem> liste) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonListe = liste
        .map((e) => jsonEncode({
              'ad': e.ad,
              'deger': e.deger,
              'tip': e.tip.name,
            }))
        .toList();
    await prefs.setStringList(_anahtar, jsonListe);
  }

  Future<List<AyarItem>?> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_anahtar);
    if (liste == null) return null;
    return liste.map((s) {
      final json = jsonDecode(s);
      return AyarItem(
        ad: json['ad'],
        deger: (json['deger'] as num).toDouble(),
        tip: PullukTipi.values.firstWhere((e) => e.name == json['tip']),
      );
    }).toList();
  }

  Future<void> temizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_anahtar);
  }
}
