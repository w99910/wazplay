import 'package:flutter/material.dart';
import 'package:wazplay/support/interfaces/previewable.dart';
import 'package:wazplay/widgets/custom_image.dart';

class Preview extends StatelessWidget {
  final PreviewAble previewAble;
  final double width;
  final double height;
  final bool centerText;
  final bool showTitle;
  final bool showSubtitle;
  final Widget? actions;
  final Axis axis;
  const Preview(
      {Key? key,
      required this.previewAble,
      required this.width,
      required this.height,
      this.axis = Axis.vertical,
      this.centerText = false,
      this.showSubtitle = true,
      this.actions,
      this.showTitle = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: axis == Axis.vertical
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: centerText
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                  buildPlaceholder(context, height: height * 0.5, width: width),
                  const SizedBox(height: 10),
                  if (showTitle) buildTitle(context),
                  if (showSubtitle) buildSubtitle(context)
                ])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              buildPlaceholder(context, height: height, width: width * 0.25),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: centerText
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    if (showTitle) buildTitle(context),
                    if (showSubtitle) buildSubtitle(context)
                  ],
                ),
              ),
              if (actions != null) actions!,
            ]),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Flexible(
      child: Text(
        previewAble.getTitle(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Text buildSubtitle(BuildContext context) {
    return Text(
      previewAble.getSubtitle(),
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget buildPlaceholder(BuildContext context,
      {required double width, required double height}) {
    return previewAble.getImagePlaceholder() != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomImage(
              url: previewAble.getImagePlaceholder()!,
              height: height,
              width: width,
              boxFit: BoxFit.fill,
            ))
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).primaryColor,
            ),
            width: width,
            height: height,
            child: Icon(
              Icons.image,
              size: width * 0.5,
              color: Theme.of(context).primaryColorDark,
            ),
          );
  }
}
