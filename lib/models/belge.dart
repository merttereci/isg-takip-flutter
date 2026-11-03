import 'calisan.dart';
import 'json_okuyucu.dart';

/// Arayüzde özel davranışı olan standart belgelerin kimlikleri.
/// Bu değerler kayıtlı verilerde kullanıldığı için değiştirilmemelidir.
abstract final class StandartBelgeId {
  /// Geçerlilik tarihi tutulan belge.
  static const riskAnalizi = '1';

  /// Çalışan bazında tarih kaydı tutulan belgeler.
  static const egitimKatilimFormu = '5';
  static const iseGirisMuayenesi = '6';
}

class Belge {
  final String id;
  final String ad;
  final BelgeTipi tip;
  bool varMi;

  DateTime? gecerlilikTarihi;
  List<CalisanBelgeKayit>? calisanKayitlar;

  Belge({
    required this.id,
    required this.ad,
    required this.tip,
    this.varMi = false,
    this.gecerlilikTarihi,
    this.calisanKayitlar,
  });

  /// Geçerlilik tarihi seçilebilen belge mi?
  bool get gecerlilikTarihliMi => id == StandartBelgeId.riskAnalizi;

  /// Çalışan bazında tarih kaydı tutulan belge mi?
  bool get calisanBazliMi =>
      id == StandartBelgeId.egitimKatilimFormu ||
      id == StandartBelgeId.iseGirisMuayenesi;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'tip': tip.toString(),
      'varMi': varMi,
      'gecerlilikTarihi': gecerlilikTarihi?.toIso8601String(),
      'calisanKayitlar': calisanKayitlar?.map((k) => k.toJson()).toList(),
    };
  }

  /// JSON'dan oluşturma. Kimliği olmayan ya da biçimi bozuk kayıtlar için
  /// null döner; diğer eksik alanlar varsayılan değerle doldurulur.
  static Belge? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = jsonString(json['id']);
    if (id == null || id.isEmpty) return null;
    return Belge(
      id: id,
      ad: jsonString(json['ad']) ?? '',
      tip: jsonEnum(json['tip'], BelgeTipi.values, BelgeTipi.standart),
      varMi: jsonBool(json['varMi']),
      gecerlilikTarihi: jsonTarih(json['gecerlilikTarihi']),
      calisanKayitlar: json['calisanKayitlar'] is List
          ? jsonListe(json['calisanKayitlar'], CalisanBelgeKayit.tryFromJson)
          : null,
    );
  }

  Belge copyWith({
    bool? varMi,
    DateTime? gecerlilikTarihi,
    List<CalisanBelgeKayit>? calisanKayitlar,
  }) {
    return Belge(
      id: id,
      ad: ad,
      tip: tip,
      varMi: varMi ?? this.varMi,
      gecerlilikTarihi: gecerlilikTarihi ?? this.gecerlilikTarihi,
      calisanKayitlar: calisanKayitlar ?? this.calisanKayitlar,
    );
  }

  static List<Belge> standartBelgeler() {
    return [
      Belge(
        id: StandartBelgeId.riskAnalizi,
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
        id: StandartBelgeId.egitimKatilimFormu,
        ad: 'İş Güvenliği Eğitim Katılım Formu',
        tip: BelgeTipi.standart,
      ),
      Belge(
        id: StandartBelgeId.iseGirisMuayenesi,
        ad: 'İşe Giriş Muayenesi',
        tip: BelgeTipi.standart,
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
