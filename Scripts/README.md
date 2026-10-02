# Build Scripts

## archive-release.sh

Archives the app with release version settings derived from a `vX.Y.Z` tag.

### Usage

```bash
Scripts/archive-release.sh v2.1.1
Scripts/archive-release.sh v2.1.1 20101
```

### Behavior

- Sets `APP_VERSION` from the tag without the leading `v`
- Derives the default build number from semver as `major * 10000 + minor * 100 + patch`
- Passes both values into `xcodebuild archive`
