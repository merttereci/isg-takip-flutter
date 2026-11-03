import 'json_okuyucu.dart';

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

  /// JSON'dan oluşturma. Kimliği olmayan ya da biçimi bozuk kayıtlar için
  /// null döner.
  static Calisan? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = jsonString(json['id']);
    if (id == null || id.isEmpty) return null;
    return Calisan(
      id: id,
      ad: jsonString(json['ad']) ?? '',
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

  /// JSON'dan oluşturma. Çalışan kimliği ya da tarihi okunamayan kayıtlar
  /// için null döner.
  static CalisanBelgeKayit? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final calisanId = jsonString(json['calisanId']);
    final tarih = jsonTarih(json['tarih']);
    if (calisanId == null || calisanId.isEmpty || tarih == null) return null;
    return CalisanBelgeKayit(calisanId: calisanId, tarih: tarih);
  }
}
