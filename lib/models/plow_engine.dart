import 'settings_model.dart';

abstract class Pulluk {
  final double ArEn;
  final double ArBo;
  final double Mig;
  final double V1Kmh;
  final OlcumDegerleri olcumDegerleri;
  final int YaSa = 2;

  Pulluk({
    required this.ArEn,
    required this.ArBo,
    required this.Mig,
    required this.V1Kmh,
    required this.olcumDegerleri,
  });

  // Ayarlar menüsünden dinamik çekilen değerler
  double get YaGe => 4.0 + (Mig / 0.3);
  int get PaSa; // SKP ve DKP kendi mantığına göre ezecek

  // Temel Hesaplamalar
  double get V1Ms => V1Kmh / 3.6;
  double get V2Ms => V2Kmh / 3.6;
  double get V2Kmh => V1Kmh * 0.8;
  double get AlanDa => ArEn * ArBo / 1000;
  double get AK_Dah => V1Kmh * Mig;
  double get AK_Dah_0_8 => V1Kmh * Mig * 0.8;

  // Pasif ve Aktif Süreler İçin Ortak Formüller (Eksik olanlar buraya eklendi)
  double get PaGe => ArEn / PaSa;
  double get ToPaSiSa => (PaGe / Mig) * PaSa;
  double get BrPaSiIsSu => 1 / V1Ms;
  double get PaBo => (ArBo - (2 * YaGe)).clamp(0.001, double.infinity);
  double get ToPaBoIsSu => ToPaSiSa * BrPaSiIsSu * PaBo;

  double get ToYaSiSa => YaGe / Mig;
  double get BrYaSiIsSu => 1 / V2Ms;
  double get YaBo => ArEn;
  double get YaBoIsSu => ToYaSiSa * BrYaSiIsSu * YaBo;
  double get ToYaBoIsSu => YaBoIsSu * YaSa;

  double get BrPaBaDoSu => 1 / V2Ms;
  double get PaBaDoSa => (YaBo / Mig) - 1;

  double get ToSuDiSu {
    if ((AlanDa / AK_Dah_0_8) <= 4) {
      return 900;
    } else if ((AlanDa / AK_Dah_0_8) <= 7.5) {
      return 1800;
    } else {
      return 3600;
    }
  }

  // Alt Sınıfların (SKP ve DKP) Kendilerine Göre Dolduracağı Metotlar
  double get ToPaBaDoSu;
  double get ToMaKoTeSu;
  double get MaBaSu;
  double get MaAySu;
  double get ToMaSoSu;
  double get toplamPasifSure;
  double get toplamAktifSure;

  // Sonuç Hesaplamaları
  double get tarlaEtkinligi => toplamAktifSure / (toplamAktifSure + toplamPasifSure);
  double get AKe_Dah => AK_Dah * tarlaEtkinligi;
}

class SKP extends Pulluk {
  SKP({
    required super.ArEn,
    required super.ArBo,
    required super.Mig,
    required super.V1Kmh,
    required super.olcumDegerleri,
  });

  @override
  int get PaSa => olcumDegerleri.degerGetir("PaSa").toInt();

  @override
  double get MaAySu => olcumDegerleri.degerGetir("MaAySu_SKP");

  @override
  double get MaBaSu => olcumDegerleri.degerGetir("MaBaSu_SKP");

  @override
  double get ToMaKoTeSu {
    double birimSure = olcumDegerleri.degerGetir("BrMaKoTeSu_SKP");
    if (AlanDa <= 20) return birimSure;
    if (AlanDa <= 40) return birimSure * 2;
    if (AlanDa <= 60) return birimSure * 3;
    if (AlanDa <= 80) return birimSure * 4;
    return birimSure * 5;
  }

  @override
  double get ToPaBaDoSu => YaBo * PaBaDoSa * BrPaBaDoSu;

  @override
  double get ToMaSoSu => olcumDegerleri.degerGetir("ToMaSoSu_SKP");

  double get BrPaOrIsSu => 1 / V1Ms;
  double get PaOrIsSu => PaBo * BrPaOrIsSu;
  double get ToPaOrIsSu => PaOrIsSu * PaSa;

  double get BrYaBoGeGeSu => 1 / V2Ms;
  double get YaBoGeGeSu => YaBo * BrYaBoGeGeSu;
  double get YaBoGeGeSa => (YaGe / Mig) - 1;
  double get ToYaBoGeGeSu => YaBoGeGeSu * YaBoGeGeSa * YaSa;

  @override
  double get toplamPasifSure {
    double anaSureler = MaAySu + MaBaSu + ToPaBaDoSu + ToPaOrIsSu + ToMaKoTeSu + ToYaBoGeGeSu + ToSuDiSu + ToMaSoSu;
    double kullaniciEkSureleri = olcumDegerleri.ekstraPasifSureleriTopla(PullukTipi.skp);
    return anaSureler + kullaniciEkSureleri;
  }

  @override
  double get toplamAktifSure => ToPaBoIsSu + ToYaBoIsSu;
}

class DKP extends Pulluk {
  DKP({
    required super.ArEn,
    required super.ArBo,
    required super.Mig,
    required super.V1Kmh,
    required super.olcumDegerleri,
  });

  @override
  int get PaSa => 1;

  @override
  double get MaAySu => olcumDegerleri.degerGetir("MaAySu_DKP");

  @override
  double get MaBaSu => olcumDegerleri.degerGetir("MaBaSu_DKP");

  @override
  double get ToMaKoTeSu {
    double birimSure = olcumDegerleri.degerGetir("BrMaKoTeSu_DKP");
    if (AlanDa <= 20) return birimSure;
    if (AlanDa <= 40) return birimSure * 2;
    if (AlanDa <= 60) return birimSure * 3;
    if (AlanDa <= 80) return birimSure * 4;
    return birimSure * 5;
  }

  @override
  double get ToPaBaDoSu => PaBaDoSa * olcumDegerleri.degerGetir("PaBaDoSu_DKP");

  @override
  double get ToMaSoSu => olcumDegerleri.degerGetir("ToMaSoSu_DKP");

  double get ToPaKeIsSu => PaBo * BrPaSiIsSu;

  double get YaBaDoSa => (YaGe / Mig) - 1;
  double get ToYaBaDoSu => olcumDegerleri.degerGetir("BrYaBaDoSu_DKP") * YaBaDoSa * YaSa;

  @override
  double get toplamPasifSure {
    double anaSureler = MaAySu + MaBaSu + ToPaBaDoSu + ToPaKeIsSu + ToMaKoTeSu + ToYaBaDoSu + ToSuDiSu + ToMaSoSu;
    double kullaniciEkSureleri = olcumDegerleri.ekstraPasifSureleriTopla(PullukTipi.dkp);
    return anaSureler + kullaniciEkSureleri;
  }

  @override
  double get toplamAktifSure => ToPaBoIsSu + ToYaBoIsSu;
}