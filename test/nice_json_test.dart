import 'dart:convert';

import 'package:nice_json/nice_json.dart';
import 'package:test/test.dart';

void main() {
  group('string escaping', () {
    test('escapes quotes, backslashes, and control characters', () {
      final data = {
        'quote': 'say "hi"',
        'slash': r'c:\temp',
        'newline': 'line1\nline2',
        'tab': 'a\tb',
        'control': '\u0001',
      };

      expect(
        niceJson(data),
        '{\n'
        ' "quote": ${jsonEncode(data['quote'])},\n'
        ' "slash": ${jsonEncode(data['slash'])},\n'
        ' "newline": ${jsonEncode(data['newline'])},\n'
        ' "tab": ${jsonEncode(data['tab'])},\n'
        ' "control": ${jsonEncode(data['control'])}\n'
        '}',
      );
    });
  });
}
