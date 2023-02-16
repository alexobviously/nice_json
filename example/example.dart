import 'dart:convert';

import 'package:nice_json/nice_json.dart';

void main(List<String> args) {
  // String j = JsonEncoder.withIndent(' ').convert(data);
  String j = niceJson(data);
  print(j);
}

Map<String, dynamic> data = {
  'a': 'something',
  'b': [0, 1],
  'c': [
    [0, 1],
    [2, 3],
  ],
  'd': ['gau', 'saturn', 'yipyip', 'morgana'],
  'e': [
    'boy',
    ['violet', 'pumpkin'],
    ['gau', 'saturn', 'yipyip', 'morgana', 5555555],
  ],
  'f': {'x': 0, 'y': -1.5},
  'g': {
    'first_name': 'Alexander',
    'last_name': 'Baker',
  },
  'h': 'yololololololololololololdsofglsodfglosflgosflhosflhoslfghoslfgholsgfohsfgsfg',
};
