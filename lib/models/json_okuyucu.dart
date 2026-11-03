// Kayıtlı JSON verisini okurken eksik ya da yanlış tipteki alanlarda
// uygulamanın çökmemesi için kullanılan yardımcı fonksiyonlar.

String? jsonString(Object? deger) {
  if (deger is String) return deger;
  if (deger is num) return deger.toString();
  return null;
}

int jsonInt(Object? deger, {int varsayilan = 0}) {
  if (deger is int) return deger;
  if (deger is num) return deger.toInt();
  if (deger is String) return int.tryParse(deger) ?? varsayilan;
  return varsayilan;
}

bool jsonBool(Object? deger, {bool varsayilan = false}) {
  if (deger is bool) return deger;
  return varsayilan;
}

DateTime? jsonTarih(Object? deger) {
  if (deger is String) return DateTime.tryParse(deger);
  return null;
}

/// Listeyi okur; okunamayan (null dönen) elemanları atlar.
List<T> jsonListe<T>(Object? deger, T? Function(Object? eleman) donustur) {
  if (deger is! List) return [];
  final sonuc = <T>[];
  for (final eleman in deger) {
    final okunan = donustur(eleman);
    if (okunan != null) sonuc.add(okunan);
  }
  return sonuc;
}

/// Enum değerini `toString()` biçiminden okur, bulunamazsa varsayılanı döner.
T jsonEnum<T extends Enum>(Object? deger, List<T> degerler, T varsayilan) {
  for (final e in degerler) {
    if (e.toString() == deger) return e;
  }
  return varsayilan;
}
