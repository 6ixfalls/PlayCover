# NIKKE support for 6ixfalls/PlayCover

This fork starts from official PlayCover `develop`. It ports the seven requested
NIKKE options and only their runtime dependencies into a matching official-based
[PlayTools fork](https://github.com/6ixfalls/PlayTools). The viatearz compatibility
frameworks and unrelated bypasses are not included.

## Build locally

Keep the repositories side by side:

```text
nikke/
  PlayCover/
  PlayTools/
```

Use full Xcode with the macOS and iOS SDKs and Command Line Tools selected. Neither
Carthage, Fastlane nor an Apple signing account is required for this build path.

```sh
cd PlayCover
bash scripts/build-local.sh
```

The script checks the sibling PlayTools checkout against `PlayTools.revision`,
compiles its iOS framework and native macOS AKInterface bundle from source, then
builds an ad-hoc signed app at:

```text
PlayCover/.build/DerivedData/Build/Products/Nightly/PlayCover.app
```

Override the sibling path with `PLAYTOOLS_SOURCE=/absolute/path/to/PlayTools` if
necessary. Build scripts use the committed Swift package resolution files and
do not automatically update Carthage dependencies. Swift packages may contain
their own binary artifacts (notably Sparkle); this is not a claim that every
transitive dependency is built from source. Automatic PlayCover updates are
disabled so an official update cannot overwrite this fork.

Before running, quit other copies of PlayCover. Copy your chosen build to
`/Applications/PlayCover.app`; the app installs its bundled PlayTools into the
shared `~/Library/Frameworks/PlayTools.framework` location. Another PlayCover
build can replace that shared framework. The build script does not install or
launch either app, alter NIKKE's user data, or change system security settings.

## Publish under 6ixfalls

Create GitHub forks of official `PlayCover/PlayTools` and `PlayCover/PlayCover`
under `6ixfalls`. These local repositories already have the intended remote
layout: `origin` points to your fork and `upstream` points to the official repo.
Push PlayTools first, because PlayCover pins its new commit:

```sh
git -C ../PlayTools push -u origin master
git push -u origin develop
```

No force-push is needed for a fresh fork. If a remote already has independent
changes, reconcile them before pushing. When changing PlayTools later, commit
its source, update `PlayTools.revision`, `Cartfile` and `Cartfile.resolved` to that
commit, then rebuild and push both repositories.

The manual **Build NIKKE fork** GitHub Actions workflow builds the pinned source
without Apple signing credentials and uploads a zipped, ad-hoc signed app.
Official release/nightly signing workflows are gated to the official repository.
The manual workflow does not publish a release.

## NIKKE settings

The bundled preset is `PlayCover/AppSettingsOverrides/com.proximabeta.nikke.json`:

```json
{
    "disableINTLUtilsSwizzling": true,
    "unityEngineForceLandscape": true,
    "unityEngineDisableOrientationCheck": true,
    "webViewSmartTextInput": true,
    "disableBuiltinGamepad": true,
    "nikkeTTSMiniGameShowKeySettings": true,
    "nikkeTTSMiniGameRemapRightShift": true
}
```

These defaults are applied on new installation, when old settings lack the new
keys, and on Reset Settings. Explicit saved values are preserved. Other apps
default to false for these options. The settings live in the normal per-app
plist and are editable in NIKKE's **NIKKE** settings tab. Restart the game after
changing options. Smart web text input requires Smart Keymapping. Controller
handling and right-Shift remapping require keymapping to be enabled.

The INTL option prevents the SDK swizzling helper implicated by the captured
delegate/KVO stack overflow. It does not disable Firebase wholesale.

The rhythm-game controls option is applied to the installed UnityFramework
before launch. It requires an ARM64 Mach-O, exactly one matching byte pattern,
and the expected original or patched instruction. Unknown versions are left
unchanged with a log message. Turning the option off restores the original
instruction on the next launch. Nested binary and app signatures are refreshed.
Only `com.proximabeta.nikke` receives this binary patch.

## Tests

```sh
bash scripts/test-nikke.sh
bash ../PlayTools/scripts/test-nikke.sh
```

The settings test uses real AppKit screen defaults, so it needs a normal macOS
user session rather than a sandbox that blocks the window server. The tests use
temporary settings and do not touch your PlayCover configuration. To verify a
real UnityFramework without modifying it, pass its path to `test-nikke.sh`.

Tests cover patch enable/disable and idempotence, ambiguous/unsupported binaries,
legacy settings migration, explicit overrides, other-app defaults, and safe
runtime hook registration. The patch was also checked against the supplied
NIKKE 153.6 IPA. Compilation and focused tests do not establish live login,
gameplay, or rhythm-game behavior; those still require testing in the game.

## Attribution

Compatibility behavior and the rhythm-game patch pattern were adapted from
viatearz/PlayCover `ba20dadcc843c990417d36bfd54b458b3ae1da58` and
viatearz/PlayTools `58f29dfc9c126ec4d334ab14be22dded2d351faf`, under AGPL-3.0.
The smaller settings integration, migration behavior, guarded reversible patch,
hook registry/lifecycle installation, and locked local build path are implemented
here. Existing upstream licensing and notices remain in each repository.
