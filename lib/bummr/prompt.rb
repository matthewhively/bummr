require 'io/console' # to enable STDIN.getch

module Bummr
  module Prompt
    def yes?(txt, *args)
      if headless?
        # don't let this get mocked out along with other "puts"
        STDOUT.puts txt
        true
      else
        super
      end
    end

    def press_any_key(txt)
      unless headless?
        puts "\n#{txt}\n"
        # TODO: "ctrl c" should not be captured
        STDIN.getch # Waits for a single key press
      end
    end

    private

    def headless?
      HEADLESS == true ||
        HEADLESS == "true"
    end
  end
end
