# ActiverecordToPoro [![Code Climate](https://codeclimate.com/github/slowjack2k/activerecord_to_poro.png)](https://codeclimate.com/github/slowjack2k/activerecord_to_poro  ) [![Build Status](https://travis-ci.org/slowjack2k/activerecord_to_poro.png?branch=master)](https://travis-ci.org/slowjack2k/activerecord_to_poro) [![Coverage Status](https://coveralls.io/repos/slowjack2k/activerecord_to_poro/badge.png?branch=master)](https://coveralls.io/r/slowjack2k/activerecord_to_poro?branch=master) [![Gem Version](https://badge.fury.io/rb/activerecord_to_poro.png)](http://badge.fury.io/rb/activerecord_to_poro)

Final goal is a mapping of ActiveRecord-Objects to plain old ruby objects.

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord_to_poro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord_to_poro

## Usage

```ruby

roles_converter = ActiverecordToPoro::Converter.new(Role)
salutation_converter = ActiverecordToPoro::Converter.new(Salutation)
user_converter = ActiverecordToPoro::Converter.new(User, roles: roles_converter, salutation: salutation_converter)


poro = user_converter.load(User.first)



```

## Contributing

1. Fork it ( http://github.com/slowjack2k/activerecord_to_poro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
