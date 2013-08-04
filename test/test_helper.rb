require 'coveralls'
Coveralls.wear! do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'

