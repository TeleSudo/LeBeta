#!/bin/bash
killall tg
killall nohup
killall .telegram-cli
killall apimode
./tg -s bot.lua
