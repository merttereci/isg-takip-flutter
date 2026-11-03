import 'package:flutter/material.dart';

/// Tarih seçicide bugünden geriye ve ileriye gidilebilecek yıl sayısı.
const int tarihSeciciYilAraligi = 10;

/// Tarihi gg.aa.yyyy biçiminde gösterir.
String formatTarih(DateTime tarih) {
  return '${tarih.day.toString().padLeft(2, '0')}.'
      '${tarih.month.toString().padLeft(2, '0')}.'
      '${tarih.year}';
}

/// Bugüne göre hesaplanan aralıkta tarih seçtirir. Başlangıç tarihi aralığın
/// dışındaysa aralığın sınırına çekilir.
Future<DateTime?> tarihSec(BuildContext context, {DateTime? baslangic}) {
  final bugun = DateUtils.dateOnly(DateTime.now());
  final ilk = DateTime(bugun.year - tarihSeciciYilAraligi);
  final son = DateTime(bugun.year + tarihSeciciYilAraligi, 12, 31);

  var secili = baslangic ?? bugun;
  if (secili.isBefore(ilk)) secili = ilk;
  if (secili.isAfter(son)) secili = son;

  return showDatePicker(
    context: context,
    initialDate: secili,
    firstDate: ilk,
    lastDate: son,
  );
}
