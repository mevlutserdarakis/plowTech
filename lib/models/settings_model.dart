// Ayarın hangi pulluk tipini etkilediğini belirleyen kategori
enum PullukTipi { skp, dkp, ikisi, sistem }

class AyarItem {
  String ad;
  double deger;
  PullukTipi tip;

  AyarItem({
    required this.ad, 
    required this.deger, 
    this.tip = PullukTipi.sistem, // Varsayılan olarak sistem ayarı
  });

  AyarItem kopya() => AyarItem(ad: ad, deger: deger, tip: tip);
}

class OlcumDegerleri {
  final List<AyarItem> _sistemSablonu = [
    // Genel Operasyonel Ayarlar
    AyarItem(ad: "PaSa", deger: 2.0, tip: PullukTipi.skp),

    // SKP Ayarları
    AyarItem(ad: "MaBaSu_SKP", deger: 120, tip: PullukTipi.skp),
    AyarItem(ad: "MaAySu_SKP", deger: 70, tip: PullukTipi.skp),
    AyarItem(ad: "BrMaKoTeSu_SKP", deger: 70, tip: PullukTipi.skp),
    AyarItem(ad: "ToMaSoSu_SKP", deger: 120, tip: PullukTipi.skp),

    // DKP Ayarları
    AyarItem(ad: "MaBaSu_DKP", deger: 200, tip: PullukTipi.dkp),
    AyarItem(ad: "MaAySu_DKP", deger: 80, tip: PullukTipi.dkp),
    AyarItem(ad: "PaBaDoSu_DKP", deger: 20, tip: PullukTipi.dkp),
    AyarItem(ad: "BrMaKoTeSu_DKP", deger: 80, tip: PullukTipi.dkp),
    AyarItem(ad: "BrYaBaDoSu_DKP", deger: 5, tip: PullukTipi.dkp),
    AyarItem(ad: "ToMaSoSu_DKP", deger: 130, tip: PullukTipi.dkp),
  ];

  List<AyarItem> ayarListesi = [];

  OlcumDegerleri() {
    varsayilanaDon();
  }

  // Listeden isimle değer çekmeyi kolaylaştıran yardımcı metot
  double degerGetir(String ad) {
    return ayarListesi.firstWhere((e) => e.ad == ad).deger;
  }

  void yeniAyarOlustur(String ad, double deger, PullukTipi tip) {
    ayarListesi.add(AyarItem(ad: ad, deger: deger, tip: tip));
  }

  void varsayilanaDon() {
    ayarListesi.clear();
    ayarListesi = _sistemSablonu.map((e) => e.kopya()).toList();
  }

  // Kullanıcının sonradan eklediği özel pasif süreleri hesaplar
  double ekstraPasifSureleriTopla(PullukTipi aktifTip) {
    double toplam = 0;
    var sistemAdlari = _sistemSablonu.map((e) => e.ad).toList();

    for (var ayar in ayarListesi) {
      if (!sistemAdlari.contains(ayar.ad)) {
        if (ayar.tip == aktifTip || ayar.tip == PullukTipi.ikisi) {
          toplam += ayar.deger;
        }
      }
    }
    return toplam;
  }

  // Mevcut bir ayarın değerini veya tipini güncelleme
  void ayarGuncelle(String ad, double yeniDeger, PullukTipi yeniTip) {
    int index = ayarListesi.indexWhere((e) => e.ad == ad);
    if (index != -1) {
      ayarListesi[index].deger = yeniDeger;
      ayarListesi[index].tip = yeniTip;
    }
  }

  // --- YENİ EKLENEN METOTLAR (SİLME VE KONTROL İÇİN) ---
  
  // Bir ayarın fabrikasyon (sistem) ayarı olup olmadığını kontrol eder
  bool isVarsayilan(String ad) {
    return _sistemSablonu.any((e) => e.ad == ad);
  }

  // Kullanıcının eklediği özel bir ayarı listeden tamamen siler
  void ayarSil(String ad) {
    ayarListesi.removeWhere((e) => e.ad == ad);
  }
}