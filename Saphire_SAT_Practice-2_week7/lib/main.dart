import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const SaphireApp());

/// Brand
const Color kBrandRed = Color(0xFFB80F0A);
const Color kBrandRedDark = Color(0xFF8E0B08);

class SaphireApp extends StatelessWidget {
  const SaphireApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: kBrandRed, brightness: Brightness.light);
    return MaterialApp(
      title: 'Saphire — SAT Practice',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Infinite carousel setup
  static const double _viewport = 0.92;
  static const double _cellSidePad = 6.0;
  late final PageController _cards;
  static const int _loopBase = 1000; // big enough to scroll “forever”
  late final int _startIndex;

  late final AnimationController _bg; // drives honeycomb drift

  final List<_Announcement> _ann = [
    const _Announcement(Icons.local_fire_department_outlined, 'Streaks launch next week', 'Keep the daily practice alive.'),
    const _Announcement(Icons.auto_stories_outlined, 'New Writing set', 'Parallel structure + misplaced modifiers.'),
    const _Announcement(Icons.lightbulb_outline, 'Tip: Estimation', 'Save time by bounding answers fast.'),
  ];

  final List<_ModeCardData> _cardsData = const [
    _ModeCardData(
      'Timed Mode',
      'Beat the clock and rack up correct answers.',
      Icons.timer_outlined,
      _ModeCta('Start', _Cta.primary),
      _ModeCta('Details', _Cta.secondary),
      tag: 'LIVE',
    ),
    _ModeCardData('Practice Sets', 'Pick a topic or difficulty and grind smart.', Icons.view_list_outlined,
        _ModeCta('Coming soon', _Cta.disabled), _ModeCta('Details', _Cta.secondary)),
    _ModeCardData('Adaptive Drill', 'Difficulty adapts to your performance.', Icons.auto_graph_outlined,
        _ModeCta('Coming soon', _Cta.disabled), _ModeCta('Details', _Cta.secondary)),
    _ModeCardData('Full-Length Test', 'Simulate a real Digital SAT.', Icons.description_outlined,
        _ModeCta('Coming soon', _Cta.disabled), _ModeCta('Details', _Cta.secondary)),
  ];

  @override
  void initState() {
    super.initState();
    _startIndex = _loopBase * _cardsData.length;   // maps to item 0, so the left neighbor is the last item
    _cards = PageController(
      viewportFraction: _viewport,
      initialPage: _startIndex,
    );
    _bg = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }


  @override
  void dispose() {
    _cards.dispose();
    _bg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).size.width >= 900 ? 28.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text('Pick a mode'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline))],
      ),
      body: Stack(
        children: [
          // Animated flat-top hex honeycomb backdrop (bigger hex, thicker lines)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bg,
              builder: (_, __) => CustomPaint(
                painter: _FlatTopHoneycombPainter(
                  progress: _bg.value,
                  base: kBrandRed,
                  baseDark: kBrandRedDark,
                  hexRadius: 18,          // ⟵ bigger hexagons
                  strokeWidth: 1.4,       // ⟵ thicker lines
                  lineOpacity: 0.12,      // a bit more visible
                ),
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Column(
              children: [
                if (_ann.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: _ann.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _AnnouncementPill(
                        data: _ann[i],
                        onClose: () => setState(() => _ann.removeAt(i)),
                      ),
                    ),
                  )
                else
                  SizedBox(height: pad),

                // Carousel
                Expanded(
  child: LayoutBuilder(
    builder: (context, c) {
      // how much horizontal space the viewport doesn't use
      final double side = (c.maxWidth * (1 - _viewport)) / 2;

      return Padding(
        // this centers the visible viewport so the current page sits dead-center
        padding: EdgeInsets.symmetric(horizontal: side),
        child: PageView.builder(
          controller: _cards,
          padEnds: false,                          // no extra gutter; we do our own padding
          allowImplicitScrolling: true,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          itemBuilder: (context, rawIndex) {
            final data = _cardsData[rawIndex % _cardsData.length];

            return AnimatedBuilder(
              animation: _cards,
              builder: (_, child) {
                final page = _cards.hasClients && _cards.page != null
                    ? _cards.page!
                    : _startIndex.toDouble();
                final d = (rawIndex - page).abs();
                final scale = (1 - d * .10).clamp(.9, 1.0);
                final lift = (d * 18).clamp(0.0, 18.0);

                return Transform.translate(
                  offset: Offset(0, lift),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _cellSidePad),
                child: _ModeCard(
                  data: data,
                  onPrimary: () => _toast(context, '${data.title} – start'),
                  onSecondary: () => _info(context, data.title),
                ),
              ),
            );
          },
        ),
      );
    },
  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kBrandRed, behavior: SnackBarBehavior.floating),
    );
  }

  void _info(BuildContext ctx, String name) {
    showModalBottomSheet(
      context: ctx,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(name, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Feature details and quick tips will live here.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

/// ───────────────────────────────────────────────────────────────
/// Announcements
class _Announcement {
  final IconData icon;
  final String title;
  final String body;
  const _Announcement(this.icon, this.title, this.body);
}

class _AnnouncementPill extends StatelessWidget {
  final _Announcement data;
  final VoidCallback onClose;
  const _AnnouncementPill({required this.data, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.2);
    final pill = MediaQuery.withClampedTextScaling(
      maxScaleFactor: textScale,
      child: Material(
        color: Colors.white.withOpacity(.94),
        shape: StadiumBorder(side: BorderSide(color: Colors.black.withOpacity(.07))),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(data.icon, size: 18, color: Colors.black.withOpacity(.70)),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                    child: Text(
                      '${data.title} — ${data.body}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              InkResponse(onTap: onClose, radius: 18, child: const Icon(Icons.close, size: 18)),
            ]),
          ),
        ),
      ),
    );
    return pill;
  }
}

/// ───────────────────────────────────────────────────────────────
/// Mode cards (tall playing-card ratio + elliptical drop shadow)
enum _Cta { primary, secondary, disabled }

class _ModeCta {
  final String label;
  final _Cta kind;
  const _ModeCta(this.label, this.kind);
}

class _ModeCardData {
  final String title, blurb;
  final IconData icon;
  final _ModeCta primary, secondary;
  final String? tag;
  const _ModeCardData(this.title, this.blurb, this.icon, this.primary, this.secondary, {this.tag});
}

class _ModeCard extends StatelessWidget {
  final _ModeCardData data;
  final VoidCallback onPrimary, onSecondary;
  const _ModeCard({required this.data, required this.onPrimary, required this.onSecondary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double cardW = math.min(MediaQuery.of(context).size.width * .72, 460);
    final double cardH = cardW * 1.28; // taller ratio

    return Center(
      child: SizedBox(
        width: cardW,
        height: cardH + 24,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Elliptical drop shadow
            Positioned(
              bottom: 6,
              left: 18,
              right: 18,
              child: Container(
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 26, spreadRadius: -6)],
                ),
              ),
            ),
            // Card
            Positioned(
              top: 28,
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 28, offset: const Offset(0, 14)),
                      BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 2, spreadRadius: 1),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 40, 22, 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(data.title, style: theme.textTheme.titleLarge)),
                        if (data.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: ShapeDecoration(
                              shape: StadiumBorder(side: BorderSide(color: kBrandRed.withOpacity(.35))),
                              color: kBrandRed.withOpacity(.06),
                            ),
                            child: Text(data.tag!, style: TextStyle(color: kBrandRedDark, fontWeight: FontWeight.w700)),
                          ),
                      ]),
                      const SizedBox(height: 8),
                      Text(data.blurb, style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black.withOpacity(.68))),
                      const Spacer(),
                      Row(children: [
                        _ctaBtn(data.primary, onPrimary),
                        const SizedBox(width: 10),
                        _ctaBtn(data.secondary, onSecondary),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
            // Floating circle badge
            Positioned(
              top: 0,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.96),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 14, offset: const Offset(0, 8))],
                ),
                child: Center(child: Icon(data.icon, color: kBrandRedDark, size: 30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaBtn(_ModeCta cta, VoidCallback onTap) {
    switch (cta.kind) {
      case _Cta.primary:
        return FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.play_arrow, size: 18),
          style: FilledButton.styleFrom(backgroundColor: kBrandRed, foregroundColor: Colors.white, shape: const StadiumBorder()),
          label: Text(cta.label),
        );
      case _Cta.secondary:
        return OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.info_outline, size: 18),
          style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
          label: Text(cta.label),
        );
      case _Cta.disabled:
        return FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.lock_clock, size: 18),
          style: FilledButton.styleFrom(
            foregroundColor: Colors.black.withOpacity(.75),
            backgroundColor: Colors.black.withOpacity(.06),
            shape: const StadiumBorder(),
          ),
          label: Text(cta.label),
        );
    }
  }
}

