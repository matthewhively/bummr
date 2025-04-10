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

    private

    def headless?
      HEADLESS == true ||
        HEADLESS == "true"
    end
  end
end
