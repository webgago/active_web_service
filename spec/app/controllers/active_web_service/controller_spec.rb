require "spec_helper"

class TestController < ActiveWebService::Controller
  wsdl "spec/fixtures/UserService.wsdl"
  layout "application"
  prepend_view_path 'spec/fixtures/views'

  def get_first_name_operation
    @first_name = "Anton"
  end
end


describe "Controller" do

  it "should not respond to index action, but route to it" do
    expect { post :index }.to raise_error
  end

  it "should be child of ApplicationController" do
    ActiveWebService::Controller.superclass.should be ActionController::Base
  end

  it "should be abstract" do
    ActiveWebService::Controller.should be_abstract
  end

  it "should allow_forgery_protection == true" do
    ActiveWebService::Controller.allow_forgery_protection.should be_false
  end

  context "class methods" do

    subject do
      Class.new ActiveWebService::Controller do
        wsdl "spec/fixtures/UserService.wsdl"

        def get_first_name_operation
        end
      end
    end

    its(:wsdl_location) { should eq "spec/fixtures/UserService.wsdl" }
    its(:wsdl_document) { should be_a WSDL::Reader::Parser }
    its(:action_methods) { should eq Set.new(["get_first_name_operation"]) }

  end

  context "instance methods" do
    subject do
      TestController.new
    end

    before do
      xml  = File.read('spec/fixtures/get_first_name.request.xml')
      @env = {
          'action_dispatch.request.path_parameters' => { :controller => 'test', :action => 'index', :format => 'xml' },
          'rack.input'                              => StringIO.new(xml),
          'RAW_POST_DATA'                           => xml,
          'REQUEST_METHOD'                          => 'POST'
      }
    end

    def env_for(hash = { })
      hash['RAW_POST_DATA'] = hash.delete(:xml) if hash.key? :xml
      @env.merge!(hash)
      @env['rack.input'] = StringIO.new(@env['RAW_POST_DATA'])
      @env
    end

    def controller
      @env['action_controller.instance']
    end

    context "behavior" do

      it "should dispatch action" do
        TestController.any_instance.should_receive(:dispatch)
        TestController.call @env
      end

      it "should set action from posted xml before dispatch" do
        TestController.any_instance.should_receive(:get_first_name_operation)
        TestController.call @env
      end

      it "should raise RoutingError for not implemented actions" do
        expect {
          TestController.call env_for(xml: File.read('spec/fixtures/not_implemented.request.xml'))
        }.to raise_error ActionController::RoutingError
      end

      it "should set assigns" do
        TestController.call @env
        controller.view_assigns['first_name'].should eq 'Anton'
      end

      it "should render template" do
        TestController.call @env
        controller.response.body.should eq <<-XML
<layout>
<get_first_name>
  <result>Anton</result>
</get_first_name>
</layout>
        XML
      end
    end

    context "custom binding name" do

      it "should raise RoutingError for not implemented actions in specific binding" do
        TestController.wsdl "spec/fixtures/UserService.wsdl", "UserServicePortBinding2"

        expect {
          TestController.call @env
        }.to raise_error ActionController::RoutingError
      end

    end
  end
end
