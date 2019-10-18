# AbcJsonapi

Minimalistic gem for JSON Serialization according to https://jsonapi.org spec
Inspired by [https://github.com/Netflix/fast_jsonapi](https://github.com/Netflix/fast_jsonapi)
Contributions are welcome.

## Installation

Add this line to your application's Gemfile:

```ruby

gem 'abc_jsonapi'

```

And then execute:

\$ bundle

Or install it yourself as:

\$ gem install abc_jsonapi

## Features

- Relationships (belongs_to, has_many, has_one)
- Compound documents ("include" option)
- Custom include strategies. It is useful when serializing a collection of records to avoid N+1 problem.
- _"Virtual"_ attributes or overriding default attribute serializing behavior

## Usage

Syntax is very similar to Active Model Serializer.

The serializer is able to work with any ruby ​​objects. Not only ActiveRecord. The idea is to use duck typing for getting object attributes, relationships and all other data.

#### Model Example

```ruby
class Author
	attr_reader :first_name, :last_name, :public_name, :contact_id
end
```

#### Serializer Definition

```ruby
class AuthorSerializer
	include AbcJsonapi::Serializer
	resource_type :people (optional)
	attributes :first_name, :last_name, :public_name
	belongs_to :contact
	has_many :books
end
```

#### Custom resource type

Default resource type of direct serializing model is taken from serializer filename. In case of `AuthorSerializer` with disabled pluralize_resources it will be `"author"`. Resource type of compound documents is downcased class of related object.

#### Attributes

Jsonapi attributes may be declared with class method of serializer - `attributes`:

```ruby
attributes :first_attribute, :second, *other
```

`attributes` arguments will be called on serializing model as methods.

Also there is `attribute` method to declare single property. You can pass a block to define the way it should be returned.

```ruby
attribute :date_of_birth  do |object|
	object.date_of_birth.strftime("%FT%T.%3N%:z") if object.stop.present?
end
```

#### Serializer usage

Return ruby hash:

```ruby
AuthorSerializer.new(resource).serializable_hash
```

Return json:

```ruby
AuthorSerializer.new(resource).serialized_json
```

## Compound Documents

To include relationships you can pass `include` option at the serializer initialization stage.

```ruby
options = {}
options[:include] = :books # or "books"
AuthorSerializer.new(resource, options).serialized_json
```

## Configuration

#### Global config options

- **transform_keys** (_true/false_) - convert keys to any case or not. Default value: _true_
- **key_transform_method** (_"camel"_ or _"snake"_) - certain key transform method to use with **transform_keys** option enabled. Default value: _"camel"_
- **pluralize_resources** (_true/false_) - pluralize all resources types in response by default or not. Default value: _false_

#### Usage

```ruby
AbcJsonapi.configure do |config|
	config.transform_keys = true
	config.key_transform_method = "camel"
	config.pluralize_resources  =  true
end
```

## Development

**TODO**:

- Write specs
- Use custom include relationship strategies for downloading relationships json block (solve N+1 problem when serializing collection).
- Meta per resource
- Add other jsonapi features

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ezname/abc_jsonapi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
