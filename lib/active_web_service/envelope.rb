require "builder"

module ActiveWebService
  class Envelope
    NAMESPACES = { "xmlns:xsd"=>"http://www.w3.org/2001/XMLSchema",
                   "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
                   "xmlns:env"=>"http://schemas.xmlsoap.org/soap/envelope/" }

    def initialize(body, header = { }, options = {})
      @header, @body = header, body
    end

    def build
      builder = Builder::XmlMarkup.new; nil
      builder.instruct!(:xml, { })

      builder.tag! :env, :Envelope, NAMESPACES do |env|
        env.tag!(:env, :Header) { |header| header << header_to_xml }
        env.tag!(:env, :Body) { |body| body << body_to_xml }
      end
    end

    def body_to_xml
      method = @body.respond_to?(:to_xml) ? :to_xml : :to_s
      @body.send method
    end

    def header_to_xml
      method = @header.respond_to?(:to_xml) ? :to_xml : :to_s
      @header.send method
    end

    def to_xml(*args)
      build
    end
  end
end