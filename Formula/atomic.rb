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

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.6.0/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "ee5891c671ca9cddf6128ae77a97e1e25d05044574d4e30a2ea489e07665e212"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.6.0/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "1db499ac08ce68597f41064959b788bd4be54a5f210a4e21ffff6d3a3fddddbb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.6.0/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "d1e6f0a5feeb485a16ce8fc86c20b9823a5914665ddfec16463763eef4379e30"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.6.0/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "43a8cc125527060f56a3e02dfaf40e62e0419879dd9e3ceced39f16dcce1aa4f"
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
