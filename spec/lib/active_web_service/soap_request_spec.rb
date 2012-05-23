require "spec_helper"

describe ActiveWebService::SoapRequest do
  let(:xml) { File.read('spec/fixtures/get_first_name.request.xml') }
  let(:wsdl) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }

  subject { described_class.new xml, wsdl }

  context "initialize" do
    it "should set xml from first argument" do
      subject.xml.should eq xml
    end

    it "should set wsdl from second argument" do
      subject.wsdl.should eq wsdl
    end

    it "should set binding from third argument, default is nil" do
      subject.binding.should be_nil
      subject2 = described_class.new xml, wsdl, 'UserServicePortBinding'
      subject2.binding_name.should eq 'UserServicePortBinding'
      subject2.binding.should eq wsdl.bindings['UserServicePortBinding']
    end

    it "should raise ArgumentError" do
      expect{
        subject2 = described_class.new xml, wsdl, 'NotExistBinding'
      }.to raise_error ArgumentError, "binding 'NotExistBinding' not found in #{wsdl.location}"
    end
  end

  context "#element" do
    it "should parse element name from xml" do
      subject.element_name.should eql 'GetFirstName'
    end
  end

  context "#operation" do
    let(:wsdl) { WSDL::Reader::Parser.new('spec/fixtures/UserService.wsdl') }
    let(:operations) { stub size: 2 }
    let(:messages) { stub lookup_operations: operations }
    subject { described_class.new xml, wsdl }

    it "should raise RoutingError when operation not found by element name" do
      wsdl.messages.stub :lookup_operations_by_element => operations
      subject.should_receive(:element_name).and_return('element')
      expect { subject.operation }.to raise_error ActionController::RoutingError
    end

    it "should lookup operation by element" do
      subject.operation.should eql 'get_first_name_operation'
    end
  end

end
