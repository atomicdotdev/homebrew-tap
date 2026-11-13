# typed: false
# frozen_string_literal: true

require "digest"
require "json"

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

  depends_on "node" => :test

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.1/atomic-aarch64-apple-darwin.tar.gz"
      sha256 "feb019b50dbabc8787bd9331b997ef426a1ddd0721fc5e2d3380bdd3450b47fe"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.1/atomic-x86_64-apple-darwin.tar.gz"
      sha256 "062cda7a1f24fa777fb57b24e1eed4f675790b37388107ea7c3cf2c57d3b9742"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.1/atomic-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "069febed158694abf647d4a657fb98ace414393f60bad10fec84b19714eaffe0"
    else
      url "https://github.com/atomicdotdev/atomic/releases/download/v0.22.1/atomic-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "859230daeb4e6c6558c78d7b87d721bc0a1ccc38c2dba83f179518d6ca17e34f"
    end
  end

  def native_library
    return "libatomic.dylib" if OS.mac? && Hardware::CPU.arm?

    "libatomic.so" if OS.linux? && Hardware::CPU.intel?
  end

  def install
    if (library = native_library)
      manifest = JSON.parse(File.read("libatomic-runtime.json"))
      if manifest.fetch("librarySha256") != Digest::SHA256.file(library).hexdigest
        odie "Atomic runtime library checksum mismatch"
      end

      libexec.install "atomic", library, "libatomic-runtime.json"
      bin.install_symlink libexec/"atomic"
    else
      bin.install "atomic"
    end
  end

  # Homebrew can rewrite native linkage and re-sign the library. Hash the
  # installed bytes; never change the producer's protobuf fingerprint.
  post_install_steps(
    type:           "run",
    command:        RbConfig.ruby,
    guards:         [{ condition: "if_exists", path: "libatomic-runtime.json", base: "libexec" }],
    writable_paths: [
      { path: "libatomic-runtime.json", base: "libexec" },
      { path: "libatomic-runtime.json.tmp", base: "libexec" },
    ],
    args:           ["-rjson", "-rdigest", "-e", <<~'RUBY', "{{libexec}}/libatomic-runtime.json"],
      path = ARGV.fetch(0)
      manifest = JSON.parse(File.read(path))
      library = File.join(File.dirname(path), manifest.fetch("library"))
      manifest["librarySha256"] = Digest::SHA256.file(library).hexdigest
      temporary = "#{path}.tmp"
      File.write(temporary, "#{JSON.pretty_generate(manifest)}\n")
      File.rename(temporary, path)
    RUBY
  )

  test do
    assert_match version.to_s, shell_output("#{bin}/atomic --version")
    assert_match "init", shell_output("#{bin}/atomic --help")
    return unless (library = native_library)

    manifest = JSON.parse((libexec/"libatomic-runtime.json").read)
    assert_equal 1, manifest.fetch("schemaVersion")
    assert_equal version.to_s, manifest.fetch("version")
    assert_equal library, manifest.fetch("library")
    assert_equal Digest::SHA256.file(libexec/library).hexdigest, manifest.fetch("librarySha256")

    (testpath/"runtime.cjs").write <<~JS
      const assert = require('node:assert/strict');
      const { createHash } = require('node:crypto');
      const { readFileSync, realpathSync } = require('node:fs');
      const { dirname, join } = require('node:path');
      // Discover beside the real CLI, just as nodeatomic does through PATH.
      const directory = dirname(realpathSync(process.argv[2]));
      const manifest = JSON.parse(readFileSync(join(directory, 'libatomic-runtime.json')));
      assert.equal(manifest.platform, process.platform);
      assert.equal(manifest.arch, process.arch);
      assert.ok(Number(process.versions.napi) >= manifest.nodeApiVersion);
      const addon = { exports: {} };
      process.dlopen(addon, join(directory, manifest.library));
      assert.equal(typeof addon.exports.call, 'function');
      assert.equal(typeof addon.exports.descriptor, 'function');
      const descriptor = addon.exports.descriptor();
      assert.ok(Buffer.isBuffer(descriptor) && descriptor.length > 0);
      assert.equal(createHash('sha256').update(descriptor).digest('hex'), manifest.descriptorSha256);
      console.log('Installed Atomic Node-API runtime loaded and verified');
    JS
    assert_match "runtime loaded and verified", shell_output("node #{testpath}/runtime.cjs #{bin}/atomic")
  end
end
