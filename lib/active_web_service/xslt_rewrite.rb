require "xml"
require "xslt"

module ActiveWebService
  class XSLTRewrite

    def initialize(app, xsl)
      @app, @xsl = app, xsl
    end

    def call(env)
      if new_input = rewrite(env)
        env['rack.input'] = new_input
      end

      @app.call(env)
    end

    def rewrite(env)
      request = ActionDispatch::Request.new(env)
      return false if request.content_length.zero?

      xml = request.body.read
      request.body.rewind if request.body.respond_to? :rewind

      # Create a new XSL Transform
      stylesheet_doc = LibXML::XML::Document.file(@xsl)
      stylesheet = LibXSLT::XSLT::Stylesheet.new(stylesheet_doc)

      # Transform a xml document
      xml_doc = LibXML::XML::Document.string(xml)
      new_xml = stylesheet.apply(xml_doc)

      StringIO.new(new_xml.to_s)
    end
  end
end