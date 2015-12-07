# tests the parser module
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require File.dirname(__FILE__) + '/spec_helper'

describe "Parser" do

  it "should  parse xsd" do
     File.write("/tmp/rxsd-test", "<schema><element name='foo' type='xs:boolean' />" +
                                  "<complexType><choice><element ref='foo' /></choice></complexType></schema>")
     schema = Parser.parse_xsd :uri => "file:///tmp/rxsd-test"
     expect(schema.elements.size).to eq(1)
     expect(schema.complex_types.size).to eq(1)
     expect(schema.elements[0].name).to eq("foo")
     expect(schema.elements[0].type).to eq(Boolean)
     expect(schema.complex_types[0].choice.elements[0].ref.name).to eq("foo")
     expect(schema.complex_types[0].choice.elements[0].ref.type).to eq(Boolean)
  end

  it "should identifity builtin types" do
     expect(Parser.is_builtin?(String)).to eq(true)
     expect(Parser.is_builtin?(Boolean)).to eq(true)
     expect(Parser.is_builtin?(XSDFloat)).to eq(true)
     expect(Parser.is_builtin?(XSDInteger)).to eq(true)
     expect(Parser.is_builtin?(Parser)).not_to eq(true)
  end

  it "should parse builtin types" do
     expect(Parser.parse_builtin_type("xs:string")).to eq(String)
     expect(Parser.parse_builtin_type("xs:boolean")).to eq(Boolean)
     expect(Parser.parse_builtin_type("xs:decimal")).to eq(XSDFloat)
     expect(Parser.parse_builtin_type("xs:float")).to eq(XSDFloat)
     expect(Parser.parse_builtin_type("xs:double")).to eq(XSDFloat)
  end

  it "should parse schema" do
     data = "<schema version='4.20' targetNamespace='foobar' xmlns='http://www.w3.org/2001/XMLSchema' xmlns:foo='http://morsi.org/myschema' " +
            "   elementFormDefault='qualified' attributeFormDefault='unqualified' />"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     expect(schema.namespaces.size).to eq(2)
     expect(schema.targetNamespace).to eq('foobar')
     expect(schema.namespaces[nil]).to eq('http://www.w3.org/2001/XMLSchema')
     expect(schema.namespaces['foo']).to eq('http://morsi.org/myschema')
     expect(schema.elementFormDefault).to eq("qualified")
     expect(schema.attributeFormDefault).to eq("unqualified")

     data = "<schema><element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     expect(schema.elements.size).to eq(1)
     expect(schema.elements[0].id).to eq("foo")

     data = "<schema xmlns:xs='http://www.w3.org/2001/XMLSchema'><xs:element id='foo'/></schema>"
     doc  = LibXML::XML::Document.string data
     schema = Schema.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root))
     expect(schema.elements.size).to eq(1)
     expect(schema.elements[0].id).to eq("foo")
  end

  it "should parse element" do
     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:element id="iii" name="xxx" type="yyy" default="Foobar" maxOccurs="5" '+
                 ' nillable="true" abstract="true" ref="Foo" form="qualified" />' +
            '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(element.id).to eq("iii")
     expect(element.name).to eq("xxx")
     expect(element.type).to eq("yyy")
     expect(element.default).to eq(nil)
     expect(element.maxOccurs).to eq(5)
     expect(element.minOccurs).to eq(1)
     expect(element.nillable).to eq(true)
     expect(element.abstract).to eq(true)
     expect(element.ref).to eq("Foo")
     expect(element.form).to eq("qualified")

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
                '<xs:element default="Foobar" minOccurs="unbounded">' +
                   '<Foo/>' +
                '</xs:element>' +
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(element.default).to eq(nil)
     expect(element.minOccurs).to eq("unbounded")

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="unqualified">'+
                '<xs:element id="iii" ref="Foo" />'+
             '</schema>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(element.id).to eq("iii")
     expect(element.ref).to eq(nil)
     expect(element.form).to eq("unqualified")

     data = '<s xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
              '<xs:element default="Foobar" minOccurs="unbounded">' +
                '<simpleType id="foobar"/>' +
              '</xs:element>'+
             '</s>'
     doc  = LibXML::XML::Document.string data
     element = Element.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(element.default).to eq("Foobar")
     expect(element.simple_type.id).to eq("foobar")
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
     expect(complexType.id).to eq("iii")
     expect(complexType.name).to eq("xxx")
     expect(complexType.abstract).to eq(true)
     expect(complexType.mixed).to eq(true)
     expect(complexType.attributes.size).to eq(2)
     expect(complexType.attributes[0].name).to eq("Foo")
     expect(complexType.attributes[1].name).to eq("Bar")
     expect(complexType.group.name).to eq("Gr")

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:complexType mixed="true">' +
                 '<xs:simpleContent id="123" />' +
               '</xs:complexType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     complexType = ComplexType.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(complexType.mixed).to eq(false)
     expect(complexType.simple_content.id).to eq("123")
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
     expect(simpleType.id).to eq("iii")
     expect(simpleType.name).to eq("xxx")
     expect(simpleType.restriction.id).to eq("rs1")
     expect(simpleType.list.id).to eq("li1")
  end

  it "should parse attribute" do
     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:attribute id="at1" name="at1" use="optional" form="qualified" default="123" type="foo" />' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(attr.id).to eq("at1")
     expect(attr.name).to eq("at1")
     expect(attr.form).to eq("qualified")
     expect(attr.default).to eq("123")
     expect(attr.type).to eq("foo")
     expect(attr.simple_type).to eq(nil)

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema" attributeFormDefault="unqualified" >' +
               '<xs:attribute id="at2" fixed="123" type="foo">' +
                 '<xs:simpleType id="st1" />' +
               '</xs:attribute>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     attr = Attribute.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(attr.id).to eq("at2")
     expect(attr.form).to eq("unqualified")
     expect(attr.type).to eq(nil)
     expect(attr.simple_type).not_to be_nil
     expect(attr.simple_type.id).to eq("st1")
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
     expect(attrGroup.id).to eq("ag1")
     expect(attrGroup.name).to eq("ag1")
     expect(attrGroup.ref).to eq("ag2")
     expect(attrGroup.attributes.size).to eq(2)
     expect(attrGroup.attribute_groups.size).to eq(1)
     expect(attrGroup.attributes[0].id).to eq("a1")
     expect(attrGroup.attributes[1].id).to eq("a2")
     expect(attrGroup.attribute_groups[0].id).to eq("ag3")
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
     expect(group.id).to eq("g1")
     expect(group.name).to eq("g1")
     expect(group.maxOccurs).to eq(5)
     expect(group.minOccurs).to eq("unbounded")
     expect(group.choice.id).to eq("c1")

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:group id="g2" ref="g1" >'+
                  '<xs:sequence id="s1" />' +
               '</xs:group>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     group = Group.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0],
                                         :parent => RXSD::XML::LibXMLNode.new(:node => doc.root)))
     expect(group.ref).to eq("g1")
     expect(group.minOccurs).to eq(1)
     expect(group.maxOccurs).to eq(1)
     expect(group.sequence.id).to eq("s1")
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
     expect(list.id).to eq("li1")
     expect(list.itemType).to eq(nil)
     expect(list.simple_type.id).to eq("st2")

     data = '<schema xmlns:xs="http://www.w3.org/2001/XMLSchema">' +
               '<xs:simpleType id="st1" name="st1">' +
                 '<xs:list id="li1" itemType="Foo" />' +
               '</xs:simpleType>' +
            '</schema>'
     doc  = LibXML::XML::Document.string data
     list = List.from_xml(RXSD::XML::LibXMLNode.new(:node => doc.root.children[0].children[0],
                              :parent => RXSD::XML::LibXMLNode.new(:node => doc.root.children[0])))
     expect(list.itemType).to eq("Foo")
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
     expect(simple_content.id).to eq("sc1")
     expect(simple_content.restriction.id).to eq("r1")
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
     expect(choice.id).to eq("c1")
     expect(choice.maxOccurs).to eq(5)
     expect(choice.minOccurs).to eq("unbounded")
     expect(choice.elements.size).to eq(3)
     expect(choice.elements[1].id).to eq("e2")
     expect(choice.choices.size).to eq(2)
     expect(choice.choices[0].id).to eq("c2")

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
     expect(choice.maxOccurs).to eq(1)
     expect(choice.minOccurs).to eq(1)
     expect(choice.sequences.size).to eq(1)
     expect(choice.sequences[0].id).to eq("s1")
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
     expect(complexContent.id).to eq("cc1")
     expect(complexContent.mixed).to eq(true)
     expect(complexContent.restriction.id).to eq("r1")
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
     expect(seq.id).to eq("s1")
     expect(seq.maxOccurs).to eq(5)
     expect(seq.minOccurs).to eq("unbounded")
     expect(seq.elements.size).to eq(3)
     expect(seq.elements[1].id).to eq("e2")
     expect(seq.choices.size).to eq(2)
     expect(seq.choices[0].id).to eq("c2")
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
     expect(ext.id).to eq("e1")
     expect(ext.base).to eq("Foo")
     expect(ext.group.id).to eq("g1")
     expect(ext.attributes.size).to eq(2)
     expect(ext.attributes[0].id).to eq("a1")
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
     expect(res.id).to eq("r1")
     expect(res.base).to eq("xs:integer")
     expect(res.attribute_groups.size).to eq(2)
     expect(res.min_length).to eq(nil)

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
     expect(res.attribute_groups.size).to eq(2)
     expect(res.min_length).to eq(5)
     expect(res.max_exclusive).to eq(15)
     expect(res.pattern).to eq("[a-zA-Z][a-zA-Z][a-zA-Z]")
     expect(res.enumerations.size).to eq(2)
     expect(res.enumerations[0]).to eq("foo")
  end


  ##########################################################

  it "should parse xml" do
     data = "<root_tag some_string='foo' MyInt='bar' >" +
             "<child_tag>" +
              "<grandchild_tag id='25' />" +
             "</child_tag>" +
            "</root_tag>"

     schema_instance = Parser.parse_xml :raw => data
     expect(schema_instance.object_builders.size).to eq(3)
     rt = schema_instance.object_builders.find { |ob| ob.tag_name == "root_tag" }
     ct = schema_instance.object_builders.find { |ob| ob.tag_name == "child_tag" }
     gt = schema_instance.object_builders.find { |ob| ob.tag_name == "grandchild_tag" }

     expect(rt).not_to be_nil
     expect(ct).not_to be_nil
     expect(gt).not_to be_nil

     #rt.children.size.should == 1
     #rt.children[0].should == ct

     #ct.children.size.should == 1
     #ct.children[0].should == gt

     expect(rt.attributes.size).to eq(2)
     expect(rt.attributes.has_key?("some_string")).to eq(true)
     expect(rt.attributes["some_string"]).to eq("foo")
     expect(rt.attributes.has_key?("MyInt")).to eq(true)
     expect(rt.attributes["MyInt"]).to eq("bar")

     #gt.children.size.should == 0
     expect(gt.attributes.has_key?("id")).to eq(true)
     expect(gt.attributes["id"]).to eq("25")
  end

end
