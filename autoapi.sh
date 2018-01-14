#!/bin/bash
COUNTER=1
while(true) do
killall tg
killall nohup
killall .telegram-cli
killall apimode
rm -rf /root/open/.telegram-cli/apimode
./api.sh
let COUNTER=COUNTER+1 
done
