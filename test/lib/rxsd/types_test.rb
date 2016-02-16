# rxsd types tests
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test_helper'

describe "RXSD Types" do

  # FIXME DateTime

  it "should convert string to/from bool" do
     assert "true".to_b
     refute "false".to_b
     assert_raises(ArgumentError) { 
        "foobar".to_b
      }

     assert_equal "money", String.from_s("money")
  end

  it "should convert bool to/from string" do
     assert Boolean.from_s("true")
     refute Boolean.from_s("false")
  end

  it "should convert char to/from string" do
     assert_equal "c", Char.from_s("c")
  end

  it "should convert int to/from string" do
     assert_equal 123, XSDInteger.from_s("123")
  end

  it "should convert float to/from string" do
     assert_equal 4.25, XSDFloat.from_s("4.25")
  end

  it "should convert array to/from string" do
     arr = Array.from_s "4 9 50 123", XSDInteger
     assert_equal 4, arr.size
     assert arr.include?(4)
     assert arr.include?(9)
     assert arr.include?(50)
     assert arr.include?(123)
  end
end
