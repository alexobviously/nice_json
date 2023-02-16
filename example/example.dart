import 'package:nice_json/nice_json.dart';

void main(List<String> args) {
  String json = niceJson(data, alwaysExpandKeys: ['kittens', 'location2']);
  print(json);
}

Map<String, dynamic> data = {
  'a': [0, 1],
  'b': [
    [0, 1],
    [2, 3],
  ],
  'person': {'first_name': 'Alexander', 'last_name': 'Baker'},
  'cats': ['gau', 'saturn', 'yipyip', 'morgana'],
  'catscatscatscatscatscatscatscatscatscatscatscats': ['gau', 'saturn', 'yipyip', 'morgana'],
  'kittens': ['boy', 'violet', 'pumpkin'],
  'mixedList': [
    'boy',
    ['violet', 'pumpkin'],
    [1111111, 2222222, 3333333, 4444444, 5555555],
    {'name': 'saturn', 'age': 3, 'species': 'cat'},
  ],
  'location': {'x': 0, 'y': -1.5},
  'location2': {'x': -6.1, 'y': 2},
  'book': 'a really really really really really long string will obviously not get wrapped at all',
};
