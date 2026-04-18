import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings_model.dart';
import '../services/ayar_deposu.dart';

class _SayiFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    // Sadece rakam, nokta ve virgüle izin ver; ondalık ayırıcı en fazla bir tane olabilir
    if (!RegExp(r'^[0-9]*[.,]?[0-9]*$').hasMatch(text)) return oldValue;
    return newValue;
  }
}

class SettingsScreen extends StatefulWidget {
  final OlcumDegerleri olcumDegerleri;

  const SettingsScreen({super.key, required this.olcumDegerleri});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AyarDeposu _ayarDeposu = AyarDeposu();

  void _kaydet() {
    _ayarDeposu.kaydet(widget.olcumDegerleri.ayarListesi);
  }
  String _birimBul(String ayarAdi) {
    if (ayarAdi == "PaSa") return "adet";
    return "s";
  }

  String _etiketBul(String ayarAdi) {
    if (ayarAdi == "PaSa") return "Miktar (adet)";
    return "Süre (saniye)";
  }

  String _pullukTipiGoster(PullukTipi tip) {
    switch (tip) {
      case PullukTipi.skp: return "SKP";
      case PullukTipi.dkp: return "DKP";
      case PullukTipi.ikisi: return "İKİSİ";
      case PullukTipi.sistem: return "SİSTEM";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operasyonel Ayarlar"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final onay = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Fabrika Ayarlarına Dön"),
                  content: const Text("Tüm değişiklikler ve eklenen süreler silinecek. Emin misiniz?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Vazgeç")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Sıfırla", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (onay == true) {
                setState(() => widget.olcumDegerleri.varsayilanaDon());
                _ayarDeposu.temizle();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tüm ayarlar fabrika ayarlarına döndürüldü.")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- ÜST BÖLÜM: MERKEZİ KONTROL PANELİ ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50.withValues(alpha: 0.5),
              border: Border(bottom: BorderSide(color: Colors.blueGrey.shade100)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.manage_accounts, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  "SİSTEM YAPILANDIRMASI",
                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.2, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _yeniAyarDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("Yeni Süre Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // --- ALT BÖLÜM: AYAR LİSTESİ ---
          Expanded(
            child: ListView.separated(
              itemCount: widget.olcumDegerleri.ayarListesi.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 60),
              itemBuilder: (context, index) {
                final ayar = widget.olcumDegerleri.ayarListesi[index];
                bool isSistemAyari = widget.olcumDegerleri.isVarsayilan(ayar.ad);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSistemAyari ? Colors.blueGrey.shade100 : Colors.orange.shade100,
                    radius: 18,
                    child: Icon(
                      isSistemAyari ? Icons.settings_suggest_outlined : Icons.person_add_alt_1,
                      color: isSistemAyari ? Colors.blueGrey : Colors.orange.shade900,
                      size: 18,
                    ),
                  ),
                  title: Text(ayar.ad, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text("Uyum: ${_pullukTipiGoster(ayar.tip)}", style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade400)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "${ayar.deger} ${_birimBul(ayar.ad)}",
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blue.shade900, fontSize: 13),
                        ),
                      ),
                      if (!isSistemAyari)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          onPressed: () => _silmeOnayiDialog(ayar),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                  onTap: () => _ayarDuzenleDialog(ayar),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _silmeOnayiDialog(AyarItem ayar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ayarı Sil"),
        content: Text("'${ayar.ad}' süresini silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () {
              setState(() {
                widget.olcumDegerleri.ayarListesi.remove(ayar);
              });
              _kaydet();
              Navigator.pop(context);
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _yeniAyarDialog() {
    String ad = "";
    double deger = 0;
    PullukTipi seciliTip = PullukTipi.ikisi;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Yeni Pasif Süre Ekle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Ayar Adı", prefixIcon: Icon(Icons.edit_note)),
                onChanged: (val) => ad = val,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: "Değer", prefixIcon: Icon(Icons.timer_outlined)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_SayiFormatter()],
                onChanged: (val) => deger = double.tryParse(val.replaceFirst(',', '.')) ?? 0,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<PullukTipi>(
                initialValue: seciliTip,
                decoration: const InputDecoration(labelText: "İşlem Tipi"),
                items: PullukTipi.values
                    .where((tip) => tip != PullukTipi.sistem)
                    .map((tip) => DropdownMenuItem(value: tip, child: Text(_pullukTipiGoster(tip))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => seciliTip = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
            ElevatedButton(
              onPressed: () {
                if (ad.isNotEmpty) {
                  setState(() => widget.olcumDegerleri.yeniAyarOlustur(ad, deger, seciliTip));
                  _kaydet();
                  Navigator.pop(context);
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }

  void _ayarDuzenleDialog(AyarItem ayar) {
    double yeniDeger = ayar.deger;
    PullukTipi yeniTip = ayar.tip;
    bool isVarsayilan = widget.olcumDegerleri.isVarsayilan(ayar.ad);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("${ayar.ad} Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: ayar.deger.toString(),
                decoration: InputDecoration(labelText: _etiketBul(ayar.ad), prefixIcon: const Icon(Icons.edit)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_SayiFormatter()],
                onChanged: (val) => yeniDeger = double.tryParse(val.replaceFirst(',', '.')) ?? ayar.deger,
              ),
              if (!isVarsayilan) ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<PullukTipi>(
                  initialValue: yeniTip,
                  decoration: const InputDecoration(labelText: "İşlem Tipi"),
                  items: PullukTipi.values
                      .where((tip) => tip != PullukTipi.sistem)
                      .map((tip) => DropdownMenuItem(value: tip, child: Text(_pullukTipiGoster(tip))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => yeniTip = val);
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
            ElevatedButton(
              onPressed: () {
                setState(() => widget.olcumDegerleri.ayarGuncelle(ayar.ad, yeniDeger, yeniTip));
                _kaydet();
                Navigator.pop(context);
              },
              child: const Text("Güncelle"),
            ),
          ],
        ),
      ),
    );
  }
}