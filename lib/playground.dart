// import 'dart:';
void main() {
  A a = A();
  // a.add(Future.delayed(const Duration(seconds: 2), () {
  //   return (val) {
  //     val += 1;
  //     print(val);
  //   };
  // }));
  var string =
      '/var/mobile/Containers/Data/Application/FBBF1143-5B91-4DC3-987A-25F6668D0E26/Documents/files/Justin Bieber - Ghost.webm';
  print(Uri.file(string));
  // String s = 'sdf sdf 6% 4421 sdf ;;';
  // print(s.splitMapJoin(RegExp(r'([^a-zA-Z\s].*)'), onMatch: (match) => ''));
}

sdf() {
  return '123';
}

class A {
  List<Future<void Function(int)>> inserts = [];
  int i = 0;
  add(Future<Function(int)> fn) {
    inserts.add(fn);
  }

  init() async {
    for (var function in inserts) {
      Function.apply(await function, [i]);
    }
    print(runtimeType);
  }
}
