import 'dart:convert';
import 'dart:math';

/// Encodes [data] as nicely formatted human-readable JSON.
/// [indent] is the indent character added to the start of each line. By default,
/// this is a single space, but other good options are two spaces or a tab ('\t').
/// [maxContentLength] is the maximum length of a single entry.
/// [maxLineLength] is the maximum length of a single line, including key and indent.
/// Any keys in [alwaysExpandKeys] will have their values expanded, regardless
/// of line length.
String niceJson(
  Map data, {
  String indent = ' ',
  int maxContentLength = 40,
  int maxLineLength = 80,
  List<String> alwaysExpandKeys = const [],
  int minDepth = 1,
}) {
  return encodeObject(
    data,
    JsonOptions(
      indent: indent,
      maxContentLength: maxContentLength,
      maxLineLength: maxLineLength,
      alwaysExpandKeys: alwaysExpandKeys,
      minDepth: minDepth,
    ),
  );
}

RegExp _buildRegex(String pattern, [bool complete = true]) => RegExp(
  '^(${pattern.replaceAll('**', '(.+)').replaceAll('*', '([^.]+)')})${complete ? '\$' : ''}',
);

class JsonOptions {
  /// The character used for indentation.
  final String indent;

  /// Maximum length of a single entry.
  final int maxContentLength;

  /// Maximum length of an entire line.
  final int maxLineLength;

  /// The current nesting depth.
  final int depth;

  /// Keys that will always be expanded.
  final List<String> alwaysExpandKeys;

  /// The minimum depth that must be reached before compressing lines.
  final int minDepth;

  final String? path;

  const JsonOptions({
    this.indent = ' ',
    this.maxContentLength = 40,
    this.maxLineLength = 80,
    this.depth = 0,
    this.alwaysExpandKeys = const [],
    this.minDepth = 1,
    this.path,
  });

  int get maxLength => min(maxContentLength, maxLineLength);
  String get baseIndent => indent * depth;
  int get baseIndentSize => depth * indent.length;
  bool get allowCompression =>
      depth >= minDepth &&
      (path == null || !_matchesAlwaysExpand(path!, false));

  bool shouldExpandKey(String key) => _matchesAlwaysExpand(key);

  bool _matchesAlwaysExpand(String key, [bool complete = false]) {
    for (String pattern in alwaysExpandKeys) {
      if (_buildRegex(pattern, complete).hasMatch(key)) return true;
    }
    return false;
  }

  /// Creates a copy with some parameters changed.
  JsonOptions copyWith({
    String? indent,
    int? maxContentLength,
    int? maxLineLength,
    int? depth,
    List<String>? alwaysExpandKeys,
    int? minDepth,
    String? path,
  }) => JsonOptions(
    indent: indent ?? this.indent,
    maxContentLength: maxContentLength ?? this.maxContentLength,
    maxLineLength: maxLineLength ?? this.maxLineLength,
    depth: depth ?? this.depth,
    alwaysExpandKeys: alwaysExpandKeys ?? this.alwaysExpandKeys,
    minDepth: minDepth ?? this.minDepth,
    path: path ?? this.path,
  );

  JsonOptions extendPath(String key) =>
      copyWith(path: path == null ? key : '$path.$key');
}

/// Encodes [object] as JSON, given [options].
/// This is the base level function, but consider using `niceJson()` instead.
String encodeObject(Object? object, JsonOptions options) => switch (object) {
  final String s => encodeString(s),
  final num n => encodeNumber(n),
  final List l => encodeList(l, options),
  final Map m => encodeMap(m, options),
  final MapEntry e => encodeMapEntry(e, options),
  final Enum e => encodeString(e.name),
  final bool b => '$b',
  null => 'null',
  _ => throw Exception('Nice JSON couldn\'t encode object: $object'),
};

/// Encodes [object] as a JSON string.
/// [jsonEncode] is used here for escaping.
String encodeString(String object) => jsonEncode(object);

/// Encodes [object] as a JSON number.
/// Non-finite values throw, as with [jsonEncode].
String encodeNumber(num object) => jsonEncode(object);

/// Encodes a map as JSON. This should probably be a `Map<String, dynamic>`, but
/// this is not a constraint that is checked.
/// Consider using `niceJson()` instead.
String encodeMap(Map object, JsonOptions options) {
  if (object.isEmpty) return '{}';
  final encoded = object.entries
      .map((e) => encodeMapEntry(e, options))
      .toList();
  final simple = '{${encoded.join(', ')}}';
  if (simple.length < options.maxLength && options.allowCompression) {
    return simple;
  }
  final indent = options.baseIndent;
  String str = '${options.indent}[';
  final opts = options.copyWith(
    depth: options.depth + 1,
    maxLineLength: options.maxLineLength - options.indent.length,
  );
  final complex = object.entries
      .map((e) => encodeMapEntry(e, opts))
      .join(',\n$indent${options.indent}');
  str = '{\n$indent${options.indent}$complex\n$indent}';
  return str;
}

/// Encodes a single map entry as JSON.
/// A key that is not a [String] throws [JsonUnsupportedObjectError].
///
/// Turns out json keys are not meant to be ints, who knew?
String encodeMapEntry(MapEntry object, JsonOptions options) {
  final rawKey = object.key;
  final key = switch (rawKey) {
    final String s => '"$s": ',
    _ => throw JsonUnsupportedObjectError(rawKey),
  };

  final path = options.path == null ? rawKey : '${options.path}.$rawKey';
  final value = encodeObject(
    object.value,
    options.copyWith(
      maxLineLength: options.maxLineLength - key.length,
      maxContentLength: options.maxContentLength,
      path: path,
    ),
  );
  return '$key$value';
}

/// Encodes a list as JSON.
String encodeList(List object, JsonOptions options) {
  if (object.isEmpty) return '[]';
  final encoded = object
      .asMap()
      .entries
      .map((e) => encodeObject(e.value, options.extendPath(e.key.toString())))
      .toList();
  final simple = '[${encoded.join(', ')}]';
  if (simple.length < options.maxLength && options.allowCompression) {
    return simple;
  }
  final base = options.baseIndent;
  String str = '${options.indent}[';
  final opts = options.copyWith(
    depth: options.depth + 1,
    maxLineLength: options.maxLineLength - options.indent.length,
  );
  final complex = object
      .asMap()
      .entries
      .map((e) => encodeObject(e.value, opts.extendPath(e.key.toString())))
      .join(',\n$base${options.indent}');
  str = '[\n$base${options.indent}$complex\n$base]';
  return str;
}
