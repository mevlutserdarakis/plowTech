# Masaüstü Uygulamas : https://github.com/mevlutserdarakis/plowTech/raw/main/SitemUygulama.rar
# Pulluk İşletme Analizi ve Tarla Etkinliği Hesaplama Modeli

Bu belge, **PlowTech (proje_ake)** uygulamasının temel aldığı mühendislik prensiplerini, matematiksel modelleri ve akademik hesaplama yöntemlerini detaylandırmaktadır. Uygulama, tarım makineleri işletmeciliği disiplini çerçevesinde, pullukların operasyonel verimliliğini analiz etmek amacıyla geliştirilmiştir.

## 1. Teorik Altyapı ve Kapsam

Tarımsal üretimde toprak işleme, enerji tüketiminin en yüksek olduğu safhalardan biridir. Pullukların tarla performansını belirleyen temel faktör, **Kapasite** ve **Tarla Etkinliği** (Field Efficiency) değerleridir. Uygulama, iki ana pulluk tipini analiz etmektedir:

*   **SKP (Sabit Kulaklı Pulluk):** Geleneksel toprak işleme yöntemlerinde kullanılan, tarlayı belirli bir yönde devirerek işleyen mekanizmalar.
*   **DKP (Döner Kulaklı Pulluk):** Çift yönlü çalışma kabiliyeti ile tarla sonu dönüşlerinde zaman tasarrufu sağlayan, modern ve yüksek verimli mekanizmalar.

## 2. Matematiksel Model ve Parametreler

Uygulama, ASAE (American Society of Agricultural and Biological Engineers) standartlarına paralel olarak aşağıdaki parametreleri kullanmaktadır:

### 2.1. Temel Değişkenler
- **ArEn / ArBo (m):** Arazi eni ve boyu.
- **Mig (m):** İş genişliği (Pulluk gövde sayısı × Gövde genişliği).
- **V1 (km/h):** Ana çalışma hızı.
- **V2 (km/h):** Dönüş ve boş geçiş hızı ($V_2 = V_1 \times 0.8$).

### 2.2. Kapasite Hesaplamaları
Teorik İş Başarısı ($C_{th}$) ve Efektif İş Başarısı ($C_{eff}$) formülleri:

$$C_{th} (da/h) = V \times Mig$$
$$C_{eff} = C_{th} \times \eta_{eff}$$

Burada $\eta_{eff}$, tarla etkinliğini temsil eder.

## 3. Süre Analizi ve Verimlilik (Tarla Etkinliği)

Verimlilik hesabı, aktif çalışma süresinin toplam süreye oranlanmasıyla elde edilir:

$$\eta_{eff} = \frac{T_{aktif}}{T_{aktif} + T_{pasif}}$$

### 3.1. Aktif Süreler ($T_{aktif}$)
- **ToPaBoIsSu:** Pulluğun toprak içindeki net ilerleme süresi.
- **ToYaBoIsSu:** Yastık başlarında yapılan işleme süreleri.

### 3.2. Pasif Süreler ($T_{pasif}$)
Uygulama, hassas bir analiz için aşağıdaki kayıp süreleri modellemektedir:
- **MaAySu / MaBaSu:** Makine ayar ve bakım süreleri.
- **ToPaBaDoSu:** Tarla başı dönüş süreleri (SKP ve DKP için farklı algoritmalar).
- **ToMaKoTeSu:** Makinenin kontrol ve temizlik süreleri.
- **ToSuDiSu:** Operatör dinlenme ve ikmal süreleri.
- **ToMaSoSu:** İş sonu temizlik ve taşıma hazırlığı.

## 4. SKP ve DKP Karşılaştırmalı Analiz Algoritması

Uygulama, DKP'nin sağladığı verimlilik artışını şu farklar üzerinden hesaplar:
- **Dönüş Kinematiği:** SKP'de tarlanın orta veya kenarlarında açılan yarılardan dolayı oluşan boş geçişler (YaBoGeGeSu) hesaplanırken, DKP'de bu süreler minimize edilir.
- **Pasif Mesafe:** DKP'de "mekik" tipi çalışma prensibi, ölü zamanları (Idle time) %15-30 oranında azaltmaktadır.

## 5. Mühendislik Çıktıları

Uygulama sonucunda kullanıcıya sunulan veriler:
1.  **Toplam Aktif/Pasif Süre Analizi:** Operasyonun hangi aşamasında ne kadar zaman harcandığının dökümü.
2.  **Tarla Etkinliği (%) :** Operasyonun ne kadar profesyonel yürütüldüğünün temel göstergesi.
3.  **Birim Alan Maliyet Projeksiyonu:** Zaman ve hız verilerinden yola çıkarak operasyonel planlama yeteneği.

---
*Bu modelleme, tarımsal mekanizasyon dersleri ve profesyonel tarım işletmeciliği raporlamaları için referans teşkil edebilecek düzeyde yapılandırılmıştır.*
