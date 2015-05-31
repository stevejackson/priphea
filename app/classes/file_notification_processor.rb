module FileNotificationProcessor

  # looks at the "file_notifications" table and checks for entries.
  # these are normally created by guard.
  def self.process!
    puts "---"
    puts "Running FileNotificationProcessor."
    puts "#{FileNotification.count} new notifications."

    fn_ids_processed = []

    FileNotification.all.each do |fn|
      puts "Processing notification: #{fn.inspect}"
      scanner = Scanner.new(Settings.library_path)
      song = scanner.import_song_to_database(fn.path)

      if song && song.album
        song.album.update_cover_art_cache
      end

      fn_ids_processed << fn.id
    end

    fn_ids_processed.each do |id|
      puts "Deleting notification: #{id}"
      FileNotification.find(id).delete
    end
  end

end
