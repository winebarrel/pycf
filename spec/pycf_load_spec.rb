require 'spec_helper'

describe Pycf do
  describe '#load' do
    let(:allow_no_value) { false }
    let(:interpolation) { false }

    subject do
      described_class.load(
        python_config,
        allow_no_value: allow_no_value,
        interpolation: interpolation
      )
    end

    context 'when basic config' do
      let(:python_config) do
        <<-EOS
[DEFAULT]
ServerAliveInterval = 45
Compression = yes
CompressionLevel = 9
ForwardX11 = yes

[bitbucket.org]
User = hg

[topsecret.server.com]
Port = 50022
ForwardX11 = no
        EOS
      end

      it do
        is_expected.to eq(
          {"DEFAULT"=>
            {"serveraliveinterval"=>"45",
             "compression"=>"yes",
             "compressionlevel"=>"9",
             "forwardx11"=>"yes"},
           "bitbucket.org"=>{"user"=>"hg"},
           "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}}
        )
      end
    end

    context 'when use colon' do
      let(:python_config) do
        <<-EOS
[DEFAULT]
ServerAliveInterval : 45
Compression : yes
CompressionLevel : 9
ForwardX11 : yes

[bitbucket.org]
User : hg

[topsecret.server.com]
Port : 50022
ForwardX11 : no
        EOS
      end

      it do
        is_expected.to eq(
          {"DEFAULT"=>
            {"serveraliveinterval"=>"45",
             "compression"=>"yes",
             "compressionlevel"=>"9",
             "forwardx11"=>"yes"},
           "bitbucket.org"=>{"user"=>"hg"},
           "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}}
        )
      end
    end

    context 'when marge section config' do
      let(:python_config) do
        <<-EOS
[topsecret.server.com]
Port = 50022

[topsecret.server.com]
ForwardX11 = no
        EOS
      end

      it do
        is_expected.to eq({"topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}})
      end
    end

    context 'when include nested value' do
      let(:python_config) do
        <<-EOS
[London Bridge]
London Bridge = broken down,
  My fair lady.
        EOS
      end

      it do
        is_expected.to eq({"London Bridge"=>{"london bridge"=>"broken down,\nMy fair lady."}})
      end
    end

    context 'when include comment' do
      let(:python_config) do
        <<-EOS
# comment
[DEFAULT]
; comment
ServerAliveInterval = 45 ; comment
# comment
Compression = yes
rem comment
CompressionLevel = 9
ForwardX11 = yes
Rem comment
        EOS
      end

      it do
        is_expected.to eq(
          {"DEFAULT"=>
            {"serveraliveinterval"=>"45",
             "compression"=>"yes",
             "compressionlevel"=>"9",
             "forwardx11"=>"yes"}}
        )
      end
    end

    context 'when include empty value' do
      let(:python_config) do
        <<-EOS
[topsecret.server.com]
ForwardX11 = ""
        EOS
      end

      it do
        is_expected.to eq({"topsecret.server.com"=>{"forwardx11"=>""}})
      end
    end

    context 'when include invalid comment' do
      let(:python_config) do
        <<-EOS
[DEFAULT]
  # comment
ServerAliveInterval = 45
Compression = yes
CompressionLevel = 9
ForwardX11 = yes
        EOS
      end

      it do
        expect { subject }.to raise_error Pycf::ParsingError
      end
    end

    context 'when include tail comment' do
      let(:python_config) do
        <<-EOS
[DEFAULT]
ServerAliveInterval = 45;comment
Compression = yes
CompressionLevel = 9
ForwardX11 = yes
        EOS
      end

      it do
        is_expected.to eq(
          {"DEFAULT"=>
            {"serveraliveinterval"=>"45;comment",
             "compression"=>"yes",
             "compressionlevel"=>"9",
             "forwardx11"=>"yes"}}
        )
      end
    end

    context 'when no value (allow_no_value: false)' do
      let(:python_config) do
        <<-EOS
[DEFAULT]
ServerAliveInterval
        EOS
      end

      it do
        expect { subject }.to raise_error Pycf::ParsingError
      end
    end

    context 'when no value (allow_no_value: true)' do
      let(:allow_no_value) { true }

      let(:python_config) do
        <<-EOS
[DEFAULT]
ServerAliveInterval
        EOS
      end

      it do
        is_expected.to eq({"DEFAULT"=>{"serveraliveinterval"=>nil}})
      end
    end

    context 'when no section' do
      let(:python_config) do
        <<-EOS
ServerAliveInterval
        EOS
      end

      it do
        expect { subject }.to raise_error Pycf::MissingSectionHeaderError
      end
    end

    context 'when use interpolation' do
      let(:interpolation) { true }

      context 'when replace key' do
        let(:python_config) do
          <<-EOS
[DEFAULT]
ServerAliveInterval = 45
Compression = yes
CompressionLevel = %(serveraliveinterval)s
ForwardX11 = %(Compression)s

[bitbucket.org]
User = hg

[topsecret.server.com]
Port = 50022
ForwardX11 = no
          EOS
        end

        it do
          is_expected.to eq(
            {"DEFAULT"=>
              {"serveraliveinterval"=>"45",
               "compression"=>"yes",
               "compressionlevel"=>"45",
               "forwardx11"=>"yes"},
             "bitbucket.org"=>{"user"=>"hg"},
             "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}}
          )
        end
      end

      context 'when escape interpolation' do
        let(:python_config) do
          <<-EOS
[DEFAULT]
ServerAliveInterval = 45
Compression = yes
CompressionLevel = %(serveraliveinterval)s
ForwardX11 = %%(Compression)s

[bitbucket.org]
User = hg

[topsecret.server.com]
Port = 50022
ForwardX11 = no
          EOS
        end

        it do
          is_expected.to eq(
            {"DEFAULT"=>
              {"serveraliveinterval"=>"45",
               "compression"=>"yes",
               "compressionlevel"=>"45",
               "forwardx11"=>"%(Compression)s"},
             "bitbucket.org"=>{"user"=>"hg"},
             "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}}
          )
        end
      end

      context 'when include invalid interpolation' do
        let(:python_config) do
          <<-EOS
[DEFAULT]
ServerAliveInterval = 45
Compression = yes
CompressionLevel = %(serveraliveinterval)
ForwardX11 = %(XXX)s

[bitbucket.org]
User = hg

[topsecret.server.com]
Port = 50022
ForwardX11 = %(Compression)s
          EOS
        end

        it do
          is_expected.to eq(
            {"DEFAULT"=>
              {"serveraliveinterval"=>"45",
               "compression"=>"yes",
               "compressionlevel"=>"%(serveraliveinterval)",
               "forwardx11"=>""},
             "bitbucket.org"=>{"user"=>"hg"},
             "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>""}}
          )
        end
      end
    end
  end
end
