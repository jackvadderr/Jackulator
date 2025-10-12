import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';

class ExpandableNavFooter extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  const ExpandableNavFooter({
    super.key,
    this.selectedIndex = 0,
    required this.onTabSelected,
  });

  @override
  State<ExpandableNavFooter> createState() => _ExpandableNavFooterState();
}

class _ExpandableNavFooterState extends State<ExpandableNavFooter>
    with SingleTickerProviderStateMixin {
  static const double _collapsedHeight = 36.0;
  static const double _expandedHeight = 48.0;
  static const double _pillWidthFraction = 0.28; // ainda mais discreto

  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _t; // 0..1

  // Indices do enum NavTab: 0=basic,1=advanced,2=scientific,3=settings,4=history
  static const int _idxBasic = 0;
  static const int _idxAdvanced = 1;
  static const int _idxScientific = 2;
  static const int _idxSettings = 3;
  static const int _idxHistory = 4;

  final List<_NavItem> _centerItems = const [
    _NavItem(
      index: _idxBasic,
      icon: CupertinoIcons.circle_grid_3x3_fill,
      label: 'Básico',
    ),
    _NavItem(
      index: _idxAdvanced,
      icon: CupertinoIcons.bolt_fill,
      label: 'Avançado',
    ),
    _NavItem(
      index: _idxScientific,
      icon: CupertinoIcons.lab_flask_solid,
      label: 'Científica',
    ),
  ];
  final _NavItem _leftFixed = const _NavItem(
    index: _idxHistory,
    icon: CupertinoIcons.time_solid,
    label: 'Histórico',
  );
  final _NavItem _rightFixed = const _NavItem(
    index: _idxSettings,
    icon: CupertinoIcons.gear_alt_fill,
    label: 'Config',
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    // Carrega persistência do estado expandido
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final exp = prefs.getBool('footer_expanded') ?? false;
        if (exp) {
          setState(() => _expanded = true);
          _controller.value = 1.0;
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _persistExpanded(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('footer_expanded', value);
    } catch (_) {}
  }

  void _expand() {
    if (_expanded) return;
    HapticFeedback.lightImpact();
    setState(() => _expanded = true);
    _persistExpanded(true);
    _controller.forward();
  }

  void _collapse() {
    if (!_expanded) return;
    HapticFeedback.selectionClick();
    setState(() => _expanded = false);
    _persistExpanded(false);
    _controller.reverse();
  }

  void _toggle() => _expanded ? _collapse() : _expand();

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    final dy = d.primaryDelta ?? 0;
    if (!_expanded && dy < -8) _expand();
    if (_expanded && dy > 8) _collapse();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final collapsedWidth = (screenWidth * _pillWidthFraction).clamp(
      96.0,
      screenWidth - 24.0,
    );
    final expandedWidth = (screenWidth - 24.0).clamp(96.0, screenWidth);

    // Cores base (sem depender de Material Theme)
    final primary = AppColors.primary;
    final fgMuted = AppColors.textPrimary.withValues(alpha: 0.7);

    return Stack(
      children: [
        // Scrim com dismiss por toque fora
        if (_expanded)
          GestureDetector(
            onTap: _collapse,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _t,
              builder: (context, _) => Opacity(
                opacity: _t.value * 0.45,
                child: Container(color: CupertinoColors.black),
              ),
            ),
          ),

        // Footer pílula central
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: _toggle,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              child: AnimatedBuilder(
                animation: _t,
                builder: (context, _) {
                  final t = _t.value;
                  final radius = 24 - 10 * t;
                  final width = lerpDouble(collapsedWidth, expandedWidth, t)!;
                  const footerHeight = _collapsedHeight; // altura constante

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 6 + 6 * t,
                          sigmaY: 6 + 6 * t,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOutCubic,
                          width: width,
                          height: footerHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CupertinoColors.white.withValues(
                                  alpha: 0.08 + 0.04 * t,
                                ),
                                primary.withValues(alpha: 0.10 * t),
                              ],
                            ),
                            border: Border.all(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.10,
                              ),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(radius),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withValues(
                                  alpha: 0.12 + 0.08 * t,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: t < 0.2
                              ? Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 160),
                                    child: Icon(
                                      _iconForIndex(widget.selectedIndex),
                                      key: ValueKey(widget.selectedIndex),
                                      color: primary,
                                      size: 16,
                                    ),
                                  ),
                                )
                              : _ExpandedCarousel(
                                  leftFixed: _leftFixed,
                                  rightFixed: _rightFixed,
                                  centerItems: _centerItems,
                                  selectedIndex: widget.selectedIndex,
                                  onSelect: (i) {
                                    HapticFeedback.selectionClick();
                                    widget.onTabSelected(i);
                                    // não colapsa após seleção
                                  },
                                  primary: primary,
                                  muted: fgMuted,
                                  height: footerHeight,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

IconData _iconForIndex(int idx) {
  switch (idx) {
    case 0:
      return CupertinoIcons.circle_grid_3x3_fill;
    case 1:
      return CupertinoIcons.bolt_fill;
    case 2:
      return CupertinoIcons.lab_flask_solid;
    case 3:
      return CupertinoIcons.gear_alt_fill;
    case 4:
      return CupertinoIcons.time_solid;
    default:
      return CupertinoIcons.circle;
  }
}

class _ExpandedCarousel extends StatefulWidget {
  final _NavItem leftFixed;
  final _NavItem rightFixed;
  final List<_NavItem> centerItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color primary;
  final Color muted;
  final double height;

  const _ExpandedCarousel({
    required this.leftFixed,
    required this.rightFixed,
    required this.centerItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.primary,
    required this.muted,
    required this.height,
    super.key,
  });

  @override
  State<_ExpandedCarousel> createState() => _ExpandedCarouselState();
}

class _ExpandedCarouselState extends State<_ExpandedCarousel> {
  late int _page;
  PageController? _pc;
  static const double _itemWidth = 112.0;

  int _centerIndexForSelected() {
    final i = widget.centerItems.indexWhere(
      (e) => e.index == widget.selectedIndex,
    );
    return i < 0 ? 0 : i;
  }

  int _pageForSelected() => _centerIndexForSelected() ~/ 2;

  void _ensureController(double viewportFraction) {
    final desiredVf = viewportFraction;
    if (_pc == null || (_pc!.viewportFraction - desiredVf).abs() > 0.001) {
      final initial = _pc?.page?.round() ?? _pageForSelected();
      _pc = PageController(initialPage: initial, viewportFraction: desiredVf);
      _page = initial;
    }
  }

  @override
  void didUpdateWidget(covariant _ExpandedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final desiredPage = _pageForSelected();
    final isCenter = widget.centerItems.any(
      (e) => e.index == widget.selectedIndex,
    );
    if (isCenter && desiredPage != _page && _pc != null) {
      _pc!.animateToPage(
        desiredPage,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      _page = desiredPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          _CarouselButton(
            item: widget.leftFixed,
            selected: widget.selectedIndex == widget.leftFixed.index,
            onSelect: widget.onSelect,
            primary: widget.primary,
            muted: widget.muted,
            width: 64,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final vw = constraints.maxWidth;
                final vf = 0.92; // levemente menor para suavizar o snap
                _ensureController(vf);

                final pageWidth = vw * vf;
                final pages = (widget.centerItems.length + 1) ~/ 2;
                final double perItemWidth =
                    (pageWidth - 2) / 2; // 2 itens + gap

                return PageView.builder(
                  controller: _pc,
                  padEnds: true,
                  physics: const PageScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  allowImplicitScrolling: true,
                  onPageChanged: (i) {
                    _page = i; // não altera a seleção ao rolar
                  },
                  itemCount: pages,
                  itemBuilder: (context, i) {
                    final i0 = i * 2;
                    final i1 = i0 + 1;
                    final item0 = widget.centerItems[i0];
                    final item1 = (i1 < widget.centerItems.length)
                        ? widget.centerItems[i1]
                        : null;
                    final sel0 = widget.selectedIndex == item0.index;
                    final sel1 =
                        item1 != null && widget.selectedIndex == item1.index;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CarouselButton(
                          item: item0,
                          selected: sel0,
                          onSelect: widget.onSelect,
                          primary: widget.primary,
                          muted: widget.muted,
                          width: perItemWidth,
                        ),
                        const SizedBox(width: 2),
                        if (item1 != null)
                          _CarouselButton(
                            item: item1,
                            selected: sel1,
                            onSelect: widget.onSelect,
                            primary: widget.primary,
                            muted: widget.muted,
                            width: perItemWidth,
                          )
                        else
                          SizedBox(width: perItemWidth),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 2),
          _CarouselButton(
            item: widget.rightFixed,
            selected: widget.selectedIndex == widget.rightFixed.index,
            onSelect: widget.onSelect,
            primary: widget.primary,
            muted: widget.muted,
            width: 64,
          ),
        ],
      ),
    );
  }
}

class _CarouselButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final ValueChanged<int> onSelect;
  final Color primary;
  final Color muted;
  final double width;

  const _CarouselButton({
    required this.item,
    required this.selected,
    required this.onSelect,
    required this.primary,
    required this.muted,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        borderRadius: BorderRadius.circular(16),
        onPressed: () => onSelect(item.index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 16, color: selected ? primary : muted),
            const SizedBox(height: 1),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: selected ? primary : muted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final int index; // NavTab index
  final IconData icon;
  final String label;
  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
  });
}
