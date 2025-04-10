module Bummr
  class Git
    include Singleton
    include Log

    def initialize
      @git_commit = ENV.fetch("BUMMR_GIT_COMMIT") { "git commit" }
    end

    def add(files)
      system("git add #{files}")
    end

    # NOTE: during active development this will catch any other files you may be working on
    #       so don't leave random files staged without committing them
    def files_staged?
      # exit code 1 when there are files staged for commit
      !system("git diff --staged --quiet")
    end

    def commit(message)
      log("Commit:".color(:green) + %Q| "#{message}"|)
      system("#{git_commit} -m '#{message}'")
    end

    def rebase_interactive(sha)
      system("git rebase -i #{BASE_BRANCH}") unless HEADLESS
    end

    # print only the commit subject line
    def message(sha)
      %x{git log --pretty=format:'%s' -n 1 #{sha}}
    end

    private

    attr_reader :git_commit
  end
end
