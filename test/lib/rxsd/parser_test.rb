# tests the parser module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test_helper'

describe RXSD::Parser do

  it "should  parse xsd" do
     File.write("/tmp/rxsd-test", "<schema><element name='foo' type='xs:boolean' />" +
                                  "<complexType><choice><element ref='foo' /></choice></complexType></schema>")
     schema = Parser.parse_xsd :uri => "file:///tmp/rxsd-test"
     assert_equal 1, schema.elements.size
     assert_equal 1, schema.complex_types.size
     assert_equal "foo", schema.elements[0].name
     assert_equal Boolean, schema.elements[0].type
     assert_equal "foo", schema.complex_types[0].choice.elements[0].ref.name
     assert_equal Boolean, schema.complex_types[0].choice.elements[0].ref.type
  end

  it "should identifity builtin types" do
     assert_equal true, Parser.is_builtin?(String)
     assert_equal true, Parser.is_builtin?(Boolean)
     assert_equal true, Parser.is_builtin?(XSDFloat)
     assert_equal true, Parser.is_builtin?(XSDInteger)
     refute Parser.is_builtin?(Parser)
  end

  it "should parse builtin types" do
     assert_equal String, Parser.parse_builtin_type("xs:string")
     assert_equal Boolean, Parser.parse_builtin_type("xs:boolean")
     assert_equal XSDFloat, Parser.parse_builtin_type("xs:decimal")
     assert_equal XSDFloat, Parser.parse_builtin_type("xs:float")
     assert_equal XSDFloat, Parser.parse_builtin_type("xs:double")
  end

  it "should parse schema" do
     data = "<schema version='4.20' targetNamespace='foobar' xmlns='http://www.w3.org/2001/XMLSchema' xmlns:foo='http://morsi.org/myschema' " +
            "   elementFormDefault='qualified' attributeFormDefault='unqualified' />"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     assert_equal 2, schema.namespaces.size
     assert_equal 'foobar', schema.targetNamespace
     assert_equal 'http://www.w3.org/2001/XMLSchema', schema.namespaces[nil]
     assert_equal 'http://morsi.org/myschema', schema.namespaces['foo']
     assert_equal "qualified", schema.elementFormDefault
     assert_equal "unqualified", schema.attributeFormDefault

     data = "<schema><element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     assert_equal 1, schema.elements.size
     assert_equal "foo", schema.elements[0].id

     data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'><xs:element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     assert_equal 1, schema.elements.size
     assert_equal "foo", schema.elements[0].id
  end

  it "should parse element" do
     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:element id="iii" name="xxx" type="yyy" default="Foobar" maxOccurs="5" '+
                 ' nillable="true" abstract="true" ref="Foo" form="qualified" />' +
            '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "iii", element.id
     assert_equal "xxx", element.name
     assert_equal "yyy", element.type
     assert_equal nil, element.default
     assert_equal 5, element.maxOccurs
     assert_equal 1, element.minOccurs
     assert_equal true, element.nillable
     assert_equal true, element.abstract
     assert_equal "Foo", element.ref
     assert_equal "qualified", element.form

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
                '<xs:element default="Foobar" minOccurs="unbounded">' +
                   '<Foo/>' +
                '</xs:element>' +
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal nil, element.default
     assert_equal "unbounded", element.minOccurs

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="unqualified">'+
                '<xs:element id="iii" ref="Foo" />'+
             '</schema>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "iii", element.id
     assert_equal nil, element.ref
     assert_equal "unqualified", element.form

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
              '<xs:element default="Foobar" minOccurs="unbounded">' +
                '<simpleType id="foobar"/>' +
              '</xs:element>'+
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "Foobar", element.default
     assert_equal "foobar", element.simple_type.id
  end

  it "should parse complex type" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="iii" name="xxx" abstract="true" mixed="true">' +
                 '<xs:attribute name="Foo" />' +
                 '<xs:attribute name="Bar" />' +
                 '<xs:group name="Gr" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "iii", complexType.id
     assert_equal "xxx", complexType.name
     assert_equal true, complexType.abstract
     assert_equal true, complexType.mixed
     assert_equal 2, complexType.attributes.size
     assert_equal "Foo", complexType.attributes[0].name
     assert_equal "Bar", complexType.attributes[1].name
     assert_equal "Gr", complexType.group.name

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType mixed="true">' +
                 '<xs:simpleContent id="123" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal false, complexType.mixed
     assert_equal "123", complexType.simple_content.id
  end

  it "should parse simple type" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="iii" name="xxx">' +
                 '<xs:restriction id="rs1" />' +
                 '<xs:list id="li1" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     simpleType = SimpleType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "iii", simpleType.id
     assert_equal "xxx", simpleType.name
     assert_equal "rs1", simpleType.restriction.id
     assert_equal "li1", simpleType.list.id
  end

  it "should parse attribute" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attribute id="at1" name="at1" use="optional" form="qualified" default="123" type="foo" />' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "at1", attr.id
     assert_equal "at1", attr.name
     assert_equal "qualified", attr.form
     assert_equal "123", attr.default
     assert_equal "foo", attr.type
     assert_equal nil, attr.simple_type

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" attributeFormDefault="unqualified" >' +
               '<xs:attribute id="at2" fixed="123" type="foo">' +
                 '<xs:simpleType id="st1" />' +
               '</xs:attribute>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "at2", attr.id
     assert_equal "unqualified", attr.form
     assert_equal nil, attr.type
     refute_nil attr.simple_type
     assert_equal "st1", attr.simple_type.id
  end

  it "should parse attribute group" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attributeGroup id="ag1" name="ag1" ref="ag2">' +
                  '<xs:attribute id="a1" />' +
                  '<xs:attribute id="a2" />' +
                  '<xs:attributeGroup id="ag3" />' +
               '</xs:attributeGroup>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attrGroup = AttributeGroup.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "ag1", attrGroup.id
     assert_equal "ag1", attrGroup.name
     assert_equal "ag2", attrGroup.ref
     assert_equal 2, attrGroup.attributes.size
     assert_equal 1, attrGroup.attribute_groups.size
     assert_equal "a1", attrGroup.attributes[0].id
     assert_equal "a2", attrGroup.attributes[1].id
     assert_equal "ag3", attrGroup.attribute_groups[0].id
  end

  it "should parse group" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g1" name="g1" maxOccurs="5" minOccurs="unbounded">' +
                  '<xs:choice id="c1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "g1", group.id
     assert_equal "g1", group.name
     assert_equal 5, group.maxOccurs
     assert_equal "unbounded", group.minOccurs
     assert_equal "c1", group.choice.id

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g2" ref="g1" >'+
                  '<xs:sequence id="s1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     assert_equal "g1", group.ref
     assert_equal 1, group.minOccurs
     assert_equal 1, group.maxOccurs
     assert_equal "s1", group.sequence.id
  end

  it "should parse list" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo">' +
                   '<xs:simpleType id="st2" />' +
                 '</xs:list>' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     assert_equal "li1", list.id
     assert_equal nil, list.itemType
     assert_equal "st2", list.simple_type.id

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     assert_equal "Foo", list.itemType
  end

  it "should parse simple content" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:simpleContent id="sc1">' +
                 '  <xs:restriction id="r1" />' +
                 '</xs:simpleContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     simple_content = SimpleContent.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     assert_equal "sc1", simple_content.id
     assert_equal "r1", simple_content.restriction.id
  end

  it "should parse choice" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:choice id="c1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element id="e2" />' +
                 '  <xs:element id="e3" />' +
                 '  <xs:choice id="c2" />' +
                 '  <xs:choice id="c3" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     choice = Choice.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root ))))
     assert_equal "c1", choice.id
     assert_equal 5, choice.maxOccurs
     assert_equal "unbounded", choice.minOccurs
     assert_equal 3, choice.elements.size
     assert_equal "e2", choice.elements[1].id
     assert_equal 2, choice.choices.size
     assert_equal "c2", choice.choices[0].id

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:choice id="c1" >'+
                 '  <xs:sequence id="s1" />' +
                 '</xs:choice>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     choice = Choice.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     assert_equal 1, choice.maxOccurs
     assert_equal 1, choice.minOccurs
     assert_equal 1, choice.sequences.size
     assert_equal "s1", choice.sequences[0].id
  end

  it "should parse complex content" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:restriction id="r1"/>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexContent = ComplexContent.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     assert_equal "cc1", complexContent.id
     assert_equal true, complexContent.mixed
     assert_equal "r1", complexContent.restriction.id
  end

  it "should parse sequence" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1">' +
                 '<xs:sequence id="s1" maxOccurs="5" minOccurs="unbounded" >' +
                 '  <xs:element id="e1" />' +
                 '  <xs:element id="e2" />' +
                 '  <xs:element id="e3" />' +
                 '  <xs:choice id="c2" />' +
                 '  <xs:choice id="c3" />' +
                 '</xs:sequence>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     seq = Sequence.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root ))))
     assert_equal "s1", seq.id
     assert_equal 5, seq.maxOccurs
     assert_equal "unbounded", seq.minOccurs
     assert_equal 3, seq.elements.size
     assert_equal "e2", seq.elements[1].id
     assert_equal 2, seq.choices.size
     assert_equal "c2", seq.choices[0].id
  end

  it "should parse extension" do
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
            '</schema>'
     doc  = LibXML::XML::Document.string data
     ext = Extension.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))))
     assert_equal "e1", ext.id
     assert_equal "Foo", ext.base
     assert_equal "g1", ext.group.id
     assert_equal 2, ext.attributes.size
     assert_equal "a1", ext.attributes[0].id
  end

  it "should parse restriction" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:complexContent id="cc1" mixed="true">' +
                    '<xs:restriction id="r1" base="xs:integer">' +
                        '<xs:attributeGroup id="ag1" />' +
                        '<xs:attributeGroup id="ag2" />' +
                        '<xs:minLength id="5" />' +
                    '</xs:restriction>' +
                 '</xs:complexContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     res = Restriction.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))))
     assert_equal "r1", res.id
     assert_equal "xs:integer", res.base
     assert_equal 2, res.attribute_groups.size
     assert_equal nil, res.min_length

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType id="ct1" name="ct1">' +
                 '<xs:simpleContent id="sc1">' +
                    '<xs:restriction id="r1">'+
                        '<xs:attributeGroup id="ag1" />' +
                        '<xs:attributeGroup id="ag2" />' +
                        '<xs:minLength value="5" />' +
                        '<xs:maxExclusive value="15" />' +
                        '<xs:pattern value="[a-zA-Z][a-zA-Z][a-zA-Z]"/>' +
                        '<xs:enumeration value="foo"/>' +
                        '<xs:enumeration value="bar"/>' +
                    '</xs:restriction>' +
                 '</xs:simpleContent>' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     res = Restriction.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                       :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))))
     assert_equal 2, res.attribute_groups.size
     assert_equal 5, res.min_length
     assert_equal 15, res.max_exclusive
     assert_equal "[a-zA-Z][a-zA-Z][a-zA-Z]", res.pattern
     assert_equal 2, res.enumerations.size
     assert_equal "foo", res.enumerations[0]
  end


  ##########################################################

  it "should parse xml" do
     data = "<root_tag some_string='foo' MyInt='bar' >" +
             "<child_tag>" +
              "<grandchild_tag id='25' />" +
             "</child_tag>" +
            "</root_tag>"

     schema_instance = Parser.parse_xml :raw => data
     assert_equal 3, schema_instance.object_builders.size
     rt = schema_instance.object_builders.find { |ob| ob.tag_name == "root_tag" }
     ct = schema_instance.object_builders.find { |ob| ob.tag_name == "child_tag" }
     gt = schema_instance.object_builders.find { |ob| ob.tag_name == "grandchild_tag" }

     refute_nil rt
     refute_nil ct
     refute_nil gt

     #rt.children.size.should == 1
     #rt.children[0].should == ct

     #ct.children.size.should == 1
     #ct.children[0].should == gt

     assert_equal 2, rt.attributes.size
     assert_equal true, rt.attributes.has_key?("some_string")
     assert_equal "foo", rt.attributes["some_string"]
     assert_equal true, rt.attributes.has_key?("MyInt")
     assert_equal "bar", rt.attributes["MyInt"]

     #gt.children.size.should == 0
     assert_equal true, gt.attributes.has_key?("id")
     assert_equal "25", gt.attributes["id"]
  end

end
