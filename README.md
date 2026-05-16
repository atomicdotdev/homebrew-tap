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

## What this tap installs

A binary build of the Atomic CLI, downloaded from the official [GitHub release](https://github.com/atomicdotdev/atomic/releases). The tap covers four platforms:

| OS | Architecture |
|---|---|
| macOS | Apple Silicon (aarch64) |
| macOS | Intel (x86_64) |
| Linux | x86_64 |
| Linux | aarch64 |

For Windows, download the `.zip` directly from the [release page](https://github.com/atomicdotdev/atomic/releases/latest).

## Other install methods

If you don't use Homebrew:

```bash
curl -sSf https://atomic.storage/install.sh | sh
```

See the [Atomic installation docs](https://docs.atomic.dev/getting-started/installation) for all options.

## Reporting issues

For issues with the **Atomic CLI itself**, open an issue at [atomicdotdev/atomic](https://github.com/atomicdotdev/atomic/issues).

For issues specific to **this tap** (formula errors, install failures via brew), open an issue here.

## License

The tap formula is dual-licensed under MIT and Apache-2.0, matching the Atomic CLI itself.
