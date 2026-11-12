# Atomic Homebrew Tap

The official Homebrew tap for the [Atomic CLI](https://github.com/atomicdotdev/atomic) — a mathematically sound distributed version control system built for AI-assisted development.

## Install

```bash
brew tap atomicdotdev/tap
brew install atomic
```

Or in one line:

```bash
brew install atomicdotdev/tap/atomic
```

## Upgrade

```bash
brew upgrade atomicdotdev/tap/atomic
```

After installation, `brew upgrade atomic` also works in normal Homebrew setups.

## Verify

```bash
atomic --version
```

To exercise the installed Node-API library as well (Node is a test-only dependency):

```bash
brew install --only-dependencies --include-test atomicdotdev/tap/atomic
brew test atomicdotdev/tap/atomic
```

## What this tap installs

A binary build of the Atomic CLI, downloaded from the official [GitHub release](https://github.com/atomicdotdev/atomic/releases). Native runtime availability follows the upstream release targets:

| OS | Architecture | Node-API runtime |
|---|---|---|
| macOS | Apple Silicon (aarch64) | Included |
| macOS | Intel (x86_64) | CLI only |
| Linux | x86_64 | Included |
| Linux | aarch64 | CLI only |

On native-runtime platforms, the formula installs `atomic`, the platform library
(`libatomic.dylib` or `libatomic.so`), and `libatomic-runtime.json` together under
`libexec`. The public `bin/atomic` is a symlink to that executable. nodeatomic
follows the symlink and discovers the adjacent library and manifest; no library
is built or downloaded separately. A missing or inconsistent runtime bundle
fails installation rather than silently installing only the CLI on these hosts.

Homebrew can rewrite library linkage and re-sign Mach-O binaries. The formula
refreshes the manifest's library checksum after that processing, while retaining
the release's protobuf descriptor fingerprint. The formula test loads the library
in Node and checks that fingerprint against the actual exported descriptor.

The installed runtime must match the protobuf contract expected by its consumer,
including Atomic Sherpa. Installing a complete older runtime does not make it
compatible with a newer consumer. A matching runtime release is still required.

The current complete-runtime formula targets **Atomic v0.22.0**. It retains
formula revision 1 so existing CLI-only v0.22.0 installations upgrade to the
complete runtime layout.

Ensure the Homebrew `atomic` is the active executable (`type -a atomic`). An
explicit runtime override or a runtime registered by another installer takes
precedence over PATH discovery. To select this installation explicitly on a
supported native-runtime platform, set the following before launching the editor:

```bash
export ATOMIC_RUNTIME_DIR="$(brew --prefix atomicdotdev/tap/atomic)/libexec"
```

Unset any conflicting `LIBATOMIC_ADDON` override. GUI-launched editors may not
inherit shell exports; configure the extension-host environment accordingly.

For Windows, download the `.zip` directly from the [release page](https://github.com/atomicdotdev/atomic/releases/latest).

## Other install methods

If you don't use Homebrew:

```bash
curl -sSf https://atomic.storage/install.sh | sh
```

See the [Atomic installation docs](https://docs.atomic.dev/getting-started/installation) for all options.

nodeatomic and Atomic Sherpa require a matching native library and runtime
manifest, not just the CLI. Verify that an alternative installation provides
the complete runtime before using those consumers.

## How updates work

`Formula/atomic.rb` is kept at the latest release automatically: the
[Update formula](.github/workflows/update-formula.yml) workflow runs daily,
reads the newest [atomic release](https://github.com/atomicdotdev/atomic/releases/latest)
and its `checksums-sha256.txt`, and commits the new version and hashes when
they differ. No secrets are involved — the release is public and the workflow
commits with its own token.

Installation-layout fixes use a formula revision so existing installations
upgrade even when the upstream version is unchanged. The updater preserves
that revision for same-version updates and removes it when moving to a new
upstream version.

The [Test tap](.github/workflows/test.yml) workflow runs updater regressions and
installs/tests the formula on macOS and Linux, using
`Homebrew/actions/setup-homebrew@main` to prepare the test environment.

To run the updater regressions locally with Minitest installed:

```bash
ruby scripts/update_formula_test.rb
```

To pick up a published formula update:

```bash
brew update
brew upgrade atomicdotdev/tap/atomic
```

or trigger the workflow directly from the Actions tab.

## Reporting issues

For issues with the **Atomic CLI itself**, open an issue at [atomicdotdev/atomic](https://github.com/atomicdotdev/atomic/issues).

For issues specific to **this tap** (formula errors, install failures via brew), open an issue here.

## License

The tap formula is dual-licensed under MIT and Apache-2.0, matching the Atomic CLI itself.
