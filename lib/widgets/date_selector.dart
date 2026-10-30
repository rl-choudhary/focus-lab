import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({super.key});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final ScrollController _scrollController = ScrollController();
  final List<DateTime> _days = List.generate(
      30, (index) => DateTime.now().subtract(Duration(days: 29 - index)));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final selectedIndex = _days.indexWhere((d) =>
        d.year == appState.selectedDate.year &&
        d.month == appState.selectedDate.month &&
        d.day == appState.selectedDate.day);

    if (selectedIndex != -1 && _scrollController.hasClients) {
      const itemWidth = 70.0;
      final offset = selectedIndex * itemWidth;
      final viewport = _scrollController.position.viewportDimension;
      final target = (offset + itemWidth / 2) - (viewport / 2);

      _scrollController.animateTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return SizedBox(
      height: 94,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected = date.year == appState.selectedDate.year &&
              date.month == appState.selectedDate.month &&
              date.day == appState.selectedDate.day;

          return InkWell(
            onTap: () {
              appState.updateSelectedDate(date);
              _scrollToSelected();
            },
            borderRadius: BorderRadius.circular(29),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(29),
                border: isSelected ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primaryGreen : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
