// Updated calculator_shell.dart with smooth transition handoff
import 'package:calculator/features/basic_calculator/presentation/pages/basic_calculator_page.dart';
import 'package:calculator/features/basic_calculator/presentation/pages/history_page.dart';
import 'package:calculator/features/basic_calculator/presentation/viewmodels/basic_calculator_viewmodel.dart';
import 'package:calculator/features/basic_calculator/presentation/widgets/history_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

enum NavigationState {
  calculator,
  drawer,
  history,
}

class CalculatorShell extends StatefulWidget {
  const CalculatorShell({super.key});

  @override
  State<CalculatorShell> createState() => _CalculatorShellState();
}

class _CalculatorShellState extends State<CalculatorShell>
    with TickerProviderStateMixin {

  late AnimationController _transitionController;
  late AnimationController _bottomSheetController;
  late Animation<Offset> _calculatorSlideAnimation;
  late Animation<Offset> _historySlideAnimation;

  // Add opacity animation for smooth handoff
  late Animation<double> _screenshotOpacityAnimation;

  NavigationState _currentState = NavigationState.calculator;
  bool _isTransitioning = false;
  bool _isCalculating = false;


  // Cached widgets for better performance
  Widget? _cachedCalculatorPage;
  Widget? _cachedHistoryPage;

  // Screenshot capture keys
  final GlobalKey _calculatorKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();

  // Screenshot images
  ui.Image? _calculatorScreenshot;
  ui.Image? _historyScreenshot;

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // History page slides in and out with its own timing
    _historySlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));

    // Calculator slides slowly throughout the entire animation duration
    _calculatorSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.05, 0.0),
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutSine),
    ));

    // Screenshot opacity for smooth handoff - fade out in the last 20% of animation
    _screenshotOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    ));

    // Listen for animation completion
    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() {
          _isTransitioning = false;
        });

        // Clear screenshots after transition to free memory
        if (status == AnimationStatus.dismissed) {
          _calculatorScreenshot?.dispose();
          _calculatorScreenshot = null;
        } else if (status == AnimationStatus.completed) {
          _historyScreenshot?.dispose();
          _historyScreenshot = null;
        }
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _bottomSheetController.dispose();
    _calculatorScreenshot?.dispose();
    _historyScreenshot?.dispose();
    super.dispose();
  }

  // Capture screenshot of a widget
  Future<ui.Image?> _captureScreenshot(GlobalKey key) async {
    try {
      // Ensure all frames are completed before capturing
      await WidgetsBinding.instance.endOfFrame;

      // Add a small delay to ensure rendering is complete
      await Future.delayed(const Duration(milliseconds: 150));

      final RenderObject? renderObject = key.currentContext?.findRenderObject();

      if (renderObject == null) {
        print('RenderObject not found for screenshot');
        return null;
      }

      if (renderObject is! RenderRepaintBoundary) {
        print('RenderObject is not a RenderRepaintBoundary');
        return null;
      }

      final RenderRepaintBoundary boundary = renderObject;

      // Multiple checks to ensure the boundary is ready
      int attempts = 0;
      const maxAttempts = 3;

      while (boundary.debugNeedsPaint && attempts < maxAttempts) {
        print('Boundary needs painting, attempt ${attempts + 1}');
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (boundary.debugNeedsPaint) {
        print('Boundary still needs painting after $maxAttempts attempts');
        return null;
      }

      // Additional safety check - ensure the boundary has a valid size
      final Size boundarySize = boundary.size;
      if (boundarySize.isEmpty) {
        print('Boundary has empty size: $boundarySize');
        return null;
      }

      print('Capturing screenshot with size: $boundarySize');

      // Capture the image with error handling
      ui.Image? image;
      try {
        image = await boundary.toImage(pixelRatio: 2.0); // Reduced pixel ratio for better performance
        print('Screenshot captured successfully');
        return image;
      } catch (imageError) {
        print('Error in toImage(): $imageError');
        return null;
      }

    } catch (e) {
      print('Error capturing screenshot: $e');
      return null;
    }
  }

  // Build screenshot widget with smooth opacity transition
  Widget _buildScreenshotWidget(ui.Image? image, {bool useOpacityTransition = false}) {
    if (image == null) {
      return Container(color: Theme.of(context).scaffoldBackgroundColor);
    }

    Widget screenshotWidget = Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: ScreenshotPainter(image),
        size: Size.infinite,
      ),
    );

    if (useOpacityTransition) {
      return AnimatedBuilder(
        animation: _screenshotOpacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _screenshotOpacityAnimation.value,
            child: screenshotWidget,
          );
        },
      );
    }

    return screenshotWidget;
  }

  // Build layered widget that smoothly transitions from screenshot to live widget
  Widget _buildLayeredTransition({
    required ui.Image? screenshot,
    required Widget liveWidget,
    required bool isTransitioning,
  }) {
    if (!isTransitioning || screenshot == null) {
      return liveWidget;
    }

    return Stack(
      children: [
        // Live widget underneath (always present)
        liveWidget,
        // Screenshot on top with opacity transition
        _buildScreenshotWidget(screenshot, useOpacityTransition: true),
      ],
    );
  }

  // Cache the actual calculator page
  Widget _buildCachedCalculatorPage() {
    _cachedCalculatorPage ??= RepaintBoundary(
      key: _calculatorKey,
      child: BasicCalculatorPage(
        onShowHistory: _showDrawer,
      ),
    );
    return _cachedCalculatorPage!;
  }

  // Build actual history page
  Widget _buildHistoryPage(BasicCalculatorViewModel viewModel) {
    return RepaintBoundary(
      key: _historyKey,
      child: HistoryPage(
        onClearHistory: () {
          viewModel.clearCalculationHistory();
          _cachedHistoryPage = null; // Clear cache when history changes
        },
        onBack: _backToCalculator,
      ),
    );
  }

  void _showDrawer() {
    if (_currentState == NavigationState.calculator) {
      setState(() {
        _currentState = NavigationState.drawer;
      });
      _bottomSheetController.forward();
    }
  }

  void _showHistoryFromDrawer() async {
    if (_currentState == NavigationState.drawer) {
      setState(() {
        _currentState = NavigationState.history;
        _isTransitioning = true;
      });

      // Start closing the drawer (takes 300ms)
      _bottomSheetController.reverse();

      // Delay slightly to allow the bottom sheet to move halfway (e.g., 150ms)
      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;

      // Capture screenshot of calculator after drawer is halfway closed
      _calculatorScreenshot = await _captureScreenshot(_calculatorKey);

      if (!mounted) return;

      // Start the history transition animation
      _transitionController.forward();
    }
  }


  void _hideDrawer() {
    if (_currentState == NavigationState.drawer) {
      _bottomSheetController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentState = NavigationState.calculator;
          });
        }
      });
    }
  }

  void _backToCalculator() async {
    if (_currentState == NavigationState.history) {
      // Capture history screenshot before transition
      _historyScreenshot = await _captureScreenshot(_historyKey);

      if (!mounted) return;

      // Start transition with screenshot
      setState(() {
        _isTransitioning = true;
      });

      // Start the reverse animation
      await _transitionController.reverse();

      if (!mounted) return;

      // Update state back to calculator
      setState(() {
        _currentState = NavigationState.calculator;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Calculator with layered transition
          AnimatedBuilder(
            animation: _transitionController,
            builder: (context, child) {
              return SlideTransition(
                position: _calculatorSlideAnimation,
                child: _buildLayeredTransition(
                  screenshot: _calculatorScreenshot,
                  liveWidget: _buildCachedCalculatorPage(),
                  isTransitioning: _isTransitioning,
                ),
              );
            },
          ),

          // Bottom Sheet Overlay (slides up from bottom)
          if (_currentState == NavigationState.drawer)
            GestureDetector(
              onTap: _hideDrawer,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _bottomSheetController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Consumer<BasicCalculatorViewModel>(
                      builder: (context, viewModel, child) {
                        return HistoryBottomSheet(
                          history: viewModel.history,
                          onClearHistory: () {
                            viewModel.clearCalculationHistory();
                            _hideDrawer();
                          },
                          onViewAllHistory: _showHistoryFromDrawer,
                          onClose: _hideDrawer,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          // History Page Overlay with layered transition
          if (_currentState == NavigationState.history)
            SlideTransition(
              position: _historySlideAnimation,
              child: Consumer<BasicCalculatorViewModel>(
                builder: (context, viewModel, child) {
                  return _buildLayeredTransition(
                    screenshot: _historyScreenshot,
                    liveWidget: _buildHistoryPage(viewModel),
                    isTransitioning: _isTransitioning,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Custom painter to draw the captured screenshot
class ScreenshotPainter extends CustomPainter {
  final ui.Image image;

  ScreenshotPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate how to fit the image to the canvas
    final double imageAspectRatio = image.width / image.height;
    final double canvasAspectRatio = size.width / size.height;

    late Rect srcRect;
    late Rect dstRect;

    if (imageAspectRatio > canvasAspectRatio) {
      // Image is wider than canvas
      final double visibleHeight = image.width / canvasAspectRatio;
      final double offsetY = (image.height - visibleHeight) / 2;
      srcRect = Rect.fromLTWH(0, offsetY, image.width.toDouble(), visibleHeight);
      dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    } else {
      // Image is taller than canvas
      final double visibleWidth = image.height * canvasAspectRatio;
      final double offsetX = (image.width - visibleWidth) / 2;
      srcRect = Rect.fromLTWH(offsetX, 0, visibleWidth, image.height.toDouble());
      dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    }

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! ScreenshotPainter || oldDelegate.image != image;
  }
}