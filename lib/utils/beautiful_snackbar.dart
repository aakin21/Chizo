import 'package:flutter/material.dart';

class BeautifulSnackBar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message: message,
      type: SnackBarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context,
      message: message,
      type: SnackBarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message: message,
      type: SnackBarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message: message,
      type: SnackBarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    String? actionLabel,
    VoidCallback? onAction,
    required Duration duration,
  }) {
    // Remove any existing snackbar
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _BeautifulSnackBarContent(
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

enum SnackBarType { success, error, info, warning }

class _BeautifulSnackBarContent extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _BeautifulSnackBarContent({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_BeautifulSnackBarContent> createState() => _BeautifulSnackBarContentState();
}

class _BeautifulSnackBarContentState extends State<_BeautifulSnackBarContent>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SnackBarType.success:
        return const Color(0xFF4CAF50);
      case SnackBarType.error:
        return const Color(0xFFF44336);
      case SnackBarType.warning:
        return const Color(0xFFFF9800);
      case SnackBarType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color _getLightBackgroundColor() {
    switch (widget.type) {
      case SnackBarType.success:
        return const Color(0xFFE8F5E8);
      case SnackBarType.error:
        return const Color(0xFFFFEBEE);
      case SnackBarType.warning:
        return const Color(0xFFFFF3E0);
      case SnackBarType.info:
        return const Color(0xFFE3F2FD);
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case SnackBarType.success:
        return const Color(0xFF2E7D32);
      case SnackBarType.error:
        return const Color(0xFFC62828);
      case SnackBarType.warning:
        return const Color(0xFFE65100);
      case SnackBarType.info:
        return const Color(0xFF1565C0);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: _getLightBackgroundColor(),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBackgroundColor().withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getBackgroundColor().withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onAction,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon with animated background
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getBackgroundColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _getBackgroundColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Message
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                    
                    // Action button or close
                    if (widget.actionLabel != null && widget.onAction != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: TextButton(
                          onPressed: widget.onAction,
                          style: TextButton.styleFrom(
                            backgroundColor: _getBackgroundColor(),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                        icon: Icon(
                          Icons.close,
                          color: _getTextColor().withValues(alpha: 0.6),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
