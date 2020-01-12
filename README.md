# Light Phone SMS Gateway

This adds a simple SMS gateway that Light Phone 2 (or any phone with SMS for
that matter) can ping with useful commands.

* [Setup](#setup)
* [Cost](#cost)
* [Supported Commands](#supported-commands)
  * [directions](#directions) texts you Google Maps directions
  * [help](#help) shows available commands
  * [ping](#ping) tiny command for testing your gateway
* [Contributing a new command](#contributing-a-new-command)
  * [Creating a command](#creating-a-command)
  * [Registering the command](#registering-the-command)
* [Developing locally with ngrok](#developing-locally-with-ngrok)

## Setup

## Cost

## Supported Commands

Here are the currently supported commands. If you want to add more commands, see [Contributing a new command](#contributing-a-new-command).

### directions

This command will give you Google Maps directions from `start` to `destination`.

*Syntax*: `directions [mode] <start> to <destination>`
*Extra cost:* consult Google Maps API fees

*Params:*
* `mode` - one of `rail bus transit walk bike drive`, defaults to `transit`
* `start`* - your starting location, e.g. `1234 Fake Street, seattle, wa 98123`
* `destination`* - your destination, e.g. `university of washington`

*Setup*:
* [Get an API key for Google Maps](https://developers.google.com/maps/gmp-get-started)
* `heroku config:set GOOGLE_MAPS_API_KEY=...`

*Examples:*

    -> directions rail Smith Tower to University of Washington

    18 mins (4.4 mi) to Seattle, WA 98195, USA

    Walk to Pioneer Square Station (3 mins)
    1. Head northwest on 2nd Ave toward James St (213 ft, 1 min)
    2. Turn right onto James St (322 ft, 2 mins)
    3. Turn left onto 3rd Ave. Destination will be on the right (157 ft, 1 min)

    Light rail towards University Of Washington Station (11 mins)
    1. Board Link light rail (Sound Transit) from Pioneer Square Station at 3:39pm
    2. Get off at University of Washington [[Station]] at 3:50pm

    Walk to Seattle, WA 98195, USA (4 mins)
    1. Head south (85 ft, 1 min)
    2. Turn right toward Montlake Blvd NE (220 ft, 1 min)
    3. Turn left onto Montlake Blvd NE. Destination will be on the right (0.1 mi, 2 mins)

    -> directions rail Barclays Center, Brooklyn, NY to Madison Square Garden

    25 mins (6.1 mi) to 4 Pennsylvania Plaza, New York, NY 10001, USA

    Walk to Atlantic Avenue Barclays Center Station (3 mins)
    1. Head northeast toward Atlantic Ave (131 ft, 1 min)
    2. Turn left onto Atlantic Ave. Destination will be on the left (135 ft, 1 min)
    3. Take entrance Barclays Center entrance (456 ft, 2 mins)

    Subway towards Harlem - 148 St (21 mins)
    1. Board 3 (MTA New York City Transit) from Atlantic Avenue Barclays Center Station at 6:32pm
    2. Get off at 34 St - Penn Station at 6:52pm

    Walk to 4 Pennsylvania Plaza, New York, NY 10001, USA (1 min)
    1. Take exit 7th Ave & 33rd St at NW corner (69 ft, 1 min)
    2. Head southeast on W 33rd St toward 7th Ave/Fashion Ave (66 ft, 1 min)
    3. Turn right onto 7th Ave/Fashion Ave. Destination will be on the right (194 ft, 1 min)

    -> directions walk SF Moma to Japanese gardens, san francisco, ca

    1 hour 30 mins (4.2 mi) to Japanese Tea Garden, 75 Hagiwara Tea Garden Dr, San Francisco, CA 94118, USA
    Head northwest on 3rd St toward Minna St (1 min)
    Turn left onto Mission St (11 mins)
    Turn right onto 6th St (3 mins)
    Turn left onto Market St. Pass by CVS (on the left in 0.2mi) (9 mins)
    Slight right onto Hayes St. Pass by Popeyes Louisiana Kitchen (on the left in 1.2mi) (49 mins)
    Slight right (4 mins)
    Turn right (1 min)
    Turn left (1 min)
    Turn right (6 mins)
    Turn left (3 mins)
    Turn left toward Hagiwara Tea Garden Dr (1 min)
    Turn right onto Hagiwara Tea Garden Dr. Destination will be on the right (2 mins)

### help

Get a list of commands, or get help for a specific command.

*Syntax:* `h [command]`
*Extra cost:* none

*Params*:
* `command` - optional, set it to the name of a known command to get help

*Setup*: none

Running `help [command]` will give you the help text for a specific command.

*Examples:*

    -> h

    Available commands: directions, h, ping

    -> h ping

    ping: returns a pong

### ping

*Syntax*: `ping`
*Params:* none
*Setup*: none
*Extra cost*: none

*Examples:*

    -> ping

    pong

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
2. Run `rackup` from the repo root (boots a web server on port 4567)
3. Run `ngrok http 4567` to tunnel an external URL to your localhost:4567 server

Once the tunnel is up:

1. Go to the [Twilio console](https://www.twilio.com/console/phone-numbers/incoming)
2. Click your phone number
3. Scroll down to Messaging
4. Set the webhook URL to https://whatever.ngrok.io/gateway as an *HTTP POST* (replace "whatever" with your URL):

![image](https://user-images.githubusercontent.com/59429/72227060-0f14d980-354d-11ea-93ae-f30d7f8d2375.png)
