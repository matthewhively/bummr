require "spec_helper"

describe Bummr::Updater do
  before(:all) do
    puts "\n<< Bummr::Updater >>\n"
  end

  let(:outdated_gems) {
    [
      { name: "myGem",    installed: "0.3.2",    newest: "0.3.5" },
      { name: "otherGem", installed: "1.3.2.23", newest: "1.6.5" },
      { name: "thirdGem", installed: "4.3.4",    newest: "5.6.45" },
    ]
  }
  let(:gem) { outdated_gems[0] }

  let(:updater) { described_class.new(outdated_gems) }

  let(:newest_version)       { outdated_gems[0][:newest] }
  let(:installed_version)    { outdated_gems[0][:installed] }
  let(:intermediate_version) { "0.3.4" }

  let(:git) { Bummr::Git.instance }

  describe "#update_outdated_gems" do
    it "calls update_gem on each gem" do
      allow(updater).to receive(:update_gem)
      allow(updater).to receive(:puts) # NOOP this function call

      updater.update_outdated_gems

      outdated_gems.each_with_index do |gem, index|
        expect(updater).to have_received(:update_gem).with(gem, index)
      end
    end
  end

  # ----------------

  describe "#update_gem" do
    # Ensure this directory exists to be added
    before do
      %x{mkdir -p vendor/cache}
    end
    after do
      %x{rm -rf vendor/cache}
    end

    def mock_system_log_commit_puts
      allow(updater).to receive(:system)
      allow(updater).to receive(:log)
      allow(updater).to receive(:puts) # NOOP this function call
      allow(git).to receive(:commit)
    end

    it "attempts to update the gem" do
      allow(updater).to receive(:bundled_version_for).with(gem).and_return installed_version
      mock_system_log_commit_puts

      updater.update_gem(gem, 0)

      # NOTE: No assertions, so this is just a smoke-test (ensure the code runs without an exception)
    end

    context "gem not updated" do
      before(:each) do
        allow(updater).to receive(:bundled_version_for).with(gem).and_return installed_version
        mock_system_log_commit_puts
      end

      it "logs that it was not updated" do
        updater.update_gem(gem, 0)

        expect(updater).to have_received(:log).with("#{gem[:name]} not updated")
      end

      it "doesn't commit anything" do
        updater.update_gem(gem, 0)

        expect(git).to_not have_received(:commit)
      end
    end

    context "gem not updated to the newest version" do
      before(:each) do
        allow(updater).to receive(:bundled_version_for).with(gem).and_return intermediate_version
        mock_system_log_commit_puts
      end

      it "logs that it's not updated to the latest" do
        not_latest_message =
          "#{gem[:name]} not updated from #{gem[:installed]} to latest: #{gem[:newest]}"

        updater.update_gem(gem, 0)

        expect(updater).to have_received(:log).with not_latest_message
      end

      it "commits" do
        commit_message =
          "Update #{gem[:name]} from #{gem[:installed]} to #{intermediate_version}"

        allow(git).to receive(:add)
        allow(git).to receive(:files_staged?).and_return true

        updater.update_gem(gem, 0)

        expect(git).to have_received(:add).with("Gemfile")
        expect(git).to have_received(:add).with("Gemfile.lock")
        expect(git).to have_received(:add).with("vendor/cache")
        expect(git).to have_received(:commit).with(commit_message)
      end
    end

    context "gem updated to the latest" do
      before(:each) do
        allow(updater).to receive(:bundled_version_for).with(gem).and_return newest_version
        mock_system_log_commit_puts
      end

      it "commits" do
        commit_message =
          "Update #{gem[:name]} from #{gem[:installed]} to #{gem[:newest]}"

        allow(git).to receive(:add)
        allow(git).to receive(:files_staged?).and_return true

        updater.update_gem(gem, 0)

        expect(git).to have_received(:add).with("Gemfile")
        expect(git).to have_received(:add).with("Gemfile.lock")
        expect(git).to have_received(:add).with("vendor/cache")
        expect(git).to have_received(:commit).with(commit_message)
      end
    end
  end # end #update_gem

  # ----------------

  describe "#bundled_version_for" do
    it "returns the correct version from bundle list" do
      allow(updater).to receive(:`).with(
        "bundle list --paths | grep \"#{gem[:name]}\""
      ).and_return("asdf/asdf/asdf/#{gem[:name]}-3.5.2")

      expect(updater.bundled_version_for(gem)).to eq "3.5.2"
    end
  end
end
