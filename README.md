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

For uptodate doc's take a look into the specs.

```ruby

# for instance you'r ActiveRecord models look like this

class User  < ActiveRecord::Base
  has_many :roles, autosave: true
  has_many :permissions, through: :roles, autosave: true

  belongs_to :salutation, autosave: true
  has_one :address, autosave: true
end

class Role < ActiveRecord::Base
  has_many :permissions, autosave: true
  belongs_to :user, autosave: true
end

class Salutation < ActiveRecord::Base
  has_many :users, autosave: true
end

class Permission < ActiveRecord::Base
  belongs_to :role, autosave: true
end


# You can convert them to poro's like this (automatic genereation of a poro class out of you'r AR class)

ActiverecordToPoro::ObjectMapper.create(Role, name: :roles_converter)
ActiverecordToPoro::ObjectMapper.create(Salutation, name: :salutation_converter)
user_converter = ActiverecordToPoro::ObjectMapper.create(User,
                                                         name: :user_converter,
                                                         convert_associations: {roles: :roles_converter, salutation: :salutation_converter})


poro = user_converter.load(User.first)

# Or with you'r custom poro class

roles_converter = ActiverecordToPoro::ObjectMapper.create(Role,
                                                          load_source: YourPoroClass
                                                         )


# default 1:1 mapping only or except

roles_converter = ActiverecordToPoro::ObjectMapper.create(Role,
                                                    except: [:lock_version]
                                                    )

roles_converter = ActiverecordToPoro::ObjectMapper.create(Role,
                                                    only: [:name]
                                                    )

# add you'r own mapping rules

roles_converter.extend_mapping do
  rule to: :lock_version # for more look @ https://github.com/slowjack2k/yaoc
end

# new rule for faster association mapping

roles_converter.extend_mapping do
  association_rule to: association_name,
                   lazy_loading: true,
                   converter: association_converter #or :association_converter when you'r converter has a name
                   # optional
                   # from: ...,
                   # reverse_to: ...,
                   # reverse_from: ...,
                   # converter: ...,  # a ActiverecordToPoro::Converter
                   # is_collection: ..., # when for instance a scope is used or another method that delivers an ar object
end





```

## Contributing

1. Fork it ( http://github.com/slowjack2k/activerecord_to_poro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
