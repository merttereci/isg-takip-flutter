// README ekran görüntülerini üreten betik.
//
// Çalıştırma (proje kök klasöründe):
//
//   flutter test tool/screenshots_test.dart
//
// Uygulamayı uydurma örnek veriyle test ortamında açar, ekranlar arasında
// gezinir ve 1080x2340 piksel PNG görüntüleri docs/screenshots/ altına yazar:
//   company-list.png, company-detail.png, employee-records.png
//
// Test ortamı varsayılan olarak her yazıyı kutucuk olarak çizen bir font
// kullanır. Bu yüzden Flutter SDK içindeki Roboto ve Material Icons fontları
// (bin/cache/artifacts/material_fonts) betiğin başında yüklenir.
//
// Betik test/ klasöründe olmadığı için normal `flutter test` çalıştırıldığında
// devreye girmez. Uygulama koduna dokunmaz; örnek veriyi uygulamanın okuduğu
// shared_preferences anahtarına koyup MyApp'i olduğu gibi açar.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isg_takip/main.dart';
import 'package:isg_takip/models/belge.dart';
import 'package:isg_takip/models/calisan.dart';
import 'package:isg_takip/models/sirket.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cikisKlasoru = 'docs/screenshots';
const _fizikselBoyut = Size(1080, 2340);
const _pikselOrani = 2.75; // yaklaşık 393x851 mantıksal boyut

void main() {
  testWidgets('README ekran görüntülerini üret', (tester) async {
    await tester.runAsync(_fontlariYukle);

    tester.view.physicalSize = _fizikselBoyut;
    tester.view.devicePixelRatio = _pikselOrani;
    addTearDown(tester.view.reset);

    // Kart gölgeleri gerçek cihazdaki gibi görünsün.
    debugDisableShadows = false;
    try {
      // Betik test/ dışında durduğu için analizci bunu test kodu saymıyor.
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({
        'sirketler': jsonEncode(_ornekSirketler().map((s) => s.toJson()).toList()),
      });

      final cerceve = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: cerceve, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      await _kaydet(tester, cerceve, 'company-list.png');

      await tester.tap(find.text(_detaySirketAdi));
      await tester.pumpAndSettle();
      await _kaydet(tester, cerceve, 'company-detail.png');

      final muayene = find.text('İşe Giriş Muayenesi');
      await tester.ensureVisible(muayene);
      await tester.pumpAndSettle();
      await tester.tap(muayene);
      await tester.pumpAndSettle();
      await _kaydet(tester, cerceve, 'employee-records.png');
    } finally {
      debugDisableShadows = true;
    }
  });
}

Future<void> _fontlariYukle() async {
  final klasor = _materialFontKlasoru();
  Future<ByteData> oku(String ad) async =>
      ByteData.sublistView(File('${klasor.path}/$ad').readAsBytesSync());

  final roboto = FontLoader('Roboto');
  for (final ad in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-italic.ttf',
  ]) {
    roboto.addFont(oku(ad));
  }
  await roboto.load();

  final ikonlar = FontLoader('MaterialIcons')
    ..addFont(oku('materialicons-regular.otf'));
  await ikonlar.load();
}

Directory _materialFontKlasoru() {
  final flutterKoku = Platform.environment['FLUTTER_ROOT'];
  final adaylar = <String>[
    if (flutterKoku != null)
      '$flutterKoku/bin/cache/artifacts/material_fonts',
    // flutter_tester: <flutter>/bin/cache/artifacts/engine/<platform>/
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}'
        '/material_fonts',
  ];
  for (final aday in adaylar) {
    final klasor = Directory(aday);
    if (File('${klasor.path}/roboto-regular.ttf').existsSync()) return klasor;
  }
  throw StateError(
      'Material fontları bulunamadı. Denenen yollar: ${adaylar.join(', ')}');
}

Future<void> _kaydet(WidgetTester tester, GlobalKey cerceve, String ad) async {
  final sinir =
      cerceve.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final goruntu = await sinir.toImage(pixelRatio: _pikselOrani);
    final veri = await goruntu.toByteData(format: ui.ImageByteFormat.png);
    final dosya = File('$_cikisKlasoru/$ad');
    dosya.parent.createSync(recursive: true);
    dosya.writeAsBytesSync(veri!.buffer.asUint8List());
    // ignore: avoid_print
    print('Yazıldı: ${dosya.path} (${goruntu.width}x${goruntu.height})');
  });
}

// ---------------------------------------------------------------------------
// Örnek veri. Şirket ve kişi adlarının hepsi uydurmadır.
// ---------------------------------------------------------------------------

const _detaySirketAdi = 'Kuzey Döküm';

