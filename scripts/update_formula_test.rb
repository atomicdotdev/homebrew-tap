# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"

class UpdateFormulaTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  ORIGINAL = File.read(File.join(ROOT, "Formula/atomic.rb"))
  VERSION = ORIGINAL[%r{/releases/download/v([^/]+)/}, 1]
  ASSETS = ORIGINAL.scan(%r{/releases/download/v[^/]+/([^"\n]+)}).flatten.freeze

  def update(version:, checksums: nil, formula: ORIGINAL)
    Dir.mktmpdir("atomic-formula-test-") do |directory|
      path = File.join(directory, "atomic.rb")
      File.write(path, formula)
      checksums ||= ASSETS.map { |asset| "#{Digest::SHA256.hexdigest(asset)}  #{asset}" }.join("\n")
      api = {
        "https://api.github.com/repos/atomicdotdev/atomic/releases/latest" => JSON.generate(
          "tag_name" => "v#{version}",
          "assets" => [{ "name" => "checksums-sha256.txt", "browser_download_url" => "https://fixture.invalid/checksums" }]
        ),
        "https://fixture.invalid/checksums" => checksums
      }
      fixture = File.join(directory, "api.json")
      File.write(fixture, JSON.generate(api))
      interceptor = File.join(directory, "api.rb")
      File.write(interceptor, <<~RUBY)
        require "json"
        require "open-uri"
        require "stringio"
        def OpenURI.open_uri(url, *)
          StringIO.new(JSON.parse(File.read(ENV.fetch("RELEASE_FIXTURE"))).fetch(url.to_s))
        end
      RUBY
      stdout, stderr, status = Open3.capture3(
        { "FORMULA_PATH" => path, "RELEASE_FIXTURE" => fixture, "GITHUB_TOKEN" => nil },
        RbConfig.ruby, "-r", interceptor, File.join(ROOT, "scripts/update_formula.rb")
      )
      [File.read(path), stdout, stderr, status]
    end
  end

  def test_new_release_resets_revision_and_updates_every_platform
    result, _, stderr, status = update(version: "99.0.0")
    assert status.success?, stderr
    refute_match(/^  revision /, result)
    ASSETS.each do |asset|
      assert_includes result, "/releases/download/v99.0.0/#{asset}"
      assert_includes result, Digest::SHA256.hexdigest(asset)
    end
  end

  def test_same_version_checksum_update_preserves_revision
    result, _, stderr, status = update(version: VERSION)
    assert status.success?, stderr
    assert_equal ORIGINAL[/^  revision \d+/], result[/^  revision \d+/]
    ASSETS.each { |asset| assert_includes result, Digest::SHA256.hexdigest(asset) }
  end

  def test_current_formula_is_unchanged
    checksums = ORIGINAL.scan(%r{/releases/download/v[^/]+/([^"\n]+)"\s+sha256 "([0-9a-f]{64})"})
                        .map { |asset, digest| "#{digest}  #{asset}" }.join("\n")
    result, stdout, stderr, status = update(version: VERSION, checksums: checksums)
    assert status.success?, stderr
    assert_equal ORIGINAL, result
    assert_includes stdout, "nothing to do"
  end

  def test_missing_platform_checksum_does_not_modify_formula
    result, _, stderr, status = update(version: "99.0.0", checksums: "")
    refute status.success?
    assert_includes stderr, "missing checksums"
    assert_equal ORIGINAL, result
  end
end
