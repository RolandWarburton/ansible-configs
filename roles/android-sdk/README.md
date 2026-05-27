# android-sdk

Installs a user-owned Android SDK command-line toolchain.
Includes:

- OpenJDK 21
- Android command-line tools
- `platform-tools`
- `platforms;android-36`
- `build-tools;36.0.0`
- `~/.local/bin/sdkmanager`
- `~/.local/bin/adb`

This role requires you to manually configure this for your path.

```bash
# Export Android SDK ENV if its detected
ANDROID_SDK_DIR="$HOME/.android-sdk"
if [[ -d "$ANDROID_SDK_DIR" ]]; then
  export ANDROID_HOME="$ANDROID_SDK_DIR"
  export ANDROID_SDK_ROOT="$ANDROID_SDK_DIR"
fi
```

Commands:

- `sdkmanager` is installed with the Android command-line tools.
- `adb` is installed by the `platform-tools` SDK package.
