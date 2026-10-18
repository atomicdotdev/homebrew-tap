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
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.20.0/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "25331d667b718b8f5f557113107df0a39c8ecb89bde183b65fac803887f72b77"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.20.0/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "56450f0acf9618098167170dec05d431f0b5edd990719b9f88cc538f12ff476a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.20.0/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "25b7acd00214b5697971b139bb8a9fcb7373b02c793ade3c0444a0bc2d19fda6"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.20.0/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "076995dd70c8e06dd3056e2919ff561443b8fd73fadcb987b69e258da71eebf0"
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
