import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const Duration _monthScrollDuration = Duration(milliseconds: 200);
const double _dayPickerRowHeight = 42.0;
const int _maxDayPickerRowCount = 6;
const double _maxDayPickerHeight =
    _dayPickerRowHeight * (_maxDayPickerRowCount + 1);
const double _monthPickerHorizontalPadding = 8.0;
const double _subHeaderHeight = 52.0;
const double _monthNavButtonsWidth = 108.0;

class CalendarDatePicker extends StatefulWidget {

  CalendarDatePicker({
    Key key,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
    DateTime currentDate,
    this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
    this.checking,
  })  : assert(initialDate != null),
        assert(firstDate != null),
        assert(lastDate != null),
        initialDate = DateUtils.dateOnly(initialDate),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        assert(onDateChanged != null),
        assert(initialCalendarMode != null),
        super(key: key) {
    assert(
    !this.lastDate.isBefore(this.firstDate),
    'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
    !this.initialDate.isBefore(this.firstDate),
    'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
    !this.initialDate.isAfter(this.lastDate),
    'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.',
    );
    assert(
    selectableDayPredicate == null ||
        selectableDayPredicate(this.initialDate),
    'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.',
    );
  }

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onDisplayedMonthChanged;
  final DatePickerMode initialCalendarMode;
  final SelectableDayPredicate selectableDayPredicate;
  final List<int> checking;

  @override
  _CalendarDatePickerState createState() => _CalendarDatePickerState();
}

class _CalendarDatePickerState extends State<CalendarDatePicker> {
  bool _announcedInitialDate = false;
  DatePickerMode _mode;
  DateTime _currentDisplayedMonthDate;
  DateTime _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  MaterialLocalizations _localizations;
  TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    _currentDisplayedMonthDate =
        DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  @override
  void didUpdateWidget(CalendarDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCalendarMode != oldWidget.initialCalendarMode) {
      _mode = widget.initialCalendarMode;
    }
    if (!DateUtils.isSameDay(widget.initialDate, oldWidget.initialDate)) {
      _currentDisplayedMonthDate =
          DateTime(widget.initialDate.year, widget.initialDate.month);
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        _localizations.formatFullDate(_selectedDate),
        _textDirection,
      );
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleMonthChanged(DateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year ||
          _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = DateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);
      }
    });
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate);
    });
  }

  Widget _buildPicker() {
    return _MonthPicker(
      key: _monthPickerKey,
      initialMonth: _currentDisplayedMonthDate,
      currentDate: widget.currentDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectedDate: _selectedDate,
      onChanged: _handleDayChanged,
      onDisplayedMonthChanged: _handleMonthChanged,
      selectableDayPredicate: widget.selectableDayPredicate,
      checking: widget.checking,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    return Stack(
      children: [
        Container(
          height: _subHeaderHeight + _maxDayPickerHeight,
          child: _buildPicker(),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20.0),
          child: Text(
            "每日记录(${_currentDisplayedMonthDate.month}月)",
            style: TextStyle(
              fontSize: 17.0,
              color: Color(0xFF333333),),
          ),
        ),
      ],
    );
  }
}

