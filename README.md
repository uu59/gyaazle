[![Build Status](https://travis-ci.org/uu59/gyaazle.png?branch=master)](https://travis-ci.org/uu59/gyaazle)
[![Coverage Status](https://coveralls.io/repos/uu59/gyaazle/badge.png?branch=master)](https://coveralls.io/r/uu59/gyaazle)

# Gyaazle

Gyazo like image uploader that upload image(s) to Google Drive.

## Installation

Add this line to your application's Gemfile:

    gem 'gyaazle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gyaazle

## Usage

    $ gyaazle [options] <file1> <file2> ..

At first time execute, you should authorize Gyaazle app by browser.

## Setting

`gyaazle -e` for open config file by $EDITOR.

### Permissions

Add "permissions" object like below:

```json
{
  "access_token": "********",
  "token_type": "Bearer",
  "expires_in": 3600,
  ...
  "permissions": {
    "role": "reader",
    "type": "domain",
    "value": "uu59.org",
    "withLink": true,
    "additionalRoles": [
      "commenter"
    ]
  }
}
```

Learn more:

* <https://developers.google.com/drive/manage-sharing>
* <https://developers.google.com/drive/v2/reference/permissions#resource>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
