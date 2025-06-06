import 'package:flutter/material.dart';
import '../../domain/entities/calculation.dart';
import '../widgets/calculator_button.dart';

class HistoryBottomSheet extends StatelessWidget {
  final List<Calculation> history;
  final VoidCallback onClearHistory;
  final VoidCallback? onViewAllHistory; // Add callback for viewing all history
  final VoidCallback? onClose; // Add callback for closing

  const HistoryBottomSheet({
    Key? key,
    required this.history,
    required this.onClearHistory,
    this.onViewAllHistory,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75, // Fixed height (75% of screen)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
      ),
      child: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Spacer(),

                if (history.isNotEmpty)
                  CalculatorButton(
                    text: '',
                    icon: Icons.clear_rounded,
                    type: ButtonType.function,
                    onPressed: onClose,
                    shape: ButtonShape.iconShaped,
                    iconColor: Colors.white,
                    backgroundColor: Colors.grey.shade800,
                    height: 36,
                    width: 36,
                  ),
              ],
            ),
          ),

          // History List or Placeholder
          Expanded(
            child: history.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/drawer_background.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No calculations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: history.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final calculation = history[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calculation.expression,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Result: ${calculation.result}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _formatTimestamp(calculation.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 8),
            child: Row(
              mainAxisAlignment: history.isNotEmpty
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
              children: [
                if (history.isNotEmpty)
                  CalculatorButton(
                    text: 'VIEW ALL',
                    type: ButtonType.function,
                    onPressed: onViewAllHistory,
                    width: 150,
                    height: 50,
                    backgroundColor: Colors.orange.shade400,
                    shape: ButtonShape.rounded,
                    textColor: Colors.white,
                    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),

                CalculatorButton(
                  text: 'CLOSE',
                  type: ButtonType.function,
                  onPressed: onClose,
                  width: history.isNotEmpty ? 150 : 325,
                  height: 50,
                  backgroundColor: Colors.orange.shade400,
                  shape: ButtonShape.rounded,
                  textColor: Colors.white,
                  textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 23),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}