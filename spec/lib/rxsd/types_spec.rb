# rxsd types tests
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'spec_helper'

describe "RXSD Types" do

  # FIXME DateTime

  it "should convert string to/from bool" do
     expect("true".to_b).to be_truthy
     expect("false".to_b).to be_falsey
     expect {
        "foobar".to_b
     }.to raise_error(ArgumentError)

     expect(String.from_s("money")).to eq("money")
  end

  it "should convert bool to/from string" do
     expect(Boolean.from_s("true")).to be_truthy
     expect(Boolean.from_s("false")).to be_falsey
  end

  it "should convert char to/from string" do
     expect(Char.from_s("c")).to eq("c")
  end

  it "should convert int to/from string" do
     expect(XSDInteger.from_s("123")).to eq(123)
  end

  it "should convert float to/from string" do
     expect(XSDFloat.from_s("4.25")).to eq(4.25)
  end

  it "should convert array to/from string" do
     arr = Array.from_s "4 9 50 123", XSDInteger
     expect(arr.size).to eq(4)
     expect(arr.include?(4)).to be_truthy
     expect(arr.include?(9)).to be_truthy
     expect(arr.include?(50)).to be_truthy
     expect(arr.include?(123)).to be_truthy
  end
end
