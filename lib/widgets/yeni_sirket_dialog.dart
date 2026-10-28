import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sirket_provider.dart';
import '../models/sirket.dart';

class YeniSirketDialog extends StatefulWidget {
  final Sirket? sirket; // null ise yeni, dolu ise düzenleme

  const YeniSirketDialog({super.key, this.sirket});

  @override
  State<YeniSirketDialog> createState() => _YeniSirketDialogState();
}

class _YeniSirketDialogState extends State<YeniSirketDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _adController;
  late TextEditingController _calisanSayisiController;
  late TehlikeSinifi _secilenTehlikeSinifi;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysa mevcut değerleri kullan
    _adController = TextEditingController(text: widget.sirket?.ad ?? '');
    _calisanSayisiController = TextEditingController(
      text: widget.sirket?.calisanSayisi.toString() ?? '',
    );
    _secilenTehlikeSinifi =
        widget.sirket?.tehlikeSinifi ?? TehlikeSinifi.azTehlikeli;
  }

  @override
  void dispose() {
    _adController.dispose();
    _calisanSayisiController.dispose();
    super.dispose();
  }

  void _kaydet() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<SirketProvider>();

      if (widget.sirket == null) {
        // Yeni şirket ekle
        provider.sirketEkle(
          ad: _adController.text.trim(),
          tehlikeSinifi: _secilenTehlikeSinifi,
          calisanSayisi: int.parse(_calisanSayisiController.text),
        );
      } else {
        // DEBUG - BURAYI EKLE
        print('ÖNCE - Çalışan sayısı: ${widget.sirket!.calisanlar.length}');

        // Mevcut şirketi güncelle
        final guncelSirket = widget.sirket!.copyWith(
          ad: _adController.text.trim(),
          tehlikeSinifi: _secilenTehlikeSinifi,
          calisanSayisi: int.parse(_calisanSayisiController.text),
        );

        // DEBUG - BURAYI EKLE
        print('SONRA - Çalışan sayısı: ${guncelSirket.calisanlar.length}');

        provider.sirketGuncelle(guncelSirket);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDuzenleme = widget.sirket != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Klavye için boşluk
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDuzenleme ? 'Şirketi Düzenle' : 'Yeni Şirket Ekle',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Şirket Adı
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: 'Şirket Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen şirket adını giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tehlike Sınıfı - Radio Buttons
              const Text(
                'Tehlike Sınıfı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...TehlikeSinifi.values.map((sinif) {
                return RadioListTile<TehlikeSinifi>(
                  title: Text(sinif.displayName),
                  value: sinif,
                  groupValue: _secilenTehlikeSinifi,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _secilenTehlikeSinifi = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
              const SizedBox(height: 16),

              // Çalışan Sayısı
              TextFormField(
                controller: _calisanSayisiController,
                decoration: const InputDecoration(
                  labelText: 'Çalışan Sayısı',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen çalışan sayısını giriniz';
                  }
                  final sayi = int.tryParse(value);
                  if (sayi == null || sayi <= 0) {
                    return 'Geçerli bir sayı giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Butonlar
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
                    child: Text(isDuzenleme ? 'Güncelle' : 'Kaydet'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
