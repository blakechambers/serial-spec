# SerialSpec [![Build Status](https://travis-ci.org/blakechambers/serial-spec.svg?branch=master)](https://travis-ci.org/blakechambers/serial-spec)

SerialSpec is designed provide some simple matchers and macros overlaying a simple `rack/test` setup for testing json apis more effectively.

## Basic Usage

```ruby
require "spec_helper"

RSpec.describe "test" do
  include SerialSpec

  request_method "GET"
  request_path   "/"

  it_expects(:content_encoding) { expect(status).to eq(200) }
  it_expects(:content_type)     { expect(status).to eq(200) }
end
```

## Contributing

1. Fork it ( https://github.com/blakechambers/serial-spec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
