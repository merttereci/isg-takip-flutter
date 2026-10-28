import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sirket_provider.dart';
import '../models/sirket.dart';

class CalisanYonetimPage extends StatelessWidget {
  final Sirket sirket;

  const CalisanYonetimPage({super.key, required this.sirket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Çalışan Yönetimi'),
      ),
      body: Consumer<SirketProvider>(
        builder: (context, provider, child) {
          final guncelSirket = provider.sirketler.firstWhere(
            (s) => s.id == sirket.id,
            orElse: () => sirket,
          );

          final toplamCalisan = guncelSirket.calisanSayisi;
          final eklenenCalisan = guncelSirket.calisanlar.length;
          final eklenmeyen = toplamCalisan - eklenenCalisan;

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
                          '$toplamCalisan',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Toplam'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$eklenenCalisan',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('Eklenmiş'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '$eklenmeyen',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text('Eklenmeyen'),
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
                          'Henüz çalışan eklenmemiş.\nSağ alttaki + butonuna tıklayarak ekleyebilirsiniz.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: guncelSirket.calisanlar.length,
                        itemBuilder: (context, index) {
                          final calisan = guncelSirket.calisanlar[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(calisan.ad),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Çalışanı Sil'),
                                      content: Text(
                                          '${calisan.ad} çalışanını silmek istediğinize emin misiniz? Bu işlem tüm belgelerden de kaldıracaktır.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('İptal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            provider.calisanSil(
                                                guncelSirket.id, calisan.id);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Sil'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _calisanEkleDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _calisanEkleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CalisanEkleSheet(sirket: sirket),
    );
  }
}

class CalisanEkleSheet extends StatefulWidget {
  final Sirket sirket;

  const CalisanEkleSheet({super.key, required this.sirket});

  @override
  State<CalisanEkleSheet> createState() => _CalisanEkleSheetState();
}

class _CalisanEkleSheetState extends State<CalisanEkleSheet> {
  final _adController = TextEditingController();

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  void _kaydet() {
    if (_adController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen çalışan adını giriniz')),
      );
      return;
    }

    final provider = context.read<SirketProvider>();
    provider.calisanEkle(widget.sirket.id, _adController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Çalışan Ekle',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _kaydet,
                  child: const Text('Kaydet'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
