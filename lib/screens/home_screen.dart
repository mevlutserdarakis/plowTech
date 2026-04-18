import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings_model.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final OlcumDegerleri olcumDegerleri;

  const HomeScreen({super.key, required this.olcumDegerleri});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  double arEn = 60.0;
  double arBo = 200.0;
  double v1Kmh = 4.0;
  double mig = 0.9;

  void girdileriYukle(double yArEn, double yArBo, double yV1Kmh, double yMig) {
    setState(() {
      arEn = yArEn;
      arBo = yArBo;
      v1Kmh = yV1Kmh;
      mig = yMig;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ekran genişliğini alıyoruz
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("PloWe - Parametre Girişi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _InputRow(
              title: "Arazi Eni (m)",
              value: arEn,
              min: 10,
              max: 1000,
              divisions: 99, // 10'ar 10'ar artış
              onChanged: (val) => setState(() => arEn = val),
            ),
            _InputRow(
              title: "Arazi Boyu (m)",
              value: arBo,
              min: 10,
              max: 1000,
              divisions: 99, // 10'ar 10'ar artış
              onChanged: (val) => setState(() => arBo = val),
            ),
            _InputRow(
              title: "Çalışma Hızı (km/h)",
              value: v1Kmh,
              min: 1,
              max: 15,
              divisions: 14, // 1'er 1'er artış
              onChanged: (val) => setState(() => v1Kmh = val),
            ),
            _InputRow(
              title: "İş Genişliği (m)",
              value: mig,
              min: 0.3,
              max: 6,
              divisions: 57,
              onChanged: (val) => setState(() => mig = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // Buton genişliğini ekranın %50'si (0.5) yapıyoruz
                minimumSize: Size(screenWidth * 0.5, 50),
              ),
              onPressed: () {
                double yaGe = 4.0 + (mig / 0.3);
                double paBo = arBo - (2 * yaGe);

                String? hata;
                if (arEn < mig) {
                  hata = "Arazi eni iş genişliğinden küçük olamaz. En az ${mig.toStringAsFixed(1)}m olmalıdır.";
                } else if (arEn < 2 * mig) {
                  hata = "Arazi eni en az 2 × iş genişliği (${(2 * mig).toStringAsFixed(1)}m) olmalıdır.";
                } else if (paBo <= 0) {
                  hata = "Arazi boyu yetersiz. Mig=${mig}m için en az ${(2 * yaGe + 1).ceil()}m olmalıdır.";
                }

                if (hata != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(hata),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      arEn: arEn,
                      arBo: arBo,
                      v1Kmh: v1Kmh,
                      mig: mig,
                      olcumDegerleri: widget.olcumDegerleri,
                    ),
                  ),
                );
              },
              child: const Text("Hesapla ve Karşılaştır"),
            )
          ],
        ),
      ),
    );
  }
}

class _InputRow extends StatefulWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _InputRow({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  State<_InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(_InputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: widget.value,
                  min: widget.min,
                  max: widget.max,
                  divisions: widget.divisions,
                  onChanged: widget.onChanged,
                ),
              ),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    // Sadece rakam, nokta ve virgüle izin verir
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    // İkinci bir nokta veya virgül girişini engelleyen akıllı fonksiyon
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final hasDot = newValue.text.contains('.');
                      final hasComma = newValue.text.contains(',');
                      final multipleDots = newValue.text.indexOf('.') != newValue.text.lastIndexOf('.');
                      final multipleCommas = newValue.text.indexOf(',') != newValue.text.lastIndexOf(',');

                      if (multipleDots || multipleCommas || (hasDot && hasComma)) {
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
                  onSubmitted: (val) {
                    double? parsed = double.tryParse(val.replaceFirst(',', '.'));
                    if (parsed != null) {
                      if (parsed < widget.min) parsed = widget.min;
                      if (parsed > widget.max) parsed = widget.max;
                      widget.onChanged(parsed);
                    } else {
                      _controller.text = _formatValue(widget.value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}