class HiraganaCharacters {
  final String karakter;
  final String latin;
  final String id;

  HiraganaCharacters(
      {required this.karakter, required this.latin, required this.id});

  factory HiraganaCharacters.fromJson(Map<String, dynamic> json) {
    return HiraganaCharacters(
      karakter: json['karakter'],
      latin: json['latin'],
      id: json['id'],
    );
  }
}

class Vocab {
  final String karakter;
  final String latin;
  final String arti;
  final String id;

  Vocab(
      {required this.karakter,
      required this.latin,
      required this.arti,
      required this.id});

  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
        karakter: json['karakter'],
        latin: json['latin'],
        arti: json['arti'],
        id: json['id']);
  }
}
