require 'spec_helper'

describe "SerialSpec::RequestResponse" do
  include SerialSpec

  def app
    ->(env) { stub_response }
  end

  let(:stub_response) { [404, {}, []] }

  context "using with_request" do
    let(:app) { double() }
    let(:with_expectation) { hash_including("PATH_INFO" => "/", "REQUEST_METHOD" => "GET") }

    before do
      expect(app).to receive(:call).
        with(with_expectation).
        and_return(stub_response)
    end

    with_request "GET /"
  end
end