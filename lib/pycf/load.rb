# https://github.com/python/cpython/blob/2.7/Lib/ConfigParser.py
# (License: https://github.com/python/cpython/blob/2.7/LICENSE)
module Pycf
  SECTCRE = /\A\[(?<header>[^\]]+)\]/
  OPTCRE_NV = /\A(?<option>[^:=\s][^:=]*)\s*(?:(?<vi>[:=])\s*(?<value>.*))?\z/
  KEYCRE = /(\A|.)%\(([^)]+)\)s/

  def load(python_config, option = {})
    hash = {}

    cursect = nil
    optname = nil

    python_config.split("\n").each_with_index do |line, lineno_minus_1|
      lineno = lineno_minus_1 + 1

      if line.split.empty? or line =~ /\A[#;]/
        next
      end

      if line =~ /\Arem\s+/i
        next
      end

      if line =~ /\A\s/ and cursect and optname
        line.strip!
        cursect[optname] << "\n#{line}" unless line.empty?
      else
        if line =~ SECTCRE
          sectname = $~[:header]

          unless hash.has_key?(sectname)
            hash[sectname] = {}
          end

          cursect = hash[sectname]
          optname = nil
        elsif not cursect
          raise MissingSectionHeaderError.new(lineno, line)
        else
          if line =~ OPTCRE_NV
            optname = $~[:option].downcase.rstrip
            vi = $~[:vi]
            optval = $~[:value]

            if optval
              if %w(= :).include?(vi)
                optval.sub!(/\s;.*\z/, '')
              end

              optval.strip!

              if optval == '""'
                optval = ''
              end
            elsif not option[:allow_no_value]
              raise ParsingError.new(lineno, line)
            end

            cursect[optname] = optval
          else
            raise ParsingError.new(lineno, line)
          end
        end
      end
    end

    if option[:interpolation]
      hash.each do |section, key_values|
        key_values.each do |key, value|
          value.gsub!(KEYCRE) do
            preword = $1
            key = $2

            if preword == '%'
              "%(#{key})s"
            else
              key_values[key.downcase]
            end
          end
        end
      end
    end

    hash
  end
  module_function :load
end
