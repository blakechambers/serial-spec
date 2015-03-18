require 'spec_helper'

describe "SerialSpec::RequestResponse" do
  include SerialSpec::RequestResponse

  def app
    ->(env) { stub_response }
  end

  let(:stub_response) { [404, {}, []] }

  context 'with_request' do
    request_method "GET"
    request_path   "/"

    let(:response) { perform_request! ; last_response }

    context "#status" do
      it "should set status" do
        expect(status).to eq(404)
      end
    end

    context "#headers" do
      it "should set status" do
        expect(headers).to be_kind_of(Hash)
      end
    end

    context "#body" do

      it "should raise an error, when not a json body" do
        expect{body}.to raise_error
      end

      context "when json formatted" do
        let(:stub_response) do
          [404, {"Content-Type" => "application/json"}, [{foo: "bar"}.to_json]]
        end

        it "should be kind of SerialSpec::ParsedBody" do
          expect(body).to be_kind_of(SerialSpec::ParsedBody)
        end
      end

    end

  end

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