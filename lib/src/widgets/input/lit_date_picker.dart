import 'package:flutter/material.dart';
import 'package:leitmotif/calendar.dart';
import 'package:leitmotif/leitmotif.dart';

/// A date picker widget allowing the modification of the provided
/// [selectedDate] DateTime value.
///
/// The total size will be determined using it's parent constraints.
class LitDatePicker extends StatefulWidget {
  final CalendarController calendarController;
  final DateTime? selectedDate;
  final void Function(DateTime value) setSelectedDate;
  final void Function() onExclusiveMonth;
  final void Function() onFutureDate;
  final bool allowFutureDates;
  final DateTime? initialDate;
  const LitDatePicker({
    Key? key,
    required this.calendarController,
    required this.selectedDate,
    required this.setSelectedDate,
    required this.onExclusiveMonth,
    required this.onFutureDate,
    this.allowFutureDates = true,
    this.initialDate,
  }) : super(key: key);

  @override
  _LitDatePickerState createState() => _LitDatePickerState();
}

class _LitDatePickerState extends State<LitDatePicker>
    with TickerProviderStateMixin {
  late AnimationController _appearAnimationController;

  void _decreaseByMonth() {
    setState(() => {widget.calendarController.decreaseByMonth()});
  }

  void _increaseByMonth() {
    setState(() => {widget.calendarController.increaseByMonth()});
  }

  void _setDisplayedMonth(int month) {
    setState(() {
      widget.calendarController.selectMonth(month);
    });
  }

  void _setDisplayedYear(int year) {
    setState(() {
      widget.calendarController.selectYear(year);
    });
  }

  void _onMonthLabelPress() {
    showDialog(
      context: context,
      builder: (_) => _SelectMonthDialog(
        setDisplayedMonthCallback: _setDisplayedMonth,
        months: CalendarLocalizationService.getLocalizedCalendarMonths(
          Localizations.localeOf(context),
        ),
      ),
    );
  }

  void _onYearLabelPress() {
    showDialog(
      context: context,
      builder: (_) => _SelectYearDialog(
        setDisplayedYearCallback: _setDisplayedYear,
        templateDate: widget.calendarController.templateDate,
        initialDate: widget.initialDate,
      ),
    );
  }

  String get _localizedMonth {
    return CalendarLocalizationService.getLocalizedCalendarMonths(
            Localizations.localeOf(context))[
        widget.calendarController.templateDate!.month - 1];
  }

  @override
  void initState() {
    super.initState();
    _appearAnimationController = AnimationController(
      duration: Duration(milliseconds: 140),
      vsync: this,
    );
    _appearAnimationController.forward();
  }

  @override
  void dispose() {
    _appearAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appearAnimationController,
      builder: (BuildContext context, Widget? _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeInTransformContainer(
              transform: Matrix4.translationValues(
                  -20 + (20 * _appearAnimationController.value), 0, 0),
              animationController: _appearAnimationController,
              child: LitCalendarNavigation(
                decreaseByMonth: _decreaseByMonth,
                increaseByMonth: _increaseByMonth,
                onMonthLabelPress: _onMonthLabelPress,
                onYearLabelPress: _onYearLabelPress,
                monthLabel: _localizedMonth,
                yearLabel: "${widget.calendarController.templateDate!.year}",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                final List<String> strings =
                    CalendarLocalizationService.getLocalizedCalendarWeekdays(
                        Localizations.localeOf(context));
                final List<Widget> labels = [];
                for (String str in strings) {
                  labels.add(
                    LitCalendarWeekdayLabel(
                        constraints: constraints, label: str),
                  );
                }
                return Row(
                  children: labels,
                );
              }),
            ),
            FadeInTransformContainer(
              animationController: _appearAnimationController,
              child: LitCalendarGrid(
                calendarController: widget.calendarController,
                selectedDate: widget.selectedDate,
                setSelectedDateTime: widget.setSelectedDate,
                exclusiveMonthCallback: widget.onExclusiveMonth,
                futureDateCallback: widget.onFutureDate,
                allowFutureDates: widget.allowFutureDates,
              ),
              transform: Matrix4.translationValues(
                0,
                -20 + (20 * _appearAnimationController.value),
                0,
              ),
            )
          ],
        );
      },
    );
  }
}

