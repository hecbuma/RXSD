# tests the xml modules
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'test_helper'

describe RXSD::XML do

   it "should provide root node given adapter and xml data" do
      root_node = XML::Node.factory :backend => :libxml, :xml => "<schema/>"
      assert root_node.is_a?(XML::LibXMLNode)
   end

   it "should return correct root node" do
       child = MockXMLNode.new
       parent = MockXMLNode.new
       gp = MockXMLNode.new

       assert_equal child, child.root
       child.test_parent = parent
       assert_equal parent, child.root
       assert_equal parent, parent.root
       parent.test_parent = gp
       assert_equal gp, child.root
       assert_equal gp, parent.root
   end

   it "should instantiate all children of a specified class type from xml" do
       child1 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child2 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child3 = MockXMLNode.new :name => "foobar"
       parent = MockXMLNode.new
       parent.children << child1 << child2 << child3

       children = parent.children_objs(MockXMLEntity)
       assert_equal 2, children.size
       assert_equal MockXMLEntity, children[0].class
       assert_equal MockXMLEntity, children[1].class
   end

   it "should return value attributes of all children w/ specified name" do
       child1 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child2 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child3 = MockXMLNode.new :name => MockXMLEntity.tag_name
       child4 = MockXMLNode.new :name => "foobar"
       parent = MockXMLNode.new
       parent.children << child1 << child2 << child3

       children = parent.child_values(MockXMLEntity.tag_name)
       assert_equal 3, children.size
       assert_equal 'pi', children[0]
       assert_equal 'pi', children[1]
       assert_equal 'pi', children[2]
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
      assert_equal 2, root.children.size
      root.children.each    { |c| assert_equal XML::LibXMLNode, c.class }
      assert root.children.collect { |c| c.name }.include?("entity")
      assert root.children.collect { |c| c.name }.include?("other_entity")
      refute root.children.collect { |c| c.name }.include?("foo_entity")

      assert_equal 1, root.children[0].children.size
      assert_equal 0, root.children[1].children.size
   end

   it "should parse xml names" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      assert_equal "schema", root.name
      assert_equal "entity", root.children[0].name
      assert_equal "other_entity", root.children[1].name
      assert_equal "child", root.children[0].children[0].name
   end

   it "should parse xml attributes" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      first = { "child_attr" => '123' }
      sec = {"some_attr" => 'foo', "another_attr"=> 'bar'}
      assert_equal(first , root.children[0].children[0].attrs)
      assert_equal( sec, root.children[0].attrs)
   end

   it "should identify and return parent" do
      root = XML::LibXMLNode.xml_root(@test_xml)

      refute root.parent?
      assert_nil root.parent

      assert root.children[0].parent?
      assert_equal root, root.children[0].parent

      assert root.children[1].parent?
      assert_equal root, root.children[1].parent

      assert root.children[0].children[0].parent?
      assert_equal root.children[0], root.children[0].children[0].parent
   end

   it "should identify text and return content" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      refute root.children[0].text?
      assert root.children[1].text?
      refute root.children[0].children[0].text?

      assert_equal "some text", root.children[1].content
   end

   it "should return namespaces" do
      root = XML::LibXMLNode.xml_root(@test_xml)
      assert_equal 2, root.namespaces.size
      assert root.namespaces.collect { |ns| ns.to_s }.include?('h:http://test.host/ns.xml')
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

