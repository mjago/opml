require "./opml/*"
require "xml"

struct Attribute
  getter name
  getter value

  def initialize(@name : String, @value : String)
  end
end

class Outline
  property attributes : Array(Attribute)
  property outlines : Array(Outline)
  property name : String = ""
  getter parent : Outline?

  def initialize(@parent = nil)
    @attributes = [] of Attribute
    @outlines = [] of Outline
    #   @name = ""
  end

  def outlines?
    @outlines.size > 0
  end

  def attributes?
    @attributes.size > 0
  end
end

class Opml
  def self.parse_file(str : String, parent : Outline? = nil) : Array(Outline)
    text = File.read(str)
    parse text, parent
  end

  def self.parse(str : String, parent : Outline? = nil) : Array(Outline)
    outlines = [] of Outline
    doc = parse_root(str)
    unless doc.nil?
      xpath = "//opml/body/outline[@text]"
      node_set = doc.xpath_nodes(xpath)
      node_set.each do |node|
        outline = Outline.new(parent)

        # attributes
        attrs = node.attributes
        attrs.each do |x|
          if x.name == "text"
            outline.name = x.content
          else
            attr = Attribute.new(x.name, x.content)
            outline.attributes << attr
          end
        end

        # child nodes
        inner_node_set = node.children
        inner_node_set.each do |inner_node|
          parse_inner_node(inner_node, outline)
        end
        outlines << outline
      end
    end
    outlines
  end

  private def self.parse_inner_node(inner_node, outline)
    if inner_node.element?
      inner_outline = Outline.new(outline)

      # child attributes
      inner_attrs = inner_node.attributes
      inner_attrs.each do |y|
        if y.name == "text"
          inner_outline.name = y.content
        else
          inner_attr = Attribute.new(y.name, y.content)
          inner_outline.attributes << inner_attr
        end
      end

      # child nodes
      inner_node_set = inner_node.children
      inner_node_set.each do |node|
        parse_inner_node(node, inner_outline)
      end

      outline.outlines << inner_outline
    end
  end

  private def self.parse_root(str)
    XML.parse(str).root
  end
end
