### 1.2.0
- Bumped Dart SDK to 3.13.7, updated dependencies, lints.
- Fixed strings not being escaped correctly.
- Non-finite numbers (`NaN`, `Infinity`, `-Infinity`) now throw, matching `jsonEncode`.
- Non-string map keys now throw, matching `jsonEncode` (no `Map<int, dynamic>`, for example).

### 1.1.2
- Relaxed the parameter type of the top level `niceJson` function from `Map<String, dynamic>` to just `Map`.

### 1.1.1
- Enums will now be encoded with `Enum.name`.

### 1.1.0
- Nested expansion keys. Specify keys for `alwaysExpandKeys` in dot notation, like `x.y`.
    - **Breaking**: if you previously had an expansion key `'z'`, it would match `z`, `x.z` or `x.y.z`, but now it will not. Use `'*.z'` to match `x.z` and `'**.z'` to match all of the above.

### 1.0.0
- Initial version.
