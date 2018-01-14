#!/bin/bash
killall tg
killall nohup
killall .telegram-cli
killall apimode
rm -rf /root/open/.telegram-cli/apimode
./tg -s ./bot.lua -p apimode --bot=TOKEN