const _adlar = [
  'Ayşe Karataş', 'Mehmet Yıldırım', 'Elif Demirci', 'Hasan Çelikkaya',
  'Zeynep Arslantürk', 'Burak Özdemir', 'Fatma Gündoğdu', 'Emre Aksoy',
  'Selin Kocabaş', 'Murat Erginer', 'Derya Toprakçı', 'Kemal Uçar',
  'Gizem Şahinler', 'Oğuz Bayraktar', 'Hülya Ekinci', 'Serkan Durmaz',
  'Nur Altıntaş', 'Cem Yavuzer', 'Esra Kılıçarslan', 'İbrahim Soylu',
];

List<Calisan> _calisanlar(String onEk, int adet) => [
      for (var i = 0; i < adet; i++)
        Calisan(id: '$onEk-c$i', ad: _adlar[i % _adlar.length]),
    ];

Sirket _sirket(
  String id,
  String ad,
  TehlikeSinifi sinif, {
  required int toplam,
  required int eklenen,
  bool yildizli = false,
}) {
  return Sirket(
    id: id,
    ad: ad,
    tehlikeSinifi: sinif,
    calisanSayisi: toplam,
    yildizli: yildizli,
    calisanlar: _calisanlar(id, eklenen),
    belgeler: Belge.standartBelgeler(),
  );
}

List<Sirket> _ornekSirketler() {
  // Detay ve çalışan kayıtları ekranlarında gösterilecek şirket.
  final calisanlar = _calisanlar('s1', 9);
  final belgeler = Belge.standartBelgeler().map((b) {
    switch (b.id) {
      case StandartBelgeId.riskAnalizi:
        return b.copyWith(varMi: true, gecerlilikTarihi: DateTime(2028, 3, 14));
      case '2': // Acil Eylem Planı
      case '3': // Risk Değerlendirmesi ve Acil Durum Ekipler Listesi
      case '7': // İş Güvenliği Talimatnamesi
      case '9': // MYK
        return b.copyWith(varMi: true);
      case StandartBelgeId.egitimKatilimFormu:
        return b.copyWith(calisanKayitlar: [
          for (var i = 0; i < 7; i++)
            CalisanBelgeKayit(
                calisanId: calisanlar[i].id, tarih: DateTime(2026, 2, 18)),
        ]);
      case StandartBelgeId.iseGirisMuayenesi:
        final tarihler = [
          DateTime(2025, 9, 8),
          DateTime(2025, 11, 3),
          DateTime(2026, 1, 12),
          DateTime(2026, 4, 27),
          DateTime(2026, 6, 15),
          DateTime(2026, 9, 1),
        ];
        return b.copyWith(calisanKayitlar: [
          for (var i = 0; i < tarihler.length; i++)
            CalisanBelgeKayit(calisanId: calisanlar[i].id, tarih: tarihler[i]),
        ]);
      default:
        return b;
    }
  }).toList()
    ..add(Belge(
      id: 's1-ozel1',
      ad: 'Basınçlı Kap Periyodik Kontrol Raporu',
      tip: BelgeTipi.ozel,
      varMi: true,
    ))
    ..add(Belge(
      id: 's1-ozel2',
      ad: 'Ortam Gürültü Ölçüm Raporu',
      tip: BelgeTipi.ozel,
    ));

  final detaySirket = Sirket(
    id: 's1',
    ad: _detaySirketAdi,
    tehlikeSinifi: TehlikeSinifi.cokTehlikeli,
    calisanSayisi: 14,
    yildizli: true,
    calisanlar: calisanlar,
    belgeler: belgeler,
    not: 'Ergitme bölümü için yeni ortam ölçümü Kasım sonunda yapılacak.',
  );

  return [
    detaySirket,
    _sirket('s2', 'Ilgaz Yapı İnşaat Ltd. Şti.', TehlikeSinifi.cokTehlikeli,
        toplam: 22, eklenen: 15),
    _sirket('s3', 'Defne Tekstil Konfeksiyon', TehlikeSinifi.tehlikeli,
        toplam: 38, eklenen: 38, yildizli: true),
    _sirket('s4', 'Martı Lojistik Depolama', TehlikeSinifi.tehlikeli,
        toplam: 11, eklenen: 4),
    _sirket('s5', 'Lale Unlu Mamuller', TehlikeSinifi.tehlikeli,
        toplam: 7, eklenen: 7),
    _sirket('s6', 'Akça Plastik Ambalaj San. Tic.', TehlikeSinifi.tehlikeli,
        toplam: 26, eklenen: 20),
    _sirket('s7', 'Pusula Mali Müşavirlik', TehlikeSinifi.azTehlikeli,
        toplam: 5, eklenen: 5),
    _sirket('s8', 'Serin Ağız ve Diş Sağlığı Polikliniği',
        TehlikeSinifi.azTehlikeli,
        toplam: 9, eklenen: 3, yildizli: true),
  ];
}
