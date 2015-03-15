require 'spec_helper'

RSpec.describe "SerialSpec::ParsedBody" do

  it "should find selector for json" do
    json = {
      foo: [
        {
          bar: {
            baz: 1
          }
        }
      ]
    }.to_json

    body = SerialSpec::ParsedBody.new(json)
    expect(body[:foo].first[:bar][:baz]).to eq(2)
  end

end