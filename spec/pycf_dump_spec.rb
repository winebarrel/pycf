require 'spec_helper'

describe Pycf do
  describe '#dump' do
    subject { Pycf.dump(hash) }

    context 'when dump config' do
      let(:hash) do
        {"Simple Values"=>
          {"key"=>"value",
           "spaces in keys"=>"allowed",
           "spaces in values"=>"allowed as well",
           "spaces around the delimiter"=>"obviously",
           "you can also use"=>"to delimit keys from values"},
         "All Values Are Strings"=>
          {"values like this"=>"1000000",
           "or this"=>"3.14159265359",
           "are they treated as numbers?"=>"no",
           "integers, floats and booleans are held as"=>"strings",
           "can use the api to get converted values directly"=>"true"},
         "Multiline Values"=>
          {"chorus"=>
            "I'm a lumberjack, and I'm okay\nI sleep all night and I work all day"},
         "No Values"=>{"key_without_value"=>nil, "empty string value here"=>""},
         "You can use comments"=>{},
         "Sections Can Be Indented"=>
          {"can_values_be_as_well"=>"True",
           "does_that_mean_anything_special"=>"False",
           "purpose"=>"formatting for readability",
           "multiline_values"=>
            "are\nhandled just fine as\nlong as they are indented\ndeeper than the first line\nof a value"}}
      end

      it do
        is_expected.to eq <<-EOS.chomp
[Simple Values]
key = value
spaces in keys = allowed
spaces in values = allowed as well
spaces around the delimiter = obviously
you can also use = to delimit keys from values
[All Values Are Strings]
values like this = 1000000
or this = 3.14159265359
are they treated as numbers? = no
integers, floats and booleans are held as = strings
can use the api to get converted values directly = true
[Multiline Values]
chorus = I'm a lumberjack, and I'm okay
\tI sleep all night and I work all day
[No Values]
key_without_value = ""
empty string value here = ""
[You can use comments]
[Sections Can Be Indented]
can_values_be_as_well = True
does_that_mean_anything_special = False
purpose = formatting for readability
multiline_values = are
\thandled just fine as
\tlong as they are indented
\tdeeper than the first line
\tof a value
        EOS
      end
    end

    context 'when invalid hash' do
      let(:hash) { 1 }

      it do
        expect { subject }.to raise_error TypeError
      end
    end

    context 'when dump no string value' do
      let(:hash) {
        {"Simple Values"=>
          {"values like this"=>1000000,
           "or this"=>3.14159265359,
           "are they treated as numbers?"=>false,
           "integers, floats and booleans are held as"=>"strings",
           "can use the api to get converted values directly"=>true}}
      }

      it do
        is_expected.to eq <<-EOS.chomp
[Simple Values]
values like this = 1000000
or this = 3.14159265359
are they treated as numbers? = false
integers, floats and booleans are held as = strings
can use the api to get converted values directly = true
        EOS
      end
    end
  end
end
