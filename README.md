# WhosInBot

[![Build Status](https://travis-ci.org/col/whos_in_bot.svg?branch=master)](https://travis-ci.org/col/whos_in_bot)

WhosInBot is a Telegram bot that helps you keep track of who is attending an event within a group chat.

## Commands

- /start_roll_call - Start a new roll call
- /end_roll_call - End the current roll call
- /in - Let everyone know you'll be attending
- /out - Let everyone know you won't be attending
- /maybe - Let everyone know that you don't know
- /whos_in - List attendees

## Usage

Simply add [@WhosInBot](https://telegram.me/whosinbot) to your group chat and send a '/start_roll_call' to start
recording who will be attending an event.

Members of the group chat can respond with '/in', '/out' or '/maybe'. They can
even provide a reason after the command. ie) '/out injured'.

Each time someone responds [@WhosInBot](https://telegram.me/whosinbot) will print the attendee list.

```
Dinner on Friday
1. Sam
2. John
2. Chris

Out
- James (on holiday)
```

You can clear all the responses and start a new roll call by sending '/start_roll_call' again.
