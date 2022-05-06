import 'dart:math';

class Greeting {
  static Period getPeriod() {
    DateTime time = DateTime.now();
    int hour = time.hour;
    if (hour >= 6 && hour < 12) {
      return Period.morning;
    }

    if (hour >= 12 && hour < 16) {
      return Period.afternoon;
    }
    if (hour >= 16 && hour < 19) {
      return Period.evening;
    }
    return Period.night;
  }

  static const List<String> mornings = [
    'Rise and Shine!',
    'Top of the morning to you!',
    'Good day to you,',
    'Have a great day,',
    'Hello there,',
    'Wishing you the best for the day ahead,',
    "Isn't it a beautiful day today?",
  ];

  static const List<String> afternoon = [
    'Have a good afternoon!',
    'Have an awesome afternoon,',
    'Wishing you a splendid afternoon,',
    'Half of the day is over; have a marvelous afternoon and enjoy the rest of the day!',
    'May this afternoon bring you delightful surprises.',
    'Have a relaxing and quiet noontime and a fun-filled afternoon.',
  ];

  static const List<String> evenings = [
    'Hi, pleasing eve.',
    'Mesmerizing evening for you',
    'Hey delightful evening,',
    'Lots of love for this sweet evening',
    "Isn't this a lovely night?",
    "What a fine evening!",
    'Hi, this evening is as adorable as you.',
  ];

  static const List<String> nights = [
    'Goodnight and sweet dreams.',
    "It's time to ride the rainbow to dreamland.",
    'Night night.',
    'Hi there, I hope you are having a good night',
    'Lights out!',
    "Until tomorrow.",
    "Sleep well,",
  ];

  static Map<Period, List<String>> messages = {
    Period.morning: mornings,
    Period.afternoon: afternoon,
    Period.evening: evenings,
    Period.night: nights,
  };

  static String getMessage() {
    Period period = getPeriod();
    List<String> data = messages[period]!;
    int index = Random().nextInt(data.length - 1);
    return data[index];
  }
}

enum Period { morning, afternoon, evening, night }
