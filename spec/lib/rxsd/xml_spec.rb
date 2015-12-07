# tests the xml modules
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'spec_helper'

describe RXSD::XML do

   it "should provide root node given adapter and xml data" do
      root_node = XML::Node.factory :backend => :libxml, :xml => "<schema/>"
      expect(root_node.is_a?(XML::LibXMLNode)).to be_truthy
   end

   it "should return correct root node" do
       child = MockXMLNode.new
       parent = MockXMLNode.new
       gp = MockXMLNode.new

       expect(child.root).to eq(child)
       child.test_parent = parent
       expect(child.root).to eq(parent)
       expect(parent.root).to eq(parent)
       parent.test_parent = gp
       expect(child.root).to eq(gp)
       expect(parent.root).to eq(gp)
   end

   it "should instantiate all children of a specified class type from xml" do
       child1 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child2 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child3 = MockXMLNode.new :name => "foobar"
       parent = MockXMLNode.new
       parent.children << child1 << child2 << child3

       children = parent.children_objs(MockXMLEntity)
       expect(children.size).to eq(2)
       expect(children[0].class).to eq(MockXMLEntity)
       expect(children[1].class).to eq(MockXMLEntity)
   end

   it "should return value attributes of all children w/ specified name" do
       child1 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child2 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child3 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child4 = MockXMLNode.new :name => "foobar"
       parent = MockXMLNode.new
       parent.children << child1 << child2 << child3

       children = parent.child_values(MockXMLEntity.tag_name)
       expect(children.size).to eq(3)
       expect(children[0]).to eq('pi')
       expect(children[1]).to eq('pi')
       expect(children[2]).to eq('pi')
   end

end

describe "RXSD::LibXMLAdapter" do

   before(:each) do
      @test_xml =
       "<schema xmlns:h='http://test.host/ns.xml' xmlns:a='aaa' >" +
         "<entity some_attr='foo' another_attr='bar'><child child_attr='123' /></entity>" +
         "<other_entity>some text</other_entity>" +
       "</schema>"
   end

   it "should parse xml children" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      expect(root.children.size).to eq(2)
      root.children.each    { |c| expect(c.class).to eq(XML::LibXMLNode) }
      expect(root.children.collect { |c| c.name }.include?("entity")).to be_truthy
      expect(root.children.collect { |c| c.name }.include?("other_entity")).to be_truthy
      expect(root.children.collect { |c| c.name }.include?("foo_entity")).to be_falsey

      expect(root.children[0].children.size).to eq(1)
      expect(root.children[1].children.size).to eq(0)
   end

   it "should parse xml names" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      expect(root.name).to eq("schema")
      expect(root.children[0].name).to eq("entity")
      expect(root.children[1].name).to eq("other_entity")
      expect(root.children[0].children[0].name).to eq("child")
   end

   it "should parse xml attributes" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      expect(root.children[0].attrs).to eq({'some_attr' => 'foo', 'another_attr' => 'bar'})
      expect(root.children[0].children[0].attrs).to eq({'child_attr' => '123' })
   end

   it "should identify and return parent" do
      root = XML::LibXMLNode.xml_root(@test_xml)

      expect(root.parent?).to be_falsey
      expect(root.parent).to be_nil

      expect(root.children[0].parent?).to be_truthy
      expect(root.children[0].parent).to eq(root)

      expect(root.children[1].parent?).to be_truthy
      expect(root.children[1].parent).to eq(root)

      expect(root.children[0].children[0].parent?).to be_truthy
      expect(root.children[0].children[0].parent).to eq(root.children[0])
   end

   it "should identify text and return content" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      expect(root.children[0].text?).to be_falsey
      expect(root.children[1].text?).to be_truthy
      expect(root.children[0].children[0].text?).to be_falsey

      expect(root.children[1].content).to  eq("some text")
   end

   it "should return namespaces" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      expect(root.namespaces.size).to eq(2)
      expect(root.namespaces.collect { |ns| ns.to_s }.include?('h:http://test.host/ns.xml')).to be_truthy
      #root.children[0].namespaces.size.should == 0 # children share the namespace apparently
   end

end


class MockXMLEntity
   def self.tag_name
      "mock_xml_entity"
   end

   def self.from_xml(node)
      MockXMLEntity.new
   end
end

class MockXMLNode < XML::Node
   attr_accessor :tag_name

   attr_accessor :test_attrs

   attr_accessor :test_parent

   attr_accessor :test_children

   def initialize(args = {})
     @tag_name = args[:name] if args.has_key? :name

     @test_parent = nil
     @test_children = []
     @test_children += args[:children] if args.has_key? :children
   end

   def name
     @tag_name
   end

   def attrs
      {:str_attr => "foobar", :int_attr => 50, :float_attr => 1.2, 'value' => 'pi'}
   end

   def parent?
      !@test_parent.nil?
   end

   def parent
      @test_parent
   end

   def children
      @test_children
   end

   def text?
      false
   end

   def content
      "contents"
   end

   def namespaces
      []
   end
end

