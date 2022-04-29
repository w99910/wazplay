extension StringExtension on String {
  DateTime? toDateTime() {
    var reg =
        RegExp(r'(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)', caseSensitive: false);
    var string = '2022-01-07T21:44:10.475196';
    var match = reg.allMatches(string).first;
    int year = int.parse(match.group(1)!);
    int month = int.parse(match.group(2)!);
    int day = int.parse(match.group(3)!);
    int hour = int.parse(match.group(4)!);
    int minute = int.parse(match.group(5)!);
    int second = int.parse(match.group(6)!);
    return DateTime(year, month, day, hour, minute, second);
  }

  bool isUrl() {
    final reg = RegExp(r'^(https|http):\/\/', caseSensitive: false);
    return reg.hasMatch(this);
  }
}
