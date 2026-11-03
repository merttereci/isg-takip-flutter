import 'belge.dart';
import 'calisan.dart';
import 'json_okuyucu.dart';

class Sirket {
  final String id;
  final String ad;
  final TehlikeSinifi tehlikeSinifi;
  final int calisanSayisi;
  final List<Belge> belgeler;
  final bool yildizli;
  final String not;
  final List<Calisan> calisanlar;

  Sirket({
    required this.id,
    required this.ad,
    required this.tehlikeSinifi,
    required this.calisanSayisi,
    List<Belge>? belgeler,
    this.yildizli = false,
    this.not = '',
    List<Calisan>? calisanlar,
  })  : belgeler = belgeler ?? [],
        calisanlar = calisanlar ?? [];

  /// Listeye henüz eklenmemiş çalışan sayısı. Çalışan sayısı, eklenen
  /// çalışanlardan az girilmişse eksiye düşmez.
  int get eklenmeyenCalisanSayisi {
    final fark = calisanSayisi - calisanlar.length;
    return fark < 0 ? 0 : fark;
  }

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

  /// JSON'dan oluşturma (veri okumak için). Kimliği olmayan ya da biçimi
  /// bozuk kayıtlar için null döner; diğer eksik alanlar varsayılan değerle
  /// doldurulur.
  static Sirket? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = jsonString(json['id']);
    if (id == null || id.isEmpty) return null;
    return Sirket(
      id: id,
      ad: jsonString(json['ad']) ?? '',
      tehlikeSinifi: jsonEnum(
        json['tehlikeSinifi'],
        TehlikeSinifi.values,
        TehlikeSinifi.azTehlikeli,
      ),
      calisanSayisi: jsonInt(json['calisanSayisi']),
      belgeler: jsonListe(json['belgeler'], Belge.tryFromJson),
      yildizli: jsonBool(json['yildizli']),
      not: jsonString(json['not']) ?? '',
      calisanlar: jsonListe(json['calisanlar'], Calisan.tryFromJson),
    );
  }

  // Kopyalama metodu (güncelleme için)
  Sirket copyWith({
    String? ad,
    TehlikeSinifi? tehlikeSinifi,
    int? calisanSayisi,
    List<Belge>? belgeler,
    bool? yildizli,
    String? not,
    List<Calisan>? calisanlar,
  }) {
    return Sirket(
      id: id,
      ad: ad ?? this.ad,
      tehlikeSinifi: tehlikeSinifi ?? this.tehlikeSinifi,
      calisanSayisi: calisanSayisi ?? this.calisanSayisi,
      belgeler: belgeler ?? this.belgeler,
      yildizli: yildizli ?? this.yildizli,
      not: not ?? this.not,
      calisanlar: calisanlar ?? this.calisanlar,
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
