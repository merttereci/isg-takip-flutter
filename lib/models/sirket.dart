import 'belge.dart';
import 'calisan.dart'; // ← BUNU EKLE

class Sirket {
  final String id;
  final String ad;
  final TehlikeSinifi tehlikeSinifi;
  final int calisanSayisi;
  final List<Belge> belgeler;
  final bool yildizli;
  final String not;
  final List<Calisan> calisanlar; // ← BUNU EKLE

  Sirket({
    required this.id,
    required this.ad,
    required this.tehlikeSinifi,
    required this.calisanSayisi,
    List<Belge>? belgeler,
    this.yildizli = false,
    this.not = '',
    List<Calisan>? calisanlar, // ← BUNU EKLE
  })  : belgeler = belgeler ?? [],
        calisanlar = calisanlar ?? []; // ← BUNU EKLE

  // JSON'a çevirme (veri kaydetmek için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'tehlikeSinifi': tehlikeSinifi.toString(),
      'calisanSayisi': calisanSayisi,
      'belgeler': belgeler.map((b) => b.toJson()).toList(),
      'yildizli': yildizli,
      'not': not,
      'calisanlar': calisanlar.map((c) => c.toJson()).toList(),
    };
  }

  // JSON'dan oluşturma (veri okumak için)
  factory Sirket.fromJson(Map<String, dynamic> json) {
    return Sirket(
      id: json['id'],
      ad: json['ad'],
      tehlikeSinifi: TehlikeSinifi.values.firstWhere(
        (e) => e.toString() == json['tehlikeSinifi'],
      ),
      calisanSayisi: json['calisanSayisi'],
      belgeler:
          (json['belgeler'] as List?)?.map((b) => Belge.fromJson(b)).toList() ??
              [],
      yildizli: json['yildizli'] ?? false,
      not: json['not'] ?? '',
      calisanlar: (json['calisanlar'] as List?) // ← BUNU EKLE
              ?.map((c) => Calisan.fromJson(c))
              .toList() ??
          [],
    );
  }

  // Kopyalama metodu (güncelleme için)
  Sirket copyWith({
    String? id,
    String? ad,
    TehlikeSinifi? tehlikeSinifi,
    int? calisanSayisi,
    List<Belge>? belgeler,
    bool? yildizli,
    String? not,
    List<Calisan>? calisanlar, // ← BUNU EKLE
  }) {
    return Sirket(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      tehlikeSinifi: tehlikeSinifi ?? this.tehlikeSinifi,
      calisanSayisi: calisanSayisi ?? this.calisanSayisi,
      belgeler: belgeler ?? this.belgeler,
      yildizli: yildizli ?? this.yildizli,
      not: not ?? this.not,
      calisanlar: calisanlar ?? this.calisanlar, // ← BUNU EKLE
    );
  }
}

enum TehlikeSinifi {
  azTehlikeli,
  tehlikeli,
  cokTehlikeli,
}

// Enum'u Türkçe göstermek için extension
extension TehlikeSinifiExtension on TehlikeSinifi {
  String get displayName {
    switch (this) {
      case TehlikeSinifi.azTehlikeli:
        return 'Az Tehlikeli';
      case TehlikeSinifi.tehlikeli:
        return 'Tehlikeli';
      case TehlikeSinifi.cokTehlikeli:
        return 'Çok Tehlikeli';
    }
  }
}
