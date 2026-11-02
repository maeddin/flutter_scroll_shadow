import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shadows let taps reach the content', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ScrollShadow(
          showStartShadow: false,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => taps++,
                child: Container(height: 2000, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Inside the hidden start shadow and the visible end shadow.
    await tester.tapAt(const Offset(200, 2));
    await tester.tapAt(const Offset(200, 798));
    expect(taps, 2);
  });
}
