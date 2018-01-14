#!/bin/bash
COUNTER=1
while(true) do
killall tg
killall nohup
killall .telegram-cli
./tg -s bot.lua
let COUNTER=COUNTER+1 
done
