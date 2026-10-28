class Calisan {
  final String id;
  final String ad;

  Calisan({
    required this.id,
    required this.ad,
  });

  // JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
    };
  }

  // JSON'dan oluşturma
  factory Calisan.fromJson(Map<String, dynamic> json) {
    return Calisan(
      id: json['id'],
      ad: json['ad'],
    );
  }
}

class CalisanBelgeKayit {
  final String calisanId;
  final DateTime tarih;

  CalisanBelgeKayit({
    required this.calisanId,
    required this.tarih,
  });

  // JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'calisanId': calisanId,
      'tarih': tarih.toIso8601String(),
    };
  }

  // JSON'dan oluşturma
  factory CalisanBelgeKayit.fromJson(Map<String, dynamic> json) {
    return CalisanBelgeKayit(
      calisanId: json['calisanId'],
      tarih: DateTime.parse(json['tarih']),
    );
  }
}
