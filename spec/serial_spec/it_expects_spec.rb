require 'spec_helper'

describe "SerialSpec::ItExpects" do
  include SerialSpec::ItExpects

  let(:obj) { double() }

  it_expects(:class_level_call) { obj.class_level_call }

  context "within subclass" do
    it_expects(:subclass_level_call) { obj.subclass_level_call }

    it "should execute inherited expectations" do
      it_expects(:instance_call) { obj.instance_call }

      expect(obj).to receive(:class_level_call)
      expect(obj).to receive(:subclass_level_call)
      expect(obj).to receive(:instance_call)
    end

    it "should allow for overrides" do
      it_expects(:instance_call)    { obj.instance_override }
      it_expects(:class_level_call) { obj.class_override }

      expect(obj).to_not  receive(:class_level_call)
      expect(obj).to_not  receive(:instance_call)

      expect(obj).to      receive(:class_override)
      expect(obj).to      receive(:subclass_level_call)
      expect(obj).to      receive(:instance_override)
    end
  end

end