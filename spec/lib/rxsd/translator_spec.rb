# tests the translator module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'spec_helper'

describe 'RXSD Translators' do

  # FIXME test child_attributes on all XSD classes!

  before(:each) do
    @data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType name="MyStrType">'+
               '  <xs:restriction base="xs:string" />' +
               '</xs:simpleType>' +
               '<xs:simpleType name="MyFArrType">'+
               '  <xs:list itemType="xs:float" />' +
               '</xs:simpleType>' +
               '<xs:complexType id="ct1" name="MyType">' +
                 '<xs:complexContent id="cc1">' +
                    '<xs:extension id="e1" base="xs:string">' +
                        '<xs:attribute name="my_s" type="xs:string"/>' +
                        '<xs:attribute name="my_a" type="MyFArrType" />' +
                    '</xs:extension>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
               '<xs:element name="Kaboom" type="MyStrType"/>' +
               '<xs:element name="Foomanchu" type="xs:boolean"/>' +
               '<xs:element name="MoMoney" type="MyType"/>' +
            '</schema>'
  end

  it "should generate correct schema tags" do
     schema = Parser.parse_xsd :raw => @data
     tags = schema.tags
     expect(tags.size).to eq(5)
     expect(tags.has_key?("Kaboom")).to be_truthy
     expect(tags.has_key?("Foomanchu")).to be_truthy
     expect(tags.has_key?("MoMoney")).to be_truthy
     expect(tags.has_key?("MoMoney:my_s")).to be_truthy
     expect(tags.has_key?("MoMoney:my_a")).to be_truthy
     expect(tags["Kaboom"]).not_to be_nil
  end

  #def test_schema_all_builders
  #end

  it "should generate ruby classes" do
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_classes
     expect(classes.size).to eq(6)
     expect(classes.include?(XSDFloat)).to be_truthy
     expect(classes.include?(Array)).to be_truthy
     expect(classes.include?(String)).to be_truthy
     expect(classes.include?(Boolean)).to be_truthy
     expect(classes.include?(Kaboom)).to be_truthy
     expect(classes.include?(MoMoney)).to be_truthy
     momoney = MoMoney.new
     expect(momoney.method(:my_s)).not_to be_nil
     expect(momoney.method(:my_s=)).not_to be_nil
     expect(momoney.method(:my_a)).not_to be_nil
     expect(momoney.method(:my_a=)).not_to be_nil
  end

  it "should generate ruby class definitions" do
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_definitions
     expect(classes.size).to eq(6)
     expect(classes.include?("class XSDFloat\nend")).to be_truthy
     expect(classes.include?("class Array\nend")).to be_truthy
     expect(classes.include?("class String\nend")).to be_truthy
     expect(classes.include?("class Boolean\nend")).to be_truthy
     expect(classes.include?("class Kaboom < String\nend")).to be_truthy
     expect(classes.include?("class MoMoney < String\n" +
                        "attr_accessor :my_s\n" +
                        "attr_accessor :my_a\n" +
                      "end")).to be_truthy
  end

  it "should generate ruby objects" do
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_classes

     instance = '<Kaboom>yo</Kaboom>'
     schema_instance = Parser.parse_xml :raw => instance
     objs = schema_instance.to :ruby_objects, :schema => schema
     expect(objs.size).to eq(1)
     expect(objs.collect { |o| o.class }.include?(Kaboom)).to be_truthy
     expect(objs.find { |o| o.class == Kaboom }).to eq("yo")

     instance = '<Foomanchu>true</Foomanchu>'
     schema_instance = Parser.parse_xml :raw => instance
     objs = schema_instance.to :ruby_objects, :schema => schema
     expect(objs.size).to eq(1)
     expect(objs[0]).to eq(true)

     instance = '<MoMoney my_s="abc" />'
     schema_instance = Parser.parse_xml :raw => instance
     objs = schema_instance.to :ruby_objects, :schema => schema
     expect(objs.size).to eq(1)
     expect(objs.collect { |o| o.class }.include?(MoMoney)).to be_truthy
     expect(objs.find { |o| o.class == MoMoney }.my_s).to eq("abc")
  end
end
