import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sirket.dart';
import '../models/belge.dart';
import '../models/calisan.dart'; // ← BUNU EKLE

class SirketProvider extends ChangeNotifier {
  List<Sirket> _sirketler = [];

  List<Sirket> get sirketler => _sirketler;

  // ID oluşturucu
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // Uygulama başladığında verileri yükle
  Future<void> verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sirketlerJson = prefs.getString('sirketler');

    if (sirketlerJson != null) {
      final List<dynamic> decoded = jsonDecode(sirketlerJson);
      _sirketler = decoded.map((json) => Sirket.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Şirketi yıldızla/yıldızdan çıkar
  Future<void> sirketYildizla(String sirketId, bool yildizli) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final guncelSirket = sirket.copyWith(yildizli: yildizli);
    await sirketGuncelle(guncelSirket);
  }

  // Verileri kaydet
  Future<void> _verileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_sirketler.map((s) => s.toJson()).toList());
    await prefs.setString('sirketler', encoded);
  }

  // Yeni şirket ekle
  Future<void> sirketEkle({
    required String ad,
    required TehlikeSinifi tehlikeSinifi,
    required int calisanSayisi,
  }) async {
    final yeniSirket = Sirket(
      id: _generateId(),
      ad: ad,
      tehlikeSinifi: tehlikeSinifi,
      calisanSayisi: calisanSayisi,
      belgeler: Belge.standartBelgeler(), // 9 standart belge otomatik ekle
    );

    _sirketler.add(yeniSirket);
    await _verileriKaydet();
    notifyListeners();
  }

  // Şirket sil
  Future<void> sirketSil(String sirketId) async {
    _sirketler.removeWhere((s) => s.id == sirketId);
    await _verileriKaydet();
    notifyListeners();
  }

  // Şirket güncelle
  Future<void> sirketGuncelle(Sirket guncelSirket) async {
    final index = _sirketler.indexWhere((s) => s.id == guncelSirket.id);
    if (index != -1) {
      print(
          'PROVIDER - Önceki: ${_sirketler[index].calisanlar.length} çalışan');
      print('PROVIDER - Yeni: ${guncelSirket.calisanlar.length} çalışan');

      _sirketler[index] = guncelSirket;
      await _verileriKaydet();
      notifyListeners();
    }
  }

  // SirketProvider class içine ekle:

// Şirket notunu güncelle
  Future<void> sirketNotuGuncelle(String sirketId, String not) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final guncelSirket = sirket.copyWith(not: not);
    await sirketGuncelle(guncelSirket);
  }

  // Belge durumunu güncelle (var/yok)
  Future<void> belgeGuncelle(
      String sirketId, String belgeId, bool varMi) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final belgeIndex = sirket.belgeler.indexWhere((b) => b.id == belgeId);

    if (belgeIndex != -1) {
      final guncelBelge = sirket.belgeler[belgeIndex].copyWith(varMi: varMi);
      final yeniBelgeler = List<Belge>.from(sirket.belgeler);
      yeniBelgeler[belgeIndex] = guncelBelge;

      final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);
      await sirketGuncelle(guncelSirket);
    }
  }

  // Belge geçerlilik tarihini güncelle (1. madde için)
  Future<void> belgeGecerlilikTarihiGuncelle(
    String sirketId,
    String belgeId,
    DateTime? tarih,
  ) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final belgeIndex = sirket.belgeler.indexWhere((b) => b.id == belgeId);

    if (belgeIndex != -1) {
      final guncelBelge = sirket.belgeler[belgeIndex].copyWith(
        gecerlilikTarihi: tarih,
      );
      final yeniBelgeler = List<Belge>.from(sirket.belgeler);
      yeniBelgeler[belgeIndex] = guncelBelge;

      final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);
      await sirketGuncelle(guncelSirket);
    }
  }

  // İşe giriş muayenesi sayılarını güncelle
  Future<void> muayeneSayilariGuncelle(
    String sirketId,
    String belgeId,
    int yapilan,
    int yapilmayan,
  ) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final belgeIndex = sirket.belgeler.indexWhere((b) => b.id == belgeId);

    if (belgeIndex != -1) {
      final guncelBelge = sirket.belgeler[belgeIndex].copyWith(
        yapilan: yapilan,
        yapilmayan: yapilmayan,
      );
      final yeniBelgeler = List<Belge>.from(sirket.belgeler);
      yeniBelgeler[belgeIndex] = guncelBelge;

      final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);
      await sirketGuncelle(guncelSirket);
    }
  }

  // Özel belge ekle
  Future<void> ozelBelgeEkle(String sirketId, String belgeAdi) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);

    final yeniBelge = Belge(
      id: _generateId(),
      ad: belgeAdi,
      tip: BelgeTipi.ozel,
    );

    final yeniBelgeler = List<Belge>.from(sirket.belgeler)..add(yeniBelge);
    final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);

    await sirketGuncelle(guncelSirket);
  }

  // Belge sil (sadece özel belgeler silinebilir)
  Future<void> belgeSil(String sirketId, String belgeId) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final yeniBelgeler = sirket.belgeler.where((b) => b.id != belgeId).toList();

    final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);
    await sirketGuncelle(guncelSirket);
  }

  // Çalışan ekle
  Future<void> calisanEkle(String sirketId, String calisanAd) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);

    final yeniCalisan = Calisan(
      id: _generateId(),
      ad: calisanAd,
    );

    final yeniCalisanlar = List<Calisan>.from(sirket.calisanlar)
      ..add(yeniCalisan);
    final guncelSirket = sirket.copyWith(calisanlar: yeniCalisanlar);

    await sirketGuncelle(guncelSirket);
  }