class _MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  _MonthPicker({
     Key key,
     this.initialMonth,
     this.currentDate,
     this.firstDate,
     this.lastDate,
     this.selectedDate,
     this.onChanged,
     this.onDisplayedMonthChanged,
    this.checking,
    this.selectableDayPredicate,
  })  : assert(selectedDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(firstDate != null),
        assert(lastDate != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate)),
        super(key: key);

  final DateTime initialMonth;
  final DateTime currentDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final ValueChanged<DateTime> onDisplayedMonthChanged;
  final SelectableDayPredicate selectableDayPredicate;
  final List<int> checking;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  final GlobalKey _pageViewKey = GlobalKey();
  DateTime _currentMonth;
  DateTime _nextMonthDate;
  DateTime _previousMonthDate;
  PageController _pageController;
  MaterialLocalizations _localizations;
  TextDirection _textDirection;
  Map<LogicalKeySet, Intent> _shortcutMap;
  Map<Type, Action<Intent>> _actionMap;
    FocusNode _dayGridFocus;
  DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _previousMonthDate = DateUtils.addMonthsToMonthDate(_currentMonth, -1);
    _nextMonthDate = DateUtils.addMonthsToMonthDate(_currentMonth, 1);
    _pageController = PageController(
        initialPage: DateUtils.monthDelta(widget.firstDate, _currentMonth));
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.arrowLeft):
      const DirectionalFocusIntent(TraversalDirection.left),
      LogicalKeySet(LogicalKeyboardKey.arrowRight):
      const DirectionalFocusIntent(TraversalDirection.right),
      LogicalKeySet(LogicalKeyboardKey.arrowDown):
      const DirectionalFocusIntent(TraversalDirection.down),
      LogicalKeySet(LogicalKeyboardKey.arrowUp):
      const DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
      CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(_MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth &&
        widget.initialMonth != _currentMonth) {
      WidgetsBinding.instance.addPostFrameCallback(
            (Duration timeStamp) => _showMonth(widget.initialMonth, jump: true),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(DateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final DateTime monthDate =
      DateUtils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
        _previousMonthDate = DateUtils.addMonthsToMonthDate(_currentMonth, -1);
        _nextMonthDate = DateUtils.addMonthsToMonthDate(_currentMonth, 1);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay.day);
        }
      }
    });
  }

  DateTime _focusableDayForMonth(DateTime month, int preferredDay) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    if (preferredDay <= daysInMonth) {
      final DateTime newFocus = DateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) return newFocus;
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime newFocus = DateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) return newFocus;
    }
    return null;
  }

  void _showMonth(DateTime month, {bool jump = false}) {
    final int monthPage = DateUtils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (DateUtils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (DateUtils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay =
              _focusableDayForMonth(_currentMonth, widget.currentDate.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final DateTime nextDate =
      _nextDateInDirection(_focusedDay, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        if (!DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _showMonth(_focusedDay);
        }
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
  <TraversalDirection, int>{
    TraversalDirection.up: -DateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: DateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(
      TraversalDirection traversalDirection, TextDirection textDirection) {
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left)
        traversalDirection = TraversalDirection.right;
      else if (traversalDirection == TraversalDirection.right)
        traversalDirection = TraversalDirection.left;
    }
    return _directionOffset[traversalDirection];
  }

  DateTime _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    DateTime nextDate = DateUtils.addDaysToDate(
        date, _dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = DateUtils.addDaysToDate(
          nextDate, _dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(DateTime date) {
    return widget.selectableDayPredicate == null ||
        widget.selectableDayPredicate.call(date);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month =
    DateUtils.addMonthsToMonthDate(widget.firstDate, index);
    return _DayPicker(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      checking: widget.checking,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: 50.00),
      child: FocusableActionDetector(
        shortcuts: _shortcutMap,
        actions: _actionMap,
        focusNode: _dayGridFocus,
        onFocusChange: _handleGridFocusChange,
        child: _FocusedDate(
          date: _dayGridFocus.hasFocus ? _focusedDay : null,
          child: PageView.builder(
            key: _pageViewKey,
            controller: _pageController,
            itemBuilder: _buildItems,
            itemCount:
            DateUtils.monthDelta(widget.firstDate, widget.lastDate) +
                1,
            scrollDirection: Axis.horizontal,
            onPageChanged: _handleMonthPageChanged,
          ),
        ),
      ),
    );
  }
}

class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
     Key key,
     Widget child,
    this.date,
  }) : super(key: key, child: child);

  final DateTime date;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static DateTime of(BuildContext context) {
    final _FocusedDate focusedDate =
    context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
    return focusedDate?.date;
  }
}

class _DayPicker extends StatefulWidget {
  _DayPicker({
     Key key,
     this.currentDate,
     this.displayedMonth,
     this.firstDate,
     this.lastDate,
     this.selectedDate,
     this.onChanged,
     this.checking,
    this.selectableDayPredicate,
  })  : assert(currentDate != null),
        assert(displayedMonth != null),
        assert(firstDate != null),
        assert(lastDate != null),
        assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate)),
        super(key: key);

  final DateTime selectedDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime displayedMonth;
  final SelectableDayPredicate selectableDayPredicate;
  final List<int> checking;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {

    List<FocusNode> _dayFocusNodes;
    List<int> checking = [];

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateUtils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
          (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime focusedDate = _FocusedDate.of(context);
    if (focusedDate != null &&
        DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<Widget> _dayHeaders(
      TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    final List<String> weekdays = ["日", "一", "二", "三", "四", "五", "六"];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = weekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MaterialLocalizations localizations =
    MaterialLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle headerStyle = textTheme.caption?.apply(
      color: colorScheme.onSurface.withOpacity(0.60),
    );
    final TextStyle dayStyle = textTheme.caption;
    final Color enabledDayColor = colorScheme.onSurface.withOpacity(0.87);
    final Color disabledDayColor = colorScheme.onSurface.withOpacity(0.38);
    final Color selectedDayColor = colorScheme.onPrimary;
    final Color selectedDayBackground = colorScheme.primary;
    final Color todayColor = colorScheme.primary;

    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateUtils.firstDayOffset(year, month, localizations);

    checking.clear();
    checking.addAll(widget.checking);
    if (checking.length < daysInMonth) {
      for (int i = checking.length; i < daysInMonth; i++) {
        checking.add(0);
      }
    }

    final List<Widget> dayItems = _dayHeaders(headerStyle, localizations);
    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.

    int day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool isDisabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate(dayToBuild));
        final bool isSelectedDay =
        DateUtils.isSameDay(widget.selectedDate, dayToBuild);
        final bool isToday =
        DateUtils.isSameDay(widget.currentDate, dayToBuild);

        BoxDecoration decoration;
        Color dayColor = enabledDayColor;
        if (isSelectedDay) {
          dayColor = selectedDayColor;
          decoration = BoxDecoration(
            color: selectedDayBackground,
            shape: BoxShape.circle,
          );
        } else if (isDisabled) {
          dayColor = disabledDayColor;
        } else if (isToday) {
          dayColor = todayColor;
          decoration = BoxDecoration(
            border: Border.all(color: todayColor, width: 1),
            shape: BoxShape.circle,
          );
        }


        //渲染月份的每一天
        Widget dayWidget = Container(
          decoration: decoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.formatDecimal(day),
                  style: dayStyle.apply(color: dayColor)),
              Visibility(
                //根据每天减一拿到每次的数组坐标  对比值是否等于1
                visible: checking[day - 1] == 1 || checking[day - 1] == 2,
                child: Container(
                  height: 6.0,
                  width: 6.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (checking[day - 1] == 1
                        ? Colors.lightGreenAccent[400]
                        : Color(0xFFFF8A21)),
                  ),
                ),
              ),
            ],
          ),
        );

        if (isDisabled) {
          dayWidget = ExcludeSemantics(
            child: dayWidget,
          );
        } else {
          dayWidget = InkResponse(
            focusNode: _dayFocusNodes[day - 1],
            onTap: () => widget.onChanged(dayToBuild),
            radius: _dayPickerRowHeight / 2 + 4,
            splashColor: selectedDayBackground.withOpacity(0.38),
            child: Semantics(
              label:
              '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child: dayWidget,
            ),
          );
        }

        dayItems.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        physics: const ClampingScrollPhysics(),
        gridDelegate: _dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(
      _dayPickerRowHeight,
      constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 1),
    );
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _dayPickerGridDelegate = _DayPickerGridDelegate();
