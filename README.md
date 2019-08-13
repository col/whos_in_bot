# WhosInBot

[![Build Status](https://travis-ci.org/col/whos_in_bot.svg?branch=master)](https://travis-ci.org/col/whos_in_bot)

WhosInBot is a Telegram bot that helps you keep track of who is attending an event within a group chat.

## Commands

### Basic Commands

- `/start_roll_call` - Start a new roll call (with optional title)
- `/end_roll_call` - End the current roll call
- `/in` - Let everyone know you'll be attending (with optional comment)
- `/out` - Let everyone know you won't be attending (with optional comment)
- `/maybe` - Let everyone know that you don't know (with optional comment)
- `/whos_in` - List attendees

### Other Commands

- `/set_title {title}` - Add a title to the current roll call
- `/set_in_for {name}` - Allows you to respond for another user
- `/set_out_for {name}` - Allows you to respond for another user
- `/set_maybe_for {name}` - Allows you to respond for another user
- `/shh` - Tells WhosInBot not to list all attendees after every response
- `/louder` - Tells WhosInBot to list all attendees after every response

### Alias
- `/can`
- `/cannot`

## Usage

Simply add [@WhosInBot](https://telegram.me/whosinbot) to your group chat and send a `/start_roll_call` to start
recording who will be attending an event.

Members of the group chat can respond with `/in`, `/out` or `/maybe`. They can
even provide a reason after the command. ie) `/out injured`.

Each time someone responds [@WhosInBot](https://telegram.me/whosinbot) will print the attendee list.

```
Dinner on Friday
1. Sam
2. John
3. Chris

Out
- James (on holiday)
```

You can clear all the responses and start a new roll call by sending `/start_roll_call` again.


## Development

`mix deps.get`

`mix test`

## Telegram

```
source .env
curl -XPOST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getWebhookInfo
```

```
source .env
curl -XPOST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook?url=$WEBHOOK_URL
```

## Docker

`docker build -t whos_in_bot .`

`docker run whos_in_bot`
