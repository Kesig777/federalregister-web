require File.dirname(__FILE__) + '/../spec_helper'

class ConditionsHelperSpec
  include ConditionsHelper
end

describe ConditionsHelperSpec do
  context "#clean_conditions" do
    it "removes the near[within] param when the near[location] param is not present" do
      klass = ConditionsHelperSpec.new
      conditions = {near: {location: "", within: 25}}

      expect(klass.send(:clean_conditions, conditions)).to eq({})
    end

    it "does not the near[within] param when the near[location] param is present" do
      klass = ConditionsHelperSpec.new
      conditions = {near: {location: "94109", within: 25}}

      expect(klass.send(:clean_conditions, conditions)).to eq(conditions)
    end
  end
end
