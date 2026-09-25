# typed: false
# frozen_string_literal: true

# Homebrew formula for the Atomic CLI.
#
# Binary-based: downloads the prebuilt release archive for the user's
# platform from GitHub Releases. The source for these binaries is the
# atomic CLI's own release workflow at https://github.com/atomicdotdev/atomic
#
# To install:
#   brew tap atomicdotdev/tap
#   brew install atomic
#
# To upgrade after a new release:
#   brew upgrade atomicdotdev/tap/atomic
class Atomic < Formula
  desc "Mathematically sound distributed version control system for the age of AI"
  homepage "https://github.com/atomicdotdev/atomic"
  license any_of: ["MIT", "Apache-2.0"]

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.18.3/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "d64f226d1eb3e4a4f5d0e7061f162ac2994e2eefd03277fb8842e2d1029dc0b0"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.18.3/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "27f1e8008b5137be20ef3cbf95254d03b70ae992b1f7ac257b1f185d45d32346"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.18.3/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "14bd6f7707bdde4b33f4b9595e90dd18d31466c84e57424299fe464e08a30b21"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.18.3/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "779ac801eecd89582741f5e8ef81fd30e4aaabaca8b50745a5834c9eb535d294"
    end
  end

  def install
    bin.install "atomic"
  end

  test do
    # The binary should be installed and report a version matching this formula.
    assert_match version.to_s, shell_output("#{bin}/atomic --version")

    # `atomic --help` should list a core subcommand.
    assert_match "init", shell_output("#{bin}/atomic --help")
  end
end