class _SelectMonthDialog extends StatefulWidget {
  final void Function(int) setDisplayedMonthCallback;
  final List<String> months;
  const _SelectMonthDialog({
    Key? key,
    required this.setDisplayedMonthCallback,
    required this.months,
  }) : super(key: key);

  @override
  _SelectMonthDialogState createState() => _SelectMonthDialogState();
}

class _SelectMonthDialogState extends State<_SelectMonthDialog> {
  void _onPressed(int value) {
    widget.setDisplayedMonthCallback(value);
    LitRouteController(context).closeDialog();
  }

  List<Widget> get _children {
    final List<Widget> children = [];
    for (int i = 0; i < widget.months.length; i++) {
      children.add(
        LitPlainLabelButton(
          label: widget.months[i],
          accentColor: LitColors.darkOliveGreen,
          onPressed: () => _onPressed(i + 1),
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ),
      child: LitTitledDialog(
        titleText: "Month",
        child: Builder(
          builder: (context) {
            return SizedBox(
              height: 384.0,
              child: ScrollableColumn(
                constrained: false,
                children: _children,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A dialog [Widget] displaying a list of selectable years.
///
/// Once the year has been selected by the user, the provided callback method
/// will return the desired year as an integer (e.g. 2021).
class _SelectYearDialog extends StatefulWidget {
  final void Function(int year) setDisplayedYearCallback;
  final DateTime? templateDate;
  final int numberOfYears;
  final DateTime? initialDate;

  /// Creates a [SelectYearDialog].
  ///
  /// Pass a [setDisplayedYearCallback] to set the parent's state and a
  /// [templateDate] to set the initially displayed year inside the list.
  const _SelectYearDialog({
    Key? key,
    required this.setDisplayedYearCallback,
    required this.templateDate,
    this.numberOfYears = 80,
    this.initialDate,
  }) : super(key: key);

  @override
  _SelectYearDialogState createState() => _SelectYearDialogState();
}

class _SelectYearDialogState extends State<_SelectYearDialog> {
  //PageController? _pageController;

  final int millisecondsPerYear = 31556926000;

  void _onPressed(int value) {
    widget.setDisplayedYearCallback(value);
    LitRouteController(context).closeDialog();
  }

  DateTime get _initialDate {
    return DateTime.now();
  }

  /// Gets the inital page that should be selected on the page view.
  int get initialPage {
    return
        // If the provided template date is as recently as the provided number
        // of years allow (e.g. as recently as 20 years ago).
        widget.templateDate!.year >
                (_initialDate)
                    .subtract(Duration(
                        milliseconds:
                            millisecondsPerYear * widget.numberOfYears))
                    .year
            // Set the index to display the provided template year
            ? ((_initialDate).year -
                (DateTime.fromMillisecondsSinceEpoch(
                        widget.templateDate!.millisecondsSinceEpoch))
                    .year)
            // Otherwise select the first year in the page list.
            : 0;
  }

  List<Widget> get _children {
    final List<Widget> children = [];
    for (int i = 0; i < widget.numberOfYears; i++) {
      final DateTime iteratedDate = (_initialDate)
          .subtract(Duration(milliseconds: millisecondsPerYear * i));
      children.add(
        LitPlainLabelButton(
          label: "${iteratedDate.year}",
          accentColor: LitColors.darkOliveGreen,
          onPressed: () => _onPressed(iteratedDate.year),
        ),
      );
    }
    return children;
  }

  @override
  void initState() {
    super.initState();
    //_pageController = PageController(initialPage: initialPage);
  }

  @override
  Widget build(BuildContext context) {
    //print(_pageController!.initialPage);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ),
      child: LitTitledDialog(
        titleText: "Year",
        child: Builder(
          builder: (context) {
            return SizedBox(
              height: 384.0,
              child: ListView(
                physics: BouncingScrollPhysics(),
                //controller: _pageController,
                scrollDirection: Axis.vertical,
                children: _children,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                reverse: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
