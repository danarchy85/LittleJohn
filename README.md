# LittleJohn: A Ruby Automation Framework

This automation framework is the culmination of my 2 years of work developing
an application which automated my stock trading activity on Robinhood.

That original application streamed stock data from Robinhood's REST-API into
MongoDB, aggregated that data into candlestick data over various time intervals,
ran simulations on that historical data to identify ideal trading positions,
then automatically performed live-trading during open market hours.

The program progressed from a series of basic Ruby scripts, to more complete
object-oriented code, and ultimately was redesigned through the development of
this framework you see here.

The primary modules of code include:
- a MongoDB wrapper to ensure connectivity and safe error handling
- a Collection/Model framework akin to ActiveRecord interacting with MongoDB
- an HTTP request class to make JSON-API requests out to external APIs
- an SMTP email sender
- a ThreadHandler to control multi-threading through use of Ruby lambdas
- a Daemon to fork the application with Docker container support

Though work still remains to be done such as proper logging, documentation, code
cleanup, and probably additional features, I am releasing this framework publicly
so that I can begin updating my other Open Source projects to take advantage of
what I have built here.

This is released under the MIT Open Source License to be used, copied, and modified
as people wish. However, since it is also a display of my personal skill development
and work, I currently do not plan to accept outside contributions. Pull-reqeusts are
still welcome if you wish to fix/implement code and share it with others, but it will
likely not be committed into the base repository.

## Installation 

**Not yet available through RubyGems; check out this code directly into your application's
code and include it as shown in the example in lib/LittleJohn.rb**

### Suggested Ruby Version ###

This was committed assuming Ruby-3.0.0, though will *probably* work with 2.7 as well.

### RVM Setup ###

I lock my including applications with RVM and a .ruby-version and .ruby-gemset file in
my app's top-level directory with the following (assuming the app name is 'MyApp'):

```
rvm install ruby-3.0.0
rvm use ruby-3.0.0
rvm gemset create MyApp
echo '3.0.0' > .ruby-version
echo 'MyApp' > .ruby-gemset
```

<!-- Add this line to your application's Gemfile: -->

<!-- ```ruby -->
<!-- gem 'LittleJohn' -->
<!-- ``` -->

<!-- And then execute: -->

<!--     $ bundle install -->

<!-- Or install it yourself as: -->

<!--     $ gem install LittleJohn -->

## Usage

TODO: Write usage instructions here

## Development/Contributing

This is released under the MIT Open Source License to be used, copied, and modified
as people wish. However, since it is also a display of my personal skill development
and work, I currently do not plan to accept outside contributions. Pull-reqeusts are
still welcome if you wish to fix/implement code and share it with others, but it will
likely not be committed into the base repository.

Please only attribute original code in this repository to Dan James, but attribute your
own code to yourself through obvious commenting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
