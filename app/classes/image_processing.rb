module ImageProcessing

  def self.copy_file(input_file, output_file)
    cmd = %{
      cp "#{input_file}" "#{output_file}"
    }

    system cmd
  end

  def self.make_thumbnail_500(input_file, output_file)
    cmd = %{
       convert "#{input_file}" -resize 500x500\\> "#{output_file}"
    }

    system cmd
  end

  def self.make_thumbnail_300(input_file, output_file)
    cmd = %{
       convert "#{input_file}" -resize 300x300\\> "#{output_file}"
    }

    system cmd
  end

end
