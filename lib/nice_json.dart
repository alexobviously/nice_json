import 'dart:math';

/// Encodes [data] as nicely formatted human-readable JSON.
/// [indent] is the indent character added to the start of each line. By default,
/// this is a single space, but other good options are two spaces or a tab ('\t').
/// [maxContentLength] is the maximum length of a single entry.
/// [maxLineLength] is the maximum length of a single line, including key and indent.
/// Any keys in [alwaysExpandKeys] will have their values expanded, regardless
/// of line length.
String niceJson(
  Map<String, dynamic> data, {
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
    '^(${pattern.replaceAll('**', '(.+)').replaceAll('*', '([^.]+)')})${complete ? '\$' : ''}');

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
  }) =>
      JsonOptions(
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
      String s => encodeString(s),
      num n => encodeNumber(n),
      List l => encodeList(l, options),
      Map m => encodeMap(m, options),
      MapEntry e => encodeMapEntry(e, options),
      Enum e => encodeString(e.name),
      bool b => '$b',
      null => 'null',
      _ => throw Exception('Nice JSON couldn\'t encode object: $object'),
    };

/// Encodes a string as JSON. Just wraps double quotes around it.
String encodeString(String object) => '"$object"';

/// Encodes a number as JSON. Just converts it to a string.
String encodeNumber(num object) => '$object';

/// Encodes a map as JSON. This should probably be a Map<String, dynamic>, but
/// this is not a constraint that is checked.
/// Consider using `niceJson()` instead.
String encodeMap(Map object, JsonOptions options) {
  if (object.isEmpty) return '{}';
  List<String> encoded =
      object.entries.map((e) => encodeMapEntry(e, options)).toList();
  String simple = '{${encoded.join(', ')}}';
  if (simple.length < options.maxLength && options.allowCompression) {
    return simple;
  }
  String indent = options.baseIndent;
  String str = '${options.indent}[';
  final opts = options.copyWith(
    depth: options.depth + 1,
    maxLineLength: options.maxLineLength - options.indent.length,
  );
  String complex = object.entries
      .map((e) => encodeMapEntry(e, opts))
      .join(',\n$indent${options.indent}');
  str = '{\n$indent${options.indent}$complex\n$indent}';
  return str;
}

/// Encodes a single map entry as JSON.
String encodeMapEntry(MapEntry object, JsonOptions options) {
  String key = '"${object.key}": ';
  String path =
      options.path == null ? object.key : '${options.path}.${object.key}';
  String value = encodeObject(
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
  List<String> encoded = object
      .asMap()
      .entries
      .map((e) => encodeObject(e.value, options.extendPath(e.key.toString())))
      .toList();
  String simple = '[${encoded.join(', ')}]';
  if (simple.length < options.maxLength && options.allowCompression) {
    return simple;
  }
  String base = options.baseIndent;
  String str = '${options.indent}[';
  final opts = options.copyWith(
    depth: options.depth + 1,
    maxLineLength: options.maxLineLength - options.indent.length,
  );
  String complex = object
      .asMap()
      .entries
      .map((e) => encodeObject(e.value, opts.extendPath(e.key.toString())))
      .join(',\n$base${options.indent}');
  str = '[\n$base${options.indent}$complex\n$base]';
  return str;
}
