# Pycf

Configuration file parser for [Python 2.7 basic configuration file](https://docs.python.org/2.7/library/configparser.html).

see [ConfigParser.py](https://github.com/python/cpython/blob/2.7/Lib/ConfigParser.py).

[![Gem Version](https://badge.fury.io/rb/pycf.svg)](http://badge.fury.io/rb/pycf)
[![Build Status](https://travis-ci.org/winebarrel/pycf.svg?branch=master)](https://travis-ci.org/winebarrel/pycf)
[![Coverage Status](https://coveralls.io/repos/winebarrel/pycf/badge.svg?branch=master)](https://coveralls.io/r/winebarrel/pycf?branch=master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pycf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pycf

## Usage

### load

```ruby
require 'pycf'

python_config = <<EOS
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

p Pycf.load(python_config)
# => {"DEFAULT"=>
#      {"serveraliveinterval"=>"45",
#       "compression"=>"yes",
#       "compressionlevel"=>"9",
#       "forwardx11"=>"yes"},
#     "bitbucket.org"=>{"user"=>"hg"},
#     "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}}
```

### dump

```ruby
require 'pycf'
require 'pp'

hash = {"DEFAULT"=>
         {"serveraliveinterval"=>"45",
          "compression"=>"yes",
          "compressionlevel"=>"9",
          "forwardx11"=>"yes"},
        "bitbucket.org"=>{"user"=>"hg"},
        "topsecret.server.com"=>{"port"=>"50022", "forwardx11"=>"no"}}

puts Pycf.dump(hash)
# => [DEFAULT]
#    serveraliveinterval = 45
#    compression = yes
#    compressionlevel = 9
#    forwardx11 = yes
#    [bitbucket.org]
#    user = hg
#    [topsecret.server.com]
#    port = 50022
#    forwardx11 = no
```

### Interpolation

```ruby
require 'pycf'

python_config = <<EOS
[My Section]
foodir: %(dir)s/whatever
dir=frob
long: this value continues
   in the next line
EOS

p Pycf.load(python_config, interpolation: true)
# => {"My Section"=>
#      {"foodir"=>"frob/whatever",
#       "dir"=>"frob",
#       "long"=>"this value continues\nin the next line"}}
```
