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
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.0/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "d59ce06dc82c950f7e7ee7fc35051e190473ccb4e1fe5d193b27504214e08104"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.0/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "f50e4f22c698b2f2066dc7a14b29857b7b11b5981b3a7a3714afea98906c04de"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.0/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "1941cc32d728e9e407066460a33b851fc84292ee151662609dbc49b4c18a9ea0"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.19.0/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d5801b2eab06b8fb387a522d2d6e718c54d2a96a5e6eb9d9520b601f8d539abe"
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
