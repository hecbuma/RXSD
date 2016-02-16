# tests the translator module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test_helper'

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
     assert_equal 5, tags.size
     assert tags.has_key?("Kaboom")
     assert tags.has_key?("Foomanchu")
     assert tags.has_key?("MoMoney")
     assert tags.has_key?("MoMoney:my_s")
     assert tags.has_key?("MoMoney:my_a")
     refute_nil tags["Kaboom"]
  end

  #def test_schema_all_builders
  #end

  it "should generate ruby classes" do
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_classes
     assert_equal 6, classes.size
     assert classes.include?(XSDFloat)
     assert classes.include?(Array)
     assert classes.include?(String)
     assert classes.include?(Boolean)
     assert classes.include?(Kaboom)
     assert classes.include?(MoMoney)
     momoney = MoMoney.new
     refute_nil momoney.method(:my_s)
     refute_nil momoney.method(:my_s=)
     refute_nil momoney.method(:my_a)
     refute_nil momoney.method(:my_a=)
  end

  it "should generate ruby class definitions" do
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_definitions
     assert_equal 6, classes.size
     assert classes.include?("class XSDFloat\nend")
     assert classes.include?("class Array\nend")
     assert classes.include?("class String\nend")
     assert classes.include?("class Boolean\nend")
     assert classes.include?("class Kaboom < String\nend")
     assert classes.include?("class MoMoney < String\n" +
                        "attr_accessor :my_s\n" +
                        "attr_accessor :my_a\n" +
                      "end")
  end

  it "should generate ruby objects" do
     schema = Parser.parse_xsd :raw => @data
     classes = schema.to :ruby_classes

     instance = '<Kaboom>yo</Kaboom>'
     schema_instance = Parser.parse_xml :raw => instance
     objs = schema_instance.to :ruby_objects, :schema => schema
     assert_equal 1, objs.size
     assert objs.collect { |o| o.class }.include?(Kaboom)
     assert_equal "yo", objs.find { |o| o.class == Kaboom }

     instance = '<Foomanchu>true</Foomanchu>'
     schema_instance = Parser.parse_xml :raw => instance
     objs = schema_instance.to :ruby_objects, :schema => schema
     assert_equal 1, objs.size
     assert_equal true, objs[0]

     instance = '<MoMoney my_s="abc" />'
     schema_instance = Parser.parse_xml :raw => instance
     objs = schema_instance.to :ruby_objects, :schema => schema
     assert_equal 1, objs.size
     assert objs.collect { |o| o.class }.include?(MoMoney)
     assert_equal "abc", objs.find { |o| o.class == MoMoney }.my_s
  end
end