class _Dots extends StatelessWidget {
  final PageController controller;
  final int count;
  final int startIndex;
  const _Dots({required this.controller, required this.count, required this.startIndex});

  @override
  Widget build(BuildContext context) {
    final pageVal = controller.hasClients && controller.page != null
        ? controller.page!
        : startIndex.toDouble();

    // Reduce to 0..count range for circular math
    double p = pageVal % count;
    if (p < 0) p += count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final diff = (p - i).abs();
        final wrap = math.min(diff, count - diff); // circular distance
        final t = (1.0 - wrap).clamp(0.0, 1.0);
        final w = 10.0 + 16.0 * t;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: w,
          decoration: BoxDecoration(
            color: Color.lerp(Colors.white.withOpacity(.55), Colors.white, t)!.withOpacity(.9),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.black.withOpacity(.15)),
          ),
        );
      }),
    );
  }
}

/// ───────────────────────────────────────────────────────────────
/// Flat-top honeycomb painter (bigger + thicker, with drift)
class _FlatTopHoneycombPainter extends CustomPainter {
  final double progress; // 0..1 loop
  final Color base, baseDark;
  final double hexRadius;
  final double strokeWidth;
  final double lineOpacity;

  _FlatTopHoneycombPainter({
    required this.progress,
    required this.base,
    required this.baseDark,
    this.hexRadius = 18,      // bigger hex
    this.strokeWidth = 1.4,   // thicker lines
    this.lineOpacity = 0.12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Vertical gradient
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [base, baseDark],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // Flat-top hex geometry
    final double r = hexRadius;
    final double h = math.sqrt(3) * r; // height
    final double stepX = 1.5 * r;      // center-to-center horizontal
    final double stepY = h;            // center-to-center vertical

    // Noticeable drift
    final double dx = (progress * stepX * 2) % stepX;
    final double dy = (progress * stepY * 0.8) % stepY;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withOpacity(lineOpacity)
      ..isAntiAlias = true;

    int col = 0;
    for (double x = -stepX * 2 + dx; x < size.width + stepX * 2; x += stepX, col++) {
      final double yOffset = ((col & 1) == 1) ? stepY / 2 : 0.0;
      for (double y = -stepY * 2 + yOffset + dy; y < size.height + stepY * 2; y += stepY) {
        _drawFlatTopHex(canvas, x, y, r, stroke);
      }
    }

    // Soft vignette to focus center
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(.14)],
        stops: const [0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  void _drawFlatTopHex(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path();
    for (int k = 0; k < 6; k++) {
      final double angle = (math.pi / 180.0) * (60.0 * k); // 0°,60°,…,300°
      final double px = cx + r * math.cos(angle);
      final double py = cy + r * math.sin(angle);
      if (k == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _FlatTopHoneycombPainter old) =>
      old.progress != progress ||
      old.base != base ||
      old.baseDark != baseDark ||
      old.hexRadius != hexRadius ||
      old.strokeWidth != strokeWidth ||
      old.lineOpacity != lineOpacity;
}
