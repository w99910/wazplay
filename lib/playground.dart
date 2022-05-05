// import 'dart:';
void main() {
  // A a = A();
  // a.add(Future.delayed(const Duration(seconds: 2), () {
  //   return (val) {
  //     val += 1;
  //     print(val);
  //   };
  // }));
  // a.init();
  Map test = {'sdf': () => sdf()};
  print(test['sdf'] is Function);
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
    print(i);
  }
}
