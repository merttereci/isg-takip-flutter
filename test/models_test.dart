import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isg_takip/models/belge.dart';
import 'package:isg_takip/models/calisan.dart';
import 'package:isg_takip/models/sirket.dart';

void main() {
  group('Sirket JSON', () {
    test('JSON\'a yazılıp tekrar okunduğunda tüm alanlar korunur', () {
      final sirket = Sirket(
        id: 's1',
        ad: 'Örnek Yapı A.Ş.',
        tehlikeSinifi: TehlikeSinifi.cokTehlikeli,
        calisanSayisi: 12,
        yildizli: true,
        not: 'Yıllık denetim mart ayında.',
        calisanlar: [Calisan(id: 'c1', ad: 'Çalışan Bir')],
        belgeler: [
          Belge(
            id: StandartBelgeId.riskAnalizi,
            ad: 'Risk Analiz Değerlendirmesi',
            tip: BelgeTipi.standart,
            varMi: true,
            gecerlilikTarihi: DateTime(2027, 5, 1),
          ),
          Belge(
            id: StandartBelgeId.egitimKatilimFormu,
            ad: 'İş Güvenliği Eğitim Katılım Formu',
            tip: BelgeTipi.standart,
            calisanKayitlar: [
              CalisanBelgeKayit(calisanId: 'c1', tarih: DateTime(2026, 3, 15)),
            ],
          ),
          Belge(id: 'o1', ad: 'Özel Belge', tip: BelgeTipi.ozel),
        ],
      );

      // Gerçek kayıttaki gibi metne çevirip geri oku.
      final metin = jsonEncode(sirket.toJson());
      final okunan = Sirket.tryFromJson(jsonDecode(metin))!;

      expect(okunan.id, 's1');
      expect(okunan.ad, 'Örnek Yapı A.Ş.');
      expect(okunan.tehlikeSinifi, TehlikeSinifi.cokTehlikeli);
      expect(okunan.calisanSayisi, 12);
      expect(okunan.yildizli, isTrue);
      expect(okunan.not, 'Yıllık denetim mart ayında.');
      expect(okunan.calisanlar.single.ad, 'Çalışan Bir');

      expect(okunan.belgeler, hasLength(3));
      final risk = okunan.belgeler[0];
      expect(risk.varMi, isTrue);
      expect(risk.gecerlilikTarihi, DateTime(2027, 5, 1));

      final kayit = okunan.belgeler[1].calisanKayitlar!.single;
      expect(kayit.calisanId, 'c1');
      expect(kayit.tarih, DateTime(2026, 3, 15));

      expect(okunan.belgeler[2].tip, BelgeTipi.ozel);
    });

    test('eski sürümün kaydettiği veri okunabilir', () {
      // Önceki sürümde kaydedilen biçim (yapilan/yapilmayan alanları dahil).
      const eskiKayit = '''
      {"id":"1700000000000","ad":"Eski Şirket",
       "tehlikeSinifi":"TehlikeSinifi.tehlikeli","calisanSayisi":5,
       "belgeler":[{"id":"6","ad":"İşe Giriş Muayenesi",
         "tip":"BelgeTipi.standart","varMi":false,"yapilan":0,
         "yapilmayan":0,"gecerlilikTarihi":null,"calisanKayitlar":null}],
       "yildizli":false,"not":"","calisanlar":[]}
      ''';

      final okunan = Sirket.tryFromJson(jsonDecode(eskiKayit))!;

      expect(okunan.ad, 'Eski Şirket');
      expect(okunan.tehlikeSinifi, TehlikeSinifi.tehlikeli);
      expect(okunan.belgeler.single.calisanBazliMi, isTrue);
      expect(okunan.belgeler.single.calisanKayitlar, isNull);
    });

    test('eksik ve yanlış tipteki alanlarda çökmez, varsayılan kullanır', () {
      final okunan = Sirket.tryFromJson({
        'id': 's1',
        'tehlikeSinifi': 'TehlikeSinifi.bilinmeyen',
        'calisanSayisi': '7',
        'yildizli': 'evet',
        'belgeler': 'liste değil',
      })!;

      expect(okunan.ad, '');
      expect(okunan.tehlikeSinifi, TehlikeSinifi.azTehlikeli);
      expect(okunan.calisanSayisi, 7);
      expect(okunan.yildizli, isFalse);
      expect(okunan.not, '');
      expect(okunan.belgeler, isEmpty);
      expect(okunan.calisanlar, isEmpty);
    });

    test('okunamayan alt kayıtlar atlanır, geçerli olanlar kalır', () {
      final okunan = Sirket.tryFromJson({
        'id': 's1',
        'ad': 'A',
        'calisanlar': [
          {'id': 'c1', 'ad': 'Geçerli'},
          {'ad': 'Kimliksiz'},
          42,
        ],
        'belgeler': [
          {
            'id': 'b1',
            'ad': 'Belge',
            'tip': 'BelgeTipi.yok',
            'gecerlilikTarihi': 'tarih değil',
            'calisanKayitlar': [
              {'calisanId': 'c1', 'tarih': '2026-01-02T00:00:00.000'},
              {'calisanId': 'c1', 'tarih': 'bozuk'},
            ],
          },
          null,
        ],
      })!;

      expect(okunan.calisanlar.map((c) => c.id), ['c1']);
      final belge = okunan.belgeler.single;
      expect(belge.tip, BelgeTipi.standart);
      expect(belge.gecerlilikTarihi, isNull);
      expect(belge.calisanKayitlar, hasLength(1));
    });

    test('kimliği olmayan ya da nesne olmayan kayıt için null döner', () {
      expect(Sirket.tryFromJson({'ad': 'Kimliksiz'}), isNull);
      expect(Sirket.tryFromJson('metin'), isNull);
      expect(Sirket.tryFromJson(null), isNull);
    });
  });

  group('Sirket.eklenmeyenCalisanSayisi', () {
    test('eklenen çalışan, toplamdan fazlaysa sıfır olur', () {
      final sirket = Sirket(
        id: 's1',
        ad: 'A',
        tehlikeSinifi: TehlikeSinifi.azTehlikeli,
        calisanSayisi: 1,
        calisanlar: [Calisan(id: 'c1', ad: 'X'), Calisan(id: 'c2', ad: 'Y')],
      );
      expect(sirket.eklenmeyenCalisanSayisi, 0);
    });

    test('normal durumda farkı verir', () {
      final sirket = Sirket(
        id: 's1',
        ad: 'A',
        tehlikeSinifi: TehlikeSinifi.azTehlikeli,
        calisanSayisi: 5,
        calisanlar: [Calisan(id: 'c1', ad: 'X')],
      );
      expect(sirket.eklenmeyenCalisanSayisi, 4);
    });
  });

  group('Belge.standartBelgeler', () {
    test('9 belge, benzersiz kimliklerle ve özel davranışlar doğru', () {
      final belgeler = Belge.standartBelgeler();

      expect(belgeler, hasLength(9));
      expect(belgeler.map((b) => b.id).toSet(), hasLength(9));
      expect(belgeler.every((b) => b.tip == BelgeTipi.standart), isTrue);

      expect(
        belgeler.where((b) => b.gecerlilikTarihliMi).map((b) => b.id),
        [StandartBelgeId.riskAnalizi],
      );
      expect(
        belgeler.where((b) => b.calisanBazliMi).map((b) => b.id),
        [StandartBelgeId.egitimKatilimFormu, StandartBelgeId.iseGirisMuayenesi],
      );
    });
  });
}
