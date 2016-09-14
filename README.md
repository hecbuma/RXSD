[![Build Status](https://travis-ci.org/MatthiasWinkelmann/RXSD.svg?branch=master)](https://travis-ci.org/MatthiasWinkelmann/RXSD)

# RXSD - XSD / Ruby Translator

This is a fork of RXSD by Mohammed Morsi <movitto@yahoo.com>

# Changes in this fork

The dependencies were updated to current versions and the tests
were converted to Minitest.

# License

RXSD is made available under the GNU LESSER GENERAL PUBLIC LICENSE
as published by the Free Software Foundation, either version 3
of the License, or (at your option) any later version.

# Info

RXSD is a library that translates XSD XML Schema Definitions into Ruby Classes 
on the fly. It is able to read XSD resources and use them to define Ruby 
classes in memory or string class definitions to be written to the filesystem

RXSD implements a full XSD parser that not only defines the various xsd schema
classes, parsing them out of a XSD file, but translates them into a 
meta-class heirarchy, for use in subsequent transformations. The builder interface
can easily be extended to output any format one could want including classes
in other languages (Python, C++, Java, etc), other XML formats, etc.

RXSD also parses XML conforming to a XSD schema, and instantiates objects 
corresponding to the XSD classes created. Furthermore, RXSD will work with
existing class definitions resulting in a quick way to map XSD to Ruby constructs,
letting you define the schema features that you need, and autogenerting handlers
to the others.

# Installation

To install the official gem do
   `gem install rxsd`

... But that will probably end with

```
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    current directory: [...]gems/libxml-ruby-1.1.4/ext/libxml
````

To use this fork add
```
gem 'RXSD', :git => 'https://github.com/MatthiasWinkelmann/RXSD.git'
````
to your Gemfile or clone the repository.

# Usage

```
  require 'lib/rxsd'
  
  xsd_uri = "file:///home/user/schema.xsd"
  xml_uri = "file:///home/user/data.xml"
  
  schema = RXSD::Parser.parse_xsd :uri => xsd_uri
  
  puts "###=Classes###="
  classes = schema.to :ruby_classes
  puts classes.collect{ |cl| !cl.nil? ? (cl.to_s + " < " + cl.superclass.to_s) : ""}.sort.join("\n")
  
  puts "###=Tags###="
  puts schema.tags.collect { |n,cb| n + ": " + cb.to_s + ": " + (cb.nil? ? "ncb" : cb.klass_name.to_s + "-" + cb.klass.to_s) }.sort.join("\n")
  
  puts "###=Objects###="
  data = RXSD::Parser.parse_xml :uri => xml_uri
  objs = data.to :ruby_objects, :schema => schema
  objs.each {  |obj|
    puts "#{obj}"
  }
```
