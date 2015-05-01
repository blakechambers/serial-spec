RSpec::Matchers.define :include_a_provided do |expected|
  match do |actual_list|
    actual_list.detect do |actual|
      SerialSpec::RequestResponse::ProvideMatcher::Provide.new(self, expected).matches?(actual)
    end
  end
end
