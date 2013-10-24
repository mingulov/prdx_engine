require_relative '../spec_helper'
require 'benchmark'

describe PrdxEngine::SavParser do
 
  it "sav_parser" do
    expect(PrdxEngine::SavParser.parse("")).to eq({})
    expect(PrdxEngine::SavParser.parse("          ")).to eq({})
    expect(PrdxEngine::SavParser.parse("a=b").inspect).to eq('{"a"=>["b"]}')
    expect(PrdxEngine::SavParser.parse("zzz a=b").inspect).to eq('{""=>["zzz"], "a"=>["b"]}')
    expect(PrdxEngine::SavParser.parse(<<END
a=b
c = d
e=f
e=f
e={1 2 3 4 5}
END
).inspect).to eq('{"a"=>["b"], "c"=>["d"], "e"=>["f", "f", ["1", "2", "3", "4", "5"]]}')
    expect(PrdxEngine::SavParser.parse(<<END
title
-44={{f=1}{f=2}{f=3}{f=4}
}
END
).inspect).to eq('{""=>["title"], "-44"=>[[{"f"=>["1"]}, {"f"=>["2"]}, {"f"=>["3"]}, {"f"=>["4"]}]]}')
    expect(PrdxEngine::SavParser.parse(<<END
title
-44={{f=1}{f=2}{f=3}{f={a=b c=d e=f}}
}
END
).inspect).to eq('{""=>["title"], "-44"=>[[{"f"=>["1"]}, {"f"=>["2"]}, {"f"=>["3"]}, {"f"=>[{"a"=>["b"], "c"=>["d"], "e"=>["f"]}]}]]}')
    expect(PrdxEngine::SavParser.parse(<<END
title
"a=b c=d"="e=f"
END
).inspect).to eq('{""=>["title"], "\"a=b c=d\""=>["\"e=f\""]}')
    expect(PrdxEngine::SavParser.parse(<<END
title
"a=b c=d{}"="e=f"
END
).inspect).to eq('{""=>["title"], "\"a=b c=d{}\""=>["\"e=f\""]}')
  end
 
  it "parse_file" do
#=begin
    contents = nil
    puts Benchmark.realtime {
      contents = File.read File.join(File.dirname(__FILE__), '../data/big.sav')
    }
    puts Benchmark.realtime {
      PrdxEngine::SavParser.parse contents
    }
    puts Benchmark.realtime {
      PrdxEngine::SavParser.parse contents
    }
    puts Benchmark.realtime {
      PrdxEngine::SavParser.parse contents
    }
#=end
    #require 'prdx_engine/sav_parser2'
    #puts Benchmark.realtime {
    #  PrdxEngine::SavParser.parse_file File.join(File.dirname(__FILE__), '../data/big.sav')
    #}
  end
end
