class JsonOptions {
  final String indent;
  final int maxLineLength;
  final int depth;

  const JsonOptions({
    this.indent = ' ',
    this.maxLineLength = 80,
    this.depth = 0,
  });

  String get baseIndent => indent * depth;
  int get baseIndentSize => depth * indent.length;

  JsonOptions copyWith({
    String? indent,
    int? maxLineLength,
    int? depth,
  }) =>
      JsonOptions(
        indent: indent ?? this.indent,
        maxLineLength: maxLineLength ?? this.maxLineLength,
        depth: depth ?? this.depth,
      );

  JsonOptions deeper() => JsonOptions(
        indent: indent,
        maxLineLength: maxLineLength,
        depth: depth + 1,
      );
}

String niceJson(
  Object? object, {
  String indent = '  ',
  int maxLineLength = 80,
}) {
  return encodeObject(
    object,
    JsonOptions(indent: indent, maxLineLength: maxLineLength),
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
  throw UnimplementedError();
}

String encodeString(String object) => '"$object"';
String encodeNumber(num object) => '$object';

String encodeMap(Map object, JsonOptions options) {
  if (object.isEmpty) return '{}';
  List<String> encoded = object.entries.map((e) => encodeMapEntry(e, options)).toList();
  String simple = '{${encoded.join(', ')}}';
  if (simple.length < options.maxLineLength) {
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
    ),
  );
  return '$key$value';
}

String encodeList(List object, JsonOptions options) {
  if (object.isEmpty) return '[]';
  List<String> encoded = object.map((e) => encodeObject(e, options)).toList();
  String simple = '[${encoded.join(', ')}]';
  if (simple.length < options.maxLineLength) {
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
