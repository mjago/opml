require "./spec_helper"

describe "Opml" do
  it "has version" do
    Opml::VERSION.class.should eq String
    (Opml::VERSION.size >= 5).should be_true
  end

  describe "parses flat hierarchy" do
    opml = <<-END
<?xml version="1.0" encoding="ISO-8859-1"?>
<opml version="2.0">
  <head>
  </head>
  <body>
    <outline text="some name" abc="def" url="http://example.com"/>
    <outline notext="no name" ghi="jkl" url="http://example2.com"/>
    <outline text="another name" mno="pqr" url="http://example3.com"/>
  </body>
</opml>
END
    it "returns Array of Outlines" do
      ol = Opml.parse(opml)
      ol.class.should eq(Array(Outline))
    end

    it "names outlines" do
      ol = Opml.parse(opml)
      ol.first.name.should eq("some name")
      ol.last.name.should eq("another name")
    end

    it "ignores outlines with no text attribute as per spec" do
      ol = Opml.parse(opml)
      ol.size.should eq(2)
    end

    it "returns attributes of each outline" do
      ol = Opml.parse(opml)
      ol.first.attributes.size.should eq(2)
      ol.first.attributes.first.name.should eq("abc")
      ol.first.attributes.first.value.should eq("def")
      ol.first.attributes.last.name.should eq("url")
      ol.first.attributes.last.value.should eq("http://example.com")
    end

    it "returns nil for parent if no parent" do
      ol = Opml.parse(opml)
      ol.first.parent.should be_nil
    end

    it "(outlines method) returns empty array if no child outlines" do
      ol = Opml.parse(opml)
      ol.first.outlines.size.should eq(0)
      ol.first.outlines.should eq([] of Array(Outline))
    end

    it "returns empty array if no valid outlines" do
      opml = <<-END
<opml version="2.0">
  <head>
  </head>
  <body>
    <outline notext="no name" ghi="jkl" url="http://example.com"/>
    <outline notext="no name2" ghi="jkl" url="http://example2.com"/>
  </body>
</opml>
END
      ol = Opml.parse(opml)
      ol.class.should eq(Array(Outline))
      ol.size.should eq(0)
    end
  end

  describe "parses two-tier hierarchy" do
    opml = <<-END
<opml version="2.0">
  <head>
  </head>
  <body>
    <outline text="Outer1">
      <outline text="Inner1" ghi1="jkl1" url="http://example.com" />
      <outline text="Inner2" ghi2="jkl2" url="http://example2.com" />
    </outline>
    <outline text="Outer2">
      <outline text="Inner3" ghi3="jkl3" url="http://example3.com" />
      <outline text="Inner4" ghi4="jkl4" url="http://example4.com" />
    </outline>
  </body>
</opml>
END
    it "returns an array of two outlines" do
      ol = Opml.parse(opml)
      ol.class.should eq(Array(Outline))
      ol.size.should eq(2)
    end

    it "contains 2 inner outlines per outline" do
      ol = Opml.parse(opml)
      ol.size.should eq(2)
      ol.first.outlines.size.should eq(2)
      ol.last.outlines.size.should eq(2)
    end

    it "inner outlines reference parent node" do
      ol = Opml.parse(opml)
      name = ol.first.name
      ol.first.outlines.each do |node|
        if ip = node.parent
          if iname = ip.name
            iname.should eq(name)
          else
            raise "inner_parent name does not match!"
          end
        else
          raise "inner_parent name does not match!"
        end
      end
    end

    it "inner outlines contain attribute named ghi1 with value jkl1" do
      ol = Opml.parse(opml)
      ol.first.outlines.first.attributes.first.name.should eq "ghi1"
      ol.first.outlines.first.attributes.first.value.should eq "jkl1"
    end
    it "inner outlines contain attribute named url with value http://example.com" do
      ol = Opml.parse(opml)
      ol.first.outlines.first.attributes.last.name.should eq "url"
      ol.first.outlines.first.attributes.last.value.should eq "http://example.com"
    end
  end

  describe "parses any hierarchy" do
    opml = <<-END
<opml version="2.0">
  <head>
  </head>
  <body>
    <outline text="Outer1">
      <outline text="Mid1" ghi1="jkl1" url="http://example.com" />
      <outline text="Mid2">
        <outline text="Inner1" ghi2="jkl2" url="http://example.com" />
        <outline text="Inner2" ghi3="jkl3" url="http://example2.com" />
      </outline>
    </outline>
    <outline text="Outer2">
      <outline text="Mid3" ghi4="jkl4" url="http://example.com" />
      <outline text="Mid4">
        <outline text="Inner3" ghi5="jkl5" url="http://example3.com" />
        <outline text="Inner4" ghi6="jkl6" url="http://example4.com" />
      </outline>
    </outline>
  </body>
</opml>
END

    it "parses a three tear hierarchy" do
      ol = Opml.parse(opml)
      ol.class.should eq(Array(Outline))
      ol.size.should eq(2)
      ol.first.outlines.size.should eq(2)
      ol.first.outlines.first.name.should eq "Mid1"
      ol.first.outlines.first.attributes.first.name.should eq "ghi1"
      ol.first.outlines.first.attributes.first.value.should eq "jkl1"
      ol.first.outlines.first.attributes.last.name.should eq "url"
      ol.first.outlines.first.outlines.size.should eq(0)
      ol.first.outlines.last.outlines.size.should eq(2)
    end
  end

  it "parses file and returns Array(Outline)" do
    ol = Opml.parse_file("spec/test_data/test.opml")
    ol.class.should eq(Array(Outline))
  end

  it "allows to pass parent to parse method" do
    opml = <<-END
<?xml version="1.0" encoding="ISO-8859-1"?>
<opml version="2.0">
  <head>
  </head>
  <body>
    <outline text="some name" abc="def" url="http://example.com"/>
    <outline notext="no name" ghi="jkl" url="http://example2.com"/>
    <outline text="another name" mno="pqr" url="http://example3.com"/>
  </body>
</opml>
END
    parent = Outline.new
    parent.name = "parent"
    ol = Opml.parse(opml, parent)
    ol.class.should eq(Array(Outline))
    ol.first.parent.should eq(parent)
    ol.first.parent.class.should eq(Outline)
    ol.first.parent.not_nil!.name.should eq("parent")
    ol.first.parent.should eq(parent)
    ol.first.parent.class.should eq(Outline)
    ol.first.parent.not_nil!.name.should eq("parent")
  end

  it "allows to pass parent to parse_file method" do
    parent = Outline.new
    parent.name = "parent"
    ol = Opml.parse_file("spec/test_data/test.opml", parent)
    ol.class.should eq(Array(Outline))
    ol.first.parent.should eq(parent)
    ol.first.parent.class.should eq(Outline)
    ol.first.parent.not_nil!.name.should eq("parent")
    ol.first.parent.should eq(parent)
    ol.first.parent.class.should eq(Outline)
    ol.first.parent.not_nil!.name.should eq("parent")
  end
end
