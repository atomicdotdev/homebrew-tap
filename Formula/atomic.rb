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
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.21.0/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "e9ca65bb0527cb68b94cc7bb74d7f3c9dadfebba54deccb3e0effca049a25fa8"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.21.0/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "ead9165bc5a2bb3bdab1eb8f624be1da15c4ac6eda1391aa700bfccc9e1f8bdf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.21.0/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "d8950600d3d832308ea684e0a9ec335dd83835face929872cfd1d25dca80440a"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.21.0/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "62fe490fb2a657ddb5c048b78c23ad2ace170eef14709d337f8fbd10b973433e"
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
