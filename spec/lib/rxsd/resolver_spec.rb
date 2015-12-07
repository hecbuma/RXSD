# tests the resolver module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'spec_helper'

describe RXSD::Resolver do

  # test children method on all XSD classes

  it "should return schema children" do
     schema = Schema.new
     elem1  = Element.new
     elem2  = Element.new
     st1    = SimpleType.new
     ct1    = ComplexType.new
     at1    = Attribute.new
     at2    = Attribute.new
     at3    = Attribute.new
     atg1   = AttributeGroup.new
     grp1   = Group.new
     grp2   = Group.new

     schema.elements     = [elem1, elem2]
     schema.simple_types = [st1]
     schema.complex_types = [ct1]
     schema.attributes   = [at1, at2, at3]
     schema.attribute_groups   = [atg1]
     schema.groups       = [grp1, grp2]

     children = schema.children
     expect(children.include?(elem1)).to be_truthy
     expect(children.include?(elem2)).to be_truthy
     expect(children.include?(st1)).to be_truthy
     expect(children.include?(ct1)).to be_truthy
     expect(children.include?(at1)).to be_truthy
     expect(children.include?(at2)).to be_truthy
     expect(children.include?(at3)).to be_truthy
     expect(children.include?(atg1)).to be_truthy
     expect(children.include?(grp1)).to be_truthy
     expect(children.include?(grp2)).to be_truthy
  end

  it "should return element children" do
     elem  = Element.new
     st1    = SimpleType.new
     ct1    = ComplexType.new
     elem.simple_type  = st1
     elem.complex_type = ct1

     children = elem.children
     expect(children.include?(st1)).to be_truthy
     expect(children.include?(ct1)).to be_truthy
  end

  it "should return complex type children" do
     complex_type   = ComplexType.new
     at1    = Attribute.new
     atg1   = AttributeGroup.new
     simple_content   = SimpleContent.new
     complex_content  = ComplexContent.new
     choice    = Choice.new
     group     = Group.new
     sequence  = Sequence.new

     complex_type.attributes = [at1]
     complex_type.attribute_groups = [atg1]
     complex_type.simple_content  = simple_content
     complex_type.complex_content = complex_content
     complex_type.choice = choice
     complex_type.group  = group
     complex_type.sequence  = sequence

     children = complex_type.children
     expect(children.include?(at1)).to be_truthy
     expect(children.include?(atg1)).to be_truthy
     expect(children.include?(simple_content)).to be_truthy
     expect(children.include?(complex_content)).to be_truthy
     expect(children.include?(choice)).to be_truthy
     expect(children.include?(group)).to be_truthy
     expect(children.include?(sequence)).to be_truthy
  end

  it "should return simple type children" do
     simple_type   = SimpleType.new
     list    = List.new
     res     = Restriction.new

     simple_type.list = list
     simple_type.restriction = res

     children = simple_type.children
     expect(children.include?(list)).to be_truthy
     expect(children.include?(res)).to be_truthy
  end

  it "should return attribute children" do
     att    = Attribute.new
     simple_type   = SimpleType.new

     att.simple_type = simple_type

     children = att.children
     expect(children.include?(simple_type)).to be_truthy
  end

  it "should return attribute group children" do
     atg    = AttributeGroup.new
     at1    = Attribute.new
     at2    = Attribute.new
     atg1   = AttributeGroup.new
     atg.attributes = [at1, at2]
     atg.attribute_groups = [atg1]

     children = atg.children
     expect(children.include?(at1)).to be_truthy
     expect(children.include?(at2)).to be_truthy
     expect(children.include?(atg1)).to be_truthy
  end

  it "should return group children" do
     grp    = Group.new
     choice    = Choice.new
     sequence  = Sequence.new

     grp.choice = choice
     grp.sequence = sequence

     children = grp.children
     expect(children.include?(choice)).to be_truthy
     expect(children.include?(sequence)).to be_truthy
  end

  it "should return list children" do
     list    = List.new
     simple_type   = SimpleType.new

     list.simple_type = simple_type

     children = list.children
     expect(children.include?(simple_type)).to be_truthy
  end

  it "should return simple content children" do
     simple_content   = SimpleContent.new
     ext     = Extension.new
     res     = Restriction.new

     simple_content.extension = ext
     simple_content.restriction = res

     children = simple_content.children
     expect(children.include?(ext)).to be_truthy
     expect(children.include?(res)).to be_truthy
  end

  it "should return choice children" do
    choice     = Choice.new
    elem1  = Element.new
    elem2  = Element.new
    grp1       = Group.new
    choice1    = Choice.new
    choice2    = Choice.new
    choice3    = Choice.new
    sequence1  = Sequence.new

    choice.elements = [elem1, elem2]
    choice.groups = [grp1]
    choice.choices = [choice1, choice2, choice3]
    choice.sequences = [sequence1]

    children = choice.children
    expect(children.include?(grp1)).to be_truthy
    expect(children.include?(choice1)).to be_truthy
    expect(children.include?(choice2)).to be_truthy
    expect(children.include?(choice3)).to be_truthy
    expect(children.include?(sequence1)).to be_truthy
  end

  it "should return complex content children" do
     complex_content   = ComplexContent.new
     ext     = Extension.new
     res     = Restriction.new

     complex_content.extension = ext
     complex_content.restriction = res

     children = complex_content.children
     expect(children.include?(ext)).to be_truthy
     expect(children.include?(res)).to be_truthy
  end

  it "should return sequence children" do
    sequence     = Sequence.new
    elem1  = Element.new
    elem2  = Element.new
    grp1       = Group.new
    choice1    = Choice.new
    choice2    = Choice.new
    choice3    = Choice.new
    sequence1  = Sequence.new

    sequence.elements = [elem1, elem2]
    sequence.groups = [grp1]
    sequence.choices = [choice1, choice2, choice3]
    sequence.sequences = [sequence1]

    children = sequence.children
    expect(children.include?(grp1)).to be_truthy
    expect(children.include?(choice1)).to be_truthy
    expect(children.include?(choice2)).to be_truthy
    expect(children.include?(choice3)).to be_truthy
    expect(children.include?(sequence1)).to be_truthy
  end

  it "should return extension children" do
    extension     = Extension.new
    grp1       = Group.new
    choice1    = Choice.new
    sequence1  = Sequence.new
    at1    = Attribute.new
    atg1   = AttributeGroup.new

    extension.group = grp1
    extension.choice = choice1
    extension.sequence = sequence1
    extension.attributes = [at1]
    extension.attribute_groups = [atg1]

    children = extension.children
    expect(children.include?(grp1)).to be_truthy
    expect(children.include?(choice1)).to be_truthy
    expect(children.include?(sequence1)).to be_truthy
    expect(children.include?(at1)).to be_truthy
    expect(children.include?(atg1)).to be_truthy
  end

  it "should return restriction children" do
    restriction     = Restriction.new
    grp1       = Group.new
    choice1    = Choice.new
    sequence1  = Sequence.new
    at1    = Attribute.new
    atg1   = AttributeGroup.new
    st1    = SimpleType.new

    restriction.group = grp1
    restriction.choice = choice1
    restriction.sequence = sequence1
    restriction.attributes = [at1]
    restriction.attribute_groups = [atg1]
    restriction.simple_type = st1

    children = restriction.children
    expect(children.include?(grp1)).to be_truthy
    expect(children.include?(choice1)).to be_truthy
    expect(children.include?(sequence1)).to be_truthy
    expect(children.include?(at1)).to be_truthy
    expect(children.include?(atg1)).to be_truthy
    expect(children.include?(st1)).to be_truthy
  end

  ##########

  # test resolve method on all XSD classes

  it "should resolve schema relationships" do
    # currently nothing to verify
  end

  it "should resolve element relationships" do
     schema = Schema.new
     schema.elements = schema.simple_types = schema.complex_types = []

     element1 = Element.new
     element1.type = "xs:string"
     element1.name = "element1"

     simple_type = SimpleType.new
     simple_type.name = "simple_type_test"
     element2 = Element.new
     element2.type = simple_type.name
     element2.ref = element1.name

     complex_type = ComplexType.new
     complex_type.attributes = complex_type.attribute_groups = []
     complex_type.name = "complex_type_test"
     element3 = Element.new
     element3.type = complex_type.name
     element3.substitutionGroup = element1.name

     schema.elements << element1 << element2 << element3
     schema.simple_types  << simple_type
     schema.complex_types << complex_type

     node_objs = Resolver.node_objects(schema)
     element1.resolve(node_objs)
     element2.resolve(node_objs)
     element3.resolve(node_objs)

     expect(element1.type).to eq(String)
     expect(element2.type).to eq(simple_type)
     expect(element2.ref).to  eq(element1)
     expect(element3.type).to eq(complex_type)
     expect(element3.substitutionGroup).to  eq(element1)
  end

  it "should resolve complex type relationships" do
    # currently nothing to verify
  end

  it "should resolve simple type relationships" do
    # currently nothing to verify
  end

  it "should resolve attribute relationships" do
     schema = Schema.new
     schema.attributes = schema.simple_types = []

     attr1 = Attribute.new
     attr1.type = "xs:int"
     attr1.name = "attr1"

     simple_type = SimpleType.new
     simple_type.name = "simple_type_test"
     attr2 = Attribute.new
     attr2.type = simple_type.name
     attr2.ref = attr1.name

     schema.attributes   << attr1 << attr2
     schema.simple_types << simple_type

     node_objs = Resolver.node_objects(schema)
     attr1.resolve(node_objs)
     attr2.resolve(node_objs)

     expect(attr1.type).to eq(XSDInteger)
     expect(attr2.type).to eq(simple_type)
     expect(attr2.ref).to eq(attr1)
  end

  it "should resolve attribute group relationships" do
     schema = Schema.new
     schema.attribute_groups = []

     attr_grp1 = AttributeGroup.new
     attr_grp1.attributes = attr_grp1.attribute_groups = []
     attr_grp1.name = "attr1"
     attr_grp2 = AttributeGroup.new
     attr_grp2.attributes = attr_grp2.attribute_groups = []
     attr_grp2.ref = attr_grp1.name

     schema.attribute_groups << attr_grp1 << attr_grp2
     node_objs = Resolver.node_objects(schema)
     attr_grp1.resolve(node_objs)
     attr_grp2.resolve(node_objs)

     expect(attr_grp2.ref).to eq(attr_grp1)
  end

  it "should resolve group relationships" do
     schema = Schema.new
     schema.groups = []

     grp1 = Group.new
     grp1.name = "grp1"
     grp2 = Group.new
     grp2.ref = grp1.name

     schema.groups << grp1 << grp2
     node_objs = Resolver.node_objects(schema)
     grp1.resolve(node_objs)
     grp2.resolve(node_objs)

     expect(grp2.ref).to eq(grp1)
  end

  it "should resolve list relationships" do
     schema = Schema.new
     simple_type1 = SimpleType.new
     simple_type1.name = "simple_type_test1"
     simple_type2 = SimpleType.new
     simple_type2.name = "simple_type_test2"
     simple_type3 = SimpleType.new
     simple_type3.name = "simple_type_test3"
     schema.simple_types = [simple_type1, simple_type2, simple_type3]

     list1 = List.new
     list1.itemType = "xs:float"

     list2 = List.new
     list2.itemType = simple_type3.name

     simple_type1.list = list1
     simple_type2.list = list2

     node_objs = Resolver.node_objects(schema)
     list1.resolve(node_objs)
     list2.resolve(node_objs)

     expect(list1.itemType).to eq(XSDFloat)
     expect(list2.itemType).to eq(simple_type3)
  end

  it "should resolve simple content relationships" do
    # currently nothing to verify
  end

  it "should resolve choice relationships" do
    # currently nothing to verify
  end

  it "should resolve complex content relationships" do
    # currently nothing to verify
  end

  it "should resolve sequence relationships" do
    # currently nothing to verify
  end

  it "should resolve restriction relationships" do
    # currently nothing to verify
  end

  it "should resolve extension relationships" do
     schema = Schema.new
     simple_type1 = SimpleType.new
     simple_type1.name = "simple_type_test1"

     complex_content1 = ComplexContent.new
     complex_type1 = ComplexType.new
     complex_type1.name = "complex_type_test1"
     complex_type1.attributes = complex_type1.attribute_groups = []
     complex_type1.complex_content = complex_content1

     complex_content2 = ComplexContent.new
     complex_type2 = ComplexType.new
     complex_type2.name   = "complex_type_test2"
     complex_type2.attributes = complex_type2.attribute_groups = []
     complex_type2.complex_content = complex_content2

     complex_content3 = ComplexContent.new
     complex_type3 = ComplexType.new
     complex_type3.name   = "complex_type_test2"
     complex_type3.attributes = complex_type3.attribute_groups = []
     complex_type3.complex_content = complex_content3

     schema.simple_types  = [simple_type1]
     schema.complex_types = [complex_type1, complex_type2, complex_type3]

     extension1 = Extension.new
     extension1.base = "xs:byte"

     extension2 = Extension.new
     extension2.base = simple_type1.name

     extension3 = Extension.new
     extension3.base = complex_type1.name

     complex_type1.complex_content.extension = extension1
     complex_type2.complex_content.extension = extension2
     complex_type3.complex_content.extension = extension3

     node_objs = Resolver.node_objects(schema)
     extension1.resolve(node_objs)
     extension2.resolve(node_objs)
     extension3.resolve(node_objs)

     expect(extension1.base).to eq(Char)
     expect(extension2.base).to eq(simple_type1)
     expect(extension3.base).to eq(complex_type1)
  end

  it "should resolve restriction relationships" do
     schema = Schema.new
     simple_type1 = SimpleType.new
     simple_type1.name = "simple_type_test1"

     complex_content1 = ComplexContent.new
     complex_type1 = ComplexType.new
     complex_type1.name = "complex_type_test1"
     complex_type1.attributes = complex_type1.attribute_groups = []
     complex_type1.complex_content = complex_content1

     complex_content2 = ComplexContent.new
     complex_type2 = ComplexType.new
     complex_type2.name   = "complex_type_test2"
     complex_type2.attributes = complex_type2.attribute_groups = []
     complex_type2.complex_content = complex_content2

     complex_content3 = ComplexContent.new
     complex_type3 = ComplexType.new
     complex_type3.name   = "complex_type_test2"
     complex_type3.attributes = complex_type3.attribute_groups = []
     complex_type3.complex_content = complex_content3

     schema.simple_types  = [simple_type1]
     schema.complex_types = [complex_type1, complex_type2, complex_type3]

     restriction1 = Restriction.new
     restriction1.base = "xs:byte"

     restriction2 = Restriction.new
     restriction2.base = simple_type1.name

     restriction3 = Restriction.new
     restriction3.base = complex_type1.name

     complex_type1.complex_content.restriction = restriction1
     complex_type2.complex_content.restriction = restriction2
     complex_type3.complex_content.restriction = restriction3

     node_objs = Resolver.node_objects(schema)
     restriction1.resolve(node_objs)
     restriction2.resolve(node_objs)
     restriction3.resolve(node_objs)

     expect(restriction1.base).to eq(Char)
     expect(restriction2.base).to eq(simple_type1)
     expect(restriction3.base).to eq(complex_type1)
  end


  ###########

  it "should correctly resolve node objects" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:extension id="e1" base="Foo">' +
                        '<xs:group id="g1" />' +
                        '<xs:attribute id="a1" />' +
                        '<xs:attribute id="a2" />' +
                    '</xs:extension>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
               '<xs:complexType id="ct2">' +
                 '<xs:choice id="c1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element id="e2" />' +
                 '  <xs:element ref="Foobar" />' +
                 '  <xs:choice id="c2" />' +
                 '  <xs:choice id="c3" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo" />' +
               '</xs:simpleType>' +
               '<xs:element name="Foobar" minOccurs="unbounded"/>' +
               '<xs:element name="Foomanchu"/>' +
               '<xs:attributeGroup name="atg1" />' +
               '<xs:restriction base="Foo">' +
                  '<xs:attributeGroup ref="atg1" />' +
               '</xs:restriction>' +
               '<xs:element id="ct3">' +
                 '<xs:simpleType>' +
                   '<xs:list id="ls1" />' +
                 '</xs:simpleType>' +
               '</xs:element>' +
               '<xs:complexType>' +
                 '<xs:complexContent>' +
                   '<xs:restriction>' +
                     '<xs:sequence name="seq1" />' +
                   '</xs:restriction>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'

     schema = Parser.parse_xsd :raw => data
     node_objs = Resolver.node_objects schema

     expect(node_objs.values.flatten.size).to eq(26)
     expect(node_objs[Schema].size).to eq(1)
     expect(node_objs[ComplexType].size).to eq(3)
     expect(node_objs[Element].size).to eq(6)
     expect(node_objs[Attribute].size).to eq(2)
     expect(node_objs[AttributeGroup].size).to eq(1)
     expect(node_objs[Choice].size).to eq(3)
     expect(node_objs[ComplexContent].size).to eq(2)
     expect(node_objs[Extension].size).to eq(1)
     expect(node_objs[Group].size).to eq(1)
     expect(node_objs[List].size).to eq(2)
     expect(node_objs[Restriction].size).to eq(1)
     expect(node_objs[Sequence].size).to eq(1)
     expect(node_objs[SimpleContent].size).to eq(0)
     expect(node_objs[SimpleType].size).to eq(2)
  end

  it "should correctly resolve nodes" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:element name="Foo"/>' +
               '<xs:complexType name="ct1">' +
                 '<xs:choice id="c1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element ref="Foo" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
               '<xs:element type="ct1" name="Bar"/>' +
            '</schema>'

     schema = Parser.parse_xsd :raw => data
     #node_objs = Resolver.resolve_nodes schema # XXX don't like doing it this way but this is invoked as part of Parser.parse_xsd, and shouldn't be invoked twice on one data set

     expect(schema.complex_types[0]).to eq(schema.elements[1].type)
     expect(schema.elements[0]).to eq(schema.complex_types[0].choice.elements[1].ref)
  end

end
