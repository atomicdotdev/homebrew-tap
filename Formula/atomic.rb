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
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.1/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "710f07da967ff8c536022db739380dd7e111a021757d2f47e43e4d127a1587d1"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.1/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "37e6741cfb2b79fb055d50180ac334e6130b1ced4cdb682ea366aad564f5bcb4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.1/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f229fafea25264b6c0afd5a74f41196cd7d6042a6e8a39b9cb7905b05a5bf838"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.1/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e7e21e9a6e5565abbd26a43533a845f2561cb33122bf7c358d788d633e582f60"
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
