import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sirket_provider.dart';
import '../models/sirket.dart';
import 'sirket_detay_page.dart';
import '../widgets/yeni_sirket_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _sadeceyildizlilar = false;
  bool _sirala = false; // ← Bunu ekle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Şirket Takip'),
        actions: [
          IconButton(
            // ← Sıralama butonu (yıldızın SOLUNA)
            icon: Icon(
              _sirala ? Icons.sort : Icons.sort_outlined,
              color: _sirala ? Colors.white : null,
            ),
            onPressed: () {
              setState(() {
                _sirala = !_sirala;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _sadeceyildizlilar ? Icons.star : Icons.star_border,
              color: _sadeceyildizlilar ? Colors.yellow[700] : null,
            ),
            onPressed: () {
              setState(() {
                _sadeceyildizlilar = !_sadeceyildizlilar;
              });
            },
          ),
        ],
      ),
      body: Consumer<SirketProvider>(
        builder: (context, provider, child) {
          var sirketler = _sadeceyildizlilar
              ? provider.sirketler.where((s) => s.yildizli).toList()
              : List.from(provider.sirketler);

          // Sonra sırala (eğer aktifse)
          if (_sirala) {
            sirketler.sort((a, b) =>
                b.calisanSayisi.compareTo(a.calisanSayisi)); // Descending
          }

          if (sirketler.isEmpty) {
            return Center(
              child: Text(
                _sadeceyildizlilar
                    ? 'Yıldızlı şirket bulunamadı.'
                    : 'Henüz şirket eklenmemiş.\nSağ alttaki + butonuna tıklayarak ekleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sirketler.length,
            itemBuilder: (context, index) {
              final sirket = sirketler[index];
              return SirketKart(sirket: sirket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => YeniSirketDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SirketKart extends StatelessWidget {
  final Sirket sirket;

  const SirketKart({super.key, required this.sirket});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SirketProvider>();
    final eklenenCalisan = sirket.calisanlar.length;
    final toplamCalisan = sirket.calisanSayisi;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            sirket.yildizli ? Icons.star : Icons.star_border,
            color: sirket.yildizli ? Colors.orange : Colors.grey,
          ),
          onPressed: () {
            provider.sirketYildizla(sirket.id, !sirket.yildizli);
          },
        ),
        title: Text(
          sirket.ad,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${sirket.tehlikeSinifi.displayName} • $eklenenCalisan/$toplamCalisan Çalışan',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SirketDetayPage(sirket: sirket),
            ),
          );
        },
      ),
    );
  }
}
