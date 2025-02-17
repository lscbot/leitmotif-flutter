import 'package:flutter/material.dart';
import 'package:leitmotif/leitmotif.dart';

/// Prevents the [Text] widget from clipping by
/// setting an overflow property. The text can
/// either be on one line or on mulitple lines.
/// This will be needed to avoid pixel overflow
/// if very long strings are displayed on small
/// devices e.g. displaying a long first or last
/// name inside constrained widgets.
class ClippedText extends StatelessWidget {
  final String value;
  final TextStyle style;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final bool? softWrap;
  final bool upperCase;
  const ClippedText(
    this.value, {
    Key? key,
    this.style = LitTextStyles.sansSerif,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.softWrap,
    this.upperCase = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    return Text(
      upperCase ? value.toUpperCase() : value,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines ?? defaultTextStyle.maxLines,

      /// The soft wrap will determine whether or not
      /// the text should continue on the next break.
      /// The text should wrap by default.
      softWrap: softWrap ?? true,
    );
  }
}
