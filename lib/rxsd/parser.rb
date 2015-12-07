# xml / xsd parsers
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

module RXSD

# Provides class methods to parse xsd and xml data
class Parser
 private
  def initialize
  end

 public

  # Parse xsd specified by uri or in raw data form into RXSD::XSD::Schema instance
  # args should be a hash w/ optional keys:
  # * :uri location which to load resource from
  # * :raw raw data which to parse
  def self.parse_xsd(args)
     data = Loader.load(args[:uri]) unless args[:uri].nil?
     data = args[:raw]              unless args[:raw].nil?
     Logger.debug "parsing xsd"

     # FIXME validate against xsd's own xsd
     root_xml_node = XML::Node.factory :backend => :libxml, :xml => data
     schema = XSD::Schema.from_xml root_xml_node

     Logger.debug "parsed xsd, resolving relationships"
     Resolver.resolve_nodes schema

     Logger.debug "xsd parsing complete"
     return schema
  end

  # Parse xml specified by uri or in raw data form into RXSD::XSD::SchemaInstance instance
  def self.parse_xml(args)
     data = Loader.load(args[:uri]) unless args[:uri].nil?
     data = args[:raw]              unless args[:raw].nil?
     Logger.debug "parsing xml"

     root_xml_node = XML::Node.factory :backend => :libxml, :xml => data
     schema_instance = SchemaInstance.new :builders => SchemaInstance.builders_from_xml(root_xml_node)

     Logger.debug "xml parsing complete"
     return schema_instance
  end

  # Return true is specified class is builtin, else false
  def self.is_builtin?(builtin_class)
    [Array, String, Boolean, Char, Time, XSDFloat, XSDInteger].include? builtin_class
  end

  def self.has_builtin_mapping?(builtin_type_name)
    !self.parse_builtin_type(builtin_type_name).nil?
  end

  # Return ruby class corresponding to builtin type
  def self.parse_builtin_type(builtin_type_name)
    res = nil

    case builtin_type_name.gsub(/^.*\:/, '')
      when "string"
        res = String
      when "boolean"
        res = Boolean
      when "decimal"
        res = XSDFloat
      when "float"
        res = XSDFloat
      when "double"
        res = XSDFloat
      when "duration", "dateTime"
        res = Time
      when "date"
        res = Time
      when "gYearMonth"
        res = Time
      when "gYear"
        res = Time
      when "gMonthDay"
        res = Time
      when "gDay"
        res = Time
      when "gMonth"
        res = Time
      when "hexBinary" , "base64Binary" , "anyURI" , "QName",
        "NOTATION", "normalizedString", "token"
         res = String # FIXME should be a string derived class, eliminating whitespace
      when "language", "NMTOKEN", "NMTOKENS", "Name", "NCName",
        "ID", "IDREF", "IDREFS", "ENTITY", "ENTITIES", "integer"
         res = XSDInteger
      when "nonPositiveInteger"
         res = XSDInteger
      when "negativeInteger"
         res = XSDInteger
      when "long"
         res = XSDInteger
      when "int"
         res = XSDInteger
      when "short"
         res = XSDInteger
      when "byte"
         res = Char
      when "nonNegativeInteger"
         res = XSDInteger
      when "unsignedLong"
         res = XSDInteger
      when "unsignedInt"
         res = XSDInteger
      when "unsignedShort"
         res = XSDInteger
      when "unsignedByte"
         res = Char
      when "positiveInteger"
         res = XSDInteger
    end

    return res
  end

end

end
