require_relative '../spec_helper'

describe PrdxEngine do
 
  it "sav_parser" do
    expect(PrdxEngine.sav_parse("")).to eq({})
    expect(PrdxEngine.sav_parse("          ")).to eq({})
    expect(PrdxEngine.sav_parse("a=b").inspect).to eq('{"a"=>"b"}')
    expect(PrdxEngine.sav_parse("zzz a=b").inspect).to eq('{""=>"zzz", "a"=>"b"}')
    expect(PrdxEngine.sav_parse(<<END
a=b
c = d
e=f
e=f
e={1 2 3 4 5}
END
).inspect).to eq('{"a"=>"b", "c"=>"d", "e"=>"f", "e"=>"f", "e"=>{""=>"1", ""=>"2", ""=>"3", ""=>"4", ""=>"5"}}')
    expect(PrdxEngine.sav_parse(<<END
title
-44={{f=1}{f=2}{f=3}{f=4}
}
END
).inspect).to eq('{""=>"title", "-44"=>{""=>{"f"=>"1"}, ""=>{"f"=>"2"}, ""=>{"f"=>"3"}, ""=>{"f"=>"4"}}}')
    expect(PrdxEngine.sav_parse(<<END
title
-44={{f=1}{f=2}{f=3}{f={a=b c=d e=f}}
}
END
).inspect).to eq('{""=>"title", "-44"=>{""=>{"f"=>"1"}, ""=>{"f"=>"2"}, ""=>{"f"=>"3"}, ""=>{"f"=>{"a"=>"b", "c"=>"d", "e"=>"f"}}}}')
    expect(PrdxEngine.sav_parse(<<END
title
"a=b c=d"="e=f"
END
).inspect).to eq('{""=>"title", "\"a=b c=d\""=>"\"e=f\""}')
    expect(PrdxEngine.sav_parse(<<END
title
"a=b c=d{}"="e=f"
END
).inspect).to eq('{""=>"title", "\"a=b c=d{}\""=>"\"e=f\""}')
  end
 
end
