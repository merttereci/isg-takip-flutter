import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sirket_provider.dart';
import '../models/sirket.dart';
import '../models/belge.dart';
import '../widgets/ozel_belge_dialog.dart';
import '../widgets/yeni_sirket_dialog.dart';
import 'belge_detay_page.dart'; // ← BUNU EKLE
import 'calisan_yonetim_page.dart'; // ← BUNU EKLE

class SirketDetayPage extends StatelessWidget {
  final Sirket sirket;

  const SirketDetayPage({super.key, required this.sirket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Consumer<SirketProvider>(
          builder: (context, provider, child) {
            final guncelSirket = provider.sirketler.firstWhere(
              (s) => s.id == sirket.id,
              orElse: () => sirket,
            );
            return Text(guncelSirket.ad);
          },
        ),
        actions: [
          IconButton(
            // ← Çalışan yönetimi butonu (ÖNCE)
            icon: const Icon(Icons.people),
            tooltip: 'Çalışan Yönetimi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalisanYonetimPage(sirket: sirket),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Güncel şirketi provider'dan al
              final provider =
                  Provider.of<SirketProvider>(context, listen: false);
              final guncelSirket = provider.sirketler.firstWhere(
                (s) => s.id == sirket.id,
                orElse: () => sirket,
              );

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => YeniSirketDialog(sirket: guncelSirket),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent[100]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Şirket Sil'),
                  content: Text(
                      '${sirket.ad} şirketini silmek istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final provider = context.read<SirketProvider>();
                        provider.sirketSil(sirket.id);
                        Navigator.pop(context);
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
        ],
      ),
      body: Consumer<SirketProvider>(
        builder: (context, provider, child) {
          final guncelSirket = provider.sirketler.firstWhere(
            (s) => s.id == sirket.id,
            orElse: () => sirket,
          );

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount:
                guncelSirket.belgeler.length + 2, // +1 not, +1 ekle butonu
            itemBuilder: (context, index) {
              // Not kartı (sondan 2. sıra)
              if (index == guncelSirket.belgeler.length) {
                return NotKarti(sirket: guncelSirket);
              }

              // Yeni belge ekle butonu (en son)
              if (index == guncelSirket.belgeler.length + 1) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: const Icon(Icons.add_circle_outline,
                        color: Colors.blue),
                    title: const Text(
                      'Yeni Belge Ekle',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            OzelBelgeDialog(sirketId: guncelSirket.id),
                      );
                    },
                  ),
                );
              }

              // Belgeler
              final belge = guncelSirket.belgeler[index];
              return BelgeItem(
                sirketId: guncelSirket.id,
                belge: belge,
              );
            },
          );
        },
      ),
      // FAB kaldırıldı - artık gerek yok
    );
  }
}

class BelgeItem extends StatelessWidget {
  final String sirketId;
  final Belge belge;

  const BelgeItem({
    super.key,
    required this.sirketId,
    required this.belge,
  });

  // Belge subtitle (geçerlilik tarihi gösterimi)
  Widget? _belgeSubtitle(Belge belge) {
    if (belge.id == '1' && belge.gecerlilikTarihi != null) {
      return Text(
        'Geçerlilik: ${_formatTarih(belge.gecerlilikTarihi!)}',
        style: const TextStyle(fontSize: 12),
      );
    }
    return null;
  }

// Tarih formatlama
  String _formatTarih(DateTime tarih) {
    return '${tarih.day.toString().padLeft(2, '0')}.${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';
  }

// Tarih seçme dialogu
  void _tarihSecDialog(BuildContext context, Belge belge) {
    showDatePicker(
      context: context,
      initialDate: belge.gecerlilikTarihi ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((secilenTarih) {
      if (secilenTarih != null) {
        final provider = context.read<SirketProvider>();
        provider.belgeGecerlilikTarihiGuncelle(
          sirketId,
          belge.id,
          secilenTarih,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SirketProvider>();

    // Risk Analiz Değerlendirmesi özel gösterim (1. madde)
    if (belge.id == '1') {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          title: Text(belge.ad),
          subtitle: belge.gecerlilikTarihi != null
              ? Text('Geçerlilik: ${_formatTarih(belge.gecerlilikTarihi!)}')
              : const Text('Geçerlilik tarihi seçilmemiş'),
          leading: const Icon(Icons.calendar_today),
          onTap: () => _tarihSecDialog(context, belge),
          trailing: Checkbox(
            value: belge.varMi,
            onChanged: (bool? value) {
              if (value != null) {
                provider.belgeGuncelle(sirketId, belge.id, value);
              }
            },
          ),
        ),
      );
    }

// 5. ve 6. madde - Çalışan listesi
    if (belge.id == '5' || belge.id == '6') {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          leading: const Icon(Icons.people),
          title: Text(belge.ad),
          // subtitle: Text('$calisanSayisi çalışan eklenmiş'), ← BUNU SİL
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BelgeDetayPage(
                  sirket:
                      provider.sirketler.firstWhere((s) => s.id == sirketId),
                  belge: belge,
                ),
              ),
            );
          },
        ),
      );
    }

    // Standart ve özel belgeler
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: CheckboxListTile(
        title: Text(belge.ad),
        value: belge.varMi,
        onChanged: (bool? value) {
          if (value != null) {
            provider.belgeGuncelle(sirketId, belge.id, value);
          }
        },
        secondary: belge.tip == BelgeTipi.ozel
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Belge Sil'),
                      content: Text(
                          '${belge.ad} belgesini silmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.belgeSil(sirketId, belge.id);
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
              )
            : null,
      ),
    );
  }
}

class NotKarti extends StatefulWidget {
  final Sirket sirket;

  const NotKarti({super.key, required this.sirket});

  @override
  State<NotKarti> createState() => _NotKartiState();
}

class _NotKartiState extends State<NotKarti> {
  late TextEditingController _notController;
  bool _duzenlemeModu = false;

  @override
  void initState() {
    super.initState();
    _notController = TextEditingController(text: widget.sirket.not);
  }

  @override
  void dispose() {
    _notController.dispose();
    super.dispose();
  }

  void _kaydet() {
    final provider = context.read<SirketProvider>();
    provider.sirketNotuGuncelle(widget.sirket.id, _notController.text);
    setState(() {
      _duzenlemeModu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: _duzenlemeModu
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sticky_note_2, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Notlar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notController,
                    maxLines: null,
                    minLines: 3,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      hintText: 'Not yazın...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _notController.text = widget.sirket.not;
                          setState(() {
                            _duzenlemeModu = false;
                          });
                        },
                        child: const Text('İptal'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _kaydet,
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : ListTile(
              leading: const Icon(Icons.sticky_note_2),
              title: const Text(
                'Notlar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: widget.sirket.not.isEmpty
                  ? const Text('Henüz not eklenmemiş.')
                  : Text(
                      widget.sirket.not,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () {
                setState(() {
                  _duzenlemeModu = true;
                });
              },
            ),
    );
  }
}
