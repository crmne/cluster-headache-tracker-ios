# Build Scripts

## load-env.sh

This script loads environment variables during the build process and generates a Swift configuration file.

### Environment Variables

- `HONEYBADGER_API_KEY`: API key for Honeybadger error tracking

### Local Development

1. Copy `.env.example` to `.env`
2. Add your Honeybadger API key to `.env`
3. The build script will automatically load these values

### CI/CD

Set the `HONEYBADGER_API_KEY` environment variable in your CI/CD pipeline. The script will use this value instead of the .env file when available.

### Generated Files

The script generates `Cluster Headache Tracker/Generated/EnvironmentConfig.swift` which is git-ignored and contains the runtime configuration.

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
