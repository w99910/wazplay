import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wazplay/pages/terms_and_conditions.dart';
import 'package:wazplay/support/singletons/app.dart';
import 'package:wazplay/support/singletons/configuration.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  late bool isDarkMode;
  late bool isAutoDownloadThumbnail;
  late bool isVibratable;

  Configuration configuration = App.instance.configuration;

  @override
  void initState() {
    isVibratable = configuration.vibrateable;
    isDarkMode = configuration.isDarkMode;
    isAutoDownloadThumbnail = configuration.autoDownloadThumb;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dark_mode),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: Text(
                        'Dark Mode',
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.w500),
                      )),
                      Switch.adaptive(
                          activeTrackColor: Colors.grey[300],
                          thumbColor: MaterialStateProperty.all(Colors.white),
                          value: isDarkMode,
                          onChanged: (val) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              isDarkMode = val;
                            });
                            configuration.toggleDarkMode();
                          })
                    ],
                  ),
                  ...buildDivider(12),
                  Row(
                    children: [
                      const Icon(Icons.vibration),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: Text(
                        'Enable Vibration',
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.w500),
                      )),
                      Switch.adaptive(
                          activeTrackColor:
                              Platform.isAndroid ? Colors.grey[300] : null,
                          thumbColor: Platform.isAndroid
                              ? MaterialStateProperty.all(Colors.white)
                              : null,
                          value: isVibratable,
                          onChanged: (val) {
                            setState(() {
                              isVibratable = val;
                            });
                            configuration.toggleVibration();
                          })
                    ],
                  ),
                  ...buildDivider(12),
                  Row(
                    children: [
                      const Icon(Icons.cloud_download),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: Text(
                        'Auto Download Thumbnail',
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.w500),
                      )),
                      Switch.adaptive(
                          activeTrackColor:
                              Platform.isAndroid ? Colors.grey[300] : null,
                          thumbColor: Platform.isAndroid
                              ? MaterialStateProperty.all(Colors.white)
                              : null,
                          value: isAutoDownloadThumbnail,
                          onChanged: (val) {
                            setState(() {
                              isAutoDownloadThumbnail = val;
                            });
                            configuration.toggleAutoDownloadThumbnail();
                          })
                    ],
                  ),
                  ...buildDivider(20),
                  Row(
                    children: [
                      const Icon(Icons.text_snippet),
                      const SizedBox(
                        width: 16,
                      ),
                      TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 20),
                                    child: TermsAndConditions(),
                                  );
                                });
                          },
                          child: Text(
                            'Terms and Conditions',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline),
                          )),
                    ],
                  ),
                  // ...buildDivider(20),
                  // Row(
                  //   children: [
                  //     const Icon(Icons.person),
                  //     const SizedBox(
                  //       width: 16,
                  //     ),
                  //     Expanded(
                  //         child: Text(
                  //       'About Us',
                  //       style: Theme.of(context).textTheme.headline6!.copyWith(
                  //           fontWeight: FontWeight.w500,
                  //           decoration: TextDecoration.underline),
                  //     )),
                  //   ],
                  // )
                ],
              ),
            )
          ],
        ));
  }

  List<Widget> buildDivider(double height) {
    return [
      SizedBox(height: height / 1.8),
      const Divider(),
      SizedBox(height: height / 1.8),
    ];
  }

  @override
  bool get wantKeepAlive => true;
}
