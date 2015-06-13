# https://github.com/python/cpython/blob/2.7/Lib/ConfigParser.py
# (License: https://github.com/python/cpython/blob/2.7/LICENSE)
module Pycf
  class ParsingError < StandardError
    def initialize(lineno, line)
      super(
        error_message +
        "\n\t[line %2d]: %s" % [lineno, line]
      )
    end

    def error_message
      'parsing errors.'
    end
  end

  class MissingSectionHeaderError < ParsingError
    def error_message
      'no section headers.'
    end
  end
end
