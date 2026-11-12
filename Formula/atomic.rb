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
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.0/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "5ef90e48318eb25ee7f144de4c313eaa7a90fd3587fec81aafa7ddb9431a827e"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.0/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "8c560d14590331cd36d7dde0a1e339ad33ee9f08df85c5e47134c28ee3b83c4b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.0/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "947fd893f6b1b4ffb6f55e09fbc3235dbc5e671b1587508bae190bb5f6586385"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.0/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f08a03a712d97b69ff3d23dc11090d5ee149b9da87a3faa74d25de82167abfcc"
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
