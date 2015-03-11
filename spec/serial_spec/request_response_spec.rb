require 'spec_helper'

describe "SerialSpec::RequestResponse" do
  include SerialSpec::RequestResponse

  def app
    ->(env) { stub_response }
  end

  let(:stub_response) { [404, {}, []] }

  context "with out configuring the request" do

    it "should raise an error on perform_request!" do
      expect{perform_request!}.to raise_error
    end

  end

  context "with valid config defined" do
    request_method "GET"
    request_path   "/"

    let(:app) { double() }
    let(:with_expectation) { hash_including("PATH_INFO" => "/") }

    before do
      expect(app).to receive(:call).
        with(with_expectation).
        and_return(stub_response)
    end

    context "and path specified" do

      it "should perform request" do
        expect{perform_request!}.to_not raise_error
      end

      context "but overriden" do
        request_path "/overriden"
        let(:with_expectation) { hash_including("PATH_INFO" => "/overriden") }

        it "should perform request" do
          expect{perform_request!}.to_not raise_error
        end
      end

    end

    context "when specifying params" do
      request_params.merge! test: "this"
      let(:with_expectation) { hash_including("QUERY_STRING" => "test=this") }

      it "should perform request" do
        expect{perform_request!}.to_not raise_error
      end

      context "but overridden" do
        request_params.merge! test: "overriden"
        let(:with_expectation) { hash_including("QUERY_STRING" => "test=overriden") }

        it "should perform request" do
          expect{perform_request!}.to_not raise_error
        end
      end

    end
  end



end