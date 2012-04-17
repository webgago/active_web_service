require "spec_helper"

class TestController < ActiveWebService::Controller
  wsdl "spec/fixtures/UserService.wsdl"
  layout "application"
  prepend_view_path 'spec/fixtures/views'

  def index
    raise
  end

  def get_first_name
    @first_name = "Anton"
  end
end


describe "Controller" do
  include RSpec::Rails::ViewRendering

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

        def get_first_name

        end
      end
    end

    its(:wsdl_location) { should eq "spec/fixtures/UserService.wsdl" }
    its(:document) { should be_a WSDL::Reader::Parser }
    its(:action_methods) { should eq Set.new(["get_first_name"]) }

  end

  context "instance methods" do
    subject do
      TestController.new
    end

    before do
      xml = File.read('spec/fixtures/get_first_name.request.xml')
      @env = {
        'action_dispatch.request.path_parameters' => { :controller => 'test', :action => 'get_first_name', :format => 'xml' },
        'rack.input' => StringIO.new(xml),
        'RAW_POST_DATA' => xml,
        'REQUEST_METHOD' => 'POST'
      }
    end

    context "behavior" do

      it "should dispatch action" do
        TestController.any_instance.should_receive(:dispatch)
        TestController.call @env
      end

      it "should set action from posted xml before dispatch" do
        TestController.any_instance.should_receive(:get_first_name)
        TestController.call @env
      end

      it "should set assigns" do
        TestController.any_instance.should_receive(:render)
        TestController.call @env
        @env['action_controller.instance'].view_assigns['first_name'].should eq 'Anton'
      end

    end

  end
end
