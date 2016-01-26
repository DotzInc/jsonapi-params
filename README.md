# Jsonapi::Params

This gem handles the parameters of a request that uses the jsonapi specification and provides simple control over input parameters and manipulation of attributes, relationships and other...

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsonapi-params'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsonapi-params

## Usage

To use jsonapi-params you should create a class to handle with your parameters. Example:

```ruby
class AuthorParam
  include JSONAPI::Param

  params :name
end

class ArticleParam
  include JSONAPI::Param

  params :title, :text, :other_text

  belongs_to :author
end

article = ArticleParam.new(
  'data' => {
    'id' => 1,
    'type' => 'x',
    'attributes' => {
      'title' => 'The guy',
      'text' => 'Loren Ipsun',
      'other-text' => 'Hello'
    },
    'relationships' => {
      'author' => {
        'data' => {
          'id' => 123,
          'type' => 'authors',
          'attributes' => {
            'name' => 'Antonio'
          }
        }
      }
    }
  }
)
```

### Available methods to handle with params

#### param

Adds a parameter to whitelist attributes

```ruby
class AuthorParam
  param :name
  param :gender
end
```

#### params

Adds a list of parameters to whitelist attributes

```ruby
class AuthorParam
  params :name, :gender
end
```

#### belongs_to

Creates a one-to-one relationship to update or create objects

```ruby
class AuthorParam
  param :name
end

class ArticleParam
  param :title

  belongs_to :author
end
```

## TODO

* one-to-many relationships
* many-to-many relationships
* metadata

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jsonapi-params.

## License

jsonapi-params is released under the MIT License.
