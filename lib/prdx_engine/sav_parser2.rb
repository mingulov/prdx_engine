require_relative 'error'

module PrdxEngine
  class SavParser
    class << self
      def parse_file fname
        lines = File.readlines(fname)
        out = { nil => lines[0].chomp.strip }
        SavParseHelper lines[1..-1], out
        out
      end

      private
    
      def SavParseHelper lines, el
        el.compare_by_identity
        els = [el]
        el_last = el
        lc = 0
        deep = 1
        append_to_hash = lambda { |name, value|
          puts "z#{name} = #{value}" if el_last.nil?
          el_last[name] = value
          if value.is_a? Hash
            value.compare_by_identity
            el_last = value
            els.push el_last
          end
        }
        append_to_array = lambda { |value|
          if el_last.is_a? Array
            el_last.push value
          elsif el_last.is_a? Hash
            # converting is needed
            unless el_last.empty?
              raise Error, "Hash should become Array but is not empty: #{el_last.inspect}, value #{value}"
            end
            els.pop
            k = els.last.keys.last
            els.last[k] = [value]
            el_last = els.last[k]
            els.push el_last
          else
            raise Error, "Incorrect type"
          end
        }
        lines.each do |line|
          lc += 1
          line.chomp!
          line.strip!
          until line.empty?
            case line
            when /\A\s+/
              # skip spaces
            when /\A([-\.\w]+)=\s*(([^{]+|$))/
              if !$2.nil? && $2.to_s.length > 0
                append_to_hash.call $1, $2
              else
                #puts $1
                            append_to_hash.call $1, {}
              end
            when /\A([-\w]+)=/
                          append_to_hash.call $1, {}
            when /\A{/
              # go deeper, handled now in the previous 'when'
              deep += 1
              if (deep > els.length) && el_last.empty?
                # { {
                append_to_hash.call nil, {}
              end
              #puts "z#{el_last.inspect} #{deep} #{els.length}" if el_last.empty?
              #puts "!" unless el_last.empty?
            when /\A}/
              els.pop
              el_last = els.last
              deep -= 1
              #if el_last.nil?
              # puts "Deep: #{deep}, #{els.inspect}"
              #end
            when /\A\".*\"/, /\A\S+/
              if $&[-1] == '='
                #puts "'#{$&.inspect}'"
                #puts (/\A([-\.\w]+)=\s*([^{]*)/.match $&).inspect
              end
              append_to_array.call $&
            else
              raise Error, "Incorrect line: #{line}"
            end
            line = $'
          end
        end
      rescue
        #pp el
        raise Error, "Error at line #{lc}. #{$!.message}", $!.backtrace
      end
    end
  end
end # module PrdxEngine
