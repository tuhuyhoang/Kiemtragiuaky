import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tu_huy_hoang/main.dart';

void main() {
  setUp(() {
    // Mock SharedPreferences (rỗng) để AuthGate -> Login
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots and shows Login screen for unauthenticated user',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NewsApp());
    // Đợi AuthGate khởi tạo (Future bootstrap) và chuyển sang Login
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Khi mới cài, chưa có user nào → màn hình Login phải hiện
    expect(find.text('News App'), findsOneWidget);
    expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  });
}
