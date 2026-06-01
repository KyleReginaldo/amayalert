import 'package:amayalert/core/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bento-style media grid. Tap any image to open the full-screen viewer.
///
/// 1 → full-width single
/// 2 → two equal columns
/// 3 → left half tall | right half split into top + bottom
/// 4 → 2×2 grid
/// 5+→ 2×2 grid, 4th tile shows "+N" overlay
class PostMediaGrid extends StatelessWidget {
  final List<String> urls;

  const PostMediaGrid({super.key, required this.urls});

  void _open(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) =>
            _ImageViewer(urls: urls, initialIndex: index),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  // Wraps a tile with a translucent tap — doesn't swallow scroll gestures
  Widget _tap(Widget child, BuildContext context, int index) =>
      GestureDetector(
        onTap: () => _open(context, index),
        behavior: HitTestBehavior.translucent,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final n = urls.length;
    const gap = 2.0;
    const h = 240.0;

    if (n == 0) return const SizedBox.shrink();

    if (n == 1) {
      return _tap(_img(urls[0], double.infinity, h), context, 0);
    }

    if (n == 2) {
      return Row(
        children: [
          Expanded(child: _tap(_img(urls[0], double.infinity, h), context, 0)),
          const SizedBox(width: gap),
          Expanded(child: _tap(_img(urls[1], double.infinity, h), context, 1)),
        ],
      );
    }

    if (n == 3) {
      return Row(
        children: [
          Expanded(
              child: _tap(_img(urls[0], double.infinity, h), context, 0)),
          const SizedBox(width: gap),
          Expanded(
            child: Column(
              children: [
                _tap(_img(urls[1], double.infinity, (h - gap) / 2), context, 1),
                const SizedBox(height: gap),
                _tap(_img(urls[2], double.infinity, (h - gap) / 2), context, 2),
              ],
            ),
          ),
        ],
      );
    }

    // 4+
    final extra = n - 4;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _tap(
                  _img(urls[0], double.infinity, (h - gap) / 2), context, 0),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: _tap(
                  _img(urls[1], double.infinity, (h - gap) / 2), context, 1),
            ),
          ],
        ),
        const SizedBox(height: gap),
        Row(
          children: [
            Expanded(
              child: _tap(
                  _img(urls[2], double.infinity, (h - gap) / 2), context, 2),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: _tap(
                Stack(
                  children: [
                    _img(urls[3], double.infinity, (h - gap) / 2),
                    if (extra > 0)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: Text(
                            '+$extra',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                context,
                3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _img(String url, double width, double height) => CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            Container(height: height, color: AppColors.gray200),
        errorWidget: (_, _, _) => Container(
          height: height,
          color: AppColors.gray100,
          child: const Icon(LucideIcons.imageOff,
              color: AppColors.gray400, size: 28),
        ),
      );
}

// ── Full-screen image viewer ───────────────────────────────────────────────────

class _ImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const _ImageViewer({required this.urls, required this.initialIndex});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _ZoomablePage(url: widget.urls[i]),
          ),

          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x,
                            color: Colors.white, size: 22),
                      ),
                      const Spacer(),
                      if (widget.urls.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_current + 1} / ${widget.urls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dot indicator
          if (widget.urls.length > 1)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.urls.length, (i) {
                      final active = i == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Single zoomable image page ────────────────────────────────────────────────

class _ZoomablePage extends StatefulWidget {
  final String url;
  const _ZoomablePage({required this.url});

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage> {
  final _controller = TransformationController();
  bool _zoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTap(TapDownDetails details) {
    if (_zoomed) {
      _controller.value = Matrix4.identity();
    } else {
      final pos = details.localPosition;
      _controller.value = Matrix4.identity()
        ..translateByDouble(-pos.dx * 1.5, -pos.dy * 1.5, 0, 1)
        ..scaleByDouble(2.5, 2.5, 1, 1);
    }
    setState(() => _zoomed = !_zoomed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTap,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 0.8,
        maxScale: 5.0,
        onInteractionEnd: (_) {
          final scale = _controller.value.getMaxScaleOnAxis();
          setState(() => _zoomed = scale > 1.05);
        },
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(
                  color: Colors.white70, strokeWidth: 2),
            ),
            errorWidget: (_, _, _) => const Icon(
              LucideIcons.imageOff,
              color: Colors.white38,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
