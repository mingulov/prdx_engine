require_relative 'error'

module PrdxEngine
  class << self
    def sav_parse str
      out = {}
      out.compare_by_identity
      _sav_parse out, str.to_s.clone.freeze
      out
    end

    def sav_parse_file filename
      contents = File.read filename
      sav_parse contents
    end

    private
    def _skip_string str, str_begin = 0, str_end = str.length, &block
      i = str_begin
      #puts "i=#{i}, str[i]='#{str[i]}', str_begin=#{str_begin}, str_end=#{str_end}"
      while (i < str_end) && block.call(str[i])
        i += 1
        #puts "i=#{i}, str[i] = '#{str[i]}'"
      end
      #puts "Skipped - #{str_begin} to #{i}, #{caller_locations(1)[0]}"
      i
    end

    def _sav_parse out, str, str_begin = 0, str_end = str.length
      i = str_begin
      name = ''
      values = []
      while i < str_end
        # skip non-characters
        i = _skip_string(str, i, str_end) { |c| c <= ' ' }
        # stop if the end of the line is reached already
        break if i >= str_end

        #puts "Current pos: #{i}, character '#{str[i]}'"
        case str[i]
        when '='
          #puts '='
          if values.length > 1
            values[0..-2].each { |item| out[''] = item }
          elsif values.empty?
            raise Error, "'=' without anything before, character #{i}, out=#{out}"
          end
          name = values.last
          values = []
        when '{'
          #puts '{'
          # parse nested {}
          res = {}
          res.compare_by_identity
          i = _sav_parse(res, str, i + 1, str_end)
          # name might be nil but it is ok
          out[name] = res
          name = ''
        when '}'
          #puts '}'
          values.each { |item| out[''] = item }
          values = []
          break if str_begin > 0
          raise Error, "'}' without '{' at #{i}"
        when nil
          # should be impossible
          raise Error, "Incorrect character #{i}"
        when '"'
          #puts '"'
          b = i
          # go to the next character (after closing '"')
          i = _skip_string(str, i + 1, str_end) { |c| c != '"' }
          # '"' must be included in the value
          values.push str[b..i]
          #puts "b=#{b} i=#{i} str[i]=#{str[i]} '#{values.last}'"
        else
          b = i
          # any other character - till space/tab/end of line
          i = _skip_string(str, i + 1, str_end) { |c| (c > ' ') and (c != '=') and (c != '}') }
          i -= 1
          #puts "B=#{b} i=#{i} str[i]=#{str[i]}"
          values.push str[b..i]
        end

        if !name.nil? and !name.empty? and !values.empty?
          out[name] = values.shift
          name = ''
        end
        #puts "Name #{name}, values: #{values.inspect}"

        # next character
        i += 1
        #puts "Current i=#{i}"
        #sleep 3
      end

      #puts "Values out: #{values.inspect}"
      # add remaining values
      values.each { |item| out[''] = item }

      #puts "#{str_begin} Out=#{out}" if str_begin == 0

      i
    end
  end # class
end # module PrdxEngine