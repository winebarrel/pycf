# https://github.com/python/cpython/blob/2.7/Lib/ConfigParser.py
# (License: https://github.com/python/cpython/blob/2.7/LICENSE)
module Pycf
  def dump(hash)
    python_config = []

    hash.each do |section, key_values|
      python_config << "[#{section}]"

      key_values.each do |key, value|
        value = (value || '').gsub("\n", "\n\t")
        value = '""' if value.empty?
        python_config << "#{key} = #{value}"
      end
    end

    python_config.join("\n")
  end
  module_function :dump
end
