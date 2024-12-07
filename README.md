# Super simple Advent of Code Slack Bot

[Advent of Code](https://adventofcode.com/)

## AoC Automation Guidelines

This script/repo/tool does follow the [automation guidelines](https://www.reddit.com/r/adventofcode/wiki/faqs/automation) on the /r/adventofcode community wiki.

Specifically:

Outbound calls are throttled to every 15 minutes in `run_diff`.
Once inputs are downloaded, they are cached locally `remember_last_result` and `fetch_new`.
The User-Agent header in `fetch_new` is set to me since I maintain this tool :)

## Setup

This comes with a [fly.io](https://fly.io/) deployment config if you want it.

## Secrets

You will need to setup the following secreats:

`AOC_BOARD_ID` .. The ID of your private board.
`AOC_SESSION` .. Your session ID. Log in to AoC and watch the network traffic when getting your input to copy out the session cookie.
`AOC_SLACK_HOOK` .. Setup a Slack App, enable Incoming Web hooks and copy the URL listed.
