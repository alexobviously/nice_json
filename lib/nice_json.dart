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

  const JsonOptions({
    this.indent = ' ',
    this.maxContentLength = 40,
    this.maxLineLength = 80,
    this.depth = 0,
    this.alwaysExpandKeys = const [],
    this.minDepth = 1,
  });

  int get maxLength => min(maxContentLength, maxLineLength);
  String get baseIndent => indent * depth;
  int get baseIndentSize => depth * indent.length;
  bool get allowCompression => depth >= minDepth;

  JsonOptions copyWith({
    String? indent,
    int? maxContentLength,
    int? maxLineLength,
    int? depth,
    List<String>? alwaysExpandKeys,
    int? minDepth,
  }) =>
      JsonOptions(
        indent: indent ?? this.indent,
        maxContentLength: maxContentLength ?? this.maxContentLength,
        maxLineLength: maxLineLength ?? this.maxLineLength,
        depth: depth ?? this.depth,
        alwaysExpandKeys: alwaysExpandKeys ?? this.alwaysExpandKeys,
        minDepth: minDepth ?? this.minDepth,
      );
}

String encodeObject(Object? object, JsonOptions options) {
  if (object is String) return encodeString(object);
  if (object is num) return encodeNumber(object);
  if (object is List) {
    return encodeList(object, options);
  }
  if (object is Map) {
    return encodeMap(object, options);
  }
  if (object is MapEntry) {
    return encodeMapEntry(object, options);
  }
  if (identical(object, true)) return 'true';
  if (identical(object, false)) return 'false';
  if (object == null) return 'null';
  throw Exception('Nice JSON couldn\'t encode object: $object');
}

String encodeString(String object) => '"$object"';
String encodeNumber(num object) => '$object';

String encodeMap(Map object, JsonOptions options) {
  if (object.isEmpty) return '{}';
  List<String> encoded = object.entries.map((e) => encodeMapEntry(e, options)).toList();
  String simple = '{${encoded.join(', ')}}';
  if (simple.length < options.maxLength && options.allowCompression) {
    return simple;
  }
  String base = options.baseIndent;
  String str = '${options.indent}[';
  final opts = options.copyWith(
    depth: options.depth + 1,
    maxLineLength: options.maxLineLength - options.indent.length,
  );
  String complex =
      object.entries.map((e) => encodeMapEntry(e, opts)).join(',\n$base${options.indent}');
  str = '{\n$base${options.indent}$complex\n$base}';
  return str;
}

String encodeMapEntry(MapEntry object, JsonOptions options) {
  String key = '"${object.key}": ';
  String value = encodeObject(
    object.value,
    options.copyWith(
      maxLineLength: options.maxLineLength - key.length,
      maxContentLength:
          options.alwaysExpandKeys.contains(object.key) ? 0 : options.maxContentLength,
    ),
  );
  return '$key$value';
}

String encodeList(List object, JsonOptions options) {
  if (object.isEmpty) return '[]';
  List<String> encoded = object.map((e) => encodeObject(e, options)).toList();
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
  String complex = object.map((e) => encodeObject(e, opts)).join(',\n$base${options.indent}');
  str = '[\n$base${options.indent}$complex\n$base]';
  return str;
}
