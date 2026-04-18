import 'package:flutter/material.dart';
import '../models/kayit_model.dart';
import '../services/kayit_deposu.dart';
import 'result_screen.dart';
import '../models/settings_model.dart';

class KaydedilenlerScreen extends StatefulWidget {
  final OlcumDegerleri olcumDegerleri;
  final void Function(double arEn, double arBo, double v1Kmh, double mig) onGirdileriYukle;

  const KaydedilenlerScreen({
    super.key,
    required this.olcumDegerleri,
    required this.onGirdileriYukle,
  });

  @override
  State<KaydedilenlerScreen> createState() => _KaydedilenlerScreenState();
}

class _KaydedilenlerScreenState extends State<KaydedilenlerScreen> {
  final KayitDeposu _depo = KayitDeposu();
  List<KarsilastirmaKaydi> _kayitlar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kayitlariYukle();
  }

  Future<void> _kayitlariYukle() async {
    final liste = await _depo.tumKayitlariGetir();
    setState(() {
      _kayitlar = liste;
      _yukleniyor = false;
    });
  }

  Future<void> _sil(KarsilastirmaKaydi kayit) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kaydı Sil"),
        content: Text("'${kayit.ad}' silinecek. Emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (onay == true) {
      await _depo.sil(kayit.id);
      _kayitlariYukle();
    }
  }

  Future<void> _adDuzenle(KarsilastirmaKaydi kayit) async {
    String yeniAd = kayit.ad;
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Adı Düzenle"),
        content: TextFormField(
          initialValue: kayit.ad,
          autofocus: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.edit)),
          onChanged: (val) => yeniAd = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
    if (onay == true && yeniAd.trim().isNotEmpty) {
      await _depo.adGuncelle(kayit.id, yeniAd.trim());
      _kayitlariYukle();
    }
  }

  void _detayGoster(KarsilastirmaKaydi kayit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          arEn: kayit.arEn,
          arBo: kayit.arBo,
          v1Kmh: kayit.v1Kmh,
          mig: kayit.mig,
          olcumDegerleri: kayit.ayarSnapshot.isEmpty
              ? widget.olcumDegerleri
              : kayit.snapshotOlcumDegerleri(),
        ),
      ),
    );
  }

  void _yenidenHesapla(KarsilastirmaKaydi kayit) {
    widget.onGirdileriYukle(kayit.arEn, kayit.arBo, kayit.v1Kmh, kayit.mig);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${kayit.ad}' girdileri Hesaplama ekranına yüklendi."),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kaydedilenler"),
        centerTitle: true,
        actions: [
          if (_kayitlar.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: "Tümünü Sil",
              onPressed: () async {
                final onay = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Tümünü Sil"),
                    content: const Text("Tüm kayıtlar silinecek. Emin misiniz?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Vazgeç")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Sil", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (onay == true) {
                  await _depo.tumunuSil();
                  _kayitlariYukle();
                }
              },
            ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _kayitlar.isEmpty
              ? _buildBosEkran()
              : RefreshIndicator(
                  onRefresh: _kayitlariYukle,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _kayitlar.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => _buildKayitKarti(_kayitlar[index]),
                  ),
                ),
    );
  }

  Widget _buildBosEkran() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 72, color: Colors.blueGrey.shade200),
          const SizedBox(height: 16),
          Text(
            "Henüz kayıt yok",
            style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "Hesaplama sonuçlarını kaydetmek için\nsağ üstteki  ikonu kullanın.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade300),
          ),
        ],
      ),
    );
  }

  Widget _buildKayitKarti(KarsilastirmaKaydi kayit) {
    final tarihStr =
        "${kayit.tarih.day.toString().padLeft(2, '0')} "
        "${_ayAdi(kayit.tarih.month)} "
        "${kayit.tarih.year}  "
        "${kayit.tarih.hour.toString().padLeft(2, '0')}:"
        "${kayit.tarih.minute.toString().padLeft(2, '0')}";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _detayGoster(kayit),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Başlık satırı ---
              Row(
                children: [
                  const Icon(Icons.bookmark, color: Colors.blueGrey, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kayit.ad,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Text(tarihStr, style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400)),
                ],
              ),
              const SizedBox(height: 8),

              // --- Girdi özeti ---
              Text(
                "${kayit.arEn.toInt()}×${kayit.arBo.toInt()} m  •  ${kayit.v1Kmh} km/h  •  ${kayit.mig} m",
                style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // --- Sonuç satırları ---
              Row(
                children: [
                  Expanded(child: _buildSonucSatiri("SKP", kayit.skpEtkinlik, kayit.skpKapasite, Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSonucSatiri("DKP", kayit.dkpEtkinlik, kayit.dkpKapasite, Colors.orange)),
                ],
              ),
              const SizedBox(height: 10),

              // --- Butonlar ---
              Wrap(
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text("Yeniden Adlandır"),
                    onPressed: () => _adDuzenle(kayit),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.replay, size: 16, color: Colors.blue.shade700),
                    label: Text("Yeniden Hesapla", style: TextStyle(color: Colors.blue.shade700)),
                    onPressed: () => _yenidenHesapla(kayit),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _sil(kayit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSonucSatiri(String tip, double etkinlik, double kapasite, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: renk.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip, style: TextStyle(fontWeight: FontWeight.bold, color: renk, fontSize: 12)),
          const SizedBox(height: 2),
          Text("%${etkinlik.toStringAsFixed(1)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text("${kapasite.toStringAsFixed(2)} da/h", style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600)),
        ],
      ),
    );
  }

  String _ayAdi(int ay) {
    const aylar = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"];
    return aylar[ay - 1];
  }
}
