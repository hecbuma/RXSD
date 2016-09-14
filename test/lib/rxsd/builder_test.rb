# tests the builder module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test_helper'

describe RXSD do

  # test to_class_builder method on all XSD classes

  it "should return schema class builders" do
    schema = Schema.new
    elem1  = MockXSDEntity.new
    elem2  = MockXSDEntity.new

    schema.elements = [elem1, elem2]
    class_builders = schema.to_class_builders

    assert_equal 2, class_builders.size
    assert_equal ClassBuilder, class_builders[0].class
    assert_equal elem1, class_builders[0].instance_variable_get("@xsd_obj")
    assert_equal ClassBuilder, class_builders[1].class
    assert_equal elem2, class_builders[1].instance_variable_get("@xsd_obj")
  end

  it "should return element class builders" do
    elem1 = MockXSDEntity.new
    st1   = MockXSDEntity.new
    ct1   = MockXSDEntity.new

    element = Element.new
    element.name = "foo_element"
    element.ref = elem1
    cb = element.to_class_builder
    assert_equal ClassBuilder, cb.class
    assert_equal elem1, cb.instance_variable_get("@xsd_obj")
    assert_equal "FooElement", cb.klass_name

    # FIXME the next two 'type' test cases need to be fixed / expanded
    element = Element.new
    element.name = "bar_element"
    element.type = st1
    cb = element.to_class_builder
    assert_equal ClassBuilder, cb.class
    #cb.instance_variable_get("@xsd_obj").should == st1     TODO since clone is invoked, @xsd_obj test field never gets copied, fix this
    assert_equal "BarElement", cb.klass_name

    element = Element.new
    element.type = ct1
    cb = element.to_class_builder
    assert_equal ClassBuilder, cb.class
    #cb.instance_variable_get("@xsd_obj").should == ct1

    element = Element.new
    element.simple_type = st1
    cb = element.to_class_builder
    assert_equal ClassBuilder, cb.class
    assert_equal st1, cb.instance_variable_get("@xsd_obj")

    element = Element.new
    element.complex_type = ct1
    cb = element.to_class_builder
    assert_equal ClassBuilder, cb.class
    assert_equal ct1, cb.instance_variable_get("@xsd_obj")
  end

  # FIXME test other XSD classes' to_class_builder methods

  ##########

  it "should correctly return associated builders" do
     gp = ClassBuilder.new
     p  = ClassBuilder.new :base_builder => gp
     c  = ClassBuilder.new :base_builder => p
     as = ClassBuilder.new
     c.associated_builder = as
     at1 = ClassBuilder.new
     at2 = ClassBuilder.new
     c.attribute_builders.push at1
     c.attribute_builders.push at2

     ab = c.associated
     assert_equal 5, ab.size
  end

  it "should build class" do
     cb1 = RubyClassBuilder.new :klass => String, :klass_name => "Widget"
     assert_equal String, cb1.build

     cb2 = RubyClassBuilder.new :klass_name => "Foobar"
     c2 = cb2.build
     assert_equal Foobar, c2
     assert_equal Object, c2.superclass

     acb = RubyClassBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1
     ac = acb.build
     assert_equal Array, ac

     tcb = RubyClassBuilder.new :klass_name => "CamelCased"

     cb3 = RubyClassBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     c3 = cb3.build
     assert_equal Foomoney, c3
     assert_equal Foobar, c3.superclass
     c3i = c3.new
     refute_nil c3i.method(:widget)
     assert_equal 0, c3i.method(:widget).arity
     refute_nil c3i.method(:widget=)
     assert_equal 1, c3i.method(:widget=).arity
     refute_nil c3i.method(:camel_cased)
     assert_equal 0, c3i.method(:camel_cased).arity
     refute_nil c3i.method(:camel_cased=)
     assert_equal 1, c3i.method(:camel_cased=).arity
     refute_nil c3i.method(:arr_socket)
     assert_equal 0, c3i.method(:arr_socket).arity
     refute_nil c3i.method(:arr_socket=)
     assert_equal 1, c3i.method(:arr_socket=).arity
  end

  it "should build definition" do
     cb1 = RubyDefinitionBuilder.new :klass => String, :klass_name => "Widget"
     assert_equal "class String\nend", cb1.build

     cb2 = RubyDefinitionBuilder.new :klass_name => "Foobar"
     d2 = cb2.build
     assert_equal "class Foobar < Object\nend", d2

     acb = RubyDefinitionBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1
     ad = acb.build
     assert_equal "class Array\nend", ad

     tcb = RubyDefinitionBuilder.new :klass_name => "CamelCased"

     cb3 = RubyDefinitionBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     d3 = cb3.build
     assert_equal "class Foomoney < Foobar\n" +
                  "attr_accessor :widget\n" +
                  "attr_accessor :camel_cased\n" +
                  "attr_accessor :arr_socket\n" +
                  "end", d3
  end

  it "should build object" do
     schema_data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'>" +
                   "<xs:element name='Godzilla'>" +
                     "<xs:complexType>" +
                       "<xs:simpleContent>" +
                         "<xs:extension base='xs:string'>" +
                           "<xs:attribute name='first_attr' type='xs:string' />" +
                           "<xs:attribute name='SecondAttr' type='xs:integer' />" +
                         "</xs:extension>" +
                       "</xs:simpleContent>"+
                     "</xs:complexType>"+
                   "</xs:element>" +
                   "</schema>"

     schema = Parser.parse_xsd :raw => schema_data
     rbclasses = schema.to :ruby_classes

     rob = RubyObjectBuilder.new :tag_name => "Godzilla", :content => "some stuff", :attributes => { "first_attr" => "first_val", "SecondAttr" => "420" }
     obj = rob.build schema

     assert_equal Godzilla, obj.class
     assert_equal "some stuff", obj  # since obj derives from string
     assert_equal "first_val", obj.first_attr
     assert_equal 420, obj.second_attr


     schema_data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'>" +
                      '<xs:element name="employee" type="fullpersoninfo"/>' +
                         '<xs:complexType name="personinfo">'+
                            '<xs:attribute name="ssn" type="xs:string" />' +
                            '<xs:sequence>'+
                               '<xs:element name="firstname" type="xs:string"/>'+
                               '<xs:element name="lastname" type="xs:string"/>'+
                            '</xs:sequence>'+
                         '</xs:complexType>'+
                         '<xs:complexType name="fullpersoninfo">'+
                           '<xs:complexContent>'+
                             '<xs:extension base="personinfo">'+
                               '<xs:attribute name="residency" type="xs:string" />' +
                               '<xs:sequence>'+
                                 '<xs:element name="address" type="xs:string"/>'+
                                 '<xs:element name="country" type="xs:string"/>'+
                               '</xs:sequence>'+
                             '</xs:extension>'+
                           '</xs:complexContent>'+
                         '</xs:complexType> '+
                   "</schema>"

     schema = Parser.parse_xsd :raw => schema_data
     rbclasses = schema.to :ruby_classes

     rob = RubyObjectBuilder.new :tag_name => "employee", :attributes => { "ssn" => "111-22-3333", "residency" => "citizen" },
                             :children => [ ObjectBuilder.new(:tag_name => "firstname", :content => "mo" ),
                                            ObjectBuilder.new(:tag_name => "lastname",  :content => "morsi"),
                                            ObjectBuilder.new(:tag_name => "address",   :content => "wouldn't you like to know :-p"),
                                            ObjectBuilder.new(:tag_name => "country",   :content => "USA") ]

     obj = rob.build schema

     assert_equal Employee, obj.class
     assert_equal "111-22-3333", obj.ssn
     assert_equal "citizen", obj.residency
     assert_equal "mo", obj.firstname
     assert_equal "morsi", obj.lastname
     assert_equal "USA", obj.country
  end
end

class MockXSDEntity
  def to_class_builder
     cb = ClassBuilder.new
     cb.instance_variable_set("@xsd_obj", self)
     return cb
  end
end
