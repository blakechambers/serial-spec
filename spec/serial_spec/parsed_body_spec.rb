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
    expect(body[:foo].first[:bar][:baz].execute).to eq(1)
  end

  it "should interpret first level missing keys as nil" do
    body = SerialSpec::ParsedBody.new("{}")

    expect(body[:missing_key].execute).to eq(nil)
  end

  it "should raise an error when an object is expected, but not availale " do
    body = SerialSpec::ParsedBody.new("{}")
    expect{body[:test][:test].execute}.to raise_error(SerialSpec::ParsedBody::MissingSelectorError)
  end

  xit "should raise an error when an object is expected, but not availale " do
    body = SerialSpec::ParsedBody.new("{}")
    expect{body.first[:test].execute}.to raise_error
  end

  context "#each" do
    it "should enumerate over item in array"
    it "should enumerate over each pair in objects"
  end

end
