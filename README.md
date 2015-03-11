# SerialSpec

SerialSpec is designed provide some simple matchers and macros overlaying a simple `rack/test` setup for testing json apis more effectively.  There are a few good requirements to get you going:

* Rspec 3.x.  This gem uses (or will use) several parts of rspecs syntax.
* Json api
* ActiveModelSerializers
* Single request testing pattern test architecture.

## Usage

TODO: code samples

## Testing architecture

SerialSpec is assuming that you are:

1. setting up preconditions
2. executing 1 request
3. inspecting the response

If you need more requests you should be using mocks and stubs.

### "But I need more than one request?"

SerialSpec, unlike rails' out of the box request testing system is closer to a controller test, than rails' request test, which is more kin to an integration test.  Some people recommend using actual requests for performing things like login, auth vs mocking.  However, this library doesn't subscribe to that pattern.  If you aren't ok with that, you should look elsewhere.

## Contributing

1. Fork it ( https://github.com/blakechambers/serial-spec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
