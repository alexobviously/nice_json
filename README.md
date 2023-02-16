# Nice JSON!

This is a simple little library for printing human-readable JSON that looks a little bit nicer than the stuff you get out of the default encoder.

## The Problem
---
The behaviour of the standard json encoder can often lead to sprawling files full of newlines and single integers on lines, for example:

```dart
final data = {
  'a': [0, 1],
  'b': [
    [0, 1],
    [2, 3]
  ]
};
String json = JsonEncoder.withIndent(' ').convert(data);
print(json);
```

Gives you something like this:

```json
{
 "a": [
  0,
  1
 ],
 "b": [
  [
   0,
   1
  ],
  [
   2,
   3
  ]
 ]
}
```

This is obviously valid json, but not much fun to read.

## The Solution
---
How about this instead:

```dart
String json = niceJson(data);
print(json);
```
->
```json
{
 "a": [0, 1],
 "b": [[0, 1], [2, 3]]
}
```

Nice JSON!

## Features & Parameters
---
### Max Content Length & Max Line Length
These are pretty straightforward.
`maxContentLength` defines the maximum length a single entry's value can be.
`maxLineLength` defines the maximum length an entire line can be, including indent and key.
If either of these is exceeded when building the compressed encoding of a value, it will be expanded.

### Minimum Depth
`minDepth` is the minimum depth that must be reached before values start getting compressed. By default, this is 1, meaning the whole JSON representation cannot simply be a single line, but anything after the root level is compressed.
If you set this to 2, for example, you can achieve this behaviour:

```dart
final data = {
  'a': {'hello': 'world'},
  'foo': {'bar': 1, 'baz': 2},
  'b': [
    [0, 1],
    2,
    3,
  ],
};
String json = niceJson(data, minDepth: 2);
```
->
```json
{
 "a": {
  "hello": "world"
 },
 "foo": {
  "bar": 1,
  "baz": 2
 },
 "b": [
  [0, 1],
  2,
  3
 ]
}
```

Instead of what you would get with `minDepth: 1`:
```json
{
 "a": {"hello": "world"},
 "foo": {"bar": 1, "baz": 2},
 "b": [[0, 1], 2, 3]
}
```

### Always Expand Specific Keys
`alwaysExpandKeys` takes a `List<String>` of key names that should always have their values expanded, regardless of length.

e.g.:
```dart
final data = {
  'a': {'hello': 'world'},
  'b': {'foo': 'bar'},
};
String json = niceJson(data, alwaysExpandKeys: ['b']);
```
->
```json
{
 "a": {"hello": "world"},
 "b": {
  "foo": "bar"
 }
}
```

Instead of:
```json
{
 "a": {"hello": "world"},
 "b": {"foo": "bar"}
}
```

## Upcoming Features
---
### Maximum Nesting

A desirable feature would be to only allow a certain amount of nesting on a single line, for example:
```json
{
 "a": [0, 1],
 "b": [
  [0, 1],
  [2, 3]
 ]
}
```

This will probably be added after Dart 3.0 because it would be nice to do this sort of thing with records.

### Nested Expansion Keys

It would be nice to be able to specify `alwaysExpandKeys` that match a nested key name, like `a.hello`, which would only match the `hello` key under `a`, but not under another parent key. Wildcards or regex could also be allowed.