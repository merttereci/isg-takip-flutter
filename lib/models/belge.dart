import 'calisan.dart';

class Belge {
  final String id;
  final String ad;
  final BelgeTipi tip;
  bool varMi;

  int? yapilan;
  int? yapilmayan;

  DateTime? gecerlilikTarihi;
  List<CalisanBelgeKayit>? calisanKayitlar;

  Belge({
    required this.id,
    required this.ad,
    required this.tip,
    this.varMi = false,
    this.yapilan,
    this.yapilmayan,
    this.gecerlilikTarihi,
    this.calisanKayitlar,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'tip': tip.toString(),
      'varMi': varMi,
      'yapilan': yapilan,
      'yapilmayan': yapilmayan,
      'gecerlilikTarihi': gecerlilikTarihi?.toIso8601String(),
      'calisanKayitlar': calisanKayitlar?.map((k) => k.toJson()).toList(),
    };
  }

  factory Belge.fromJson(Map<String, dynamic> json) {
    return Belge(
      id: json['id'],
      ad: json['ad'],
      tip: BelgeTipi.values.firstWhere(
        (e) => e.toString() == json['tip'],
      ),
      varMi: json['varMi'] ?? false,
      yapilan: json['yapilan'],
      yapilmayan: json['yapilmayan'],
      gecerlilikTarihi: json['gecerlilikTarihi'] != null
          ? DateTime.parse(json['gecerlilikTarihi'])
          : null,
      calisanKayitlar: (json['calisanKayitlar'] as List?)
          ?.map((k) => CalisanBelgeKayit.fromJson(k))
          .toList(),
    );
  }

  Belge copyWith({
    String? id,
    String? ad,
    BelgeTipi? tip,
    bool? varMi,
    int? yapilan,
    int? yapilmayan,
    DateTime? gecerlilikTarihi,
    List<CalisanBelgeKayit>? calisanKayitlar,
  }) {
    return Belge(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      tip: tip ?? this.tip,
      varMi: varMi ?? this.varMi,
      yapilan: yapilan ?? this.yapilan,
      yapilmayan: yapilmayan ?? this.yapilmayan,
      gecerlilikTarihi: gecerlilikTarihi ?? this.gecerlilikTarihi,
      calisanKayitlar: calisanKayitlar ?? this.calisanKayitlar,
    );
  }

  static List<Belge> standartBelgeler() {
    return [
      Belge(
        id: '1',
        ad: 'Risk Analiz Değerlendirmesi',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '2',
        ad: 'Acil Eylem Planı',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '3',
        ad: 'Risk Değerlendirmesi ve Acil Durum Ekipler Listesi',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '4',
        ad: 'İş Güvenliği Eğitim Belgeleri',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '5',
        ad: 'İş Güvenliği Eğitim Katılım Formu',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '6',
        ad: 'İşe Giriş Muayenesi',
        tip: BelgeTipi.standart,
        yapilan: 0,
        yapilmayan: 0,
      ),
      Belge(
        id: '7',
        ad: 'İş Güvenliği Talimatnamesi',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '8',
        ad: 'KKD Zimmet Formu',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: '9',
        ad: 'MYK',
        tip: BelgeTipi.standart,
      ),
    ];
  }
}

enum BelgeTipi {
  standart,
  ozel,
}
