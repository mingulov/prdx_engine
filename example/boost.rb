require 'prdx_engine'

def main fname
  content = File.read fname
  h = PrdxEngine::SavParser.parse(content)
  puts h['player'].inspect

  out = PrdxEngine::SavParser.generate_file_content h
  File.open("sav", 'w') { |file| file.write(out) }
end

if $0 == __FILE__
  if (ARGV.length == 0) || !File.exists?(ARGV[0])
    puts "Usage: #{$0} save_file"
    exit 0
  end

  fname = ARGV[0]
  main fname
end
