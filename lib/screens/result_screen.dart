import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/settings_model.dart';
import '../models/plow_engine.dart';
import '../models/kayit_model.dart';
import '../services/kayit_deposu.dart';

class ResultScreen extends StatefulWidget {
  final double arEn;
  final double arBo;
  final double v1Kmh;
  final double mig;
  final OlcumDegerleri olcumDegerleri;

  const ResultScreen({
    super.key,
    required this.arEn,
    required this.arBo,
    required this.v1Kmh,
    required this.mig,
    required this.olcumDegerleri,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late SKP skp;
  late DKP dkp;

  late double simV1Kmh;
  late double simMig;

  @override
  void initState() {
    super.initState();
    skp = SKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: widget.mig,
      V1Kmh: widget.v1Kmh,
      olcumDegerleri: widget.olcumDegerleri,
    );
    dkp = DKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: widget.mig,
      V1Kmh: widget.v1Kmh,
      olcumDegerleri: widget.olcumDegerleri,
    );

    simV1Kmh = widget.v1Kmh;
    simMig = widget.mig;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Karşılaştırma Sonuçları"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: "Sonucu Kaydet",
              onPressed: _kaydetDialog,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.85),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            indicator: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: "Süre ve Kapasite",
              ),
              Tab(icon: Icon(Icons.stacked_line_chart), text: "Dinamik Analiz"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildIlkSekme(), _buildIkinciSekme()]),
      ),
    );
  }

  // ==========================================
  // --- İKİNCİ SEKME: DİNAMİK ANALİZ (GRAFİKLER) ---
  // ==========================================
  Widget _buildIkinciSekme() {
    var anlikSkp = SKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: simMig,
      V1Kmh: simV1Kmh,
      olcumDegerleri: widget.olcumDegerleri,
    );
    var anlikDkp = DKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: simMig,
      V1Kmh: simV1Kmh,
      olcumDegerleri: widget.olcumDegerleri,
    );

    return Column(
      children: [
        Container(
          color: Colors.blueGrey.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              const Text(
                "CANLI SİMÜLASYON KONTROLLERİ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text("Hız: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              "${simV1Kmh.toStringAsFixed(1)} km/h",
                              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Expanded(
                              child: Slider(
                                value: simV1Kmh,
                                min: 1,
                                max: 15,
                                divisions: 140,
                                onChanged: (val) => setState(() => simV1Kmh = val),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("İş Gen.: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              "${simMig.toStringAsFixed(1)} m",
                              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Expanded(
                              child: Slider(
                                value: simMig,
                                min: 0.3,
                                max: 6,
                                divisions: 57,
                                onChanged: (val) => setState(() => simMig = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay, size: 22),
                    tooltip: "Başlangıç değerlerine dön",
                    color: const Color.fromARGB(255, 0, 170, 255),
                    onPressed: () => setState(() {
                      simV1Kmh = widget.v1Kmh;
                      simMig = widget.mig;
                    }),
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnlikDegerKutusu(
                      "SKP",
                      anlikSkp.tarlaEtkinligi * 100,
                      anlikSkp.AKe_Dah,
                      Colors.blue,
                    ),
                    _buildAnlikFark(
                      anlikSkp.tarlaEtkinligi * 100,
                      anlikDkp.tarlaEtkinligi * 100,
                    ),
                    _buildAnlikDegerKutusu(
                      "DKP",
                      anlikDkp.tarlaEtkinligi * 100,
                      anlikDkp.AKe_Dah,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGrafikKarti(
                          baslik: "HIZ - PERFORMANS EĞRİSİ",
                          xEksenAdi: "Çalışma Hızı (km/h)",
                          grafikWidget: _buildHizGrafigi(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGrafikKarti(
                          baslik: "İŞ GENİŞLİĞİ - PERFORMANS EĞRİSİ",
                          xEksenAdi: "İş Genişliği (m)",
                          grafikWidget: _buildGenislikGrafigi(),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildGrafikKarti(
                        baslik: "HIZ - PERFORMANS EĞRİSİ",
                        xEksenAdi: "Çalışma Hızı (km/h)",
                        grafikWidget: _buildHizGrafigi(),
                      ),
                      const SizedBox(height: 16),
                      _buildGrafikKarti(
                        baslik: "İŞ GENİŞLİĞİ - PERFORMANS EĞRİSİ",
                        xEksenAdi: "İş Genişliği (m)",
                        grafikWidget: _buildGenislikGrafigi(),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnlikFark(double skpEtk, double dkpEtk) {
    final fark = (skpEtk - dkpEtk).abs();
    final berabere = fark < 0.1;
    final kazanan = skpEtk > dkpEtk ? "SKP" : "DKP";
    final renk = berabere
        ? Colors.blueGrey
        : (skpEtk > dkpEtk ? Colors.blue.shade700 : Colors.orange.shade700);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          berabere ? "=" : "▲${fark.toStringAsFixed(1)}%",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: renk),
        ),
        Text(
          berabere ? "Eşit" : kazanan,
          style: TextStyle(fontSize: 10, color: renk),
        ),
      ],
    );
  }

  Widget _buildAnlikDegerKutusu(
    String baslik,
    double etkinlik,
    double kapasite,
    Color renk,
  ) {
    return Column(
      children: [
        Text(
          baslik,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: renk,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.percent, size: 14, color: Colors.blueGrey),
            const SizedBox(width: 2),
            Text(
              etkinlik.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.agriculture, size: 14, color: Colors.blueGrey),
            const SizedBox(width: 2),
            Text(
              "${kapasite.toStringAsFixed(1)} da/h",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrafikKarti({
    required String baslik,
    required String xEksenAdi,
    required Widget grafikWidget,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                _lejantKutusu(Colors.blue, "SKP %"),
                _lejantKutusu(Colors.orange, "DKP %"),
                _lejantKutusu(Colors.blue, "SKP da/h", isDashed: true),
                _lejantKutusu(Colors.orange, "DKP da/h", isDashed: true),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 280, child: grafikWidget),
            const SizedBox(height: 12),
            Text(
              xEksenAdi,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lejantKutusu(Color renk, String metin, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isDashed
            ? SizedBox(
                width: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 4, height: 3, color: renk),
                    Container(width: 4, height: 3, color: renk),
                    Container(width: 4, height: 3, color: renk),
                  ],
                ),
              )
            : Container(width: 16, height: 3, color: renk),
        const SizedBox(width: 6),
        Text(
          metin,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ==========================================
  // --- EKSEN VE GRID (IZGARA) AYARLARI ---
  // ==========================================
  FlTitlesData _buildDualAxisTitles(double scaleFactor, double xInterval) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        axisNameSize: 22,
        axisNameWidget: const Text(
          "% Etkinlik",
          style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 20,
          getTitlesWidget: (value, meta) {
            // Y EKSENİ SIFIRI GİZLE
            if (value == 0) return const SizedBox.shrink();
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 11),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(
        axisNameSize: 22,
        axisNameWidget: const Text(
          "Kapasite (da/h)",
          style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 52,
          interval: 20,
          getTitlesWidget: (value, meta) {
            // Y EKSENİ SIFIRI GİZLE
            if (value == 0) return const SizedBox.shrink();
            double realValue = value / scaleFactor;
            String etiket = realValue % 1 == 0
                ? realValue.toInt().toString()
                : realValue.toStringAsFixed(1);
            return Text(etiket, style: const TextStyle(fontSize: 11));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: xInterval,
          getTitlesWidget: (value, meta) {
            // 1. DURUM: HIZ GRAFİĞİ (xInterval == 1.0 gelirse)
            // Sadece 2, 4, 6... (çift sayıları) göster
            if (xInterval == 1.0) {
              if (value.toInt() % 2 != 0 || value == 0) {
                return const SizedBox.shrink();
              }
            }

            // 2. DURUM: GENİŞLİK GRAFİĞİ (xInterval == 0.3 gelirse)
            // Sadece 0.9, 1.8, 2.7... (0.9'un katlarını) göster
            if (xInterval == 0.3) {
              if ((value * 10).round() % 9 != 0 || value == 0) {
                return const SizedBox.shrink();
              }
            }

            String etiket = value % 1 == 0
                ? value.toInt().toString()
                : value.toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                etiket,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // --- GRAFİK 1: HIZ (X EKSENİ) GRAFİĞİ ---
  // ==========================================
  Widget _buildHizGrafigi() {
    var maxSkp = SKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: 6.0,
      V1Kmh: 15.0,
      olcumDegerleri: widget.olcumDegerleri,
    );
    var maxDkp = DKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: 6.0,
      V1Kmh: 15.0,
      olcumDegerleri: widget.olcumDegerleri,
    );

    double ustSinir = maxSkp.AKe_Dah > maxDkp.AKe_Dah
        ? maxSkp.AKe_Dah
        : maxDkp.AKe_Dah;
    if (ustSinir < 0.1) ustSinir = 0.1;

    double scaleFactor = 100.0 / ustSinir;

    List<FlSpot> skpEtkinlik = [];
    List<FlSpot> dkpEtkinlik = [];
    List<FlSpot> skpKapasite = [];
    List<FlSpot> dkpKapasite = [];

    for (double v = 1; v <= 15; v += 1) {
      var tSkp = SKP(
        ArEn: widget.arEn,
        ArBo: widget.arBo,
        Mig: simMig,
        V1Kmh: v,
        olcumDegerleri: widget.olcumDegerleri,
      );
      var tDkp = DKP(
        ArEn: widget.arEn,
        ArBo: widget.arBo,
        Mig: simMig,
        V1Kmh: v,
        olcumDegerleri: widget.olcumDegerleri,
      );

      skpEtkinlik.add(FlSpot(v, tSkp.tarlaEtkinligi * 100));
      dkpEtkinlik.add(FlSpot(v, tDkp.tarlaEtkinligi * 100));
      skpKapasite.add(FlSpot(v, tSkp.AKe_Dah * scaleFactor));
      dkpKapasite.add(FlSpot(v, tDkp.AKe_Dah * scaleFactor));
    }

    return LineChart(
      LineChartData(
        clipData: const FlClipData.all(),
        lineTouchData: const LineTouchData(handleBuiltInTouches: false),
        minX: 1,
        maxX: 15,
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1.0,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: simV1Kmh,
              color: Colors.red.withValues(alpha: 0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
          ],
        ),
        titlesData: _buildDualAxisTitles(scaleFactor, 1.0),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineBarsData: [
          _cizgiOlustur(skpEtkinlik, Colors.blue),
          _cizgiOlustur(dkpEtkinlik, Colors.orange),
          _cizgiOlustur(skpKapasite, Colors.blue, isDashed: true),
          _cizgiOlustur(dkpKapasite, Colors.orange, isDashed: true),
        ],
      ),
      duration: const Duration(milliseconds: 150),
    );
  }

  // ==========================================
  // --- GRAFİK 2: İŞ GENİŞLİĞİ (X EKSENİ) GRAFİĞİ ---
  // ==========================================
  Widget _buildGenislikGrafigi() {
    var maxSkp = SKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: 6.0,
      V1Kmh: 15.0,
      olcumDegerleri: widget.olcumDegerleri,
    );
    var maxDkp = DKP(
      ArEn: widget.arEn,
      ArBo: widget.arBo,
      Mig: 6.0,
      V1Kmh: 15.0,
      olcumDegerleri: widget.olcumDegerleri,
    );

    double ustSinir = maxSkp.AKe_Dah > maxDkp.AKe_Dah
        ? maxSkp.AKe_Dah
        : maxDkp.AKe_Dah;
    if (ustSinir < 0.1) ustSinir = 0.1;

    double scaleFactor = 100.0 / ustSinir;

    List<FlSpot> skpEtkinlik = [];
    List<FlSpot> dkpEtkinlik = [];
    List<FlSpot> skpKapasite = [];
    List<FlSpot> dkpKapasite = [];

    for (double m = 0.3; m <= 6.0; m += 0.3) {
      var tSkp = SKP(
        ArEn: widget.arEn,
        ArBo: widget.arBo,
        Mig: m,
        V1Kmh: simV1Kmh,
        olcumDegerleri: widget.olcumDegerleri,
      );
      var tDkp = DKP(
        ArEn: widget.arEn,
        ArBo: widget.arBo,
        Mig: m,
        V1Kmh: simV1Kmh,
        olcumDegerleri: widget.olcumDegerleri,
      );

      skpEtkinlik.add(FlSpot(m, tSkp.tarlaEtkinligi * 100));
      dkpEtkinlik.add(FlSpot(m, tDkp.tarlaEtkinligi * 100));
      skpKapasite.add(FlSpot(m, tSkp.AKe_Dah * scaleFactor));
      dkpKapasite.add(FlSpot(m, tDkp.AKe_Dah * scaleFactor));
    }

    return LineChart(
      LineChartData(
        clipData: const FlClipData.all(),
        lineTouchData: const LineTouchData(handleBuiltInTouches: false),
        minX: 0.3,
        maxX: 6,
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 0.3, // Grid çizgileri hassas kalsın (0.3)
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: simMig,
              color: Colors.red.withValues(alpha: 0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
          ],
        ),
        // DÜZELTİLDİ: Artış miktarını 0.6 yaparak "0.3, 0.9, 1.5..." düzenini sağlıyoruz
        titlesData: _buildDualAxisTitles(scaleFactor, 0.3),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineBarsData: [
          _cizgiOlustur(skpEtkinlik, Colors.blue),
          _cizgiOlustur(dkpEtkinlik, Colors.orange),
          _cizgiOlustur(skpKapasite, Colors.blue, isDashed: true),
          _cizgiOlustur(dkpKapasite, Colors.orange, isDashed: true),
        ],
      ),
      duration: const Duration(milliseconds: 150),
    );
  }

  // --- ÇİZGİ METODU ---
  LineChartBarData _cizgiOlustur(
    List<FlSpot> noktalar,
    Color renk, {
    bool isDashed = false,
  }) {
    return LineChartBarData(
      spots: noktalar,
      isCurved: true,
      color: renk,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: isDashed ? [5, 5] : null,
    );
  }

  // ==========================================
  // --- İLK SEKME KODLARI ---
  // ==========================================
  Widget _buildIlkSekme() {
    // 1. ADIM: Sadece kullanıcının eklediği ekstra ayarları filtreliyoruz
    var ekstraAyarlar = widget.olcumDegerleri.ayarListesi
        .where((a) => !widget.olcumDegerleri.isVarsayilan(a.ad))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildInputSummaryCard(),
          const SizedBox(height: 12),
          _buildKazananKarti(),
          const SizedBox(height: 12),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSatir(
                    baslik: "PARAMETRE",
                    skpDeger: "SKP",
                    dkpDeger: "DKP",
                    isHeader: true,
                  ),
                  const Divider(thickness: 1.5),

                  _buildGrupBasligi("AKTİF SÜRELER"),
                  _buildSatir(
                    baslik: "Parsel Boyu İşleme Süresi",
                    skpDeger: "${skp.ToPaBoIsSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.ToPaBoIsSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Yastık Boyu İşleme Süresi",
                    skpDeger: "${skp.ToYaBoIsSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.ToYaBoIsSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "TOPLAM AKTİF SÜRE",
                    skpDeger: "${skp.toplamAktifSure.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.toplamAktifSure.toStringAsFixed(1)} s",
                    isBold: true,
                    color: Colors.green.shade700,
                  ),

                  _buildGrupBasligi("PASİF SÜRELER"),
                  _buildSatir(
                    baslik: "Makine Bağlama Süresi",
                    skpDeger: "${skp.MaBaSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.MaBaSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Makine Ayırma Süresi",
                    skpDeger: "${skp.MaAySu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.MaAySu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Parsel Başı Dönme Süresi",
                    skpDeger: "${skp.ToPaBaDoSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.ToPaBaDoSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Makine Kontrol/Temizleme",
                    skpDeger: "${skp.ToMaKoTeSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.ToMaKoTeSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Makine Sökme Süresi",
                    skpDeger: "${skp.ToMaSoSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.ToMaSoSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Sürücü Dinlenme Süresi",
                    skpDeger: "${skp.ToSuDiSu.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.ToSuDiSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Parsel Ortası İşleme Süresi",
                    skpDeger: "${skp.ToPaOrIsSu.toStringAsFixed(1)} s",
                    dkpDeger: "-",
                  ),
                  _buildSatir(
                    baslik: "Parsel Kenarı İşleme Süresi",
                    skpDeger: "-",
                    dkpDeger: "${dkp.ToPaKeIsSu.toStringAsFixed(1)} s",
                  ),
                  _buildSatir(
                    baslik: "Yastık Boyu Geri Geliş",
                    skpDeger: "${skp.ToYaBoGeGeSu.toStringAsFixed(1)} s",
                    dkpDeger: "-",
                  ),
                  _buildSatir(
                    baslik: "Yastık Başı Dönüş Süresi",
                    skpDeger: "-",
                    dkpDeger: "${dkp.ToYaBaDoSu.toStringAsFixed(1)} s",
                  ),

                  // =================================================================
                  // 2. ADIM: KULLANICININ EKLEDİĞİ DİNAMİK SÜRELER BURADA LİSTELENİYOR
                  // =================================================================
                  if (ekstraAyarlar.isNotEmpty) ...[
                    const Divider(indent: 16, endIndent: 16),
                    // Spread operator (...) ile listeyi widget'lara çeviriyoruz
                    ...ekstraAyarlar.map((ayar) {
                      // Hangi pulluğa aitse sadece ona değer yazdırıyoruz, diğerine "-" basıyoruz
                      String skpStr =
                          (ayar.tip == PullukTipi.skp ||
                              ayar.tip == PullukTipi.ikisi)
                          ? "${ayar.deger.toStringAsFixed(1)} s"
                          : "-";
                      String dkpStr =
                          (ayar.tip == PullukTipi.dkp ||
                              ayar.tip == PullukTipi.ikisi)
                          ? "${ayar.deger.toStringAsFixed(1)} s"
                          : "-";

                      return _buildSatir(
                        baslik: ayar
                            .ad, // Ekstra olduğunu belli etmek için başına + koyduk
                        skpDeger: skpStr,
                        dkpDeger: dkpStr,
                        // Fabrika ayarlarından farklı renkte görünsün
                      );
                    }),
                  ],

                  // =================================================================
                  const Divider(),
                  _buildSatir(
                    baslik: "TOPLAM PASİF SÜRE",
                    skpDeger: "${skp.toplamPasifSure.toStringAsFixed(1)} s",
                    dkpDeger: "${dkp.toplamPasifSure.toStringAsFixed(1)} s",
                    isBold: true,
                    color: Colors.red.shade700,
                  ),

                  _buildGrupBasligi("PERFORMANS SONUÇLARI"),
                  _buildSatir(
                    baslik: "Toplam Çalışma Süresi",
                    skpDeger:
                        "${(skp.toplamAktifSure + skp.toplamPasifSure).toStringAsFixed(1)} s",
                    dkpDeger:
                        "${(dkp.toplamAktifSure + dkp.toplamPasifSure).toStringAsFixed(1)} s",
                    isBold: true,
                    color: Colors.purple.shade800,
                  ),
                  _buildSatir(
                    baslik: "Tarla Etkinliği",
                    skpDeger:
                        "%${(skp.tarlaEtkinligi * 100).toStringAsFixed(2)}",
                    dkpDeger:
                        "%${(dkp.tarlaEtkinligi * 100).toStringAsFixed(2)}",
                    isBold: true,
                  ),
                  _buildSatir(
                    baslik: "Teorik Kapasite (AK_dah)",
                    skpDeger: "${skp.AK_Dah.toStringAsFixed(2)} da/h",
                    dkpDeger: "${dkp.AK_Dah.toStringAsFixed(2)} da/h",
                    isBold: true,
                  ),
                  _buildSatir(
                    baslik: "Efektif Kapasite (AKe)",
                    skpDeger: "${skp.AKe_Dah.toStringAsFixed(2)} da/h",
                    dkpDeger: "${dkp.AKe_Dah.toStringAsFixed(2)} da/h",
                    isBold: true,
                    color: Colors.blue.shade900,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSummaryCard() {
    return Card(
      color: Colors.blueGrey.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              "GİRDİ VE ARAZİ ÖZETİ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn("Arazi", "${widget.arEn}x${widget.arBo} m"),
                _buildInfoColumn(
                  "Alan",
                  "${((widget.arEn * widget.arBo) / 1000).toStringAsFixed(1)} da",
                ),
                _buildInfoColumn("Hız (V1)", "${widget.v1Kmh} km/h"),
                _buildInfoColumn("İş Gen. (Mig)", "${widget.mig} m"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildGrupBasligi(String baslik) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        baslik,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildSatir({
    required String baslik,
    required String skpDeger,
    required String dkpDeger,
    bool isHeader = false,
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              baslik,
              style: TextStyle(
                fontWeight: isHeader || isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: isHeader ? 15 : 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              skpDeger,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader || isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              dkpDeger,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader || isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKazananKarti() {
    final skpEtk = skp.tarlaEtkinligi * 100;
    final dkpEtk = dkp.tarlaEtkinligi * 100;
    final fark = (skpEtk - dkpEtk).abs();
    final berabere = fark < 0.1;

    final String kazanan = berabere ? "Berabere" : (skpEtk > dkpEtk ? "SKP" : "DKP");
    final Color kazananRenk = berabere
        ? Colors.blueGrey
        : (skpEtk > dkpEtk ? Colors.blue.shade700 : const Color.fromARGB(255, 0, 0, 0));
    final IconData ikon = berabere ? Icons.balance : Icons.emoji_events;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(ikon, color: kazananRenk, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berabere ? "Sonuçlar çok yakın" : "$kazanan daha verimli",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: kazananRenk,
                    ),
                  ),
                  if (!berabere)
                    Text(
                      "+${fark.toStringAsFixed(1)}% etkinlik farkı",
                      style: TextStyle(fontSize: 12, color: kazananRenk.withValues(alpha: 0.8)),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOzetChip("SKP", skpEtk, const Color.fromARGB(255, 23, 116, 209)),
                const SizedBox(height: 4),
                _buildOzetChip("DKP", dkpEtk, const Color.fromARGB(255, 212, 107, 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOzetChip(String etiket, double etkinlik, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$etiket %${etkinlik.toStringAsFixed(1)}",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: renk),
      ),
    );
  }

  void _kaydetDialog() {
    String ad = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sonucu Kaydet"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Kayıt Adı",
            hintText: "örn. Kuzey Tarla",
            prefixIcon: Icon(Icons.bookmark_outlined),
          ),
          onChanged: (val) => ad = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              if (ad.trim().isEmpty) return;
              final kayit = KarsilastirmaKaydi(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                ad: ad.trim(),
                tarih: DateTime.now(),
                arEn: widget.arEn,
                arBo: widget.arBo,
                v1Kmh: widget.v1Kmh,
                mig: widget.mig,
                skpEtkinlik: skp.tarlaEtkinligi * 100,
                dkpEtkinlik: dkp.tarlaEtkinligi * 100,
                skpKapasite: skp.AKe_Dah,
                dkpKapasite: dkp.AKe_Dah,
                ayarSnapshot: widget.olcumDegerleri.ayarListesi
                    .map((e) => e.kopya())
                    .toList(),
              );
              await KayitDeposu().kaydet(kayit);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("'${kayit.ad}' kaydedildi."),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            },
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }
}
