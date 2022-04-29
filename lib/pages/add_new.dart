import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddNewSong extends StatefulWidget {
  const AddNewSong({Key? key}) : super(key: key);

  @override
  State<AddNewSong> createState() => _AddNewSongState();
}

class _AddNewSongState extends State<AddNewSong> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        // constraints: const BoxConstraints.expand(),
        height: size.height,
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Song',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(41, 184, 184, 184),
                        blurRadius: 4.0,
                        offset: Offset(0, 6),
                        spreadRadius: 0.4)
                  ]),
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (s) => print(s),
                decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: const Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'Enter youtube url'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: size.width * 0.5,
                    height: size.height * 0.5,
                    child: SvgPicture.asset('assets/icons/search.svg',
                        // color: Colors.red,
                        semanticsLabel: 'Search'),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
