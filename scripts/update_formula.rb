#!/usr/bin/env ruby
# frozen_string_literal: true

# Updates Formula/atomic.rb to the latest atomicdotdev/atomic release.
#
# Fetches the latest GitHub release, reads its checksums file, and rewrites the
# versioned url/sha256 pairs in the formula. Prints "nothing to do" and exits 0
# when the formula is already current, so the calling workflow can skip the
# commit. The upstream release is public, so no token is required.

require "json"
require "open-uri"

OWNER = "atomicdotdev"
REPO = "atomic"
FORMULA = ENV.fetch("FORMULA_PATH", "Formula/atomic.rb")

# Assets the formula installs from, in formula order.
ASSETS = [
  "atomic-aarch64-apple-darwin.tar.gz",
  "atomic-x86_64-apple-darwin.tar.gz",
  "atomic-aarch64-unknown-linux-gnu.tar.gz",
  "atomic-x86_64-unknown-linux-gnu.tar.gz"
].freeze

def get(url)
  headers = { "User-Agent" => "atomic-brew-tap" }
  token = ENV["GITHUB_TOKEN"]
  headers["Authorization"] = "Bearer #{token}" unless token.nil? || token.empty?
  URI.parse(url).open(headers).read
end

release = JSON.parse(get("https://api.github.com/repos/#{OWNER}/#{REPO}/releases/latest"))
version = release["tag_name"].delete_prefix("v")
puts "latest release: #{version}"

checksums = {}
release["assets"].each do |asset|
  next unless asset["name"].include?("checksum")

  get(asset["browser_download_url"]).each_line do |line|
    digest, _, name = line.strip.partition("  ")
    checksums[name.delete_prefix("./")] = digest unless name.empty?
  end
  break
end

missing = ASSETS.reject { |asset| checksums.key?(asset) }
unless missing.empty?
  warn "missing checksums for: #{missing.join(", ")}"
  exit 1
end

original = File.read(FORMULA)
formula = original

ASSETS.each do |asset|
  url = "https://github.com/#{OWNER}/#{REPO}/releases/download/v#{version}/#{asset}"
  pattern = /url\s+"https:\/\/github\.com\/#{OWNER}\/#{REPO}\/releases\/download\/v[^\"]+\/#{Regexp.escape(asset)}"(\s*\n\s*sha256\s+")[0-9a-f]{64}(")/
  replaced = 0

  formula = formula.gsub(pattern) do
    replaced += 1
    %(url "#{url}"#{Regexp.last_match(1)}#{checksums[asset]}#{Regexp.last_match(2)})
  end

  next if replaced == 1

  warn "expected 1 match for #{asset}, found #{replaced}"
  exit 1
end

if formula == original
  puts "formula already at #{version}; nothing to do"
  exit 0
end

File.write(FORMULA, formula)
puts "updated #{FORMULA} to #{version}"
