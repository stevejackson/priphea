require 'guard/compat/plugin'
require 'moped'

# the double-colons below are *required* for inline Guards!!!

module ::Guard
  class Monitor < Plugin
    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      super

    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
    end

    def insert_into_file_notifications(paths, event_type)
      begin
        session = Moped::Session.new([ "127.0.0.1:27017" ])
        if ENV["RAILS_ENV"] == 'production'
          session.use("priphea-production")
        else
          session.use("priphea-development")
        end

        if paths.is_a? String
          paths = [paths]
        end

        entries = []
        paths.each do |path|
          entries << {
            path: File.expand_path(path),
            type: event_type
          }

          puts "Event type - #{event_type} - On path --- #{path.inspect}"
        end

        entries.each do |entry|
          # fn = FileNotification.new
          # fn.path = entry[:path]
          # fn.event_type = entry[:event_type]
          # fn.save!
          session[:file_notifications].insert(entry)
          puts "Created file notifciation: #{entry.inspect}"
        end

        true
      rescue Exception => e
        puts "!!! Caught exception. #{e.backtrace}"
        raise e
      end
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
      insert_into_file_notifications(paths, "addition")
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
      insert_into_file_notifications(paths, "modification")
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
      insert_into_file_notifications(paths, "removal")
    end

  end
end

#notification :growl_notify

paths = if ENV["RAILS_ENV"] == "production"
  %w{ /Volumes/Kiki/musiclib }
else
  %w{ /Users/steve/fakemusiclib }
end


directories paths
guard :monitor do
  watch %r{/(.+).(flac|mp3)}
end
