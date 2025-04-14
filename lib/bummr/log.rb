module Bummr
  module Log
    def log(message)
      puts message
      system("touch log/bummr.log && echo '#{Rainbow.uncolor(message)}' >> log/bummr.log")
    end
  end
end
