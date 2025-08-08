
import 'package:flutter/material.dart';

import 'card_data.dart';

class HomeScreenCard extends StatefulWidget {
  const HomeScreenCard({Key? key, required this.cardData}) : super(key: key);

  final CardData cardData;

  @override
  State<HomeScreenCard> createState() => _HomeScreenCardState();
}

class _HomeScreenCardState extends State<HomeScreenCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void navigateToScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => widget.cardData.widget),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: navigateToScreen,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Main shadow
                    BoxShadow(
                      color: _isPressed 
                          ? Colors.black.withOpacity(0.10)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: _isPressed ? 8 : 16,
                      offset: _isPressed 
                          ? const Offset(0, 2)
                          : const Offset(0, 6),
                      spreadRadius: _isPressed ? 0 : 2,
                    ),
                    // Secondary shadow for depth
                    BoxShadow(
                      color: _isPressed 
                          ? Colors.black.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: _isPressed ? 4 : 8,
                      offset: _isPressed 
                          ? const Offset(0, 1)
                          : const Offset(0, 2),
                    ),
                    // Highlight shadow (top)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: navigateToScreen,
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Container
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor.withOpacity(0.1),
                                  Theme.of(context).primaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.cardData.icon,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Text
                          Text(
                            widget.cardData.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtle indicator
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor.withOpacity(0.3),
                                  Theme.of(context).primaryColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
