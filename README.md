# Light Phone SMS Gateway

This adds a simple SMS gateway that Light Phone 2 (or any phone with SMS for
that matter) can ping with useful commands.

* [Setup](#setup)
* [Cost](#cost)
* [Supported Commands](#supported-commands)
  * [ping](#ping) tiny command for testing your gateway
* [Contributing a new command](#contributing-a-new-command)
  * [Creating a command](#creating-a-command)
  * [Registering the command](#registering-the-command)
* [Developing locally with ngrok](#developing-locally-with-ngrok)

## Setup

## Cost

## Supported Commands

Here are the currently supported commands. If you want to add more commands

### ping

Syntax: `ping`

Response: Sends back a simple `pong`

## Contributing a new command

To add a command, you need to do two things:

1. Create a command in `lib/commands/my_command.rb`
2. Register the command in `lib/commands.rb`

### Creating a command

To create a new command, it needs to conform to the interface in
`lib/command/base.rb`. Let's make a simple command that adds two numbers:

```ruby
# lib/command/add.rb
module Commands
  class AddNumbers < Base
    # This is the command name that someone will use when texting
    sig { override.returns(String) }
    def self.name
      'add'
    end

    # This is the help text someone will get back if they text `h add` to
    # the service.
    sig { override.returns(String) }
    def self.help
      <<~HELP
        add [num] [num2]: adds two numbers together

        Example: add 2 4
        Returns: 6
      HELP
    end

    # This returns the response SMS that we want to send back.
    sig { override.returns(String) }
    def response_body
      # arg_text contains everything after the command name.
      # E.g., if someone sends in `add 2 4`, arg_text will contain the string
      # `2 4`
      matches = arg_text.match(/^(?<num1>\d+)\s+(?<num2>\d+)$/)

      # Send back help text if they put the wrong command in
      return help unless matches

      num1 = matches[:num1].to_i
      num2 = matches[:num2].to_i

      result = num1 + num2

      # Send back the sum as an SMS
      result.to_s
    end
  end
end
```

### Registering the command

To register the new `add` command we just made, add this line to `lib/commands.rb`:

```ruby
require_relative './commands/add'
```

Next, in the same file, add `Commands::AddNumbers` to the list of commands in
the `def self.all` method.

This should be all you need to do to hook your new command up to the gateway!

## Developing locally with ngrok

The easiest way to test any new commands you write is to use ngrok.

1. `brew cask install ngrok`
2. Run `rackup` from the repo root (boots a server on 4567)
3. Run `ngrok http 4567` to tunnel an external URL to your localhost:4567 server

Once the tunnel is up:

1. Go to the [Twilio console](https://www.twilio.com/console/phone-numbers/incoming)
2. Click your phone number
3. Scroll down to Messaging
4. Set the webhook URL to https://whatever.ngrok.io/gateway as an *HTTP POST* (replace "whatever" with your URL):

![image](https://user-images.githubusercontent.com/59429/72227060-0f14d980-354d-11ea-93ae-f30d7f8d2375.png)
