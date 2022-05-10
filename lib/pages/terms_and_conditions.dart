import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Terms and Conditions', style: textTheme.headline3),
        const SizedBox(height: 12),
        Text(
          '- Liability',
          style: textTheme.headline5,
        ),
        const SizedBox(height: 6),
        const Text(
            'WazPlay is just a service in which you can download songs and play them. Thus all of your actions done in the app are YOUR RESPONSBLITIES. You must know that whether to download song is legal or not.'),
        const SizedBox(height: 12),
        Text(
          '- Restrictions',
          style: textTheme.headline5,
        ),
        const SizedBox(height: 6),
        const Text(
            'You are not allowed to selling or sub-licensing this app for your own profit or others. '),
        const SizedBox(height: 12),
        Text(
          '- Intellectual Property Rights',
          style: textTheme.headline5,
        ),
        const SizedBox(height: 6),
        const Text(
            'Other than the content you own, under these Terms, WazPlay own all the intellectual property rights and materials contained in this App.'),
        const SizedBox(height: 12),
        Text(
          '- Permissions',
          style: textTheme.headline5,
        ),
        const SizedBox(height: 6),
        const Text(
            'Storage permission is required to download into your device.'),
        const SizedBox(height: 12),
        Text(
          '- Privacy',
          style: textTheme.headline5,
        ),
        const SizedBox(height: 6),
        const Text(
            'We - WazPlay do not store any of your data on any online server or services. Your data remain within your device and all data will be deleted as soon as you delete the app.'),
        const SizedBox(height: 12),
      ],
    );
  }
}
