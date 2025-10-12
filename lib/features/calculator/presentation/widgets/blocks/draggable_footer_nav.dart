import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class DraggableFooterNav extends StatefulWidget {
  const DraggableFooterNav({super.key});

  @override
  State<DraggableFooterNav> createState() => _DraggableFooterNavState();
}

class _DraggableFooterNavState extends State<DraggableFooterNav> {
  static const double _collapsedPx = 56;
  static const double _expandedPx = 220;
  static const double _cornerRadius = 28;

  late DraggableScrollableController _dragController;

  double _currentExtent = 0.0; // fraction of screen height
  double _minExtent = 0.1; // computed at build
  double _maxExtent = 0.3; // computed at build
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _dragController = DraggableScrollableController();
    _dragController.addListener(_onDragChanged);
    // Remove auto-animate on first frame to avoid re-attach scenarios
    // and keep the sheet initially collapsed by initialChildSize.
  }

  @override
  void dispose() {
    _dragController.removeListener(_onDragChanged);
    _dragController.dispose();
    super.dispose();
  }

  void _onDragChanged() {
    setState(() {
      _currentExtent = _dragController.size;
      final progress = _progress;
      _expanded = progress > 0.2;
    });
  }

  double get _progress {
    if (_maxExtent <= _minExtent) return 0;
    final p = (_currentExtent - _minExtent) / (_maxExtent - _minExtent);
    return p.clamp(0, 1);
  }

  void _animateTo(double target, {bool haptic = true}) {
    if (haptic) {
      if (target == _maxExtent) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    _dragController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _expand() => _animateTo(_maxExtent);
  void _collapse() => _animateTo(_minExtent);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final size = MediaQuery.of(context).size;

    _minExtent = (_collapsedPx / size.height).clamp(0.05, 0.2);
    _maxExtent = (_expandedPx / size.height).clamp(_minExtent + 0.05, 0.5);

    final radius = BorderRadius.circular(_cornerRadius * (1 - 0.2 * _progress));

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          children: [
            // Scrim overlay
            if (_progress > 0)
              GestureDetector(
                onTap: _collapse,
                behavior: HitTestBehavior.opaque,
                child: AnimatedOpacity(
                  opacity: 0.5 * _progress,
                  duration: const Duration(milliseconds: 120),
                  child: Container(color: CupertinoColors.black),
                ),
              ),

            // Draggable glass footer
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: SizedBox(
                  height: size.height * _maxExtent,
                  child: DraggableScrollableSheet(
                    controller: _dragController,
                    initialChildSize: _minExtent,
                    minChildSize: _minExtent,
                    maxChildSize: _maxExtent,
                    snap: true,
                    snapSizes: [_minExtent, _maxExtent],
                    builder: (context, scrollController) {
                      return ClipRRect(
                        borderRadius: radius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 16 * (0.5 + _progress),
                            sigmaY: 16 * (0.5 + _progress),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: radius,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  CupertinoColors.white.withValues(
                                    alpha: 0.08 + 0.06 * _progress,
                                  ),
                                  AppColors.surface.withValues(alpha: 0.9),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.black.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.08,
                                ),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: CustomScrollView(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      // Grab handle
                                      Opacity(
                                        opacity: 0.6,
                                        child: Container(
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColors.muted,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      if (_progress < 0.2)
                                        _CollapsedStrip(tab: provider.navTab)
                                      else
                                        SizedBox(
                                          height: (_expandedPx - 40)
                                              .clamp(120, 600)
                                              .toDouble(),
                                          child: _ExpandedNavGrid(
                                            selected: provider.navTab,
                                            onSelect: (tab) {
                                              HapticFeedback.selectionClick();
                                              provider.setNavTab(tab);
                                              _collapse();
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Tap target to toggle when collapsed
            if (_progress <= 0.01)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: SizedBox(
                    height: _collapsedPx,
                    child: GestureDetector(
                      onTap: () => _expanded ? _collapse() : _expand(),
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedStrip extends StatelessWidget {
  final NavTab tab;
  const _CollapsedStrip({required this.tab});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _iconFor(tab);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textPrimary, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _ExpandedNavGrid extends StatelessWidget {
  final NavTab selected;
  final void Function(NavTab) onSelect;
  const _ExpandedNavGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const tileHeight = 56.0; // compact to avoid overflow
    final items = [
      NavTab.basic,
      NavTab.advanced,
      NavTab.scientific,
      NavTab.settings,
      NavTab.history,
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: tileHeight,
      ),
      itemBuilder: (context, i) {
        final t = items[i];
        return _NavButton(
          tab: t,
          selected: t == selected,
          onTap: () => onSelect(t),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _iconFor(tab);
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.20)
        : AppColors.inputBackground;
    final fg = selected ? AppColors.primary : AppColors.textPrimary;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: fg, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

(IconData, String) _iconFor(NavTab tab) {
  switch (tab) {
    case NavTab.basic:
      return (CupertinoIcons.circle_grid_3x3_fill, 'Básico');
    case NavTab.advanced:
      return (CupertinoIcons.bolt_fill, 'Avançado');
    case NavTab.scientific:
      return (CupertinoIcons.lab_flask_solid, 'Científica');
    case NavTab.settings:
      return (CupertinoIcons.gear_alt_fill, 'Config');
    case NavTab.history:
      return (CupertinoIcons.time_solid, 'Histórico');
  }
}
