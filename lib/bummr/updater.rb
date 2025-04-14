module Bummr
  class Updater
    include Log
    include Scm

    def initialize(outdated_gems)
      @outdated_gems = outdated_gems
    end

    def update_outdated_gems
      puts "Updating outdated gems".color(:green)

      @outdated_gems.each_with_index do |gem, index|
        update_gem(gem, index)
      end
    end

    def update_gem(gem, index)
      puts "Updating #{gem[:name]}: #{index + 1} of #{@outdated_gems.count}"
      system("bundle update #{gem[:name]}")

      # Get the current (maybe new?) bundled version for this gem
      bundled_version = bundled_version_for(gem)

      # If the gem could not be updated at all
      if gem[:installed] == bundled_version
        log("#{gem[:name]} not updated")
        # might still be dependency updates, so cannot stop here

      # If the gem was updated, but not to latest
      elsif gem[:newest] != bundled_version
        log("#{gem[:name]} not updated from #{gem[:installed]} to latest: #{gem[:newest]}")
      end

      git.add("Gemfile")
      git.add("Gemfile.lock")
      git.add("vendor/cache")

      return unless git.files_staged?
      # ... something was changed

      # When the targeted gem itself is not modified, one of its dependencies must have been
      if gem[:installed] == bundled_version
        message = "Update #{gem[:name]} dependencies"
      else
        message = "Update #{gem[:name]} from #{gem[:installed]} to #{bundled_version}"
      end
      git.commit(message)
    end

    # NOTE: cannot be private method because it is tested specifically by updater_spec.rb
    def bundled_version_for(gem)
      string = %x{bundle list --paths | grep "#{gem[:name]}"}
      if string.empty?
        # :nocov: We don't need to test when an exception happens
        # Raise a understandable error message
        raise "FATAL: Unable to find '#{gem[:name]}' within 'bundle list --paths'."
        # :nocov: end
      end
      string.match(/#{gem[:name]}-(.*)$/)[1]
    end
  end
end
