### 1.1.2
- Relaxed the parameter type of the top level `niceJson` function from `Map<String, dynamic>` to just `Map`.

### 1.1.1
- Enums will now be encoded with `Enum.name`.

### 1.1.0
- Nested expansion keys. Specify keys for `alwaysExpandKeys` in dot notation, like `x.y`.
    - **Breaking**: if you previously had an expansion key `'z'`, it would match `z`, `x.z` or `x.y.z`, but now it will not. Use `'*.z'` to match `x.z` and `'**.z'` to match all of the above.

### 1.0.0
- Initial version.
