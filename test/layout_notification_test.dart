import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:flutter_test/flutter_test.dart';

/// Without the [RangeMaintainingScrollPhysics] of the default behavior, new
/// content dimensions start a ballistic activity during layout.
class _BouncingScrollBehavior extends ScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}

Iterable<double> _shadowOpacities(WidgetTester tester) => tester
    .widgetList<AnimatedOpacity>(find.byWidgetPredicate(
        (widget) => widget is AnimatedOpacity && widget.child is Container))
    .map((shadow) => shadow.opacity);

void main() {
  testWidgets('Scroll notification during layout', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: ScrollConfiguration(
        behavior: const _BouncingScrollBehavior(),
        child: LayoutBuilder(
          builder: (context, constraints) => ScrollShadow(
            child: ListView(children: const [SizedBox(height: 700)]),
          ),
        ),
      ),
    ));
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable)).position;
    position.jumpTo(150);
    await tester.pumpAndSettle();
    expect(_shadowOpacities(tester), [1.0, 1.0]);

    // The content fits now, so the position springs back while laid out.
    tester.view.physicalSize = const Size(400, 800);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(_shadowOpacities(tester), [0.0, 0.0]);
  });
}
