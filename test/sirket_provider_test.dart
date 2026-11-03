import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isg_takip/models/belge.dart';
import 'package:isg_takip/models/sirket.dart';
import 'package:isg_takip/providers/sirket_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<SirketProvider> yeniSirketliProvider() async {
    final provider = SirketProvider();
    await provider.sirketEkle(
      ad: 'Test Şirketi',
      tehlikeSinifi: TehlikeSinifi.tehlikeli,
      calisanSayisi: 3,
    );
    return provider;
  }

  test('yeni şirkete 9 standart belge eklenir', () async {
    final provider = await yeniSirketliProvider();

    final sirket = provider.sirketler.single;
    expect(sirket.belgeler, hasLength(9));
    expect(sirket.belgeler.every((b) => !b.varMi), isTrue);
  });

  test('kaydedilen veri yeni bir provider ile aynen yüklenir', () async {
    final provider = await yeniSirketliProvider();
    final sirketId = provider.sirketler.single.id;
    await provider.calisanEkle(sirketId, 'Çalışan Bir');
    await provider.belgeGuncelle(sirketId, '2', true);
    await provider.sirketNotuGuncelle(sirketId, 'not');

    final yeniProvider = SirketProvider();
    await yeniProvider.verileriYukle();

    final sirket = yeniProvider.sirketler.single;
    expect(sirket.ad, 'Test Şirketi');
    expect(sirket.calisanlar.single.ad, 'Çalışan Bir');
    expect(sirket.belgeler.firstWhere((b) => b.id == '2').varMi, isTrue);
    expect(sirket.not, 'not');
  });

  test('art arda eklenen çalışanlar farklı kimlik alır', () async {
    final provider = await yeniSirketliProvider();
    final sirketId = provider.sirketler.single.id;

    await provider.calisanEkle(sirketId, 'A');
    await provider.calisanEkle(sirketId, 'B');
    await provider.calisanEkle(sirketId, 'C');

    final idler = provider.sirketler.single.calisanlar.map((c) => c.id);
    expect(idler.toSet(), hasLength(3));
  });

  test('çalışan silinince tüm belge kayıtlarından da temizlenir', () async {
    final provider = await yeniSirketliProvider();
    final sirketId = provider.sirketler.single.id;
    await provider.calisanEkle(sirketId, 'Silinecek');
    await provider.calisanEkle(sirketId, 'Kalacak');
    final calisanlar = provider.sirketler.single.calisanlar;
    final silinecek = calisanlar[0].id;
    final kalacak = calisanlar[1].id;

    for (final belgeId in [
      StandartBelgeId.egitimKatilimFormu,
      StandartBelgeId.iseGirisMuayenesi,
    ]) {
      await provider.belgeyeCalisanEkle(
          sirketId, belgeId, silinecek, DateTime(2026, 1, 1));
      await provider.belgeyeCalisanEkle(
          sirketId, belgeId, kalacak, DateTime(2026, 1, 2));
    }

    await provider.calisanSil(sirketId, silinecek);

    final sirket = provider.sirketler.single;
    expect(sirket.calisanlar.map((c) => c.id), [kalacak]);
    for (final belge in sirket.belgeler.where((b) => b.calisanBazliMi)) {
      expect(belge.calisanKayitlar!.map((k) => k.calisanId), [kalacak]);
    }
  });

  test('özel belge eklenip silinebilir', () async {
    final provider = await yeniSirketliProvider();
    final sirketId = provider.sirketler.single.id;

    await provider.ozelBelgeEkle(sirketId, 'Yangın Tatbikatı');
    final ozel = provider.sirketler.single.belgeler.last;
    expect(ozel.ad, 'Yangın Tatbikatı');
    expect(ozel.tip, BelgeTipi.ozel);

    await provider.belgeSil(sirketId, ozel.id);
    expect(provider.sirketler.single.belgeler, hasLength(9));
  });

  test('okunamayan kayıtlı veride çökmez ve ham veriyi yedekler', () async {
    SharedPreferences.setMockInitialValues({'sirketler': '{bozuk json'});

    final provider = SirketProvider();
    await provider.verileriYukle();

    expect(provider.sirketler, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sirketler_okunamayan_yedek'), '{bozuk json');
  });

  test('listedeki okunamayan şirket kayıtları atlanır', () async {
    SharedPreferences.setMockInitialValues({
      'sirketler': jsonEncode([
        {'id': 's1', 'ad': 'Geçerli', 'calisanSayisi': 2},
        {'ad': 'Kimliksiz'},
        'metin',
      ]),
    });

    final provider = SirketProvider();
    await provider.verileriYukle();

    expect(provider.sirketler.map((s) => s.ad), ['Geçerli']);
  });
}
