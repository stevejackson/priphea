class MiniExiftool
  # this class is copied from MiniExiftool 2.7.2
  #
  # I've changed the code that converted "2/8" to a Rational,
  # because this would turn track 2/8 to track 1/4.
  def convert_after_load tag, value
    return value unless value.kind_of?(String)
    return value unless value.valid_encoding?
    case value
    when /^\d{4}:\d\d:\d\d \d\d:\d\d:\d\d/
      s = value.sub(/^(\d+):(\d+):/, '\1-\2-')
      begin
        if @opts[:timestamps] == Time
          value = Time.parse(s)
        elsif @opts[:timestamps] == DateTime
          value = DateTime.parse(s)
        else
          raise MiniExiftool::Error.new("Value #{@opts[:timestamps]} not allowed for option timestamps.")
        end
      rescue ArgumentError
        value = false
      end
    when /^\+\d+\.\d+$/
      value = value.to_f
    when /^0+[1-9]+$/
      # nothing => String
    when /^-?\d+$/
      value = value.to_i
    when %r(^(\d+)/(\d+)$)
      # nothing => String
    when /^[\d ]+$/
      # nothing => String
    end
    value
  end
end
