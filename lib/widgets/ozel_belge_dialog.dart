import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sirket_provider.dart';

class OzelBelgeDialog extends StatefulWidget {
  final String sirketId;

  const OzelBelgeDialog({super.key, required this.sirketId});

  @override
  State<OzelBelgeDialog> createState() => _OzelBelgeDialogState();
}

class _OzelBelgeDialogState extends State<OzelBelgeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _kaydet() {
    if (_controller.text.trim().isNotEmpty) {
      final provider = context.read<SirketProvider>();
      provider.ozelBelgeEkle(widget.sirketId, _controller.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Belge Ekle'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Belge Adı',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (_) => _kaydet(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _kaydet,
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}
