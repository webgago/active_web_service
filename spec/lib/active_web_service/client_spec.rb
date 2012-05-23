require "spec_helper"

describe ActiveWebService::Client do
  SimpleSoapClient = Class.new(ActiveWebService::Client)

  context "defaults" do
    subject { SimpleSoapClient }

    its(:abstract?) { should be_false }
    its(:name) { should eql 'SimpleSoapClient' }
    its(:controller_path) { should eql 'simple_soap' }
    its(:enable) { should be_true }
    its(:disabled_actions) { should eql [] }
    its(:default_xml_namespaces) { should eql Hash.new }
    its(:helpers_path) { should eql ['app/helpers'] }
  end

  context ".bind" do
    subject { SimpleSoapClient }

    it "should fill wsdl_binding with WSDL::Reader::Binding" do
      wsdl_location        = 'spec/fixtures/UserService.wsdl'
      service_port_binding = stub(service_address: 'http://service-host.org/userService')
      wsdl                 = stub(bindings: { 'UserServicePortBinding' => service_port_binding }, services: { })

      WSDL::Reader::Parser.should_receive(:new).with(wsdl_location).and_return(wsdl)
      subject.should_receive(:wsdl_binding=).with(service_port_binding)
      subject.should_receive(:wsdl_binding).twice.and_return(service_port_binding)

      subject.bind(wsdl_location => 'UserServicePortBinding')
    end

    it "should find service address in wsdl and set it to endpoint" do
      subject.bind 'spec/fixtures/UserService.wsdl' => 'UserServicePortBinding'
      instance = subject.new
      instance.client.wsdl.document.should eql "spec/fixtures/UserService.wsdl"
      instance.client.wsdl.endpoint.should eql "http://service-host.org/userService"
    end
  end

  context "#xml_namespaces" do
    subject { SimpleSoapClient.new }

    its(:formats) { should eql ['xml'] }

    it "with empty hash should be default_xml_namespaces" do
      subject.default_xml_namespaces = { 'xmlns:n1' => 'http://example.org/n1/type' }
      subject.xml_namespaces.should eql 'xmlns:n1' => 'http://example.org/n1/type'
    end

    it " with custom namespaces should be merged with default_xml_namespaces" do
      subject.default_xml_namespaces = { 'xmlns:n1' => 'http://example.org/n1/type' }
      custom_ns                      = { 'xmlns:n2' => 'http://example.org/n2/type' }

      subject.xml_namespaces(custom_ns).should eql 'xmlns:n1' => 'http://example.org/n1/type',
                                                   'xmlns:n2' => 'http://example.org/n2/type'
    end

    it "xml_namespaces with custom namespaces should rewrite default_xml_namespaces" do
      subject.default_xml_namespaces = { 'xmlns:n1' => 'http://example.org/n1/type', 'xmlns:n2' => 'http://example.org/n2/default' }
      custom_ns                      = { 'xmlns:n2' => 'http://example.org/n2/type' }

      subject.xml_namespaces(custom_ns).should eql 'xmlns:n1' => 'http://example.org/n1/type',
                                                   'xmlns:n2' => 'http://example.org/n2/type'
    end
  end
end