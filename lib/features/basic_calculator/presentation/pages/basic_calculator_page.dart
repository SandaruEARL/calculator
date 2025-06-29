// presentation/pages/basic_calculator_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/basic_calculator_viewmodel.dart';
import '../viewmodels/scientific_calculator_viewmodel.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_display.dart';
import '../widgets/history_drawer.dart';

typedef ShowHistoryCallback = void Function();

class BasicCalculatorPage extends StatefulWidget {
  final Animation<double>? animation;
  final bool isSynchronizedTransition;
  final ShowHistoryCallback? onShowHistory;

  const BasicCalculatorPage({super.key, this.animation, this.isSynchronizedTransition = true, this.onShowHistory});

  @override
  _BasicCalculatorPageState createState() => _BasicCalculatorPageState();

}

class _BasicCalculatorPageState extends State<BasicCalculatorPage>
    with TickerProviderStateMixin {

  bool _showExpandedButtons = false;
  late AnimationController _animationController;
  late AnimationController _textSizeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textSizeAnimation;
  late ShowHistoryCallback? onShowHistory;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundFadeAnimation;

  // Animation for synchronized slide effect with history page
  late Animation<Offset> _slideFromRightAnimation;

  // Constants for better performance and consistency
  static const double _bannerHeight = 50.0;
  static const double _expandedPanelHeight = 100.0; // 3 rows × 33px each
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const Duration _textAnimationDuration = Duration(milliseconds: 250);

  // Pre-built widgets to avoid rebuilding during animations
  late Widget _bannerPlaceholder;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _buildStaticWidgets();

    // Load history after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BasicCalculatorViewModel>().loadHistory();
    });
  }

  void _initializeAnimations() {
    // Main animation controller for panel expansion
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,

    );

    // Separate controller for text size animation for better control
    _textSizeController = AnimationController(
      duration: _textAnimationDuration,
      vsync: this,
    );

    // Use smoother curves for slide animation
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Fade animation with custom curve
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeInQuart),
    ));

    // Text size animation with smooth easing
    _textSizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85, // Slightly smaller text when expanded
    ).animate(CurvedAnimation(
      parent: _textSizeController,
      curve: Curves.easeInOutCubic,
    ));

    // Synchronized slide animation for history page navigation
    if (widget.animation != null && widget.isSynchronizedTransition) {
      // When used in synchronized transition, animate background calculator
      _slideFromRightAnimation = Tween<Offset>(
        begin: Offset.zero, // Start at current position
        end: const Offset(-0.3, 0.0), // Move slightly left (same direction as history)
      ).animate(CurvedAnimation(
        parent: widget.animation!,
        curve: const Interval(0.1, 0.9, curve: Curves.easeInOutCubic),
      ));

      // Add scale animation for depth effect
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(
        parent: widget.animation!,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInCubic),
      ));

      // Add fade animation
      _fadeAnimation = Tween<double>(
        begin: 1.0,
        end: 0.7,
      ).animate(CurvedAnimation(
        parent: widget.animation!,
        curve: const Interval(0.1, 0.8, curve: Curves.easeIn),
      ));
    } else if (widget.animation != null) {
      // Regular slide from right animation (for coming back from history)
      _slideFromRightAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: widget.animation!,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ));
    } else {
      // Fallback - no animation
      _slideFromRightAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(kAlwaysCompleteAnimation);
    }
  }

  void _buildStaticWidgets() {
    // Build banner placeholder once to avoid rebuilding
    _bannerPlaceholder = Container(
      height: _bannerHeight,
      margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0), // Minimal horizontal margin
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey[500], size: 16),
            SizedBox(width: 8),
            Text(
              'Advertisement Banner Space',
              style: TextStyle(
                color: Colors.red[500],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textSizeController.dispose();
    super.dispose();
  }

  void _toggleExpandedButtons() {
    setState(() {
      _showExpandedButtons = !_showExpandedButtons;
      if (_showExpandedButtons) {
        _animationController.forward();
        _textSizeController.forward();
      } else {
        _animationController.reverse();
        _textSizeController.reverse();
      }
    });
  }

  // Handle scientific function button press
  void _handleScientificFunction(String function, BasicCalculatorViewModel basicVM, ScientificCalculatorViewModel sciVM) {
    final scientificFunction = sciVM.getScientificFunction(function);
    if (scientificFunction.isNotEmpty) {
      // Check if we need to add multiplication before the function
      final trimmedExpr = basicVM.expression.trimRight();
      final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';

      if (sciVM.needsMultiplicationBefore(lastChar)) {
        basicVM.onOperatorPressed('*');
      }

      // Add the function to the expression
      basicVM.onNumberPressed(scientificFunction);
    }
  }

  // Handle scientific constant button press
  void _handleScientificConstant(String constant, BasicCalculatorViewModel basicVM, ScientificCalculatorViewModel sciVM) {
    // Check if we need to add multiplication before the constant
    final trimmedExpr = basicVM.expression.trimRight();
    final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';

    if (sciVM.needsMultiplicationBefore(lastChar)) {
      basicVM.onOperatorPressed('*');
    }

    // Insert the constant symbol directly, not its value
    basicVM.onNumberPressed(constant); // Use the symbol (π, e, φ) not the numerical value
  }

  // Handle power function button press
  void _handlePowerFunction(String power, BasicCalculatorViewModel basicVM, ScientificCalculatorViewModel sciVM) {
    if (sciVM.isValidForPower(basicVM.expression)) {
      // For power operations, we need to handle them differently
      switch (power) {
        case 'x²':
          basicVM.onOperatorPressed('^');
          basicVM.onNumberPressed('2');
          break;
        case 'x³':
          basicVM.onOperatorPressed('^');
          basicVM.onNumberPressed('3');
          break;
        case '^':
          basicVM.onOperatorPressed('^');
          break;
        case '10ˣ':
        // Handle 10^x specially
          final trimmedExpr = basicVM.expression.trimRight();
          final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';
          if (sciVM.needsMultiplicationBefore(lastChar)) {
            basicVM.onOperatorPressed('*');
          }
          basicVM.onNumberPressed('10^(');
          break;
        case '2ˣ':
        // Handle 2^x specially
          final trimmedExpr = basicVM.expression.trimRight();
          final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';
          if (sciVM.needsMultiplicationBefore(lastChar)) {
            basicVM.onOperatorPressed('*');
          }
          basicVM.onNumberPressed('2^(');
          break;
        case 'eˣ':
        // Handle e^x specially
          final trimmedExpr = basicVM.expression.trimRight();
          final lastChar = trimmedExpr.isNotEmpty ? trimmedExpr.characters.last : '';
          if (sciVM.needsMultiplicationBefore(lastChar)) {
            basicVM.onOperatorPressed('*');
          }
          basicVM.onNumberPressed('${sciVM.getConstantValue('e')}^(');
          break;
        default:
          basicVM.onOperatorPressed('^');
          break;
      }
    }
  }

  // Handle factorial button press
  void _handleFactorial(BasicCalculatorViewModel basicVM, ScientificCalculatorViewModel sciVM) {
    if (sciVM.isValidForFactorial(basicVM.expression)) {
      // Update the expression directly
      basicVM.onNumberPressed('!');
    }
  }

  // Optimized expanded button panel without conflicting animations
  Widget _buildExpandedButtonPanel() {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _slideAnimation,
        axisAlignment: -1.0,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: _expandedPanelHeight,
            child: Consumer2<BasicCalculatorViewModel, ScientificCalculatorViewModel>(
              builder: (context, basicVM, sciVM, child) {
                return Column(
                  children: [
                    _buildExpandedButtonRow([
                      _buildExpandedButton('φ', () => _handleScientificConstant('φ', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('e', () => _handleScientificConstant('e', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('ln', () => _handleScientificFunction('ln', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('log', () => _handleScientificFunction('log', basicVM, sciVM), ButtonType.function),
                    ]),

                    _buildExpandedButtonRow([
                      _buildExpandedButton('sin', () => _handleScientificFunction('sin', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('cos', () => _handleScientificFunction('cos', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('tan', () => _handleScientificFunction('tan', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('π', () => _handleScientificConstant('π', basicVM, sciVM), ButtonType.function),
                    ]),

                    _buildExpandedButtonRow([
                      _buildExpandedButton('!', () => _handleFactorial(basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('³√', () => _handleScientificFunction('∛', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('√', () => _handleScientificFunction('√', basicVM, sciVM), ButtonType.function),
                      _buildExpandedButton('^', () => _handlePowerFunction('^', basicVM, sciVM), ButtonType.operator),
                    ]),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedButtonRow(List<Widget> buttons) {
    return Expanded(
      child: Row(children: buttons),
    );
  }

  Widget _buildExpandedButton(String text, VoidCallback onPressed, ButtonType type) {
    return CalculatorButton(
      text: text,
      textStyle: TextStyle(fontSize: 17),
      onPressed: onPressed,
      type: type,
      isExpandedMode: true,
      textColor: Colors.black,
      backgroundColor: Colors.grey.shade300,
    );
  }

  // Dynamic Rad/Deg toggle button that appears only in scientific mode
  Widget _buildRadDegButton(ScientificCalculatorViewModel sciVM) {
    if (!_showExpandedButtons) {
      return SizedBox.shrink(); // Return empty widget when not in scientific mode
    }

    return Container(
      height: 38, // Smaller height than regular buttons
      width: 70,  // Smaller width than regular buttons
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ElevatedButton(
        onPressed: () => sciVM.toggleAngleMode(),
        style: ElevatedButton.styleFrom(
          backgroundColor: sciVM.isDegreeMode ? Colors.orange[100] : Colors.blue[100],
          foregroundColor: sciVM.isDegreeMode ? Colors.orange[800] : Colors.blue[800],
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: sciVM.isDegreeMode ? Colors.orange[300]! : Colors.blue[300]!,
              width: 0,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          sciVM.isDegreeMode ? 'Deg' : 'Rad',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Fixed swap and backspace row with proper alignment
  Widget _buildSwapAndBackspaceRow(BasicCalculatorViewModel basicVM, ScientificCalculatorViewModel sciVM) {
    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10), // Minimal horizontal margin
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center align all children
        children: [
          CalculatorButton(
            icon: _showExpandedButtons ? Icons.functions : Icons.calculate,
            text: _showExpandedButtons ? "Scientific" : "Basic",
            onPressed: _toggleExpandedButtons,
            textStyle: TextStyle(fontSize: 17),
            isExpandedMode: _showExpandedButtons,
            keepFixedHeight: true, // Keep fixed height regardless of expanded mode
            flex: 2,
          ),

          // Dynamic spacing based on scientific mode
          _showExpandedButtons
              ? SizedBox(width: 1) // Less space when rad/deg button is visible
              : SizedBox(width: 150), // More space when rad/deg button is hidden

          // Dynamic Rad/Deg button - only visible in scientific mode
          _buildRadDegButton(sciVM),

          // Flexible spacing to push backspace to the right
          Spacer(),

          // Properly aligned backspace button with disabled touch effect
          Container(
            height: 48, // Match the container height for proper alignment
            child: CalculatorButton(
              icon: Icons.backspace,
              iconSize: 35,
              iconColor: Colors.orange.shade400,
              backgroundColor: Colors.white,
              enableTouchEffect: false,
              text: "",
              shape: ButtonShape.iconShaped,
              onPressed: basicVM.onBackspacePressed,
              isExpandedMode: _showExpandedButtons,
              keepFixedHeight: true, // Keep fixed height regardless of expanded mode
            ),
          )
        ],
      ),
    );
  }

  // Basic calculator buttons with smooth text size animation
  Widget _buildBasicCalculatorButtons(BasicCalculatorViewModel viewModel) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _textSizeAnimation,
        builder: (context, child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0), // Minimal horizontal padding for buttons
            child: Column(
              children: [
                // Row 1 - Clear, Parentheses, Modulo, Division
                _buildBasicButtonRow([
                  _buildBasicButton('C', viewModel.onClearPressed, ButtonType.function),
                  _buildBasicButton('( )', viewModel.onParenthesisPressed, ButtonType.function),
                  _buildBasicButton('%', () => viewModel.onOperatorPressed('%'), ButtonType.operator),
                  _buildBasicButton('÷', () => viewModel.onOperatorPressed('/'), ButtonType.operator),
                ]),
                // Row 2 - Numbers 7, 8, 9 and Multiplication
                _buildBasicButtonRow([
                  _buildBasicButton('7', () => viewModel.onNumberPressed('7')),
                  _buildBasicButton('8', () => viewModel.onNumberPressed('8')),
                  _buildBasicButton('9', () => viewModel.onNumberPressed('9')),
                  _buildBasicButton('×', () => viewModel.onOperatorPressed('*'), ButtonType.operator),
                ]),
                // Row 3 - Numbers 4, 5, 6 and Subtraction
                _buildBasicButtonRow([
                  _buildBasicButton('4', () => viewModel.onNumberPressed('4')),
                  _buildBasicButton('5', () => viewModel.onNumberPressed('5')),
                  _buildBasicButton('6', () => viewModel.onNumberPressed('6')),
                  _buildBasicButton('-', () => viewModel.onOperatorPressed('-'), ButtonType.operator),
                ]),
                // Row 4 - Numbers 1, 2, 3 and Addition
                _buildBasicButtonRow([
                  _buildBasicButton('1', () => viewModel.onNumberPressed('1')),
                  _buildBasicButton('2', () => viewModel.onNumberPressed('2')),
                  _buildBasicButton('3', () => viewModel.onNumberPressed('3')),
                  _buildBasicButton('+', () => viewModel.onOperatorPressed('+'), ButtonType.operator),
                ]),
                // Row 5 - Zero, Double Zero, Decimal, Equals
                _buildBasicButtonRow([
                  _buildBasicButton('0', () => viewModel.onNumberPressed("0")),
                  _buildBasicButton('00', () => viewModel.onDoubleZeroPressed()),
                  _buildBasicButton('.', viewModel.onDecimalPressed),
                  _buildBasicButton('=', viewModel.onEqualsPressed, ButtonType.equals),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicButtonRow(List<Widget> buttons) {
    return Expanded(
      child: Row(children: buttons),
    );
  }

  Widget _buildBasicButton(String text, VoidCallback onPressed, [ButtonType? type]) {
    return CalculatorButton(
      text: text,
      textStyle: TextStyle(fontSize: 19),
      onPressed: onPressed,
      type: type ?? ButtonType.number,
      isExpandedMode: _showExpandedButtons,
      textSizeMultiplier: _textSizeAnimation.value, // Pass the animated text size multiplier
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideFromRightAnimation,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Calculator"),
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.orangeAccent,
            elevation: 0, // Remove shadow to blend better
            actions: [
              Consumer<BasicCalculatorViewModel>(
                builder: (context, viewModel, child) {
                  return IconButton(
                    icon: Icon(Icons.history),
                    onPressed: () {
                      if (widget.onShowHistory != null) {
                        widget.onShowHistory!();
                      } else {
                        // Fallback to bottom sheet if no callback provided
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => HistoryBottomSheet(
                            history: viewModel.history,
                            onClearHistory: viewModel.clearCalculationHistory,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),

          body: Consumer2<BasicCalculatorViewModel, ScientificCalculatorViewModel>(
            builder: (context, basicVM, sciVM, child) {
              return Column( // Removed padding to use full width
                children: [
                  // Display Section - Takes full width and uses available height

                    SizedBox(
                      height: MediaQuery.of(context).size.height * (_showExpandedButtons ? 0.30 : 0.34),
                      child: CalculatorDisplay(
                        expression: basicVM.expression,
                        result: basicVM.state == CalculatorState.error
                            ? basicVM.errorMessage
                            : basicVM.display,
                        state: basicVM.state,
                        liveResult: basicVM.liveResult,
                        isCompactMode: _showExpandedButtons,
                      ),
                    ),


                  // Swap and Backspace button row with dynamic rad/deg button
                  _buildSwapAndBackspaceRow(basicVM, sciVM),

                  // Expandable button panel with optimized animations
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: _buildExpandedButtonPanel(),
                  ),

                  // Basic calculator buttons with smooth text animation
                  _buildBasicCalculatorButtons(basicVM),

                  // Fixed banner space at the bottom
                  _bannerPlaceholder,
                ],
              );

            },
          ),
        ),
      ),

    );

  }
}