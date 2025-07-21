require "spec_helper"

describe Bummr::Prompt do
  before(:all) do
    puts "\n<< Bummr::Prompt >>\n"
  end

  # Mock the parent class, so `super` has some effect (normally super calls Thor.yes?)
  let(:parent_class) do
    Class.new do
      def yes?(message)
        "called parent with #{message}"
      end
    end
  end
  let(:object_class) { Class.new(parent_class) }
  let(:object) { object_class.new }

  before do
    object.extend(Bummr::Prompt)
  end

  describe "#yes?" do

    context "when HEADLESS is false" do
      it "calls super" do
        stub_const("HEADLESS", false)

        expect(
          object.yes?("foo")
        ).to eq "called parent with foo"
      end
    end

    context "when HEADLESS is nil" do
      it "calls super" do
        stub_const("HEADLESS", nil)

        expect(
          object.yes?("foo")
        ).to eq "called parent with foo"
      end
    end

    context "when HEADLESS is true" do
      it "returns true and skips asking for user input" do
        allow(STDOUT).to receive(:puts) # NOOP this particular case
        stub_const("HEADLESS", true)

        expect(
          object.yes?("foo")
        ).to eq true
      end
    end

  end # describe "#yes?"

  describe "#press_any_key" do

    context "when HEADLESS" do
      it "does nothing" do
        stub_const("HEADLESS", true)

        allow(STDIN).to receive(:getch)

        expect(
          object.press_any_key("Press any key to continue...")
        ).to eq nil
        # TODO: is there a better way?

        expect(STDIN).not_to have_received(:getch)
      end
    end

    context "when not headless" do
      it "prints message and waits for a keystroke" do
        stub_const("HEADLESS", false)

        # Fake the user pressing any key
        allow(STDIN).to receive(:getch).and_return("a")

        expect {
          object.press_any_key("Press any key to continue...")
        }.to output("\nPress any key to continue...\n").to_stdout

        expect(STDIN).to have_received(:getch)
      end
    end

  end # describe "#press_any_key"

end
