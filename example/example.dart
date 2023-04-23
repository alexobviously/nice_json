import 'package:nice_json/nice_json.dart';

void main(List<String> args) {
  Map<String, dynamic> data = {
    'a': [0, 1],
    'b': [
      [0, 1],
      [2, 3],
    ],
    'person': {'first_name': 'Alexander', 'last_name': 'Baker'},
    'cats': ['gau', 'saturn', 'yipyip', 'morgana'],
    'catscatscatscatscatscatscatscatscatscatscatscats': [
      'gau',
      'saturn',
      'yipyip',
      'morgana'
    ],
    'kittens': ['boy', 'violet', 'pumpkin'],
    'mixedList': [
      'boy',
      ['violet', 'pumpkin'],
      [1111111, 2222222, 3333333, 4444444, 5555555],
      {'name': 'saturn', 'age': 3, 'species': 'cat'},
    ],
    'locations': {
      'loc1': {'x': 0, 'y': -1.5},
      'loc2': {'x': -6.1, 'y': 2},
    },
    'book': 'a really really really really really long'
        ' string will obviously not get wrapped at all',
    'people': [
      {
        'name': 'Alice',
        'numbers': [1, 2, 3],
        'friends': ['Bob', 'Charlie'],
      },
      {
        'name': 'Bob',
        'numbers': [4, 5, 6],
        'friends': ['Alice', 'Charlie'],
      },
    ],
  };

  String json = niceJson(data,
      alwaysExpandKeys: ['kittens', 'locations.loc2', 'people.*.friends']);
  print(json);
}
