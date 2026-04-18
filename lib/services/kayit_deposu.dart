import 'package:shared_preferences/shared_preferences.dart';
import '../models/kayit_model.dart';

class KayitDeposu {
  static const String _anaAnahtar = 'karsilastirma_kayitlari';

  Future<List<KarsilastirmaKaydi>> tumKayitlariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_anaAnahtar) ?? [];
    return liste.map((s) => KarsilastirmaKaydi.fromJsonString(s)).toList()
      ..sort((a, b) => b.tarih.compareTo(a.tarih)); // en yeni üstte
  }

  Future<void> kaydet(KarsilastirmaKaydi kayit) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_anaAnahtar) ?? [];
    liste.add(kayit.toJsonString());
    await prefs.setStringList(_anaAnahtar, liste);
  }

  Future<void> adGuncelle(String id, String yeniAd) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_anaAnahtar) ?? [];
    final guncellenmis = liste.map((s) {
      final kayit = KarsilastirmaKaydi.fromJsonString(s);
      if (kayit.id == id) {
        kayit.ad = yeniAd;
        return kayit.toJsonString();
      }
      return s;
    }).toList();
    await prefs.setStringList(_anaAnahtar, guncellenmis);
  }

  Future<void> sil(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_anaAnahtar) ?? [];
    liste.removeWhere((s) {
      final kayit = KarsilastirmaKaydi.fromJsonString(s);
      return kayit.id == id;
    });
    await prefs.setStringList(_anaAnahtar, liste);
  }

  Future<void> tumunuSil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_anaAnahtar);
  }
}
