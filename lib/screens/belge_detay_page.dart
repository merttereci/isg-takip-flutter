import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sirket_provider.dart';
import '../models/sirket.dart';
import '../models/belge.dart';
import '../models/calisan.dart';

class BelgeDetayPage extends StatelessWidget {
  final Sirket sirket;
  final Belge belge;

  const BelgeDetayPage({
    super.key,
    required this.sirket,
    required this.belge,
  });

  String _formatTarih(DateTime tarih) {
    return '${tarih.day.toString().padLeft(2, '0')}.${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(belge.ad),
      ),
      body: Consumer<SirketProvider>(
        builder: (context, provider, child) {
          final guncelSirket = provider.sirketler.firstWhere(
            (s) => s.id == sirket.id,
            orElse: () => sirket,
          );

          final guncelBelge = guncelSirket.belgeler.firstWhere(
            (b) => b.id == belge.id,
            orElse: () => belge,
          );

          final calisanKayitlari = guncelBelge.calisanKayitlar ?? [];
          final toplamCalisan = guncelSirket.calisanSayisi;
          final eklenenCalisan = guncelSirket.calisanlar.length;
          final belgeli = calisanKayitlari.length;
          final belgesiz = eklenenCalisan - belgeli;
          final kayitsiz = toplamCalisan - eklenenCalisan;

          return Column(
            children: [
              // Bilgi kartı
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$belgeli',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('Belgeli'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$belgesiz',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text('Belgesiz'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$kayitsiz',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const Text('Kayıtsız'),
                      ],
                    ),
                  ],
                ),
              ),

              // Çalışan listesi
              Expanded(
                child: guncelSirket.calisanlar.isEmpty
                    ? const Center(
                        child: Text(
                          'Henüz çalışan eklenmemiş.\nŞirket detayında çalışan ekleyebilirsiniz.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: guncelSirket.calisanlar.length,
                        itemBuilder: (context, index) {
                          final calisan = guncelSirket.calisanlar[index];

                          // Bu çalışanın bu belgedeki kaydını bul
                          // Bu çalışanın bu belgedeki kaydını bul
                          final kayit = calisanKayitlari
                              .where((k) => k.calisanId == calisan.id)
                              .firstOrNull;

                          final belgeli = kayit != null;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: Icon(
                                belgeli ? Icons.check_circle : Icons.cancel,
                                color: belgeli ? Colors.green : Colors.orange,
                              ),
                              title: Text(calisan.ad),
                              subtitle: belgeli
                                  ? Text('Tarih: ${_formatTarih(kayit.tarih)}')
                                  : const Text('Belge yok'),
                              trailing: belgeli
                                  ? IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _belgeKaldir(context, provider,
                                            guncelSirket, calisan);
                                      },
                                    )
                                  : const Icon(Icons.add_circle_outline,
                                      color: Colors.blue),
                              onTap: () {
                                if (belgeli) {
                                  _tarihDuzenle(context, provider, guncelSirket,
                                      calisan, kayit.tarih);
                                } else {
                                  _tarihEkle(
                                      context, provider, guncelSirket, calisan);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _tarihEkle(BuildContext context, SirketProvider provider, Sirket sirket,
      Calisan calisan) async {
    final tarih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (tarih != null) {
      await provider.belgeyeCalisanEkle(
        sirket.id,
        belge.id,
        calisan.id,
        tarih,
      );
    }
  }

  void _tarihDuzenle(BuildContext context, SirketProvider provider,
      Sirket sirket, Calisan calisan, DateTime mevcutTarih) async {
    // Dialog göster: Tarih düzenle veya kaldır
    final secim = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(calisan.ad),
        content: const Text('Ne yapmak istersiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'tarih'),
            child: const Text('Tarih Düzenle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'kaldir'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Belgeyi Kaldır'),
          ),
        ],
      ),
    );

    if (secim == 'tarih') {
      // Tarih düzenle
      final tarih = await showDatePicker(
        context: context,
        initialDate: mevcutTarih,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );

      if (tarih != null) {
        await provider.belgedenCalisanSil(sirket.id, belge.id, calisan.id);
        await provider.belgeyeCalisanEkle(
            sirket.id, belge.id, calisan.id, tarih);
      }
    } else if (secim == 'kaldir') {
      // Belgeyi kaldır
      await provider.belgedenCalisanSil(sirket.id, belge.id, calisan.id);
    }
  }

  void _belgeKaldir(BuildContext context, SirketProvider provider,
      Sirket sirket, Calisan calisan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Belgeyi Kaldır'),
        content: Text(
            '${calisan.ad} çalışanının belgesini kaldırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.belgedenCalisanSil(sirket.id, belge.id, calisan.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
  }
}
