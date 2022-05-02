void main() {
  String s = 'ILLENIUM, Jon Bellion - Good Things Fall Apart (Lyric Video)';
  List split = s.split('-');
  String author = split[0];
  String title = split[1];
  // for (var i in RegExp(r'(\w+)[^\((\w+)\)]').allMatches(title)) {
  //   print(i.group(0));
  // }
  final newString = title.replaceAllMapped(RegExp(r'\([^)]+\)'), (match) {
    return '';
  });
  print(newString);
}

enum A { test, last }
