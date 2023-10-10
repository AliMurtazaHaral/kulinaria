import 'package:flutter/material.dart';

class LoadingOverlay {
  late OverlayEntry _overlayEntry;
  late OverlayState _overlayState;
  bool _isVisible = false;

  LoadingOverlay(BuildContext context) {
    _overlayState = Overlay.of(context)!;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.orange.withOpacity(0.5),
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      _overlayState.insert(_overlayEntry);
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      _overlayEntry.remove();
    }
  }
}
