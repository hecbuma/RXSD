# tests the builder module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'spec_helper'

describe RXSD do

  # test to_class_builder method on all XSD classes

  it "should return schema class builders" do
    schema = Schema.new
    elem1  = MockXSDEntity.new
    elem2  = MockXSDEntity.new

    schema.elements = [elem1, elem2]
    class_builders = schema.to_class_builders

    expect(class_builders.size).to eq(2)
    expect(class_builders[0].class).to eq(ClassBuilder)
    expect(class_builders[0].instance_variable_get("@xsd_obj")).to eq(elem1)
    expect(class_builders[1].class).to eq(ClassBuilder)
    expect(class_builders[1].instance_variable_get("@xsd_obj")).to eq(elem2)
  end

  it "should return element class builders" do
    elem1 = MockXSDEntity.new
    st1   = MockXSDEntity.new
    ct1   = MockXSDEntity.new

    element = Element.new
    element.name = "foo_element"
    element.ref = elem1
    cb = element.to_class_builder
    expect(cb.class).to eq(ClassBuilder)
    expect(cb.instance_variable_get("@xsd_obj")).to eq(elem1)
    expect(cb.klass_name).to eq("FooElement")

    # FIXME the next two 'type' test cases need to be fixed / expanded
    element = Element.new
    element.name = "bar_element"
    element.type = st1
    cb = element.to_class_builder
    expect(cb.class).to eq(ClassBuilder)
    #cb.instance_variable_get("@xsd_obj").should == st1     TODO since clone is invoked, @xsd_obj test field never gets copied, fix this
    expect(cb.klass_name).to eq("BarElement")

    element = Element.new
    element.type = ct1
    cb = element.to_class_builder
    expect(cb.class).to eq(ClassBuilder)
    #cb.instance_variable_get("@xsd_obj").should == ct1

    element = Element.new
    element.simple_type = st1
    cb = element.to_class_builder
    expect(cb.class).to eq(ClassBuilder)
    expect(cb.instance_variable_get("@xsd_obj")).to eq(st1)

    element = Element.new
    element.complex_type = ct1
    cb = element.to_class_builder
    expect(cb.class).to eq(ClassBuilder)
    expect(cb.instance_variable_get("@xsd_obj")).to eq(ct1)
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
     expect(ab.size).to eq(5)
  end

  it "should build class" do
     cb1 = RubyClassBuilder.new :klass => String, :klass_name => "Widget"
     expect(cb1.build).to eq(String)

     cb2 = RubyClassBuilder.new :klass_name => "Foobar"
     c2 = cb2.build
     expect(c2).to eq(Foobar)
     expect(c2.superclass).to eq(Object)

     acb = RubyClassBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1
     ac = acb.build
     expect(ac).to eq(Array)

     tcb = RubyClassBuilder.new :klass_name => "CamelCased"

     cb3 = RubyClassBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     c3 = cb3.build
     expect(c3).to eq(Foomoney)
     expect(c3.superclass).to eq(Foobar)
     c3i = c3.new
     expect(c3i.method(:widget)).not_to be_nil
     expect(c3i.method(:widget).arity).to eq(0)
     expect(c3i.method(:widget=)).not_to be_nil
     expect(c3i.method(:widget=).arity).to eq(1)
     expect(c3i.method(:camel_cased)).not_to be_nil
     expect(c3i.method(:camel_cased).arity).to eq(0)
     expect(c3i.method(:camel_cased=)).not_to be_nil
     expect(c3i.method(:camel_cased=).arity).to eq(1)
     expect(c3i.method(:arr_socket)).not_to be_nil
     expect(c3i.method(:arr_socket).arity).to eq(0)
     expect(c3i.method(:arr_socket=)).not_to be_nil
     expect(c3i.method(:arr_socket=).arity).to eq(1)
  end

  it "should build definition" do
     cb1 = RubyDefinitionBuilder.new :klass => String, :klass_name => "Widget"
     expect(cb1.build).to eq("class String\nend")

     cb2 = RubyDefinitionBuilder.new :klass_name => "Foobar"
     d2 = cb2.build
     expect(d2).to eq("class Foobar < Object\nend")

     acb = RubyDefinitionBuilder.new :klass => Array, :klass_name => "ArrSocket", :associated_builder => cb1
     ad = acb.build
     expect(ad).to eq("class Array\nend")

     tcb = RubyDefinitionBuilder.new :klass_name => "CamelCased"

     cb3 = RubyDefinitionBuilder.new :klass_name => "Foomoney", :base_builder => cb2
     cb3.attribute_builders.push cb1
     cb3.attribute_builders.push tcb
     cb3.attribute_builders.push acb
     d3 = cb3.build
     expect(d3).to eq("class Foomoney < Foobar\n" +
                  "attr_accessor :widget\n" +
                  "attr_accessor :camel_cased\n" +
                  "attr_accessor :arr_socket\n" +
                  "end")
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

     expect(obj.class).to eq(Godzilla)
     expect(obj).to eq("some stuff")  # since obj derives from string
     expect(obj.first_attr).to eq("first_val")
     expect(obj.second_attr).to eq(420)


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

     expect(obj.class).to eq(Employee)
     expect(obj.ssn).to eq("111-22-3333")
     expect(obj.residency).to eq("citizen")
     expect(obj.firstname).to eq("mo")
     expect(obj.lastname).to eq("morsi")
     expect(obj.country).to eq("USA")
  end
end

class MockXSDEntity
  def to_class_builder
     cb = ClassBuilder.new
     cb.instance_variable_set("@xsd_obj", self)
     return cb
  end
end