// Çalışan sil
  Future<void> calisanSil(String sirketId, String calisanId) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final yeniCalisanlar =
        sirket.calisanlar.where((c) => c.id != calisanId).toList();

    // Çalışanı tüm belgelerden de temizle
    final yeniBelgeler = sirket.belgeler.map((belge) {
      if (belge.calisanKayitlar != null) {
        final yeniKayitlar = belge.calisanKayitlar!
            .where((k) => k.calisanId != calisanId)
            .toList();
        return belge.copyWith(calisanKayitlar: yeniKayitlar);
      }
      return belge;
    }).toList();

    final guncelSirket = sirket.copyWith(
      calisanlar: yeniCalisanlar,
      belgeler: yeniBelgeler,
    );

    await sirketGuncelle(guncelSirket);
  }

// Belgeye çalışan kaydı ekle
  Future<void> belgeyeCalisanEkle(
    String sirketId,
    String belgeId,
    String calisanId,
    DateTime tarih,
  ) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final belgeIndex = sirket.belgeler.indexWhere((b) => b.id == belgeId);

    if (belgeIndex != -1) {
      final belge = sirket.belgeler[belgeIndex];
      final mevcutKayitlar = belge.calisanKayitlar ?? [];

      final yeniKayit = CalisanBelgeKayit(
        calisanId: calisanId,
        tarih: tarih,
      );

      final yeniKayitlar = List<CalisanBelgeKayit>.from(mevcutKayitlar)
        ..add(yeniKayit);
      final guncelBelge = belge.copyWith(calisanKayitlar: yeniKayitlar);

      final yeniBelgeler = List<Belge>.from(sirket.belgeler);
      yeniBelgeler[belgeIndex] = guncelBelge;

      final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);
      await sirketGuncelle(guncelSirket);
    }
  }

// Belgeden çalışan kaydını sil
  Future<void> belgedenCalisanSil(
    String sirketId,
    String belgeId,
    String calisanId,
  ) async {
    final sirket = _sirketler.firstWhere((s) => s.id == sirketId);
    final belgeIndex = sirket.belgeler.indexWhere((b) => b.id == belgeId);

    if (belgeIndex != -1) {
      final belge = sirket.belgeler[belgeIndex];
      final yeniKayitlar = belge.calisanKayitlar
              ?.where((k) => k.calisanId != calisanId)
              .toList() ??
          [];

      final guncelBelge = belge.copyWith(calisanKayitlar: yeniKayitlar);

      final yeniBelgeler = List<Belge>.from(sirket.belgeler);
      yeniBelgeler[belgeIndex] = guncelBelge;

      final guncelSirket = sirket.copyWith(belgeler: yeniBelgeler);
      await sirketGuncelle(guncelSirket);
    }
  }
}
