# flutter

Installs the Flutter SDK to `~/.flutter`.

## Shell configuration

Add the following to your shell rc (e.g. `~/.zshrc`):

```sh
# Flutter & Dart
# sort -V orders by version, tail -1 picks the highest,
# xargs dirname strips the filename e.g. ~/.flutter/bin/flutter -> ~/.flutter/bin
FLUTTER_DIR=$(find $HOME/.flutter -maxdepth 3 -name flutter -type f 2>/dev/null | sort -V | tail -1 | xargs --no-run-if-empty dirname)
if [[ -n "$FLUTTER_DIR" ]]; then
  export PATH="$PATH:${FLUTTER_DIR}"
  export CHROME_EXECUTABLE=$(which chromium)
fi
```
