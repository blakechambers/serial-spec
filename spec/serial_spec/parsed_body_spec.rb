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
    expect{body[:parent][:child].execute}.to raise_error(SerialSpec::ParsedBody::MissingSelectorError, "expected an object to have [:child], but found NilClass:\"\" at [:parent]")
  end

  it "should raise an error when an array is expected, but not availale " do
    json = { foo: 'test'}.to_json
    body = SerialSpec::ParsedBody.new(json)
    expect{body.first.execute}.to raise_error(SerialSpec::ParsedBody::MissingSelectorError, "expected an array at \"\", but found Hash:'{\"foo\"=>\"test\"}'")
  end

  it "should not mutate when adding selectors" do
    json = {
      foo: {
        bar: "bar value"
      }
    }.to_json

    body = SerialSpec::ParsedBody.new(json)
    body[:foo] # this is mutating the selector, problem

    expect(body[:bar].execute).to_not eq("bar value")
    expect(body[:foo][:bar].execute).to eq("bar value")
  end

  it "should mix enumerable" do
    expect(SerialSpec::ParsedBody.included_modules).to include(Enumerable)
  end

  context "#each" do
    it "should raise an error when attempting to iterate over non-array or hash items (strings, numbers, etc)" do
      json = {
        str: "bar",
        num: 0
      }.to_json

      body = SerialSpec::ParsedBody.new(json)

      expect{body[:str].each}.to raise_error(SerialSpec::ParsedBody::NotAnEnumerableObject)
      expect{body[:num].each}.to raise_error(SerialSpec::ParsedBody::NotAnEnumerableObject)
    end

    it "should enumerate over item in array" do
      json = [
        {
          foo: "bar"
        },
        {
          foo: "bar"
        }
      ].to_json

      body = SerialSpec::ParsedBody.new(json)
      body.each do |member|
        expect(member[:foo].execute).to eq("bar")
      end
    end

    it "should enumerate over each pair in objects" do
      json = {
        a: "bar",
        b: "bar",
        c: "bar"
      }

      expected_keys = json.keys
      body = SerialSpec::ParsedBody.new(json.to_json)

      body.each do |key, member|
        expect(member.execute).to eq("bar")
      end
    end
  end

end
