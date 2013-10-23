require 'rubygems'
require 'pp'

if RUBY_VERSION < '1.9'
	raise LoadError, "Ruby 1.9 or newer is must to load this file due to ordered Hash feature usage"
end

module PrdxEngine
	class Error < StandardError
	end

	class SavedGame
		def load fname
		end
	end

	class << self
		def SavParse fname
			lines = File.readlines(fname)
			out = { nil => lines[0].chomp.strip }
			lines[0] = '{'
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
=begin
				if el_last.has_key? name
					# duplicate element
					if el_last[name].is_a? Array
						el_last[name].push value
					else
						el_last[name] = [el_last[name], value]
						p el_last[name]
					end
				end
=end
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
						#	puts "Deep: #{deep}, #{els.inspect}"
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
end # module PrdxEngine

if $0 == __FILE__
	if (ARGV.length == 0) || !File.exists?(ARGV[0])
		puts "Usage: #{$0} save_file"
		exit 0
	end

    fname = ARGV[0]
	out = PrdxEngine.SavParse(fname)
    pp out
	#engine = PrdxEngine.SavedGame.new
    #engine.load(fname)
end
