require "spec_helper"
require "jet_black"

describe "bummr version command" do
  before(:all) do
    puts "\n<< black_box/bummr_version_spec >>\n"
  end

  # REM: the JetBlack session captures all STDOUT and STDERR output originating within the session
  let(:session) { JetBlack::Session.new(options: { clean_bundler_env: true }) }

  let(:bummr_gem_path) { File.expand_path("../../", __dir__) }

  let(:version_out) { "Bummr #{Bummr::VERSION}" }

  # Install bummr into this black_box session construct
  def mock_gemfile_and_install
    session.create_file "Gemfile", <<~RUBY
      source "https://rubygems.org"
      gem "bummr", path: "#{bummr_gem_path}"
    RUBY
    session.run("bundle install --retry 3")
  end

  context "via 'bummr version'" do
    it "prints the bummr version" do
      mock_gemfile_and_install

      version_result = session.run(
        "bundle exec bummr version"
      )
      # Debugging
      #puts version_result.stdout
      #puts version_result.stderr

      expect(version_result).to have_stdout(version_out)
    end
  end

  # -v is also implied to be working since its defined the same way
  context "via 'bummr --version'" do
    it "prints the bummr version" do
      mock_gemfile_and_install

      version_result = session.run(
        "bundle exec bummr --version"
      )
      # Debugging
      #puts version_result.stdout

      expect(version_result).to have_stdout(version_out)
    end
  end
end
