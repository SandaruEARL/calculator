// Alternative approach: HistoryPage that loads its own data
import 'dart:ffi';

import 'package:calculator/features/basic_calculator/presentation/pages/basic_calculator_page.dart';
import 'package:calculator/features/basic_calculator/presentation/viewmodels/basic_calculator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/calculation.dart';

class HistoryPage extends StatefulWidget {


  final VoidCallback onClearHistory;
  final VoidCallback? onBack;

  const HistoryPage({
    Key? key,
    required this.onClearHistory,
    this.onBack
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load history when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _loadHistory() async {
    final viewModel = Provider.of<BasicCalculatorViewModel>(context, listen: false);
    await viewModel.loadHistory();
  }

  @override
  Widget build(BuildContext context) {

    final history = context.watch<BasicCalculatorViewModel>().history.reversed.toList();
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<BasicCalculatorViewModel>(
          builder: (context, viewModel, child) {
            // Use viewModel.history instead of widget.history for live data
            final currentHistory = viewModel.history;

            return Container(
              height: screenHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
              ),
              child: Column(
                children: [
                  // Custom AppBar with enhanced styling
                  Container(
                    padding: EdgeInsets.only(
                        left: 8,
                        right: 16,
                        top: MediaQuery.of(context).padding.top + 8,
                        bottom: 16
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black12,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        // Custom back button with ripple effect
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (widget.onBack != null) {
                                widget.onBack!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.black87,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        // Title with better typography
                        Text(
                          'Calculation History',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),

                        Spacer(),

                        // Action menu with better styling
                        if (currentHistory.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: PopupMenuButton<String>(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              onSelected: (value) {
                                if (value == 'clear') {
                                  _showClearConfirmationDialog(context, viewModel);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'clear',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: Colors.red[600], size: 20),
                                      SizedBox(width: 12),
                                      Text(
                                        'Clear History',
                                        style: TextStyle(color: Colors.red[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content area with better spacing
                  Expanded(
                    child: currentHistory.isEmpty
                        ? _buildEmptyState()
                        : _buildHistoryList(currentHistory),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No calculations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start calculating to see your history here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Calculation> history) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final calc = history[index]; // newest first
        return _buildHistoryItem(calc, index);
      },
    );
  }

  Widget _buildHistoryItem(Calculation calc, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Optional: Handle tap to reuse calculation
            _showCalculationDetails(calc);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expression
                Text(
                  calc.expression,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),

                // Result - FIXED: Handle both String and double types
                Row(
                  children: [
                    Icon(
                      Icons.trending_flat_rounded,
                      color: Colors.orange[600],
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatResult(calc.result),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[600],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTimestamp(calc.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ADDED: Helper method to safely format the result
  String _formatResult(dynamic result) {
    if (result is String) {
      return result;
    } else if (result is double) {
      // Format double to remove unnecessary decimal places
      if (result == result.toInt()) {
        return result.toInt().toString();
      } else {
        return result.toString();
      }
    } else if (result is int) {
      return result.toString();
    } else {
      return result.toString();
    }
  }

  void _showCalculationDetails(Calculation calc) {
    // Optional: Show more details or copy functionality
  }

  void _showClearConfirmationDialog(BuildContext context, BasicCalculatorViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Clear History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear all calculation history? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                viewModel.clearCalculationHistory();
                // History will automatically update via Consumer
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }
}