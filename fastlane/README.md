fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android aab

```sh
[bundle exec] fastlane android aab
```

Build the signed release AAB (requires android/key.properties)

### android internal

```sh
[bundle exec] fastlane android internal
```

Build + upload the AAB to the internal testing track

### android assets

```sh
[bundle exec] fastlane android assets
```

Regenerate launcher icon + store graphics from submission/assets-src

### android screenshots

```sh
[bundle exec] fastlane android screenshots
```

Capture marketing screenshots via the scripted emulator walk

### android listing

```sh
[bundle exec] fastlane android listing
```

Push listing text, graphics, and screenshots from submission/metadata

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
