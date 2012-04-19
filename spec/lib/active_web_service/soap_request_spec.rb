require "spec_helper"

describe ActiveWebService::SoapRequest do
  let(:xml) { File.read('spec/fixtures/get_first_name.request.xml') }
  let(:wsdl) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }

  context "initializer" do

    it "should require 2 attributes" do
      described_class.new xml, wsdl
    end

  end

  context "#lookup_operation_name" do
    let(:wsdl) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
    let(:operations) { stub size: 2 }
    let(:messages) { stub lookup_operations: operations }
    subject { described_class.new double('xml'), wsdl }

    it "should raise RoutingError when operation not found by element name" do
      wsdl.messages.stub :lookup_operations_by_element => operations
      subject.should_receive(:element_name).and_return('element')
      expect { subject.operation }.to raise_error ActionController::RoutingError
    end
  end

end