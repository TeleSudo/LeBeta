lua = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()
serpent = require('serpent')
json = (loadfile "./libs/JSON.lua")()
http = require "socket.http"
https = require "ssl.https"
JSON = (loadfile "./libs/dkjson.lua")()
serp = require 'serpent'.block
URL = (loadfile "./libs/url.lua")()
day = 86400
botname = redis:get('bot:name') or 'nil' -- Bot Name
cli_id = 501937504 -- Put Your Cli Bot ID
api_id = 314178487 -- Put Your Api Bot ID
bot_username = redis:get('bot:username') or '@nil' -- Bot Username
not_fwd_user = 'Please Reply on a forwarded Message from a user!'
not_reply = 'Please Reply on a message!'
user_not_found = 'User Not Found!'
usm_not_found = 'Username Not Found.'
you_not_mod = 'For Moderators!'
you_not_owner = 'For Owner!'
have_acces = 'User is Owner/Moderator/Sudo\nFirst,Demote user!'
sudo = 282958812 -- SUDO Orginal


function sleep(time)
local clock = os.clock
local t0 = clock()
while clock() - t0 <= time do end
end
local function run_bash(str)
local result = io.popen(str):read('*all')
return result
end
function getChatId(id)
local chat = {}
local id = tostring(id)
if id:match('^-100') then
local channel_id = id:gsub('-100','')
chat = {ID = channel_id,type = 'channel'}
else
local group_id = id:gsub('-','')
chat = {ID = group_id,type = 'group'}
end
return chat
end
local function delgp(chat)
local hash = redis:keys('*'..chat..'*')
for i=1,#hash do
redis:del(hash[i])
end
local hash2 = redis:keys('*'..chat)
for i=1,#hash2 do
redis:del(hash2[i])
end
redis:srem('groups',chat)
end
function banlock(chatid,userid,mid)
if not redis:sismember('banned:'..chatid,userid) then
redis:sadd('banned:'..chatid,userid)
lua.changeChatMemberStatus(chatid,userid,'Kicked')
else
lua.changeChatMemberStatus(chatid,userid,'Kicked')
end
lua.deleteMessages(chatid,mid)
end
function kicklock(chatid,userid,mid)
lua.changeChatMemberStatus(chatid,userid,'Kicked')
lua.deleteMessages(chatid,mid)
end
-- function owner
function is_owner(msg)
local var = false
if redis:sismember('owner:'..msg.chat_id_,msg.sender_user_id_) then
var = true
elseif tonumber(redis:get('oneowner:'..msg.chat_id_)) == msg.sender_user_id_ then
var = true
end
if sudo == msg.sender_user_id_ then
var = true
end
if redis:sismember('sudousers',msg.sender_user_id_) then
var = true
end
return var
end
--- function super
function is_super(msg)
chat_id = tostring(msg.chat_id_)
if chat_id:match('^-100') then
if not msg.is_post_ then
return true
end
else
return false
end
end
--- function sudo
function is_sudo(msg)
local var = false
if sudo == msg.sender_user_id_ then
var = true
end
return var
end
--- function sudo2
function is_sudo2(msg)
local var = false
if sudo == msg.sender_user_id_ then
var = true
end
if redis:sismember('sudousers',msg.sender_user_id_) then
var = true
end
return var
end
--- function promote
function is_mod(msg)
local var = false
if redis:sismember('mods:'..msg.chat_id_,msg.sender_user_id_) then
var = true
elseif tonumber(redis:get('oneowner:'..msg.chat_id_)) == msg.sender_user_id_ then
var = true
elseif redis:sismember('owner:'..msg.chat_id_,msg.sender_user_id_) then
var = true
end
if sudo == msg.sender_user_id_ then
var = true
elseif redis:sismember('sudousers',msg.sender_user_id_) then
var = true
end
return var
end
--- function promote2
function is_mod2(chat,user)
local var = false
if redis:sismember('mods:'..chat,user) then
var = true
elseif tonumber(redis:get('oneowner:'..chat)) == user then
var = true
elseif redis:sismember('owner:'..chat,user) then
var = true
elseif sudo == user then
var = true
elseif redis:sismember('sudousers',user) then
var = true
end
return var
end
-- function owner2
function is_owner2(chat,user)
local var = false
if redis:sismember('owner:'..chat,user) then
var = true
elseif tonumber(redis:get('oneowner:'..chat)) == user then
var = true
elseif sudo == user then
var = true
elseif redis:sismember('sudousers',user) then
var = true
end
return var
end
--- function okuser
function is_okuser(chat,user)
local var = true
if redis:sismember('muteusers:'..chat,user) or redis:get('cmdtg:'..chat) then
var = false
elseif redis:get('chattg:'..chat) then
var = false
elseif redis:get('alltg:'..chat) then
var = false
end
return var
end
--- function whiteuser
function is_whiteuser(msg)
local var = false
if redis:sismember('whitelist:'..msg.chat_id_,msg.sender_user_id_) then
var = true
end
return var
end
--- function whiteuser2
function is_whiteuser2(chat,user)
local var = false
if redis:sismember('whitelist:'..chat,user) then
var = true
end
return var
end
-- function setowner
function setowner(chat,user)
redis:del('owner:'..chat)
redis:del('owngp',user)
redis:set('oneowner:'..chat,user)
redis:sadd('owner:'..chat,user)
redis:hset('owngp',user,chat)
end
-- Print callback
function dl_cb(arg,data)
end
function setupmonth(msg,input)
redis:setex('checklinkgp:'..input,1800,true)
redis:setex("bot:charge:"..input,2592000,true)
redis:srem("gptested",input)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Plan 1 [30 Day] *Actived*!',1,'md')
 function getuser(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
 lua.sendText(sudo,0,0,1,nil,"ID: <code>"..input.."</code>\nInstaller: "..name.." [<code>"..msg.sender_user_id_.."</code>]\nOwner: <code>"..(redis:get("oneowner:"..input) or "Not Seted").."</code>\nExpire: <b>30 Day</b>\nLink: "..(redis:get("group:link"..input) or "Not Seted!"),1,'html')
end
lua.getUserFull(msg.sender_user_id_,getuser)
redis:set("bot:enable:"..input,true)
end

function setup3month(msg,input)
redis:setex('checklinkgp:'..input,1800,true)
redis:setex("bot:charge:"..input,7776000,true)
redis:srem("gptested",input)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Plan 2 [90 Day] *Actived*!',1,'md')
 function getuser(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
 lua.sendText(sudo,0,0,1,nil,"ID: <code>"..input.."</code>\nInstaller: "..name.." [<code>"..msg.sender_user_id_.."</code>]\nOwner: <code>"..(redis:get("oneowner:"..input) or "Not Seted").."</code>\nExpire: <b>90 Day</b>\nLink: "..(redis:get("group:link"..input) or "Not Seted!"),1,'html')
 end
 lua.getUserFull(msg.sender_user_id_,getuser)
 redis:set("bot:enable:"..input,true)
end

function setupunlimited(msg,input)
redis:setex('checklinkgp:'..input,1800,true)
redis:set("bot:charge:"..input,true)
redis:srem("gptested",input)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Plan 3 [Unlimited] *Actived*',1,'md')
 function getuser(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
 lua.sendText(sudo,0,0,1,nil,"ID: <code>"..input.."</code>\nInstaller: "..name.." [<code>"..msg.sender_user_id_.."</code>]\nOwner: <code>"..(redis:get("oneowner:"..input) or "Not Seted").."</code>\nExpire: <b>Unlimited</b>\nLink: "..(redis:get("group:link"..input) or "Not Seted!"),1,'html')
 end
 lua.getUserFull(msg.sender_user_id_,getuser)
 redis:set("bot:enable:"..input,true)
end

function setupcharge(msg,input,charge)
local jdat = json:decode(http.request("http://irapi.ir/time/"))
redis:set('setuptime:'..input,jdat.ENtime)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Group Charged for *'..charge..'* Day',1,'md')
local time = charge * day
 redis:setex("bot:charge:"..input,time,true)
 redis:set("bot:enable:"..input,true)
redis:srem("gptested",input)
function getuser(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
 lua.sendText(sudo,0,0,1,nil,"ID: <code>"..input.."</code>\nInstaller: "..name.." [<code>"..msg.sender_user_id_"</code>]\nOwner: <code>"..(redis:get("oneowner:"..input) or "Not Seted").."</code>\nExpire: <b>"..charge.." (Charge)</b>\nLink: "..(redis:get("group:link"..input) or "Not Seted!"),1,'html')
end
lua.getUserFull(msg.sender_user_id_,getuser)
end
local function go_warn(msg,chat,user,dalil)
if msg.sender_user_id_ ~= cli_id and msg.sender_user_id_ ~= api_id then
warns = redis:get('warns:'..chat..':'..user) or 0
setwarn = tonumber(warns) + 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
if redis:get('warn_action:'..chat) then
action = 'Ban'
else
action = 'Kick'
end
if setwarn == max_warn then
if redis:get('warn_action:'..chat) then
redis:sadd('banned:'..chat,user)
redis:del('warns:'..chat..':'..user)
lua.sendText(chat,0,0,1,nil,'User [<code>'..user..'</code>] #Banned For Reach to Max Warn [<b>'..max_warn..'</b>]',1,'html')
lua.changeChatMemberStatus(chat,user,'Kicked')
else
redis:del('warns:'..chat..':'..user)
lua.sendText(chat,0,0,1,nil,'User [<code>'..user..'</code>] #Kicked For Reach to Max Warn [<b>'..max_warn..'</b>]',1,'html')
lua.changeChatMemberStatus(chat,user,'Kicked')
end -- END of warn_action
else
redis:set('warns:'..chat..':'..user,setwarn)
if not redis:get('warn_limit:'..chat..':'..user) then
redis:setex('warn_limit:'..chat..':'..user,20,true)
function getname(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat,0,0,1,nil,'👤User '..name..' You #Received 1 warn!\n🔢Your Warns: [<b>'..setwarn..'</b>/<code>'..max_warn..'</code>]\n❓Reason Warn: '..dalil..'\n⚠️After Receive '..max_warn..' Warn you #'..action..' From Group!',1,'html')
end
lua.getUserFull(user,getname)
end
end -- END of setwarn == max_warn
end -- END redis:setex
end -- END function
function vardump(value,depth,key)
local linePrefix = ''
local spaces = ''
if key ~= nil then
linePrefix = key .. ' = '
end
if depth == nil then
depth = 0
else
depth = depth + 1
for i=1,depth do
spaces = spaces .. ''
end
end
if type(value) == 'table' then
mTable = getmetatable(value)
if mTable == nil then
print(spaces .. linePrefix .. '(table) ')
else
print(spaces .. '(metatable) ')
value = mTable
end
for tableKey,tableValue in pairs(value) do
vardump(tableValue,depth,tableKey)
end
elseif type(value)== 'function' or
type(value) == 'thread' or
type(value) == 'userdata' or
value == nil then --@Radical_TG
print(spaces .. tostring(value))
elseif type(value)== 'string' then
print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
else
print(spaces .. linePrefix .. tostring(value) .. ',')
end
end
function tdcli_update_callback(data)
if (data.ID == "UpdateMessageEdited") then
function on_edit(extra,result,success)
chat = result.chat_id_
user = result.sender_user_id_
mid = {[0] = tonumber(result.id_)}
if user ~= cli_id and user ~= api_id then
if not is_mod2(chat,user) and not is_whiteuser2(chat,user) then
if result.content_.text_ or result.content_.caption_ then
 LError2 = (result.content_.text_ or result.content_.caption_)
 end
if LError2:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or LError2:match("[Tt].[Mm][Ee]/") or LError2:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") then
if redis:get('linktg:'..chat) == 'del' then
lua.deleteMessages(chat,mid)
if redis:get('warntg:'..chat) then
dalil = 'Send Link (Editing Message)'
go_warn(msg,chat,user,dalil)
end
elseif redis:get('linktg:'..chat) == 'kick' then
kicklock(chat,user,mid)
elseif redis:get('linktg:'..chat) == 'ban' then
banlock(chat,user,mid)
 end
end
if result.content_.entities_ and redis:get('mentiontg:'..chat) then
local Entities = result.content_.entities_
for i=0,#Entities do
if Entities and Entities[i].ID == "MessageEntityMentionName" then
if redis:get('mentiontg:'..chat) == 'del' then
lua.deleteMessages(chat,mid)
if redis:get('warntg:'..chat) then
dalil = 'Mention Name'
go_warn(msg,chat,user,dalil)
end
elseif redis:get('mentiontg:'..chat) == 'kick' then
kicklock(chat,user,mid)
elseif redis:get('mentiontg:'..chat) == 'ban' then
banlock(chat,user,mid)
end
end
end
end
if LError2:match("@") then
if redis:get('tagtg:'..chat) == 'del' then
lua.deleteMessages(chat,mid)
if redis:get('warntg:'..chat) then
dalil = 'Send Tag [@] (Editing Message)'
go_warn(msg,chat,user,dalil)
end
elseif redis:get('tagtg:'..chat) == 'kick' then
kicklock(chat,user,mid)
elseif redis:get('tagtg:'..chat) == 'ban' then
banlock(chat,user,mid)
end
end
if redis:get('spamtg:'..chat) then
local MAX_SPAM_GP = 4096
if redis:get('spam:char:'..chat) then
MAX_SPAM_GP = tonumber(redis:get('spam:char:'..chat))
end
local max_mesg = MAX_SPAM_GP * 1
if string.len(LError2) > max_mesg then
lua.deleteMessages(chat,{[0] = tonumber(result.id_)})
if redis:get('warntg:'..chat) then
dalil = 'Spaming [Long Text] (Editing Message)'
go_warn(msg,chat,user,dalil)
end
end
end
end
end
end
lua.getMessage(data.chat_id_,data.message_id_,on_edit)
elseif (data.ID == "UpdateNewMessage") then
msg = data.message_
if tonumber(msg.date_) < tonumber(os.time() - 2) then
print('Old Message!')
return false
end
chat_id = msg.chat_id_
user_id = msg.sender_user_id_
mid = {[0] = msg.id_}
reply_id = msg.reply_to_message_id_
mygp = redis:sismember('groups',msg.chat_id_)
--vardump(msg)
if msg.content_.text_ then
LError = msg.content_.text_
end
if msg.content_.text_ or msg.content_.caption_ then
LError2 = (msg.content_.text_ or msg.content_.caption_)
end
if redis:get('markread') then
lua.viewMessages(msg.chat_id_,{[0] = msg.id_})
end
--vardump(msg)
-------------------------- Start Message Checks --------------------------
if is_super(msg) and msg.can_be_deleted_ == true and not is_mod(msg) and not is_whiteuser(msg) and not redis:get('bot:load'..msg.chat_id_) then
if redis:get('addtg:'..msg.chat_id_) and tonumber(redis:scard('addofuser:'..msg.sender_user_id_)) == tonumber(redis:get('setadd:'..msg.chat_id_)) then
redis:sadd('ucansend:'..msg.chat_id_,msg.sender_user_id_)
redis:del("addofuser:"..msg.sender_user_id_)
redis:srem('ucantsend:'..msg.chat_id_,msg.sender_user_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'User [<code>'..msg.sender_user_id_..'</code>] You Add '..tonumber(redis:get('setadd:'..msg.chat_id_))..' Member!\nNow You can send Message✌️',1,'html')
elseif msg.content_.text_ and redis:get('addtg:'..msg.chat_id_) and not redis:sismember('ucansend:'..msg.chat_id_,msg.sender_user_id_) and not redis:sismember('ucantsend:'..msg.chat_id_,msg.sender_user_id_) then
if tonumber(redis:scard('addofuser:'..msg.sender_user_id_)) ~= tonumber(redis:get('setadd:'..msg.chat_id_)) then
function check_can_send(extra,result,success)
redis:sadd('ucantsend:'..msg.chat_id_,msg.sender_user_id_)
local first_name = result.user_.first_name_
first_name = string.gsub(first_name,'*','')
first_name = string.gsub(first_name,'_','')
first_name = string.gsub(first_name,'`','')
first_name = string.gsub(first_name,'ـ','')
local mustadd = (redis:get('setadd:'..msg.chat_id_) or '0')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'Dear User '..first_name..',if you send Message you must add '..mustadd..' new Member to group!\nStart to adding Member! Come on 💪',1,'md')
end
lua.getUserFull(msg.sender_user_id_,check_can_send)
end
end

if LError2 and redis:get('filtertg:'..msg.chat_id_) then
local hash = 'badword:'..msg.chat_id_
if hash then
local names = redis:hkeys(hash)
local text = ''
for i=1,#names do
 if string.match(LError2:lower(),names[i]:lower()) then
 lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
 end
end
 end
 end

if redis:get('alltg:'..msg.chat_id_) then
if msg.content_.ID == "MessageChatAddMembers" then
return false
elseif msg.content_.ID == "MessageChatJoinByLink" then
return false
else
 lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
end
end

if redis:get("lc_ato:"..msg.chat_id_) then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
end

if msg.content_.ID == "MessageUnsupported" and redis:get('selfietg:'..msg.chat_id_) then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
end

if redis:get("bottg:"..msg.chat_id_) then
function CheckBot(extra,result,success)
if result.user_.username_ and result.user_.username_:match("[Bb][Oo][Tt]$") then
lua.changeChatMemberStatus(msg.chat_id_,result.user_.id_,'Kicked')
lua.deleteMessagesFromUser(msg.chat_id_,result.user_.id_)
if redis:get("bottg:"..msg.chat_id_) == "ban" then
redis:sadd("banned:"..msg.chat_id_,result.user_.id_)
end
end
end
lua.getUserFull(msg.sender_user_id_,CheckBot)
end

if msg.content_.ID == "MessageChatAddMembers" then
local mem_id = msg.content_.members_
for i=0,#mem_id do
if redis:get('memberstg:'..msg.chat_id_) == 'add' or redis:get('memberstg:'..msg.chat_id_) == 'all' then
lua.changeChatMemberStatus(msg.chat_id_,mem_id[i].id_,'Kicked')
elseif redis:get('tgservicetg:'..msg.chat_id_) == 'add' or redis:get('tgservicetg:'..msg.chat_id_) == 'all' then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
elseif redis:get('bottg:'..msg.chat_id_) and mem_id[i].username_ and mem_id[i].username_:match("[Bb][Oo][Tt]$") then
lua.changeChatMemberStatus(msg.chat_id_,mem_id[i].id_,'Kicked')
elseif redis:sismember('banned:'..msg.chat_id_,mem_id[i].id_) then
lua.changeChatMemberStatus(msg.chat_id_,mem_id[i].id_,'Kicked')
elseif redis:sismember('gbanned',mem_id[i].id_) then
lua.changeChatMemberStatus(msg.chat_id_,mem_id[i].id_,'Kicked')
elseif redis:get('addtg:'..msg.chat_id_) then
if not redis:sismember('ucansend:'..msg.chat_id_,msg.sender_user_id_) then
if mem_id[i].username_ and mem_id[i].username_:match("[Bb][Oo][Tt]$") then
return false
else
redis:sadd('addofuser:'..msg.sender_user_id_,mem_id[i].id_)
end
end
end
end
end

if msg.content_.ID == "MessageChatJoinByLink" then
if redis:get('memberstg:'..msg.chat_id_) == 'link' or redis:get('memberstg:'..msg.chat_id_) == 'all' then
lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
elseif redis:get('tgservicetg:'..msg.chat_id_) == 'link' or redis:get('tgservicetg:'..msg.chat_id_) == 'all' then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
end
end

if msg.content_.ID == "MessageChatDeleteMember" then
if redis:get('tgservicetg:'..msg.chat_id_) == 'left' or redis:get('tgservicetg:'..msg.chat_id_) == 'all' then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
end
end

if msg.content_.sticker_ then
if redis:get('stickertg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Sticker'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('stickertg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('stickertg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.animation_ then
if redis:get('giftg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Gif'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('giftg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('giftg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.contact_ then
 if redis:get('contacttg:'..msg.chat_id_) == 'del' then
 lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Contact'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('contacttg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('contacttg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
 end
end

if msg.content_.photo_ then
if redis:get('phototg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Photo'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('phototg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('phototg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
 end
end

if msg.content_.audio_ then
if redis:get('audiotg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Audio or Music'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('audiotg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('audiotg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
 end
 
if msg.content_.voice_ then
if redis:get('voicetg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Voice'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('voicetg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('voicetg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.video_ then
if redis:get('videotg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Video'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('videotg:'..msg.chat_id_) == 'kick' then 
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
 elseif redis:get('videotg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.document_ then
if redis:get('filetg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send File'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('filetg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('filetg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.text_ then
if redis:get('chattg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Text (Chating)'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('chattg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('chattg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.entities_ and redis:get('mentiontg:'..msg.chat_id_) then
local Entities = msg.content_.entities_
for i=0,#Entities do
vardump(msg)
if Entities and Entities[i].ID == "MessageEntityMentionName" then
if redis:get('mentiontg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Mention Name'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('mentiontg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('mentiontg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end
end
end

if msg.forward_info_ and redis:get('fwdtg:'..msg.chat_id_) then
if msg.forward_info_.ID == "MessageForwardedPost" and redis:get('fwdtg:'..msg.chat_id_) == 'post' then
if redis:get('fwdtg2:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Forwarding from some Channels'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
 elseif redis:get('fwdtg2:'..msg.chat_id_) == 'kick' then
 kicklock(msg.chat_id_,msg.sender_user_id_,mid)
 elseif redis:get('fwdtg2:'..msg.chat_id_) == 'ban' then
 banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
elseif msg.forward_info_.ID == "MessageForwardedFromUser" and redis:get('fwdtg:'..msg.chat_id_) == 'user' then
if redis:get('fwdtg2:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Forwarding from some Users'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('fwdtg2:'..msg.chat_id_) == 'kick' then
 kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('fwdtg2:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
elseif msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" and redis:get('fwdtg:'..msg.chat_id_) == 'all' then
if redis:get('fwdtg2:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Forwarding'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('fwdtg2:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('fwdtg2:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end
end

if LError2:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or LError2:match("[Tt].[Mm][Ee]/") or LError2:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") then
if redis:get('linktg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Link'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('linktg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('linktg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if LError2:match("@") then
if redis:get('tagtg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Tag (@)'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('tagtg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('tagtg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.content_.location_ then
if redis:get('loctg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Location'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('loctg:'..msg.chat_id_) == 'kick' then
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('loctg:'..msg.chat_id_) == 'ban' then
 banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.via_bot_user_id_ ~= 0 then
if redis:get('inlinetg:'..msg.chat_id_) == 'del' then
lua.deleteMessages(msg.chat_id_,mid)
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Send Inline'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
elseif redis:get('inlinetg:'..msg.chat_id_) == 'kick' then 
kicklock(msg.chat_id_,msg.sender_user_id_,mid)
elseif redis:get('inlinetg:'..msg.chat_id_) == 'ban' then
banlock(msg.chat_id_,msg.sender_user_id_,mid)
end
end

if msg.can_be_deleted_ == true then
 if redis:sismember('muteusers:'..msg.chat_id_,msg.sender_user_id_) then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
elseif redis:sismember('gbanned',msg.sender_user_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,0,0,1,nil,'User [<code>'..msg.sender_user_id_..'</code>] is <i>Globally Ban</i> from '..botname..' Groups!',1,'html')
redis:del('warns:'..msg.chat_id_..':'..msg.sender_user_id_)
lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
elseif redis:sismember('banned:'..msg.chat_id_,msg.sender_user_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'User [<code>'..msg.sender_user_id_..'</code>] is <i>Ban</i> from This Group!',1,'html')
redis:del('warns:'..msg.chat_id_..':'..msg.sender_user_id_)
lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
end
end

-- Anti-Spam
if msg.content_.text_ or msg.content_.caption_ then
if redis:get('spamtg:'..msg.chat_id_) then
if redis:get('spam:char:'..msg.chat_id_) then
MAX_SPAM_GP = tonumber(redis:get('spam:char:'..msg.chat_id_))
else
MAX_SPAM_GP = 4096
end 
local max_mesg = MAX_SPAM_GP * 1
if string.len(LError2) > max_mesg then
lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
if redis:get('warntg:'..msg.chat_id_) then
dalil = 'Spaming (Long Text)'
go_warn(msg,msg.chat_id_,msg.sender_user_id_,dalil)
end
end
end
end

-- Anti-Flood
if tonumber(redis:get("floodban:"..msg.sender_user_id_)) == 3 then
redis:del("floodban:"..msg.sender_user_id_)
redis:del('warns:'..msg.chat_id_..':'..msg.sender_user_id_)
redis:sadd('gbanned',msg.sender_user_id_)
lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
function check_id(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
if result.user_.username_ then
user = result.user_.username_
else
user = '"'..name..'" [<code>'..msg.sender_user_id_..'</code>]'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'User '..user..' Has been flooding for 3 time! then Globally Banned from '..botname..' All Group!',1,'md')
end
lua.getUserFull(msg.sender_user_id_,check_id)
end

if redis:get('floodtg:'..msg.chat_id_) then
if not redis:get('flood:max:'..msg.chat_id_) then
floodMax = 5
else
floodMax = tonumber(redis:get('flood:max:'..msg.chat_id_))
end
if not redis:get('flood:time:'..msg.chat_id_) then
floodTime = 3
else
floodTime = tonumber(redis:get('flood:time:'..msg.chat_id_))
end
local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
local msgs = tonumber(redis:get(hash) or 0)
if msgs > (floodMax - 1) then
 if redis:sismember("banned:"..msg.chat_id_,msg.sender_user_id_) then
 lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
lua.deleteMessagesFromUser(msg.chat_id_,msg.sender_user_id_)
else
redis:del("user:msgs:"..msg.chat_id_..":"..msg.sender_user_id_)
redis:del("amaruser:add:"..msg.chat_id_..":"..msg.sender_user_id_)
redis:del('warns:'..msg.chat_id_..':'..msg.sender_user_id_)
if redis:get('floodtg:'..msg.chat_id_) == 'kick' then
lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
lua.deleteMessagesFromUser(msg.chat_id_,msg.sender_user_id_)
text = '#Kicked From Group!!!👊'
elseif redis:get('floodtg:'..msg.chat_id_) == 'ban' then
redis:sadd('banned:'..msg.chat_id_,msg.sender_user_id_)
lua.changeChatMemberStatus(msg.chat_id_,msg.sender_user_id_,'Kicked')
lua.deleteMessagesFromUser(msg.chat_id_,msg.sender_user_id_)
 text = '#Banned From Group!!!👊'
 elseif redis:get('floodtg:'..msg.chat_id_) == 'del' then
lua.deleteMessagesFromUser(msg.chat_id_,msg.sender_user_id_)
text = '#Deleted All Messages this user From Group!!!👊'
end
 function sendalertflood(extra,result,success)
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
if result.user_.username_ then
user = result.user_.username_
else
user = '"'..name..'" [<code>'..msg.sender_user_id_..'</code>]'
end
redis:set("floodban:"..msg.sender_user_id_,tonumber((redis:get("floodban:"..msg.sender_user_id_) or 0)) + 1)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'User'..user..';\nIn this Group has been send *'..floodMax..'* post Under *'..floodTime..'* Second!\n'..text,1,'md')
end
lua.getUserFull(msg.sender_user_id_,sendalertflood)
end
end
redis:setex(hash,floodTime,msgs+1)
redis:sadd('floods:'..msg.chat_id_..':'..msg.sender_user_id_,msg.id_)
end


if redis:get('addtg:'..msg.chat_id_) and not redis:sismember('ucansend:'..msg.chat_id_,msg.sender_user_id_) then
 if msg.content_.ID == "MessageChatAddMembers" then
return false
elseif msg.content_.ID == "MessageChatJoinByLink" then
return false
else
 lua.deleteMessages(msg.chat_id_,{[0] = msg.id_})
end
end
end --End if not is_mod(msg) and not redis:get('bot:load'..msg.chat_id_) in 515
-------------------------- End Message Checks --------------------------

-------- |Amar Gir| --------
redis:incr("user:sendall:"..msg.sender_user_id_)
if msg.forward_info_ and (msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost") then
redis:incr("user:sendfwd:"..msg.sender_user_id_)
elseif msg.content_.text_ then
redis:incr("user:sendtext:"..msg.sender_user_id_)
elseif msg.content_.sticker_ then
redis:incr("user:sendsticker:"..msg.sender_user_id_)
elseif msg.content_.video_ then
redis:incr("user:sendvideo:"..msg.sender_user_id_)
elseif msg.content_.voice then
redis:incr("user:sendvoice:"..msg.sender_user_id_)
elseif msg.content_.audio_ then
redis:incr("user:sendaudio:"..msg.sender_user_id_)
elseif msg.content_.animation_ then
redis:incr("user:sendgif:"..msg.sender_user_id_)
elseif msg.content_.location_ then
redis:incr("user:sendmap:"..msg.sender_user_id_)
elseif msg.content_.photo_ then
redis:incr("user:sendphoto:"..msg.sender_user_id_)
elseif msg.content_.document_ then
redis:incr("user:sendfile:"..msg.sender_user_id_)
elseif msg.content_.contact_ then
redis:incr("user:sendcontact:"..msg.sender_user_id_)
elseif msg.content_.ID == "MessageChatAddMembers" then
redis:incr("user:sendadd:"..msg.sender_user_id_)
elseif msg.content_.ID == "MessageUnsupported" then
redis:incr("user:sendselfie:"..msg.sender_user_id_)
end
-------- |Amar Gir| --------
if msg.content_.ID == "MessagePinMessage" and is_owner(msg) and redis:get('pintg:'..msg.chat_id_) then
redis:set('pintg:'..msg.chat_id_,msg.content_.message_id_)
lua.sendText(msg.chat_id_,msg.content_.message_id_,0,1,nil,'Your Message Set for _Pin Lock_',1,'md')
elseif msg.content_.ID == "MessagePinMessage" and not is_owner(msg) and redis:get('pintg:'..msg.chat_id_) then
function getbotforpin(extra,result,success)
if msg.sender_user_id_ ~= result.id_ then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Dear User,_Pin_ is *Locked* so i pin message of *Owner Group* again!',1,'md')
lua.pinChannelMessage(msg.chat_id_,tonumber(redis:get('pintg:'..msg.chat_id_)),1)
end
end
lua.getMe(getbotforpin)
end
-------------------------- Start SuperGroup Commands ----------------------------
if not redis:get("bot:charge:"..msg.chat_id_) then
 if redis:get("bot:enable:"..msg.chat_id_) then
redis:del("bot:enable:"..msg.chat_id_)
redis:del('expis1:'..chat_id)
lua.sendText(sudo,0,0,1,nil,'#Expired\nID: `'..chat_id..'`\nOwner: `'..(redis:get('oneowner:'..chat_id) or 'Not Seted!')..'`',1,'md')
lua.sendText(sudo,0,0,1,nil,"Charge of This Group is END!\nLink : "..(redis:get("group:link"..msg.chat_id_) or "Nil!").."\nID : <code>"..msg.chat_id_.."</code>\n\nFor Leave Bot from This Group run:\n/leave"..msg.chat_id_.."",1,'html')
delgp(msg,msg.chat_id_)
lua.sendText(msg.chat_id_,0,0,1,nil,'Group Charge Expired!\nFor Extend it go to @LError',1,'html')
function leavecharge(extra,result,success)
lua.changeChatMemberStatus(msg.chat_id_,result.id_,'Left')
end
lua.getMe(leavecharge)
end
end
if msg.content_.text_ then
if LError:match("^[!/#][Bb][Oo][Tt]$") and is_owner(msg) and mygp then
if redis:get('bot:load'..chat_id) then
redis:del('bot:load'..chat_id)
lua.sendText(chat_id,msg.id_,0,1,nil,'Bot Has Been <b>Power ON</b>! ✅',1,'html')
else
redis:set('bot:load'..chat_id,true)
lua.sendText(chat_id,msg.id_,0,1,nil,'Bot Has Been <b>Power OFF</b>! 💤\nFor power on bot send: !bot',1,'html')
end
end
if not redis:get('bot:load'..msg.chat_id_) then
if redis:get("alltg_begin:"..msg.chat_id_) or redis:get("alltg_end:"..msg.chat_id_) then
local time = os.date("%H%M")
local time2 = redis:get("alltg_begin:"..msg.chat_id_)
time2 = time2.gsub(time2,":","")
local time3 = redis:get("alltg_end:"..msg.chat_id_)
time3 = time3.gsub(time3,":","")
if tonumber(time3) < tonumber(time2) then
if tonumber(time) <= 2359 and tonumber(time) >= tonumber(time2) then
if not redis:get("lc_ato:"..msg.chat_id_) then
redis:set("lc_ato:"..msg.chat_id_,true)
lua.sendText(msg.chat_id_,0,0,1,nil,'_Auto Lock_ has been *Actived*! 🚫\nDear Members,Please Do not send Any Message.\n_Auto Lock_ is *Active* until *'..redis:get("alltg_end:"..msg.chat_id_)..'*💤',1,'md')
end
elseif tonumber(time) >= 0000 and tonumber(time) < tonumber(time3) then
if not redis:get("lc_ato:"..msg.chat_id_) then
lua.sendText(msg.chat_id_,0,0,1,nil,'_Auto Lock_ has been *Actived*! 🚫\nDear Members,Please Do not send Any Message.\n_Auto Lock_ is *Active* until *'..redis:get("alltg_end:"..msg.chat_id_)..'*💤',1,'md')
redis:set("lc_ato:"..msg.chat_id_,true)
end
else
if redis:get("lc_ato:"..msg.chat_id_) then
redis:del("lc_ato:"..msg.chat_id_,true)
lua.sendText(msg.chat_id_,0,0,1,nil,'_Auto Lock_ has been *Disactived*! 🚫\nDear Members,now you can send Any Message.',1,'md')
end
end
elseif tonumber(time3) > tonumber(time2) then
if tonumber(time) >= tonumber(time2) and tonumber(time) < tonumber(time3) then
if not redis:get("lc_ato:"..msg.chat_id_) then
lua.sendText(msg.chat_id_,0,0,1,nil,'_Auto Lock_ has been *Actived*! 🚫\nDear Members,Please Do not send Any Message.\n_Auto Lock_ is *Active* until *'..redis:get("alltg_end:"..msg.chat_id_)..'*💤',1,'md')
redis:set("lc_ato:"..msg.chat_id_,true)
end
else
if redis:get("lc_ato:"..msg.chat_id_) then
redis:del("lc_ato:"..msg.chat_id_,true)
lua.sendText(msg.chat_id_,0,0,1,nil,'_Auto Lock_ has been *Disactived*! 🚫\nDear Members,now you can send Any Message.',1,'md')
end
end
end
end
if LError:match('^[!/#][Ss]etowner$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if reply_id ~= 0 then
local function setowner_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
setowner(msg.chat_id_,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User `'..user..'` Promoted to *Owner Group*!',1,'md')
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,setowner_reply)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,not_reply,1,'md')
end
end
end
if LError:match('^[!/#][Ss]etowner (%d+)') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
local m = LError:match('^[!/#][Ss]etowner (%d+)')
setowner(msg.chat_id_,m)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User '..name..' Promoted to *Owner Group*',1,'md')
end
end
lua.getUserFull(LError:match('^[!/#][Ss]etowner (%d+)'),check_id)
end
end
if LError:match('^[!/#][Ss]etowner @(%S+)') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
function setmod_by_username(extra,result,success)
if result.id_ then
setowner(msg.chat_id_,result.id_)
texts = 'User @'..LError:match('^[!/#][Ss]etowner @(%S+)')..' Promoted to <b>Owner Group</b>👑'
 else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(LError:match('^[!/#][Ss]etowner @(%S+)'),setmod_by_username)
end
end
if LError:match('^[!/#][Oo]wner$') and mygp then
if is_okuser(chat_id,user_id) or is_mod(msg) then
local userid = redis:get('oneowner:'..msg.chat_id_)
if userid then
function getowner(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User `'..userid..'` is *Owner Group* But has been _Deleted Account_ from Telegram!!',1,'md')
else
name = result.user_.first_name_.." "..(result.user_.last_name_ or "")
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
local id = result.user_.id_
if result.user_.username_ then
usname = "\nUsername: @"..result.user_.username_
else
usname = "\nUsername: Nothing!"
end
local text = "👑Group Owner👑\n\nName: <i>"..name.."</i>\nID: <code>"..id.."</code>"..usname
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'html')
end
end
lua.getUserFull(userid,getowner)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Group have not Owner!',1,'html')
end
end
end
if LError:match("^[!/#][Ww]hite[Ll]ist$") and is_mod(msg) and mygp and reply_id == 0 then
local list = redis:smembers('whitelist:'..msg.chat_id_)
local text = "White List (Users):\n\n"
if #list == 0 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'WhiteList is *Empty*!',1,'md')
else
for k,v in pairs(list) do
function getwhite(extra,result,success)
if result.message_ == "User not found" then
name = '<i>❌Deleted Account❌</i>'
username = '\nDeleted From List👆'
redis:srem('whitelist:'..msg.chat_id_,v)
else
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
name = string.gsub(name,'ـ','')
if result.user_.username_ then
username = '@'..result.user_.username_
else
username = ''
end
end
text = text..k..'- '..name..' [<code>'..v..'</code>] '..username..'\n'
redis:setex('whitelists:'..msg.chat_id_,86400,text)
end
lua.getUserFull(v,getwhite)
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,redis:get('whitelists:'..msg.chat_id_),1,'html')
end
end
if LError:match("^[!/#][Cc]lean [Ww]hite[Ll]ist$") and is_mod(msg) then
if redis:scard("whitelist:"..msg.chat_id_) == 0 then
text = 'WhiteList is *Already Empty*'
else
redis:del("whitelist:"..msg.chat_id_)
text = 'WhiteList has been *Cleaned*'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,"md")
end
if LError:match('^[!/#][Ww]hite[Ll]ist$') and is_mod(msg) and reply_id ~= 0 then
local function mute_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
if is_whiteuser2(chat_id,user_id) then
redis:srem("whitelist:"..chat_id,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,"User Replyed is *Already* in WhiteList so,#Removed from WhiteList",1,"md")
else
redis:sadd("whitelist:"..chat_id,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,"User [<code>"..user.."</code>] has been #Added to WhiteList",1,"html")
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,mute_reply,nil)
end
if LError:match("^[!/#][Ww]hite[Ll]ist (%d+)$") and is_mod(msg) then
local user = LError:match("^[!/#][Ww]hite[Ll]ist (%d+)$")
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_ or result.user_.id_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if is_whiteuser2(msg.chat_id_,user) then
redis:srem("whitelist:"..msg.chat_id_,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,"User "..name.." #Removed from WhiteList",1,"md")
else
redis:sadd("whitelist:"..msg.chat_id_,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,"User "..name.." #Added to WhiteList",1,"md")
end
end
end
lua.getUserFull(LError:match("^[!/#][Ww]hite[Ll]ist (%d+)$"),check_id)
end
if LError:match("^[!/#][Ww]hite[Ll]ist @(%S+)$") and is_mod(msg) then
local ap = {string.match(LError,"^([!/#][Ww]hite[Ll]ist) @(%S+)$")} 
function from_whitelist(extra,result,success)
if result.id_ then
if is_whiteuser2(msg.chat_id_,result.id_) then
redis:srem("whitelist:"..msg.chat_id_,result.id_)
text = "User @"..ap[2].." #Removed from WhiteList"
else
redis:sadd("whitelist:"..msg.chat_id_,result.id_)
text = "User @"..ap[2].." #Added to WhiteList"
end
else
text = user_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
lua.searchPublicChat(ap[2],from_whitelist)
end
if LError:match('^[!/#][Pp]romote$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if reply_id ~= 0 then
 local function setmod_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
local chat = msg.chat_id_
if redis:sismember('mods:'..chat,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'This User is *Already* Moderator!',1,'md')
else
redis:sadd('mods:'..chat,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *['..user..']* #Added to *Moderator List*',1,'md')
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,setmod_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,not_reply,1,'md')
end
end
end
if LError:match('^[!/#][Dd]emote$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if reply_id ~= 0 then
local function remmod_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
local chat = msg.chat_id_
if not redis:sismember('mods:'..chat,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'This user is Already *not* a Moderator!',1,'md')
else
redis:srem('mods:'..chat,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *['..user..']* #Removed from *Moderator List*',1,'md')
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,remmod_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,not_reply,1,'md')
end
end
end
if LError:match('^[!/#][Pp]romote (%d+)') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,user_not_found,1,'md')
else
user = result.user_.first_name_ or result.user_.id_
 if redis:sismember('mods:'..msg.chat_id_,LError:match('^[!/#][Pp]romote (%d+)')) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'This User is *Already* Moderator!',1,'md')
 else
redis:sadd('mods:'..msg.chat_id_,LError:match('^[!/#][Pp]romote (%d+)'))
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'🚀 User `'..user..'` #Added to *Moderator List*',1,'md')
end
end
end
lua.getUserFull(LError:match('^[!/#][Pp]romote (%d+)'),check_id)
end
end
if LError:match('^[!/#][Dd]emote (%d+)') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_ or result.user_.id_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if not redis:sismember('mods:'..msg.chat_id_,LError:match('^[!/#][Dd]emote (%d+)')) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'This user is Already *not* a Moderator',1,'md')
 else
redis:srem('mods:'..msg.chat_id_,LError:match('^[!/#][Dd]emote (%d+)'))
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'🚀 User `'..name..'` #Removed from *Moderator List*',1,'md')
end
end
end
lua.getUserFull(LError:match('^[!/#][Dd]emote (%d+)'),check_id)
end
end
if LError:match("^[!/#][Pp]romote @(%S+)$") and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local ap = {string.match(LError,"^([!/#][Pp]romote) @(%S+)$")} 
function setmod_username(extra,result,success)
if result.id_ then
if redis:sismember('mods:'..msg.chat_id_,result.id_) then
texts = 'This User is <b>Already</b> Moderator'
else
redis:sadd('mods:'..msg.chat_id_,result.id_)
texts = 'User @'..ap[2]..' #Added to <b>Moderator List</b>'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],setmod_username)
end
end
if LError:match("^[!/#][Dd]emote @(%S+)$") and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local ap = {string.match(LError,"^([!/#][Dd]emote) @(%S+)$")} 
function demod_username(extra,result,success)
if result.id_ then
if not redis:sismember('mods:'..msg.chat_id_,result.id_) then
texts = 'This user is Already <b>not</b> a Moderator!'
else
redis:srem('mods:'..msg.chat_id_,result.id_)
texts = 'User @'..ap[2]..' #Removed from <b>Moderator List</b>'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],demod_username)
end
end
if LError:match("^[!/#][Mm]od[Ll]ist$") and mygp then
if is_okuser(msg.chat_id_,user_id) or is_mod(msg) then
local list = redis:smembers('mods:'..msg.chat_id_)
local text = "Moderator List:\n\n"
if #list == 0 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Moderator List is Empty!',1,'html')
else
for k,v in pairs(list) do
function getmods(extra,result,success)
if result.message_ == "User not found" then
name = '<i>❌Deleted Account❌</i>'
username = '\nRemoved from List👆'
redis:srem('mods:'..msg.chat_id_,v)
else
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
name = string.gsub(name,'ـ','')
if result.user_.username_ then
username = '@'..result.user_.username_
else
username = ''
end
end
text = text..k..'- '..name..' [<code>'..v..'</code>] '..username..'\n'
redis:setex('modss:'..msg.chat_id_,86400,text)
end
lua.getUserFull(v,getmods)
end
lua.sendChatAction(msg.chat_id_,'Typing')
sleep(0.5)
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,redis:get('modss:'..msg.chat_id_),1,'html')
end
end
end
if LError:match("^[!/#][Cc]lean [Mm]od[Ll]ist$") and is_owner(msg) then
if redis:scard('mods:'..msg.chat_id_) == 0 then
text = 'ModList is *Empty*'
else
redis:del('mods:'..msg.chat_id_)
text = 'ModList has been *Cleaned*'
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
if LError:match("^[!/#][Dd]el (%d+)$") and mygp and is_mod(msg) then
hash = 'limit_clnmsg:'..msg.chat_id_
if not redis:get(hash) then
local function del_msg(extra,result,success)
local num = 0
local message = result.messages_
for i=0 ,#message do
num = num + 1
lua.deleteMessages(msg.chat_id_,{[0] = message[i].id_})
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'*'..num..'* Message Deleted',1,'md')
end
lua.getChatHistory(msg.chat_id_,0,0,tonumber(LError:match("^[!/#][Dd]el (%d+)$")),del_msg,nil)
redis:setex(hash,3600,true)
else
local td = math.floor(redis:ttl(hash) / 60) + 1
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Error!\nYou can use this command after '..td..' Minute',1,'md')
end
end
if LError:match('^[!/#][Aa]dd[Kk]icks$') then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if redis:get('cleanaddkickedslimit:'..msg.chat_id_) then
local td = math.floor(redis:ttl('cleanaddkickedslimit:'..msg.chat_id_) / 60) + 1
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'Error!\nYou can use this command after '..td..' Minute',1,'md')
else
redis:setex('cleanaddkickedslimit:'..msg.chat_id_,3600,true)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'_Adding Kicked Users..._',1,'md')
function LError(arg,data)
local num = 0
for k,v in pairs(data.members_) do
lua.addChatMember(msg.chat_id_,v.user_id_,1,dl_cb,nil)
num = num + 1
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Added '..num..' User from *Kicked List*!✅',1,'md')
end
lua.getChannelMembers(msg.chat_id_,'Kicked',0,200,LError)
end
end
end
if LError:match("^[!/#][Cc]lean [Bb]ots$") and mygp and is_mod(msg) then
if redis:get('cleanbotslimit:'..msg.chat_id_) then
local td = math.floor(redis:ttl('cleanbotslimit:'..msg.chat_id_) / 60) + 1
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'Error!\nYou can use this command after '..td..' Minute',1,'md')
else
redis:setex('cleanbotslimit:'..msg.chat_id_,3600,true)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'_Cleaing Bots..._',1,'md')
local num = 0
function LErrorgp(arg,data)
for k,v in pairs(data.members_) do
if v.user_id_ ~= api_id then
redis:del('warns:'..msg.chat_id_..':'..v.user_id_)
num = num + 1
lua.changeChatMemberStatus(msg.chat_id_,v.user_id_,'Kicked')
lua.changeChatMemberStatus(msg.chat_id_,v.user_id_,'Left',dl_cb,nil)
end
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Deleted '..num..' Bot!',1,'md')
end
lua.getChannelMembers(msg.chat_id_,'Bots',0,200,LErrorgp)
end
end
if LError:match("^[!/#][Cc]lean [Bb]locklist$") and mygp and is_mod(msg) then
if redis:get('cleankickedlimit:'..msg.chat_id_) then
local td = math.floor(redis:ttl('cleankickedlimit:'..msg.chat_id_) / 60) + 1
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'Error!\nYou can use this command after '..td..' Minute',1,'md')
else
redis:setex('cleankickedlimit:'..msg.chat_id_,3600,true)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,0,0,1,nil,'_Cleaing Block List..._',1,'md')
local num = 0
function LErrorgp(arg,data)
for k,v in pairs(data.members_) do
num = num + 1
lua.changeChatMemberStatus(msg.chat_id_,v.user_id_,'Left',dl_cb,nil)
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Deleted '..num..' User from Block List!',1,'md')
end
lua.getChannelMembers(msg.chat_id_,'Kicked',0,200,LErrorgp)
end
end
if LError:match("^[!/#][Cc]lean [Dd]eleted$") and mygp and is_mod(msg) then
function Dle(extra,result,success)
for k,v in pairs(result.members_) do
local function Uss(arg,data)
if data.type and data.type.ID == "UserTypeDeleted" then
lua.changeChatMemberStatus(msg.chat_id_,v.user_id_,'Kicked')
end
end
lua.getUser(v.user_id_,Uss)
end
end
lua.getChannelMembers(msg.chat_id_,'Recent',0,200,Dle)
lua.sendText(msg.chat_id_,0,0,1,nil,'Users of Group has been Checked and thats is Deleted Kicked from group',1,'md')
end
if LError:match('^[!/#][Bb]an$') and is_mod(msg) and mygp then
if reply_id ~= 0 then
 local function ban_reply(extra,result,success)
 if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
if redis:sismember('banned:'..chat_id,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'This is user is *Already Banned*',1,'md')
else
if is_mod2(msg.chat_id_,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,0,0,1,nil,have_acces,1,"html")
else
redis:sadd('banned:'..chat_id,user)
redis:del('warns:'..chat_id..':'..user)
lua.changeChatMemberStatus(chat_id,user,'Kicked')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User [<code>'..user..'</code>] #Added to BanList',1,'html')
end
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,ban_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match("^[!/#][Bb]an @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Bb]an) @(%S+)$")} 
function ban_by_username(extra,result,success)
if result.id_ then
if is_mod2(msg.chat_id_,result.id_) then
texts = "This User is Mod!"
else
if redis:sismember('banned:'..msg.chat_id_,result.id_) then
texts = 'کاربر موردنظر قبلا در لیست مسدود بود'
else
redis:sadd('banned:'..msg.chat_id_,result.id_)
redis:del('warns:'..chat_id..':'..result.id_)
lua.changeChatMemberStatus(msg.chat_id_,result.id_,'Kicked')
texts = 'User @'..ap[2]..' #Added to BanList'
end
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],ban_by_username)
end
if LError:match("^[!/#][Bb]an (%d+)$") and is_mod(msg) and mygp then
local user_id = LError:match("^[!/#][Bb]an (%d+)$")
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_ or result.user_.id_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if redis:sismember("banned:"..chat_id,LError:match("^[!/#][Bb]an (%d+)$")) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User is *Already Banned*',1,'html')
else
if is_mod2(msg.chat_id_,user_id) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,have_acces,1,"html")
else
redis:sadd("banned:"..chat_id,LError:match("^[!/#][Bb]an (%d+)$"))
redis:del('warns:'..chat_id..':'..user_id)
lua.changeChatMemberStatus(msg.chat_id_,user_id,'Kicked')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User `'..name..'` #Added to BanList',1,'md')
end
end
end
end
lua.getUserFull(user_id,check_id)
end
if LError:match('^[!/#][Uu]n[Bb]an$') and is_mod(msg) and mygp then
if reply_id ~= 0 then
 local function unban_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
local chat = result.chat_id_
if not redis:sismember('banned:'..chat,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User not Banned',1,'md')
else
redis:srem('banned:'..chat,user)
lua.changeChatMemberStatus(chat,user,'Left',dl_cb,nil)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *['..user..']* #Removed from BanList',1,'md')
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,unban_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end

if LError:match("^[!/#][Uu]n[Bb]an @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Uu]n[Bb]an) @(%S+)$")} 
function unban_by_username(extra,result,success)
if result.id_ then
if not redis:sismember('banned:'..msg.chat_id_,result.id_) then
texts = 'User not Banned'
else
redis:srem('banned:'..msg.chat_id_,result.id_)
lua.changeChatMemberStatus(msg.chat_id_,result.id_,'Left',dl_cb,nil)
texts = 'User @'..ap[2]..' #Removed from BanList'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],unban_by_username)
end

if LError:match('^[!/#][Uu]n[Bb]an (%d+)$') and is_mod(msg) and mygp then
userid = LError:match('^[!/#][Uu]n[Bb]an (%d+)$')
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_ or result.user_.id_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if not redis:sismember('banned:'..chat_id,userid) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User Not Banned',1,'html')
else
redis:srem('banned:'..chat_id,userid)
lua.changeChatMemberStatus(chat_id,userid,'Left',dl_cb,nil)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User `'..name..'` #Removed from BanList',1,'md')
end
end
end
lua.getUserFull(userid,check_id)
end
if LError:match("^[!/#][Bb]an[Ll]ist$") and mygp and is_mod(msg) then
local list = redis:smembers('banned:'..chat_id)
local text = "Ban List:\n\n"
if #list == 0 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'BanList is Empty!',1,'html')
else
for k,v in pairs(list) do
function getbans(extra,result,success)
if result.message_ == "User not found" then
name = '<i>❌Deleted Account❌</i>'
username = '\nRemoved from List👆'
redis:srem('banned:'..chat_id,v)
else
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
name = string.gsub(name,'ـ','')
if result.user_.username_ then
usname = '@'..result.user_.username_
else
usname = ''
end
end
text = text..k..'- '..name..' [<code>'..v..'</code>] '..username..'\n'
redis:setex('banneds:'..chat_id,86400,text)
end
lua.getUserFull(v,getbans)
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,redis:get('banneds:'..ow),1,'html')
end
end
if LError:match("^[!/#][Cc]lean [Bb]anlist$") and mygp and is_mod(msg) then
if redis:scard('banned:'..chat_id) == 0 then
text = 'BanList is Empty!'
else
redis:del('banned:'..chat_id)
text = 'BanList *Cleaned*'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
if LError:match('^[!/#][Kk]ick$') and is_mod(msg) and mygp then
if reply_id ~= 0 then
function kick_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
redis:del('warns:'..msg.chat_id_..':'..user)
lua.changeChatMemberStatus(msg.chat_id_,user,'Kicked')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'🔹User '..user..' #Kicked from Group',1,'md')
end
lua.getMessage(chat_id,reply_id,kick_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match('^[!/#][Kk]ick (%d+)$') and is_mod(msg) and mygp then
 function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_ or result.user_.id_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User `'..name..'` #Kicked from Group',1,'md')
redis:del('warns:'..chat_id..':'..LError:match('^[!/#][Kk]ick (%d+)'))
lua.changeChatMemberStatus(chat_id,LError:match('^[!/#][Kk]ick (%d+)'),'Kicked')
end 
end
 lua.getUserFull(LError:match('^[!/#][Kk]ick (%d+)$'),check_id)
end
if LError:match("^[!/#][Kk]ick @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Kk]ick) @(%S+)$")} 
function kick_by_username(extra,result,success)
if result.id_ then
text = 'User @'..ap[2]..' #Kicked from Group'
redis:del('warns:'..chat_id..':'..result.id_)
lua.changeChatMemberStatus(chat_id,result.id_,'Kicked')
else
text = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'html')
end
lua.searchPublicChat(ap[2],kick_by_username)
end
if LError:match('^[!/#][Mm]ute$') and is_mod(msg) and mygp then
if reply_id ~= 0 then
 local function mute_reply(extra,result,success)
 if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
local chat = result.chat_id_
if redis:sismember('muteusers:'..chat,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User is Muted',1,'md')
else
if is_mod2(chat,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,0,0,1,nil,have_acces,1,"html")
else
redis:sadd('muteusers:'..chat,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User [`'..user..'`] #Added to *Mute List*',1,'md')
end
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,mute_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match('^[!/#][Uu]n[Mm]ute$') and is_mod(msg) and mygp then
if reply_id ~= 0 then
 local function unmute_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
local chat = result.chat_id_
if not redis:sismember('muteusers:'..chat,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User not Muted',1,'md')
else
redis:srem('muteusers:'..chat,user)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'کاربر [`'..user..'`] #Removed from *Mute List*',1,'md')
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,unmute_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match("^[!/#][Mm]ute (%d+)$") and is_mod(msg) and mygp then
local user = LError:match("^[!/#][Mm]ute (%d+)$")
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if redis:sismember("muteusers:"..chat_id,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User is Muted',1,'html')
else
if is_mod2(chat_id,user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,have_acces,1,"html")
else
redis:sadd("muteusers:"..chat_id,LError:match("^[!/#][Mm]ute (%d+)$"))
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User [`'..name..'`] #Added to *Mute List*',1,'md')
end
end
end
end
lua.getUserFull(user,check_id)
end
if LError:match('^[!/#][Uu]n[Mm]ute (%d+)$') and is_mod(msg) and mygp then
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if not redis:sismember('muteusers:'..chat_id,LError:match('^[!/#][Uu]n[Mm]ute (%d+)$')) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User not Muted',1,'html')
else
redis:srem('muteusers:'..chat_id,LError:match('^[!/#][Uu]n[Mm]ute (%d+)$'))
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User [`'..name..'`] #Removed from Mute List',1,'md')
end
end
end
lua.getUserFull(LError:match('^[!/#][Uu]n[Mm]ute (%d+)$'),check_id)
end
if LError:match("^[!/#][Mm]ute @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Mm]ute) @(%S+)$")} 
function mute_by_username(extra,result,success)
if result.id_ then
if redis:sismember('muteusers:'..msg.chat_id_,result.id_) then
texts = 'User is Muted'
else
redis:sadd('muteusers:'..msg.chat_id_,result.id_)
texts = 'User @'..ap[2]..' #Added to Mute List'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],mute_by_username)
end
if LError:match("^[!/#][Uu]n[Mm]ute @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Uu]n[Mm]ute) @(%S+)$")} 
function unmute_by_username(extra,result,success)
if result.id_ then
if not redis:sismember('muteusers:'..msg.chat_id_,result.id_) then
texts = 'User not Muted'
else
redis:srem('muteusers:'..msg.chat_id_,result.id_)
texts = 'User @'..ap[2]..' #Removed from Mute List'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],unmute_by_username)
end
if LError:match("^[!/#][Cc]lean [Mm]ute[Ll]ist$") and mygp and is_mod(msg) then
if redis:scard('muteusers:'..chat_id) == 0 then
text = 'Mute List is *Empty*!'
else
redis:del('muteusers:'..chat_id)
text = 'Mute List *Cleaned*'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
if LError:match("^[!/#][Mm]ute[Ll]ist$") and mygp and is_mod(msg) then
local list = redis:smembers('muteusers:'..chat_id)
local text = "Mute Users List:\n\n"
if #list == 0 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Mute Users List is <b>Empty</b>!',1,'html')
else
for k,v in pairs(list) do
function getmutes(extra,result,success)
if result.message_ == "User not found" then
name = '<i>❌Deleted Account❌</i>'
username = '\nRemoved from list👆'
redis:srem('muteusers:'..chat_id,v)
else
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
name = string.gsub(name,'ـ','')
if result.user_.username_ then
username = '@'..result.user_.username_
else
username = ''
end
end
text = text..k..'- '..name..' [<code>'..v..'</code>] '..username..'\n'
redis:setex('muteuserss:'..chat_id,86400,text)
end
lua.getUserFull(v,getmutes)
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,redis:get('muteuserss:'..chat_id),1,'html')
end
end
if LError:match('^[!/#][Ss]et[Ll]ink http://t.me/joinchat/(.*)$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Ss]et[Ll]ink http://t.me/joinchat/)(.*)$")}
redis:set('group:link'..chat_id,'https://telegram.me/joinchat/'..matches[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link Seted!','md')
end
end
if LError:match('^[!/#][Ss]et[Ll]ink http://telegram.me/joinchat/(.*)$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Ss]et[Ll]ink http://telegram.me/joinchat/)(.*)$")}
redis:set('group:link'..chat_id,'https://telegram.me/joinchat/'..matches[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link Seted!','md')
end
end
if LError:match('^[!/#][Ss]et[Ll]ink http://telegram.dog/joinchat/(.*)$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Ss]et[Ll]ink http://telegram.dog/joinchat/)(.*)$")}
redis:set('group:link'..chat_id,'https://telegram.me/joinchat/'..matches[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link Seted!','md')
end
end

if LError:match('^[!/#][Ss]et[Ll]ink https://t.me/joinchat/(.*)$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Ss]et[Ll]ink https://t.me/joinchat/)(.*)$")}
redis:set('group:link'..chat_id,'https://telegram.me/joinchat/'..matches[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link Seted!','md')
end
end
if LError:match('^[!/#][Ss]et[Ll]ink https://telegram.me/joinchat/(.*)$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Ss]et[Ll]ink https://telegram.me/joinchat/)(.*)$")}
redis:set('group:link'..chat_id,'https://telegram.me/joinchat/'..matches[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link Seted!','md')
end
end
if LError:match('^[!/#][Ss]et[Ll]ink https://telegram.dog/joinchat/(.*)$') and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Ss]et[Ll]ink https://telegram.dog/joinchat/)(.*)$")}
redis:set('group:link'..chat_id,'https://telegram.me/joinchat/'..matches[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link Seted!','md')
end
end
if not redis:get('group:link'..chat_id) and not redis:get('checklinkgp:'..chat_id) and mygp then
redis:setex('checklinkgp:'..chat_id,3600,true)
lua.sendText(chat_id,0,0,1,nil,'Not Seted Any link in Bot!\nPlease Set Link with "setlink" command\nExample: !setlink _https://telegram.me/joinchat/CFdqvUFas-D4QMbpK6ldQ_',1,'md')
end
if LError:match('^[!/#][Ll][Ii][Nn][Kk]$') and mygp then
if is_okuser(chat_id,user_id) or is_mod(msg) then
if redis:get('group:link'..chat_id) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Link: '..redis:get('group:link'..chat_id),1,'html')
end
if not redis:get('group:link'..chat_id) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Not Seted!','html')
redis:del('checklinkgp:'..chat_id)
end
end
end
if LError:match("^[!/#][Ii][Dd]$") and msg.reply_to_message_id_ == 0 and mygp then
if is_okuser(chat_id,user_id) or is_mod(msg) then
local function getpro(extra,result,success)
 if result.photos_[0] then
 lua.sendChatAction(chat_id,'UploadPhoto',100)
lua.sendPhoto(msg.chat_id_,msg.id_,0,1,nil,result.photos_[0].sizes_[1].photo_.persistent_id_,'>Your Photos: '..result.total_count_..'\n> 👤Your ID: '..msg.sender_user_id_..'\n>📰Group Name: '..(redis:get('gpname:'..msg.chat_id_) or 'Nil')..'\n>👥Group ID: '..msg.chat_id_,msg.id_)
 else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'>👥Group ID: '..msg.chat_id_..'\n>👤Your ID: '..msg.sender_user_id_,1,'html')
 end
 end
 tdcli_function ({
ID = "GetUserProfilePhotos",
user_id_ = msg.sender_user_id_,
offset_ = 0,
limit_ = 1
},getpro,nil)
end
 end
 if LError:match("^[!/#][Hh][Ee][Ll][Pp]$") and is_mod(msg) then
 if redis:get('help') then
 helping = redis:get('help')
 else
 helping = [[راهنمای ربات 

قفل ها

قفل ها به صورت 
kick ban lock del
میباشند

contact قفل اکانت
link قفل لینک
bot قفل ربات 
video قفل ویدیو
gif قفل گیف
phtoto قفل عکس
gif قفل گیف 
add قفل اد اجباری
selfie قفل فیلم های تلگرامی
file قفل فایل
chat قفل چت
inline قفل اینلاین
member قفل ممبر 
spam قفل اسپم 
tgservice قفل فعالیت تلگرام
flood قفل فلود
filtering قفل کلمات فیلتر
forward قفل فروارد 
sticker قفل استیکر

/setcmd mem
بازکردن دستورات برای کاربر معمولی
/setcmd rank 
قفل کردن دستورات برای کابر معمولی
/setadd [1-50] 
قفل اد اجباری 
/actwarn [ban-kick-del]  
نوع عمل اخطار
/warn[id-username]
اخطار به کاربر
/maxwarn [3-50]
ست کردن تعداد اخطار
/remwarn [username-id]
پاک کردن تمامی اخطارها
/setforward [all-channel-user]
ست کردن نوع فروارد
/filterlist 
لیست کلمات فیلتر
/clean filterlist
پاک کردن کلمات فیلتر
/charge [3-10000]
شارژ کردن ربات در گروه
/setflood [3-50]
تنظیم فلود
/setfloodtime [1-10000]
تنظیم ثانیه فلود
/setchar [10-4096]
تعداد حروف ها 
/report 
گزارش دادن پیام به اونر گروه
/settings 
گرفتن تنظیمات
/auto lock [00:00]-[00:01]
قفل کردن ساعتی گروه
/ban [id-username]
بن کردن کاربر
/unban [id-username]
خارج کردن کاربر ازبن
/gban [id-username]
بن کردن جهانی کاربر
/guban [id-username]
خارج کردن کاربر از بن جهانی
/addsudo [id-username]
اضافه کردن سودو
/remsudo [id-username]
حذف کردن سودو
/sudo list
لیست سودو ها
/clean bots
پاک کردن تمام رباتهای گروه
/del [1-1000]
پاک کردن پیام های گروه
/clean blocklist
خالی کردن بلک لیست گروه
/addkicks
اضافه کردن افراد حذف شده از گروه
/reload
بارگذاری مجدد
/addfilter [کلمه]
اضافه کردن کلمه به فیلتر
/remfilter [کلمه]
حذف کلمه از فیلتر
/add
نصب گروه
/rem
حذف گروه
/setlink link
تنظیم کردن لینک گروه
/whitelist [id-username]
اضافه کردن کاربر به لیست سیاه
/promote
کمک ادمین کردن کاربر
/demote
حذف کمک ادمین
/modlist 
نمایش لیست کمک ادمین ها
/clean modlist
حذف تمامی کمک ادمین ها
/mute [id-username]
موت کردن کاربر
/unmute
آنموت کردن کاربر
/mutelist
نمایش لیست کاربران لال
/id
نمایش ایدی
 ]] 
     end
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,helping,1,'md')
 end
 if LError:match("^[!/#][Ii][Dd]$") and mygp then
 if reply_id ~= 0 then
if is_okuser(chat_id,user_id) or is_mod(msg) then
function id_by_replyf(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
if result.forward_info_.ID == 'MessageForwardedFromUser' then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'>Your ID: `'..user_id..'`\n>User ID: `'..user..'`\n>Message ID: `'..reply_id..'`\n>_Forwarded from User_',1,'md')
elseif result.forward_info_.ID == 'MessageForwardedPost' then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'>Your ID: `'..user_id..'`\n>User ID: `'..user..'`\nMessage ID: `'..reply_id..'`\n>_Forwarded from Channel_',1,'md')
 end
else
user = result.sender_user_id_
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'>Your ID: `'..user_id..'`\n>User ID: `'..user..'`\nMessage ID: `'..reply_id..'`\n>_Message of User_',1,'md')
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,id_by_replyf)
end -- END of cmd and mod
end -- END of match
end
if LError:match("^[!/#][Aa]ddfilter (.*)$") and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local filters = {string.match(LError,"^([!/#][Aa]ddfilter) (.*)$")} 
local name = string.sub(filters[2],1,50)
if redis:hget('badword:'..chat_id,name) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Word "'..filters[2]..'" is *Already Filtered*!',1,'md')
else
redis:hset('badword:'..msg.chat_id_,name,'filtered')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,"*Filtered Now*!\n> "..name,1,'md')
end
end
end
if LError:match("^[!/#][Rr]emfilter (.*)$") and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local rws = {string.match(LError,"^([!/#][Rr]emfilter) (.*)$")} 
local name = string.sub(rws[2],1,50)
if redis:hget('badword:'..chat_id,name) then
redis:hdel('badword:'..msg.chat_id_,rws[2])
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,"`"..rws[2].."` #Removed from Filter List",1,'md')
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Word "'..rws[2]..'" *Not Filtered*!',1,'md')
end
end
end
if LError:match("^[!/#][Ff]ilter[Ll]ist$") and is_mod(msg) and mygp then
local filtering = 'filtertg:'..chat_id
if redis:get(filtering) then
filtering = "On✅"
else 
filtering = "Off❌"
end
local hash = 'badword:'..chat_id
if hash then
 local names = redis:hkeys(hash)
 local text = 'Status Filtering: `'..filtering..'`\nFilter List:\n\n'
for i=1,#names do
text = text..'> `'..names[i]..'`\n'
end
if #names == 0 then
 text = "Filter List is *Empty*"
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 end
end
if LError:match("^[!/#][Cc]lean [Ff]ilter[Ll]ist$") and is_owner(msg) and mygp then
redis:del("badword:"..chat_id)
lua.sendText(chat_id,msg.id_,0,1,nil,'Filter List now *Cleaned*',1,'md')
end
--SetWarn
if LError:match("^[!/#][Mm]ax[Ww]arn (%d+)$") and mygp then
if not is_owner(msg) then
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if tonumber(LError:match("^[!/#][Mm]ax[Ww]arn (%d+)$")) < 2 or tonumber(LError:match("^[!/#][Mm]ax[Ww]arn (%d+)$")) > 10 then
 lua.sendText(chat_id,msg.id_,0,1,nil,'<code>Error!</code>\nYour Number must be between [2-10]',1,'html')
else
redis:set('max_warn:'..chat_id,LError:match("^[!/#][Mm]ax[Ww]arn (%d+)$"))
 lua.sendText(chat_id,msg.id_,0,1,nil,'MaxWarn Set on :*'..LError:match("^[!/#][Mm]ax[Ww]arn (%d+)$")..'*',1,'md')
end
end
end
if LError:match("^[!/#][Aa]ct[Ww]arn (.*)") and mygp then
if not is_owner(msg) then
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
local matches = {string.match(LError,"^([!/#][Aa]ct[Ww]arn) (.*)")}
if matches[2] == 'ban' then
redis:set('warn_action:'..chat_id,true)
text = 'Status Warn Set on: *Ban*'
elseif matches[2] == 'kick' then
redis:del('warn_action:'..chat_id)
text = 'Status Warn Set on: *Kick*'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
end
if LError:match("^[!/#][Ww]arn (.*)$") and is_mod(msg) then
local matches = {string.match(LError,"^([!/#][Ww]arn) (.*)$")}
if matches[2] == 'on' then
if redis:get('warntg:'..chat_id) then
text = 'Warn is *Already* On!'
else
redis:set('warntg:'..chat_id,true)
text = 'Warn has been power On✅'
end
elseif matches[2] == 'off' then
if redis:get('warntg:'..chat_id) then
redis:del('warntg:'..chat_id)
text = 'Warn has been power off☑️'
else
text = 'Warn is *Already* Power off!'
end
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
if LError:match("^([!/#][Ff]orward) (.*)$") and is_mod(msg) and mygp then
local a = {string.match(LError,"^([!/#][Ff]orward) (.*)$")}
if not redis:get('fwdtg:'..chat_id) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'_Error!_\nLock Forward not Active!\nFirst send: !lock forward',1,'md')
else
if a[2] == 'user' then
redis:set('fwdtg:'..chat_id,'user')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'from now bot _delete_ post that forward from *Users*',1,'md')
--savelog(chat_id,'کاربر '..user_id..' قفل فوروارد را روی کاربر تنظیم کرد')
end
if a[2] == 'channel' then
redis:set('fwdtg:'..chat_id,'post')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'from now bot _delete_ post that forward from *Channels*',1,'md')
--savelog(chat_id,'کاربر '..user_id..' قفل فوروارد را روی کانال تنظیم کرد')
end
if a[2] == 'all' then
redis:set('fwdtg:'..chat_id,'all')
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'from now bot _delete_ post that forward from *Users and Channels*',1,'md')
--savelog(chat_id,'کاربر '..user_id..' قفل فوروارد را روی همه تنظیم کرد')
end
end
end
if LError:match("^[!/#][Ss]tatus [Cc]harge$") and is_mod(msg) and mygp then
local ex = redis:ttl("bot:charge:"..chat_id)
 if ex == -1 or ex == -2 then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'_Unlimited!_',1,'md')
 else
local d = math.floor(ex / day ) + 1
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,"*"..d.."* Day until to _end!_",1,'md')
 end
end
if is_super(msg) and mygp then
local exp_alarm = redis:ttl("bot:charge:"..chat_id)
local exp_arm = math.floor(exp_alarm / day ) + 1
if tonumber(exp_alarm) < 259200 and tonumber(exp_alarm) > 172800 and not redis:get('expis3:'..chat_id) then
redis:set('expis3:'..chat_id,true)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,0,0,1,nil,'3 Day Until END of Expire!\nFor Extend bot go to: @LError',1,'md')
elseif tonumber(exp_alarm) < 172800 and tonumber(exp_alarm) > 86400 and not redis:get('expis2:'..chat_id) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,0,0,1,nil,'2 Day Until END of Expire!\nFor Extend bot go to: @LError',1,'md')
redis:del('expis3:'..chat_id)
redis:set('expis2:'..chat_id,true)
elseif tonumber(exp_alarm) < 86400 and tonumber(exp_alarm) > 0 and not redis:get('expis1:'..chat_id) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,0,0,1,nil,'1 Day Until END of Expire!\nFor Extend bot go to: @LError',1,'md')
redis:del('expis2:'..chat_id)
redis:set('expis1:'..chat_id,true)
end
end
if LError:match("^[!/#][Ww]arn$") and is_mod(msg) and mygp then
if reply_id ~= 0 then
local function setwarn_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
chat = msg.chat_id_
warns = redis:get('warns:'..chat..':'..user) or 0
setwarn = tonumber(warns) + 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
action = (redis:get('warn_action:'..chat) or 'Kick')
if setwarn == max_warn then
if redis:get('warn_action:'..chat) then
redis:sadd('banned:'..chat,user)
redis:del('warns:'..chat..':'..user)
lua.changeChatMemberStatus(chat,user,'Kicked')
action = 'Ban'
else
redis:del('warns:'..chat..':'..user)
lua.changeChatMemberStatus(chat,user,'Kicked')
action = 'Kick'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'Warn of User [<code>'..user..'</code>] *Arrived* to ('..max_warn..') and #'..action..' from Group',1,'html')
else
redis:set('warns:'..chat..':'..user,setwarn)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User [<code>'..user..'</code>] 1 warn #Received!\nWarn of User: [<b>'..setwarn..'</b>/<code>'..max_warn..'</code>]',1,'html')
end -- END setwarn == max_warn
end -- END function
lua.getMessage(msg.chat_id_,reply_id,setwarn_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match('^[!/#][Uu]n[Ww]arn$') and is_mod(msg) and mygp then
if reply_id ~= 0 then
local function remwarn_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
chat = msg.chat_id_
if tonumber(redis:get('warns:'..chat..':'..user)) >= 1 then
warns = redis:get('warns:'..chat..':'..user)
setwarn = tonumber(warns) - 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
redis:set('warns:'..chat..':'..user,setwarn)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'1 warn #Removed of user [<code>'..user..'</code>]\nWarn of user: [<b>'..setwarn..'</b>/<code>'..max_warn..'</code>]',1,'html')
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User [<code>'..user..'</code>] Not Have <b>Any Warn</b>!',1,'html')
end
end
lua.getMessage(msg.chat_id_,reply_id,remwarn_reply,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match('^[!/#][Ww]arn (%d+)$') and is_mod(msg) and mygp then
function addwarn_by_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
user = result.user_.first_name_ or result.user_.id_
userid = LError:match('^[!/#][Ww]arn (%d+)$')
end
chat = msg.chat_id_
warns = redis:get('warns:'..chat..':'..userid) or 0
setwarn = tonumber(warns) + 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
action = (redis:get('warn_action:'..chat) or 'Kick')
if setwarn == max_warn then
if redis:get('warn_action:'..chat) then
redis:sadd('banned:'..chat,userid)
redis:del('warns:'..chat..':'..userid)
lua.changeChatMemberStatus(chat,userid,'Kicked')
action = 'Ban'
else
redis:del('warns:'..chat..':'..userid)
lua.changeChatMemberStatus(chat,userid,'Kicked')
action = 'Kick'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'warns of User "'..user..'" [<code>'..userid..'</code>] *Arrived* to ('..max_warn..') And #'..action..' from Group',1,'md')
else
redis:set('warns:'..chat..':'..userid,setwarn)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User "'..user..'" [<code>'..userid..'</code>] 1 warn #Received!\nWarn of user: [<b>'..setwarn..'</b>/<code>'..max_warn..'</code>]',1,'html')
end -- END setwarn == max_warn
end -- END function
lua.getUserFull(LError:match('^[!/#][Ww]arn (%d+)'),addwarn_by_id)
end
if LError:match('^[!/#][Uu]n[Ww]arn (%d+)') and is_mod(msg) and mygp then
function remwarn_by_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'کاربر وجود ندارد! 😐\nلطفا شناسه واقعی وارد کنید',1,'md')
else
user = result.user_.first_name_ or result.user_.id_
userid = LError:match('^[!/#][Ww]arn (%d+)')
end
chat = msg.chat_id_
if tonumber(redis:get('warns:'..chat..':'..userid)) >= 1 then
warns = redis:get('warns:'..chat..':'..userid) or 0
setwarn = tonumber(warns) - 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
redis:set('warns:'..chat..':'..userid,setwarn)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'1 warn #Removed of user "'..user..'" [<code>'..user..'</code>]\nWarn of user: [<b>'..setwarn..'</b>/<code>'..max_warn..'</code>]',1,'html')
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User "'..user..'" [<code>'..userid..'</code>] Not have *Any Warn*!',1,'html')
end -- END of redisget warns
end -- END function
lua.getUserFull(LError:match('^[!/#][Ww]arn (%d+)'),remwarn_by_id)
end
if LError:match("^[!/#][Ww]arn @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Ww]arn) @(%S+)$")} 
function setwarn_username(extra,result,success)
if result.id_ then
userid = result.id_
chat = msg.chat_id_
warns = redis:get('warns:'..chat..':'..userid) or 0
setwarn = tonumber(warns) + 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
action = (redis:get('warn_action:'..chat) or 'Kick')
if setwarn == max_warn then
if redis:get('warn_action:'..chat) then
redis:sadd('banned:'..chat,userid)
redis:del('warns:'..chat..':'..userid)
lua.changeChatMemberStatus(chat,userid,'Kicked')
action = 'Ban'
else
redis:del('warns:'..chat..':'..userid)
lua.changeChatMemberStatus(chat,userid,'Kicked')
action = 'Kick'
end
texts = 'User @'..ap[2]..' #Arrived to ('..max_warn..') And #'..action..' From Group'
else
redis:set('warns:'..chat..':'..userid,setwarn)
texts = 'User @'..ap[2]..' #Received 1 warn!\nWarn User: [<b>'..setwarn..'</b>/'..max_warn..']'
end -- END setwarn == max_warn
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],setwarn_username)
end
if LError:match("^[!/#][Uu]n[Ww]arn @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Uu]n[Ww]arn) @(%S+)$")} 
function dewarn_username(extra,result,success)
if result.id_ then
chat = msg.chat_id_
userid = result.id_
if tonumber(redis:get('warns:'..chat..':'..userid)) >= 1 then
warns = redis:get('warns:'..chat..':'..userid)
setwarn = tonumber(warns) - 1
max_warn = tonumber(redis:get('max_warn:'..chat) or 3)
redis:set('warns:'..chat..':'..userid,setwarn)
texts = '1 warn of User @'..ap[2]..' #Removed!\nWarn of User: [<b>'..setwarn..'</b>/'..max_warn..']'
else
texts = 'User @'..ap[2]..' Not have <b>Any Warn</b>!'
end -- END of redisget warns
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],dewarn_username)
end
if LError:match("^[!/#][Rr]em[Ww]arns$") and is_mod(msg) and mygp then
if reply_id ~= 0 then
function del_warns(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
chat = msg.chat_id_
if redis:get('warns:'..chat..':'..user) then
redis:del('warns:'..chat..':'..user)
text = 'All Warns of [`'..user..'`] #Removed!'
else
text = 'User [`'..user..'`] Not have *Any Warns*!'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
lua.getMessage(msg.chat_id_,reply_id,del_warns,nil)
else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match('^[!/#][Rr]em[Ww]arns (%d+)$') and is_mod(msg) and mygp then
function del_warn_id(extra,result,success)
if result.message_ == "User not found" then
text = user_not_found
else
user = result.user_.first_name_ or result.user_.id_
chat = msg.chat_id_
userid = LError:match('^[!/#][Rr]em[Ww]arns (%d+)')
if redis:get('warns:'..chat..':'..userid) then
redis:del('warns:'..chat..':'..userid)
text = 'All Warns of "'..user..'" [`'..userid..'`] #Removed!'
else
text = 'User "'..user..'" [`'..userid..'`] Not have *Any Warns*!'
end
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
lua.getUserFull(LError:match('^[!/#][Rr]em[Ww]arns (%d+)'),del_warn_id)
end
if LError:match("^[!/#][Rr]em[Ww]arns @(%S+)$") and is_mod(msg) and mygp then
local ap = {string.match(LError,"^([!/#][Rr]em[Ww]arns) @(%S+)$")} 
function delwarn_username(extra,result,success)
if result.id_ then
chat = msg.chat_id_
userid = result.id_
if redis:get('warns:'..chat..':'..userid) then
redis:del('warns:'..chat..':'..userid)
texts = 'All Warns of @'..ap[2]..' #Removed!'
else
texts = 'User @'..ap[2]..' Not have *Any Warn*!'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],delwarn_username)
end

--SetFloodMsg 
if LError:match("^[!/#][Ss]et[Ff]lood (%d+)$") and mygp then
local maxr = LError:match("^[!/#][Ss]et[Ff]lood (%d+)$")
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if tonumber(maxr) < 5 or tonumber(maxr) > 50 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'<code>Error!</code>\nYour Number be between <b>[5-50]</b>',1,'html')
else
redis:set('flood:max:'..chat_id,maxr)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'Max Flood Set on: *'..maxr..'*',1,'md')
end
end
end
--SetFloodTime
if LError:match("^[!/#][Ss]et[Ff]lood[Tt]ime (%d+)$") and mygp then
local maxr = LError:match("^[!/#][Ss]et[Ff]lood[Tt]ime (%d+)$")
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if tonumber(maxr) < 3 or tonumber(maxr) > day then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'<code>Error!</code>\nYour Number be between [3-86400]',1,'html')
else
redis:set('flood:time:'..chat_id,maxr)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'Flood Time Set on: *'..maxr..'*',1,'md')
end
end
end
--SetChar
if LError:match("^[!/#][Ss]et[Cc]har (%d+)$") and mygp then
local maxr = LError:match("^[!/#][Ss]et[Cc]har (%d+)$")
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
if tonumber(maxr) < 500 or tonumber(maxr) > 4096 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'<code>Error!</code>\nYour Number be between [500-4096]',1,'html')
else
redis:set('spam:char:'..chat_id,maxr)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'Max Character Set on: *'..maxr..'*',1,'md')
end
end
end
--SetAdd
if LError:match("^[!/#][Ss]et[Aa]dd (%d+)$") and mygp then
if not is_owner(msg) then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,you_not_owner,1,'md')
 else
 local maxr = LError:match("^[!/#][Ss]et[Aa]dd (%d+)$")
if tonumber(maxr) < 1 or tonumber(maxr) > 20 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'<code>Error!</code>\nYour Number be between [1-20]',1,'html')
else
redis:set('setadd:'..chat_id,maxr)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,msg.id_,0,1,nil,'The number of members to be added to the _Lock Add_ is set to: *'..maxr..'*',1,'md')
end
end
end
if LError:match("^[!/#][Rr]eport$") and mygp then
if redis:get('alltg:'..msg.chat_id_) or redis:get('chattg:'..msg.chat_id_) or redis:sismember('muteusers:'..msg.chat_id_,msg.sender_user_id_) then
return false
else
if reply_id ~= 0 then
function getuser(extra,result,success)
if redis:get('oneowner:'..msg.chat_id_) then
owner = redis:get('oneowner:'..msg.chat_id_)
else
owner = 282958812
end
if result.user_.last_name_ then
user = result.user_.first_name_..' '..result.user_.last_name_
user = string.gsub(user,'>','')
user = string.gsub(user,'<','')
else
user = result.user_.first_name_
user = string.gsub(user,'>','')
user = string.gsub(user,'<','')
end
if owner == 282958812 then
ownername = 'سازنده لوا ارور'
else
ownername = owner
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Dear User "'..user..'" Your Report Sent to "'..ownername..'"',1,'html')
lua.sendText(owner,0,0,1,nil,'User <code>'..user..'</code> From Group <code>'..(redis:get('gpname:'..msg.chat_id_) or msg.chat_id_)..'</code> One Message Reported and Forward it for you.',1,'html')
lua.forwardMessages(owner,msg.chat_id_,{[0] = reply_id},0)
end
lua.getUserFull(msg.sender_user_id_,getuser)
else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,not_reply,1,'md')
end
end
end
if not redis:get('checkgpname:'..msg.chat_id_) then
redis:setex('checkgpname:'..msg.chat_id_,3600,true)
function setname_group(extra,result,success)
redis:set('gpname:'..msg.chat_id_,result.title_)
end
lua.getChat(msg.chat_id_,setname_group)
end
if LError:match("^[!/#][Gg]et[Pp]rof (%d+) (%d+)$") and msg.reply_to_message_id_ == 0 then
local ap = {string.match(LError,"^([!/#][Gg]et[Pp]rof) (%d+) (%d+)$")}
if is_okuser(chat_id,user_id) or is_mod(msg) then
local function getprof(extra,result,success)
 if result.photos_[0] then
 lua.sendChatAction(chat_id,'UploadPhoto',100)
lua.sendPhoto(msg.chat_id_,msg.id_,0,1,nil,result.photos_[0].sizes_[1].photo_.persistent_id_,'>Profile Photos Count: '..result.total_count_ - 1 ..'\nUser ID: '..ap[2],msg.id_)
 else
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User not have '..ap[3]..' Photo!',1,'html')
 end
 end
 lua.getUserProfilePhotos(ap[2],ap[3],100,getprof)
end
 end
 if not LError:find("^[!/#][Uu]nlock") and is_mod(msg) then
 if LError:match("^[!/#](.*) [Ll]ink$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ll]ink)$")}
 if lock[2] == "del" or lock[2] == "lock" then
 noe = 'del'
 elseif lock[2] == "kick" then
 noe = 'kick'
 elseif lock[2] == "ban" then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'del' or lock[2] == 'lock' then
 local hash = 'linktg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Link has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Link is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Link is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Link is *Already* Active on _Ban_'
else
text = 'Lock Link has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Tt]ag$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Tt]ag)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'del' or lock[2] == 'lock' then
 local hash = 'tagtg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Tag has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Tag is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Tag is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Tag is *Already* Active on _Ban_'
else
text = 'Lock Tag has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Bb]ot$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Bb]ot)$")}
 if lock[2] == 'kick' or lock[2] == 'lock' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'lock' then
 local hash = 'bottg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Bot has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'kick' then
text = 'Lock Bot is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Bot is *Already* Active on _Ban_'
else
text = 'Lock Bot has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "ban" or "kick" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md') 
 elseif LError:match("^[!/#](.*) [Ff]orward$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ff]orward)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'del' or lock[2] == 'lock' then
local hash = 'fwdtg:'..msg.chat_id_
 local hash2 = 'fwdtg2:'..msg.chat_id_
 if redis:get(hash) == 'all' then
nn = '_Forward of Channels and Users_'
elseif redis:get(hash) == 'post' then
nn = '_Forward of Channels_'
elseif redis:get(hash) == 'user' then
nn = '_Forward of Users_'
else
nn = '_Forward of Channels and Users_'
end
if redis:get(hash2) ~= noe then
text = 'Lock Forward has been *Actived* and set on '..lock[2]..'\nType: '..nn
redis:set(hash,(redis:get(hash) or 'all'))
redis:set(hash2,noe)
elseif redis:get(hash2) == 'del' then
text = 'Lock Forward is *Already* Active on _Delete Post_\nType: '..nn
elseif redis:get(hash2) == 'kick' then
text = 'Lock Forward is *Already* Active on _Kick_\nType: '..nn
elseif redis:get(hash2) == 'ban' then
text = 'Lock Forward is *Already* Active on _Ban_\nType: '..nn
else
text = 'Lock Forward has been *Actived* and set on '..lock[2]..'\nType: '..nn
redis:set(hash,(redis:get(hash) or 'all'))
redis:set(hash2,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md') 
 elseif LError:match("^[!/#](.*) [Ll]ocation$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ll]ocation)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'del' or lock[2] == 'lock' then
 local hash = 'loctg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Location has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Location is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Location is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Location is *Already* Active on _Ban_'
else
text = 'Lock Location has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Ff]lood$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ff]lood)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'del' or lock[2] == 'lock' then
 local hash = 'floodtg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Flooding has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Flooding is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Flooding is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Flooding is *Already* Active on _Ban_'
else
text = 'Lock Flooding has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Ss]pam$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ss]pam)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'ban' or lock[2] == 'kick' or lock[2] == 'del' or lock[2] == 'lock' then
 local hash = 'spamtg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Spaming has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Spaming is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Spaming is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Spaming is *Already* Active on _Ban_'
else
text = 'Lock Spaming has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'ban' or lock[2] ~= 'kick' or lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md') 
 elseif LError:match("^[!/#](.*) [Tt]g[Ss]ervice$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Tt]g[Ss]ervice)$")}
 if lock[2] == 'all' or lock[2] == 'lock' then
 noe = 'all'
 elseif lock[2] == 'add' then
 noe = 'add'
 elseif lock[2] == 'link' then
 noe = 'link'
 elseif lock[2] == 'left' then
 noe = 'left'
 end
 if lock[2] == 'all' or lock[2] == 'link' or lock[2] == 'left' or lock[2] == 'add' or lock[2] == 'lock' then
 local hash = 'tgservicetg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock TgService has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'all' then
text = 'Lock TgService is *Already* Active on _All Types_'
elseif redis:get(hash) == 'add' then
text = 'Lock TgService is *Already* Active on _Adding Types_'
elseif redis:get(hash) == 'link' then
text = 'Lock TgService is *Already* Active on _Join by Link Type_'
elseif redis:get(hash) == 'left' then
text = 'Lock TgService is *Already* Active on _Left Type_'
else
text = 'Lock TgService has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'all' or lock[2] ~= 'link' or lock[2] ~= 'left' or lock[2] == 'add' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "all" or "add" or "left" or "link" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Mm]embers$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Mm]embers)$")}
 if lock[2] == 'link' then
 noe = 'link'
 elseif lock[2] == 'add' then
 noe = 'add'
 elseif lock[2] == 'all' or lock[2] == 'lock' then
 noe = 'all'
 end
 if lock[2] == 'all' or lock[2] == 'link' or lock[2] == 'add' or lock[2] == 'lock' then
 local hash = 'memberstg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Member has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'add' then
text = 'Lock Member is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'link' then
text = 'Lock Member is *Already* Active on _Kick_'
elseif redis:get(hash) == 'all' then
text = 'Lock Member is *Already* Active on _Ban_'
else
text = 'Lock Member has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'all' or lock[2] ~= 'link' or lock[2] ~= 'add' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "all" or "add" or "link" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md') 
 elseif LError:match("^[!/#](.*) [Ss]ticker$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ss]ticker)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' or lock[2] == 'del' then
 local hash = 'stickertg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Sticker has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Sticker is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Sticker is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Sticker is *Already* Active on _Ban_'
else
text = 'Lock Sticker has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' or lock[2] ~= 'del' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md') 
 elseif LError:match("^[!/#](.*) [Cc]ontact$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Cc]ontact)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' or lock[2] == 'del' then
 local hash = 'contacttg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Contact has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Contact is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Contact is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Contact is *Already* Active on _Ban_'
else
text = 'Lock Contact has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' or lock[2] ~= 'del' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Ii]nline$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ii]nline)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' or lock[2] == 'del' then
 local hash = 'inlinetg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Inline has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Inline is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Inline is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Inline is *Already* Active on _Ban_'
else
text = 'Lock Inline has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' or lock[2] ~= 'del' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
elseif not LError:find("status") and LError:match("^[!/#](.*) [Aa]ll$") and is_mod(msg) and mygp then
local lock = {string.match(LError,"^([!/#])(.*) ([Aa]ll)$")}
if lock[2] == 'del' or lock[2] == 'lock' then
local hash = 'alltg:'..msg.chat_id_
if redis:get(hash) then
text = 'Lock All is *Already* Active'
else
redis:set(hash,true)
text = 'Lock All has been *Actived*'
end
elseif lock[2] ~= 'del' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
elseif LError:match("^[!/#](.*) [Gg]if$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Gg]if)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'giftg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Gif has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Gif is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Gif is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Gif is *Already* Active on _Ban_'
else
text = 'Lock Gif has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Pp]hoto$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Pp]hoto)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'phototg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Photo has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Photo is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Photo is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Photo is *Already* Active on _Ban_'
else
text = 'Lock Photo has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Aa]udio$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Aa]udio)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
local hash = 'audiotg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Audio has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Audio is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Audio is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Audio is *Already* Active on _Ban_'
else
text = 'Lock Audio has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Vv]oice$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Vv]oice)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'voicetg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Voice has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Voice is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Voice is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Voice is *Already* Active on _Ban_'
else
text = 'Lock Voice has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Vv]ideo$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Vv]ideo)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'videotg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Video has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Video is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Video is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Video is *Already* Active on _Ban_'
else
text = 'Lock Video has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Ss]elfie$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ss]elfie)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'selfietg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Selfie Videos has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Selfie Videos is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Selfie Videos is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Selfie Videos is *Already* Active on _Ban_'
else
text = 'Lock Selfie Videos has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Ff]ile$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ff]ile)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'filetg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock File has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock File is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock File is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock File is *Already* Active on _Ban_'
else
text = 'Lock File has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Cc]hat$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Cc]hat)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'chattg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Chat has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Chat is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Chat is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Chat is *Already* Active on _Ban_'
else
text = 'Lock Chat has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#](.*) [Ff]iltering$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Ff]iltering)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'filtertg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Filtering has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Filtering is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Filtering is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Filtering is *Already* Active on _Ban_'
else
text = 'Lock Filtering has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
elseif LError:match("^[!/#](.*) [Mm]ention$") and is_mod(msg) and mygp then
 local lock = {string.match(LError,"^([!/#])(.*) ([Mm]ention)$")}
 if lock[2] == 'del' or lock[2] == 'lock' then
 noe = 'del'
 elseif lock[2] == 'kick' then
 noe = 'kick'
 elseif lock[2] == 'ban' then
 noe = 'ban'
 end
 if lock[2] == 'del' or lock[2] == 'kick' or lock[2] == 'ban' or lock[2] == 'lock' then
 local hash = 'mentiontg:'..msg.chat_id_
if redis:get(hash) ~= noe then
text = 'Lock Mention has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
elseif redis:get(hash) == 'del' then
text = 'Lock Mention is *Already* Active on _Delete Post_'
elseif redis:get(hash) == 'kick' then
text = 'Lock Mention is *Already* Active on _Kick_'
elseif redis:get(hash) == 'ban' then
text = 'Lock Mention is *Already* Active on _Ban_'
else
text = 'Lock Mention has been *Actived* and set on '..lock[2]
redis:set(hash,noe)
end
elseif lock[2] ~= 'del' or lock[2] ~= 'kick' or lock[2] ~= 'ban' or lock[2] ~= 'lock' then
text = '_Error!_\nPlease use "lock" or "del" or "kick" or "ban" in begining your command'
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif LError:match("^[!/#][Ss]et[Cc]md (.*)$") and is_mod(msg) and mygp then
 local setcmd = {string.match(LError,"^([!/#][Ss]et[Cc]md) (.*)$")}
 local hash = 'cmdtg:'..msg.chat_id_
 if setcmd[2] == 'mem' then
if not redis:get(hash) then
text = 'Access Commands is *Already* Unlock for Members👥'
else
redis:del(hash)
text = "Access Commands has been *Unlocked* for Members👥"
end
 elseif setcmd[2] == 'rank' then
 redis:set(hash,true)
 text = 'Access Commands is *Locked* for Members👥'
 elseif setcmd[2] ~= 'rank' or setcmd[2] ~= 'mem' then
text = '_Error!_\nPlease use "mem" or "rank" in Endless your command'
end
 lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
elseif LError:match("^[!/#][Ll]ock [Pp]in$") and mygp then
if not is_owner(msg) then
text = you_not_owner
else
local hash = 'pintg:'..msg.chat_id_
if redis:get(hash) then
text = '_Pin_ is *Already* Lock'
else
redis:set(hash,true)
text = '_Pin_ has been *Locked*'
end
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
elseif LError:match("^[!/#][Ll]ock [Aa]dd$") and is_mod(msg) and mygp then
local hash = 'addtg:'..msg.chat_id_
if redis:get(hash) then
text = '_Lock Add_ is *Already* Lock'
else
redis:set(hash,true)
text = '_Lock Add_ has been *Locked*'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end -- End Lock
 end
 if not LError:find("^[!/#][Ss]et[Cc]md (.*)") then
 if LError:match("^[!/#][Uu]nlock (.*)$") and is_mod(msg) and mygp then
 local unlock = {string.match(LError,"^([!/#][Uu]nlock) (.*)$")}
 unlock[2] = string.lower(unlock[2])
 if unlock[2] == 'link' then
 if not redis:get('linktg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Link_ is *Already* Unlock',1,'md')
else
redis:del('linktg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Link_ has been *Unlocked*🔓',1,'md')
end
elseif unlock[2] == 'pin' then
if not redis:get('pintg:'..msg.chat_id_) then
text = '_Pin_ is *Already* Unlock'
else
redis:del('pintg:'..msg.chat_id_)
text = '_Pin_ has been *Unlocked*'
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
elseif unlock[2] == 'add' then
if not redis:get('addtg:'..msg.chat_id_) then
text = '_Lock Add_ is *Already* Unlock'
else
redis:del('addtg:'..msg.chat_id_)
redis:del('ucansend:'..msg.chat_id_)
redis:del('ucantsend:'..msg.chat_id_)
local kkk = redis:keys("addofuser:*")
for i=1,#kkk do
redis:del(kkk[i])
end
text = '_Lock Add_ has been *Unlocked*🔓'
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
 elseif unlock[2] == 'tag' then
 if not redis:get('tagtg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Tag_ is *Already* Unlock',1,'md')
else
redis:del('tagtg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Tag_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'bot' then
 if not redis:get('bottg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Bot (Add or join)_ is *Already* Unlock',1,'md')
else
redis:del('bottg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Bot (Add or Join)_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'forward' then
 if not redis:get('fwdtg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Forward_ is *Already* Unlock',1,'md')
else
redis:del('fwdtg:'..msg.chat_id_)
redis:del('fwdtg2:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Forward_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'location' then
 if not redis:get('loctg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Location_ is *Already* Unlock',1,'md')
else
redis:del('loctg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Location_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'flood' then
 if not redis:get('floodtg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Flooding_ is *Already* Unlock',1,'md')
else
redis:del('floodtg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Flooding_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'spam' then
 if not redis:get('spamtg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Spaming_ is *Already* Unlock',1,'md')
else
redis:del('spamtg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Spaming_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'tgservice' then
 if not redis:get('tgservicetg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_TgService_ is *Already* Unlock',1,'md')
else
redis:del('tgservicetg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_TgService_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'members' then
 if not redis:get('memberstg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Member_ is *Already* Unlock',1,'md')
else
redis:del('memberstg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Member_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'sticker' then
 if not redis:get('stickertg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Sticker_ is *Already* Unlock',1,'md')
else
redis:del('stickertg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Sticker_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'contact' then
 if not redis:get('contacttg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Contact_ is *Already* Unlock',1,'md')
else
redis:del('contacttg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Contact_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'inline' then
 if not redis:get('inlinetg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Inline_ is *Already* Unlock',1,'md')
else
redis:del('inlinetg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Inline_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'all' then
 if not redis:get('alltg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_All_ is *Already* Unlock',1,'md')
else
redis:del('alltg:'..msg.chat_id_)
redis:del('malltime:'..msg.chat_id_)
redis:del('status:mutetime:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_All_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'gif' then
 if not redis:get('giftg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Gif_ is *Already* Unlock',1,'md')
else
redis:del('giftg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Gif_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'photo' then
 if not redis:get('phototg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Photo_ is *Already* Unlock',1,'md')
else
redis:del('phototg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Photo_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'audio' then
 if not redis:get('audiotg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Audio_ is *Already* Unlock',1,'md')
else
redis:del('audiotg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Audio_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'voice' then
 if not redis:get('voicetg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Voice_ is *Already* Unlock',1,'md')
else
redis:del('voicetg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Voice_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'video' then
 if not redis:get('videotg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Video_ is *Already* Unlock',1,'md')
else
redis:del('videotg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Video_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'selfie' then
 if not redis:get('selfietg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Video Selfie_ is *Already* Unlock',1,'md')
else
redis:del('selfietg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Video Selfie_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'file' then
 if not redis:get('filetg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_File_ is *Already* Unlock',1,'md')
else
redis:del('filetg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_File_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'chat' then
 if not redis:get('chattg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Chating_ is *Already* Unlock',1,'md')
else
redis:del('chattg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Chating_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'mention' then
 if not redis:get('mentiontg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Mention_ is *Already* Unlock',1,'md')
else
redis:del('mentiontg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Mention_ has been *Unlocked*🔓',1,'md')
end
 elseif unlock[2] == 'filtering' then
 if not redis:get('filtertg:'..msg.chat_id_) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Filtering_ is *Already* Unlock',1,'md')
else
redis:del('filtertg:'..msg.chat_id_)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Filtering_ has been *Unlocked*🔓',1,'md')
end
 end -- End unlock[2]
 end -- not setcmd
 end -- End Unlock
 if LError:match('^[!/#][Ll]ock [Aa]ll (%d+) [Hh]our$') and is_mod(msg) and mygp then
local hash = 'malltime:'..msg.chat_id_
local hour = LError:match('^[!/#][Ll]ock [Aa]ll (%d+) [Hh]our$')
local num1 = tonumber(hour) * 3600
local num2 = tonumber(num1)
redis:setex(hash,num2,true)
redis:set('alltg:'..chat_id,true)
redis:set('status:mutetime:'..chat_id,true)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_All_ has been *Locked* for '..hour..' Hour🚫',1,'md')
end
if LError:match('^[!/#][Ll]ock [Aa]ll (%d+) [Mm]in$') and is_mod(msg) and mygp then
local hash = 'malltime:'..msg.chat_id_
local hour = LError:match('^[!/#][Ll]ock [Aa]ll (%d+) [Mm]in$')
local num1 = tonumber(hour) * 60
local num2 = tonumber(num1)
redis:setex(hash,num2,true)
redis:set('alltg:'..chat_id,true)
redis:set('status:mutetime:'..chat_id,true)
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_All_ has been *Locked* for '..hour..' Minute🚫',1,'md')
--savelog(chat_id,'کاربر '..user_id..' گروه را برای مدتی قفل کرد')
end
 if not redis:get('malltime:'..msg.chat_id_) and redis:get('status:mutetime:'..chat_id) then
 redis:del('alltg:'..chat_id)
 redis:del('status:mutetime:'..chat_id)
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(chat_id,0,0,1,nil,'Time of _Lock All_ has been *Ended* then *Unlocked*!\nNow Members can send post',1,'md')
 --savelog(chat_id,'کاربر '..user_id..' قفل مدت دار گروه غیرفعال شد')
 end
 if LError:match('^[!/#][Ss]tatus [Ll]ock [Aa]ll$') and is_mod(msg) and mygp then
 local hash = 'malltime:'..msg.chat_id_
 if redis:get(hash) then
 local ttl = math.floor(redis:ttl(hash) / 3600) + 1
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,"_Lock All_ has been *Unlock* after "..ttl.." and Members Can send post",1,'md')
 else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,"_Lock All_ with time is *Already* Deactive",1,'md')
 end
 end
 if LError:match('^[!/#][Ll]ock [Aa]uto (%d+):(%d+)-(%d+):(%d+)$') and is_mod(msg) then
local matches = {string.match(LError,'^([!/#][Ll]ock [Aa]uto) (%d+)(:)(%d+)(-)(%d+)(:)(%d+)$')}
if (matches[2] == "00" or matches[2] == "01" or matches[2] == "02" or matches[2] == "03" or matches[2] == "04" or matches[2] == "05" or matches[2] == "06" or matches[2] == "07" or matches[2] == "08" or matches[2] == "09" or matches[2] == "10" or matches[2] == "11" or matches[2] == "12" or matches[2] == "13" or matches[2] == "14" or matches[2] == "15" or matches[2] == "16" or matches[2] == "17" or matches[2] == "18" or matches[2] == "19" or matches[2] == "20" or matches[2] == "21" or matches[2] == "22" or matches[2] == "23") and (matches[4] == "00" or matches[4] == "01" or matches[4] == "02" or matches[4] == "03" or matches[4] == "04" or matches[4] == "05" or matches[4] == "06" or matches[4] == "07" or matches[4] == "08" or matches[4] == "09" or matches[4] == "10" or matches[4] == "11" or matches[4] == "12" or matches[4] == "13" or matches[4] == "14" or matches[4] == "15" or matches[4] == "16" or matches[4] == "17" or matches[4] == "18" or matches[4] == "19" or matches[4] == "20" or matches[4] == "21" or matches[4] == "22" or matches[4] == "23" or matches[4] == "24" or matches[4] == "25" or matches[4] == "26" or matches[4] == "27" or matches[4] == "28" or matches[4] == "29" or matches[4] == "30" or matches[4] == "31" or matches[4] == "32" or matches[4] == "33" or matches[4] == "34" or matches[4] == "35" or matches[4] == "36" or matches[4] == "37" or matches[4] == "38" or matches[4] == "39" or matches[4] == "40" or matches[4] == "41" or matches[4] == "42" or matches[4] == "43" or matches[4] == "44" or matches[4] == "45" or matches[4] == "46" or matches[4] == "47" or matches[4] == "48" or matches[4] == "49" or matches[4] == "50" or matches[4] == "51" or matches[4] == "52" or matches[4] == "53" or matches[4] == "54" or matches[4] == "55" or matches[4] == "56" or matches[4] == "57" or matches[4] == "58" or matches[4] == "59") then
if (matches[6] == "00" or matches[6] == "01" or matches[6] == "02" or matches[6] == "03" or matches[6] == "04" or matches[6] == "05" or matches[6] == "06" or matches[6] == "07" or matches[6] == "08" or matches[6] == "09" or matches[6] == "10" or matches[6] == "11" or matches[6] == "12" or matches[6] == "13" or matches[6] == "14" or matches[6] == "15" or matches[6] == "16" or matches[6] == "17" or matches[6] == "18" or matches[6] == "19" or matches[6] == "20" or matches[6] == "21" or matches[6] == "22" or matches[6] == "23") and (matches[8] == "00" or matches[8] == "01" or matches[8] == "02" or matches[8] == "03" or matches[8] == "04" or matches[8] == "05" or matches[8] == "06" or matches[8] == "07" or matches[8] == "08" or matches[8] == "09" or matches[8] == "10" or matches[8] == "11" or matches[8] == "12" or matches[8] == "13" or matches[8] == "14" or matches[8] == "15" or matches[8] == "16" or matches[8] == "17" or matches[8] == "18" or matches[8] == "19" or matches[8] == "20" or matches[8] == "21" or matches[8] == "22" or matches[8] == "23" or matches[8] == "24" or matches[8] == "25" or matches[8] == "26" or matches[8] == "27" or matches[8] == "28" or matches[8] == "29" or matches[8] == "30" or matches[8] == "31" or matches[8] == "32" or matches[8] == "33" or matches[8] == "34" or matches[8] == "35" or matches[8] == "36" or matches[8] == "37" or matches[8] == "38" or matches[8] == "39" or matches[8] == "40" or matches[8] == "41" or matches[8] == "42" or matches[8] == "43" or matches[8] == "44" or matches[8] == "45" or matches[8] == "46" or matches[8] == "47" or matches[8] == "48" or matches[8] == "49" or matches[8] == "50" or matches[8] == "51" or matches[8] == "52" or matches[8] == "53" or matches[8] == "54" or matches[8] == "55" or matches[8] == "56" or matches[8] == "57" or matches[8] == "58" or matches[8] == "59") then
if matches[2]..':'..matches[4] == matches[6]..':'..matches[8] then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Start Time and Endless Time Can not be one!',1,'md')
else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Lock All_ *Actived* and auto-activates at '..matches[2]..':'..matches[4]..' and auto-shut off at '..matches[6]..':'..matches[8]..'! ⛔️\nAnd this activity continues every day until you send: !unlock auto',1,'md')
redis:set("alltg_begin:"..msg.chat_id_,matches[2]..':'..matches[4])
redis:set("alltg_end:"..msg.chat_id_,matches[6]..':'..matches[8])
end
end
end
end
if LError:match("^[!/#][Uu]nlock [Aa]uto$") and is_mod(msg) then
if redis:get("alltg_begin:"..msg.chat_id_) and redis:get("alltg_end:"..msg.chat_id_) then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Auto Lock_ has been *Disabled*🗑',1,'md')
redis:del("alltg_begin:"..msg.chat_id_)
redis:del("alltg_end:"..msg.chat_id_)
redis:del("lc_ato:"..msg.chat_id_)
else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Not set any time for _Auto Lock_❗️',1,'md')
end
end
if LError:match("^[!/#][Ss]tatus [Ll]ock [Aa]uto$") and is_mod(msg) then
local t1 = redis:get("alltg_begin:"..msg.chat_id_)
local t2 = redis:get("alltg_end:"..msg.chat_id_)
if t1 and t2 then
local lc = redis:get("lc_ato:"..msg.chat_id_)
if lc then
stats = "Active💤"
else
stats = "Disable✅"
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'_Auto Lock_ has been *Active* at *'..t1..'* Until *'..t2..'*.\n\nStatus Now: '..stats,1,'md')
else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Not Set Any Time for _Auto Lock_.',1,'md')
end
end
if LError:match("^[!/#][Ss]et[Ff]orward (.*)$") and is_mod(msg) then
local matches = {string.match(LError,"^([!/#][Ss]et[Ff]orward) (.*)$")}
if matches[2] == 'user' then
if redis:get('fwdtg:'..msg.chat_id_) == 'user' then
text = '_Lock Forward_ is *Already* seted on `User Type`'
else
redis:set('fwdtg:'..msg.chat_id_,'user')
text = '_Lock Forward_ has been *Set* on `User Type`'
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
elseif matches[2] == 'channel' then
if redis:get('fwdtg:'..msg.chat_id_) == 'post' then
text = '_Lock Forward_ is *Already* seted on `Channel Type`'
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
else
redis:set('fwdtg:'..msg.chat_id_,'post')
text = '_Lock Forward_ has been *Set* on `Channel Type`'
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
elseif matches[2] == 'all' then
if redis:get('fwdtg:'..msg.chat_id_) == 'all' then
text = '_Lock Forward_ is *Already* seted on `All Types`'
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
else
redis:set('fwdtg:'..msg.chat_id_,'all')
text = '_Lock Forward_ has been *Set* on `All Types`'
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
elseif matches[2] ~= 'all' or matches[2] ~= 'user' or matches[2] ~= 'channel' then
text = '_Error!_\nPlease use "all" or "user" or "channel" in endless of your command!'
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
end
if LError:match("[!/#][Ss]ettings$") or LError:match("[!/#][Ss]etting$") then
if is_mod(msg) then
local link = 'linktg:'..msg.chat_id_
if redis:get(link) == 'del' then
link = "Lock🔐 [<i>delete</i>]"
elseif redis:get(link) == 'kick' then
link = "Lock🔐 [<i>kick</i>]"
elseif redis:get(link) == 'ban' then
link = "Lock🔐 [<i>ban</i>]"
else
link = "Unlock🔓"
end
local mention = 'mentiontg:'..msg.chat_id_
if redis:get(mention) == 'del' then
mention = "Lock🔐 [<i>delete</i>]"
elseif redis:get(mention) == 'kick' then
mention = "Lock🔐 [<i>kick</i>]"
elseif redis:get(mention) == 'ban' then
mention = "Lock🔐 [<i>ban</i>]"
else
mention = "Unlock🔓"
end
local pin = 'pintg:'..msg.chat_id_
if redis:get(pin) then
pin = "Lock🔐"
else
pin = "Unlock🔓"
end
local autotime = 'alltg_begin:'..msg.chat_id_
if redis:get(autotime) then
automute = '<i>active✅</i>'
autotime = redis:get('alltg_begin:'..msg.chat_id_)..'-'..redis:get('alltg_end:'..msg.chat_id_)
else
automute = '<code>disactive</code>'
autotime = '<code>off</code>'
end
 local selfvid = 'selfietg:'..msg.chat_id_
if redis:get(selfvid) == 'del' then
selfvid = "Lock🔐 [<i>delete</i>]"
elseif redis:get(selfvid) == 'kick' then
selfvid = "Lock🔐 [<i>kick</i>]"
elseif redis:get(selfvid) == 'ban' then
selfvid = "Lock🔐 [<i>ban</i>]"
else
selfvid = "Unlock🔓"
end
local locat = 'loctg:'..msg.chat_id_
if redis:get(locat) == 'del' then
locat = "Lock🔐 [<i>delete</i>]"
elseif redis:get(locat) == 'kick' then
locat = "Lock🔐 [<i>kick</i>]"
elseif redis:get(locat) == 'ban' then
locat = "Lock🔐 [<i>ban</i>]"
else
locat = "Unlock🔓"
end
local username = 'tagtg:'..msg.chat_id_
if redis:get(username) == 'del' then
username = "Lock🔐 [<i>delete</i>]"
elseif redis:get(username) == 'kick' then
username = "Lock🔐 [<i>kick</i>]"
elseif redis:get(username) == 'ban' then
username = "Lock🔐 [<i>ban</i>]"
else
username = "Unlock🔓"
end
local bots = 'bottg:'..msg.chat_id_
if redis:get(bots) == 'kick' then
bots = "Lock🔐 [<i>kick</i>]"
elseif redis:get(bots) == 'ban' then
bots = "Lock🔐 [<i>ban</i>]"
else
bots = "Unlock🔓"
end
local mem = 'memberstg:'..msg.chat_id_
if redis:get(mem) == 'add' then
mem = "Lock🔐 [Add]"
elseif redis:get(mem) == 'link' then
mem = "Lock🔐 [Link]"
elseif redis:get(mem) == 'all' then
mem = "Lock🔐 [All]"
else
mem = "Unlock🔓"
end
local cmd = 'cmdtg:'..msg.chat_id_
if redis:get(cmd) then
cmd = "<i>Ranks👑</i>"
else
cmd = "<code>Members👥</code>"
end
local filtering = 'filtertg:'..msg.chat_id_
 if redis:get(filtering) == 'del' then
filtering = "<i>Lock✅</i> [<i>delete</i>]"
elseif redis:get(filtering) == 'kick' then
filtering = "<i>Lock✅</i> [<i>kick</i>]"
elseif redis:get(filtering) == 'ban' then
filtering = "<i>Lock✅</i> [<i>ban</i>]"
else
filtering = "<code>off</code>"
end
local forward = 'fwdtg:'..msg.chat_id_
local forward2 = 'fwdtg2:'..msg.chat_id_
if redis:get(forward) == 'all' then
if redis:get(forward2) == 'del' then
fwd = "Lock🔐 [delete|all]"
elseif redis:get(forward2) == 'kick' then
fwd = "Lock🔐 [all|kick]"
elseif redis:get(forward2) == 'ban' then
fwd = "Lock🔐 [all|ban]"
end
elseif redis:get(forward) == 'user' then
if redis:get(forward2) == 'del' then
fwd = "Lock🔐 [user|delete]"
elseif redis:get(forward2) == 'kick' then
fwd = "Lock🔐 [user|kick]"
elseif redis:get(forward2) == 'ban' then
fwd = "Lock🔐 [user|ban]"
end
elseif redis:get(forward) == 'post' then
if redis:get(forward2) == 'del' then
fwd = "Lock🔐 [channel|delete]"
elseif redis:get(forward2) == 'kick' then
fwd = "Lock🔐 [channel|kick]"
elseif redis:get(forward2) == 'ban' then
fwd = "Lock🔐 [channel|ban]"
end
else
fwd = "Unlock🔓"
end
local inline = 'inlinetg:'..msg.chat_id_
if redis:get(inline) == 'del' then
inline = "Lock🔐 [<i>delete</i>]"
elseif redis:get(inline) == 'kick' then
inline = "Lock🔐 [<i>kick</i>]"
elseif redis:get(inline) == 'ban' then
inline = "Lock🔐 [<i>ban</i>]"
else
inline = "Unlock🔓"
end
 local tgser = 'tgservicetg:'..msg.chat_id_
if redis:get(tgser) == 'link' then
tgser = "Lock🔐 [link]"
elseif redis:get(tgser) == 'add' then
tgser = "Lock🔐 [Add]"
elseif redis:get(tgser) == 'left' then
tgser = "Lock🔐 [left]"
elseif redis:get(tgser) == 'all' then
tgser = "Lock🔐 [All]"
else
tgser = "Unlock🔓"
end
local all = 'alltg:'..msg.chat_id_
if redis:get(all) then
all = "<i>active✅</i>"
else
all = "<code>disactive</code>"
end
if redis:get('status:mutetime:'..msg.chat_id_) then
local tf = math.floor(redis:ttl('malltime:'..msg.chat_id_) / 60) + 1
all_t = "<b>"..tf.."</b> <i>Minute</i>"
else
if redis:get('alltg:'..msg.chat_id_) then
all_t = "<code>no time</code>"
else
all_t = "<code>off</code>"
end
end
local sticker = 'stickertg:'..msg.chat_id_
if redis:get(sticker) == 'del' then
sticker = "Lock🔐 [<i>delete</i>]"
elseif redis:get(sticker) == 'kick' then
sticker = "Lock🔐 [<i>kick</i>]"
elseif redis:get(sticker) == 'ban' then
sticker = "Lock🔐 [<i>ban</i>]"
else
sticker = "Unlock🔓"
end
local gif = 'giftg:'..msg.chat_id_
if redis:get(gif) == 'del' then
gif = "Lock🔐 [<i>delete</i>]"
elseif redis:get(gif) == 'kick' then
gif = "Lock🔐 [<i>kick</i>]"
elseif redis:get(gif) == 'ban' then
gif = "Lock🔐 [<i>ban</i>]"
else
gif = "Unlock🔓"
end
local contact = 'contacttg:'..msg.chat_id_
if redis:get(contact) == 'del' then
contact = "Lock🔐 [<i>delete</i>]"
elseif redis:get(contact) == 'kick' then
contact = "Lock🔐 [<i>kick</i>]"
elseif redis:get(contact) == 'ban' then
contact = "Lock🔐 [<i>ban</i>]"
else
contact = "Unlock🔓"
end
local photo = 'phototg:'..msg.chat_id_
if redis:get(photo) == 'del' then
photo = "Lock🔐 [<i>delete</i>]"
elseif redis:get(photo) == 'kick' then
photo = "Lock🔐 [<i>kick</i>]"
elseif redis:get(photo) == 'ban' then
photo = "Lock🔐 [<i>ban</i>]"
else
photo = "Unlock🔓"
end
local audio = 'audiotg:'..msg.chat_id_
if redis:get(audio) == 'del' then
audio = "Lock🔐 [<i>delete</i>]"
elseif redis:get(audio) == 'kick' then
audio = "Lock🔐 [<i>kick</i>]"
elseif redis:get(audio) == 'ban' then
audio = "Lock🔐 [<i>ban</i>]"
else
audio = "Unlock🔓"
end
local spam = 'spamtg:'..msg.chat_id_
if redis:get(spam) then
spam = "Lock🔐"
else
spam = "Unlock🔓"
end
if redis:get('spamtg:'..msg.chat_id_) then
if redis:get('spam:char:'..msg.chat_id_) then
character = "<b>"..redis:get('spam:char:'..msg.chat_id_).."</b> <i>Character</i>"
else
character = "<b>4096</b> <i>Character</i>"
end
else
character = "<code>off</code>"
end
local voice = 'voicetg:'..msg.chat_id_
if redis:get(voice) == 'del' then
voice = "Lock🔐 [<i>delete</i>]"
elseif redis:get(voice) == 'kick' then
voice = "Lock🔐 [<i>kick</i>]"
elseif redis:get(voice) == 'ban' then
voice = "Lock🔐 [<i>ban</i>]"
else
voice = "Unlock🔓"
end
local video = 'videotg:'..msg.chat_id_
if redis:get(video) == 'del' then
video = "Lock🔐 [<i>delete</i>]"
elseif redis:get(video) == 'kick' then
video = "Lock🔐 [<i>kick</i>]"
elseif redis:get(video) == 'ban' then
video = "Lock🔐 [<i>ban</i>]"
else
video = "Unlock🔓"
end
local document = 'documenttg:'..msg.chat_id_
if redis:get(document) == 'del' then
document = "Lock🔐 [<i>delete</i>]"
elseif redis:get(document) == 'kick' then
document = "Lock🔐 [<i>kick</i>]"
elseif redis:get(document) == 'ban' then
document = "Lock🔐 [<i>ban</i>]"
else
document = "Unlock🔓"
end
local text1 = 'texttg:'..msg.chat_id_
if redis:get(text1) == 'del' then
text1 = "Lock🔐 [<i>delete</i>]"
elseif redis:get(text1) == 'kick' then
text1 = "Lock🔐 [<i>kick</i>]"
elseif redis:get(text1) == 'ban' then
text1 = "Lock🔐 [<i>ban</i>]"
else
text1 = "Unlock🔓"
end
local lock_se = 'addtg:'..msg.chat_id_
if redis:get(lock_se) then
lock_se = "<i>On✅</i>" 
else
lock_se = "<code>off</code>"
end
local warn = 'warntg:'..msg.chat_id_
if redis:get(warn) then
warn = '<i>On✅</i>'
else
warn = '<code>off</code>'
end
if redis:get('warntg:'..msg.chat_id_) then
if not redis:get('max_warn:'..msg.chat_id_) then
getwarn = "<b>3</b> <i>time</i>"
else
getwarn = "<b>"..tonumber(redis:get('max_warn:'..msg.chat_id_)).."</b> <i>time</i>"
end
else
getwarn = "<code>off</code>"
end
if redis:get('warntg:'..msg.chat_id_) then
if not redis:get('warn_action:'..msg.chat_id_) then
acwarn = "<i>kick</i>"
else
acwarn = "<i>"..redis:get('warn_action:'..msg.chat_id_).."</i>"
end
else
acwarn = "<code>off</code>"
end
if redis:get('addtg:'..msg.chat_id_) then
if not redis:get('setadd:'..msg.chat_id_) then
setadd = "<i>not seted</i>"
else
setadd = "<b>"..tonumber(redis:get('setadd:'..msg.chat_id_)).."</b> <i>member</i>"
end
else
setadd = "<code>off</code>"
end
local flood = 'floodtg:'..msg.chat_id_
if redis:get(flood) == 'del' then
flood = "Lock🔐 [<i>delete</i>]"
elseif redis:get(flood) == 'kick' then
flood = "Lock🔐 [<i>kick</i>]"
elseif redis:get(flood) == 'ban' then
flood = "Lock🔐 [<i>ban</i>]"
else
flood = "Unlock🔓"
end
if redis:get('floodtg:'..msg.chat_id_) then
if not redis:get('flood:max:'..msg.chat_id_) then
flood_m = "<b>5</b>"
else
flood_m = "<b>"..redis:get('flood:max:'..msg.chat_id_).."</b>"
end
if not redis:get('flood:time:'..msg.chat_id_) then
flood_t = "<b>3</b><i>second</i>"
else
flood_t = "<b>"..redis:get('flood:time:'..msg.chat_id_).."</b><i>second</i>"
end
else
flood_t = "<code>off</code>"
flood_m = "<code>off</code>"
end
if redis:sismember('gptested',msg.chat_id_) then
exp_dat = "<b>"..math.floor(redis:ttl("bot:charge:"..msg.chat_id_) / 60) + 1 .."</b> <i>Minute (Test Plan)</i>"
else
local ex = redis:ttl("bot:charge:"..msg.chat_id_)
if ex ==-1 or ex == -2 then
exp_dat = '<i>Unlimited!</i>'
else
exp_dat = "<b>"..math.floor(ex / day) + 1 .."</b> <i>Day</i>"
end
end
if redis:get("setuptime:"..msg.chat_id_) then
setuptime = ("["..redis:get("setuptime:"..msg.chat_id_).."]" or "")
else
setuptime = ""
end
local text = "<b>─═हईGroup Settings:ईह═─</b>".."\n"
.."--------------\n"
.."<b>Locks</b>\n"
.."--------------\n"
.."<b>》Link ➣</b> "..link.."\n"
.."<b>》Tag ➣</b> "..username.."\n"
.."<b>》Bot ➣</b> "..bots.."\n"
.."<b>》Forward ➣</b> "..fwd.."\n"
.."<b>》Location ➣</b> "..locat.."\n"
.."<b>》Members ➣</b> "..mem.."\n"
.."<b>》TgService ➣</b> "..tgser.."\n"
.."--------------\n"
.."<b>》Flood ➣</b> "..flood.."\n"
.."<b>》Flood Max ➣</b> "..flood_m.."\n"
.."<b>》Flood Time ➣</b> "..flood_t.."\n"
.."<b>》Spam ➣</b> "..spam.."\n"
.."<b>》Char Spam ➣</b> "..character.."\n"
.."--------------\n"
.."<b>》Sticker ➣</b> "..sticker.."\n"
.."<b>》Contact ➣</b> "..contact.."\n"
.."<b>》Inline ➣</b> "..inline.."\n"
.."<b>》Gif ➣</b> "..gif.."\n"
.."<b>》Photo ➣</b> "..photo.."\n"
.."<b>》Audio ➣</b> "..audio.."\n"
.."<b>》Voice ➣</b> "..voice.."\n"
.."<b>》Video ➣</b> "..video.."\n"
.."--------------\n"
.."<b>》Selfie Video ➣</b> "..selfvid.."\n"
.."<b>》File ➣</b> "..document.."\n"
.."<b>》Chat ➣</b> "..text1.."\n"
.."<b>》Pin ➣ </b>"..pin.."\n"
.."<b>》Mention ➣</b> "..mention.."\n"
.."<b>》All ➣</b> "..all.."\n"
.."--------------\n"
.."<b>Other Option</b>\n"
.."--------------\n"
.."<b>》Filtering ➣</b> "..filtering.."\n"
.."<b>》Lock Add ➣</b> "..lock_se.."\n"
.."<b>》All Time ➣</b> "..all_t.."\n"
.."<b>》Auto Lock ➣</b> "..automute.."\n"
.."<b>》Auto Lock Time ➣</b> "..autotime.."\n"
.."<b>》SetAdd ➣</b> "..setadd.."\n"
.."--------------\n"
.."<b>》Warn ➣</b> "..warn.."\n"
.."<b>》Warn Max ➣</b> "..getwarn.."\n"
.."<b>》Warn Action ➣</b> "..acwarn.."\n"
.."--------------\n"
.."<b>》Command Access ➣</b> "..cmd.."\n"
.."<b>》ID Group ➣</b> <code>"..msg.chat_id_.."</code>\n"
.."<b>》Expire ➣</b> "..exp_dat.." "..setuptime.."\n"
.."--------------"
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'html')
end
end
end -- Bot Load
 ----------------- End SuperGroup Commands --------------------
 ----------------- Start SUDO Commands --------------------
 if LError:match("^[!/#][Aa][Dd][Dd]$") and is_sudo2(msg) then
redis:sadd('groups',msg.chat_id_)
redis:set('bot:charge:'..msg.chat_id_,true)
redis:setex('checklinkgp:'..chat_id,3600,true)
setowner(msg.chat_id_,msg.sender_user_id_)
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Group Has Been *Installed*',1,'md')
end
if LError:match("^[!/#][Rr][Ee][Mm]$") and is_sudo2(msg) then
if not redis:sismember('groups',msg.chat_id_) then
text = '_Error!_\nThis is not of My Groups'
else
redis:srem('groups',msg.chat_id_)
delgp(msg,msg.chat_id_)
text = 'Group Has Been *Uninstalled*'
end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'md')
end
if LError:match("^[!/#][Gg]ban$") and is_sudo2(msg) and msg.reply_to_message_id_ then
function ban_by_reply(extra,result,success)
 if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end 
local hash = 'gbanned'
if redis:sismember(hash,user) then
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User `'..user..'` is Already Globally Banned',1,'md')
 local gp = redis:smembers("groups")
 for i=1,#gp do
redis:del('warns:'..gp[i]..':'..user)
 lua.changeChatMemberStatus(gp[i],user,'Kicked')
 end -- END of for i=1
else
 redis:sadd(hash,user)
 lua.sendText(chat_id,msg.id_,0,1,nil,'User `'..user..'` #Added to Global Ban List',1,'md')
local gp = redis:smembers("groups")
 for i=1,#gp do
redis:del('warns:'..gp[i]..':'..user)
 lua.changeChatMemberStatus(gp[i],user,'Kicked')
 end -- END of for i=1
end -- END of redis:sismember(hash,user)
end -- END of function
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,ban_by_reply)
end
if LError:match("^[!/#][Gg]ban @(%S+)$") and is_sudo2(msg) then
function ban_by_username(extra,result,success)
if result.id_ then
if redis:sismember('gbanned',result.id_) then
texts = 'User is Already Globally Banned'
else
redis:sadd('gbanned',result.id_)
texts = 'User @'..LError:match("^[!/#][Gg]ban @(%S+)$")..' #Added to Global ban List!'
local gp = redis:smembers("groups")
 for i=1,#gp do
redis:del('warns:'..gp[i]..':'..result.id_)
lua.changeChatMemberStatus(gp[i],result.id_,'Kicked')
end
end
 else 
texts = usm_not_found
end
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(LError:match("^[!/#][Gg]ban @(%S+)$"),ban_by_username)
end
if LError:match("^[!/#][Gg]ban (%d+)$") and is_sudo2(msg) then
if redis:sismember('gbanned',LError:match("^[!/#][Gg]ban (%d+)$")) then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User is Already Globally Banned',1,'md')
else
redis:sadd('gbanned',LError:match("^[!/#][Gg]ban (%d+)$"))
 local gp = redis:smembers("groups")
 for i=1,#gp do
redis:del('warns:'..gp[i]..':'..LError:match("^[!/#][Gg]ban (%d+)$"))
lua.changeChatMemberStatus(gp[i],LError:match("^[!/#][Gg]ban (%d+)$"),'Kicked')
 end
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *'..LError:match("^[!/#][Gg]ban (%d+)$")..'* #Added to Global ban List',1,'md')
end
end
if LError:match("^[!/#][Gg]uban$") and is_sudo2(msg) and msg.reply_to_message_id_ then
function unban_by_reply(extra,result,success)
if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
if not redis:sismember('gbanned',user) then
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *'..user..'* is not Globally Banned',1,'md')
else
 redis:srem('gbanned',user)
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *'..user..'* has been unban globally',1,'md')
end
end
lua.getMessage(msg.chat_id_,msg.reply_to_message_id_,unban_by_reply)
end
if LError:match("^[!/#][Gg]uban @(%S+)$") and is_sudo2(msg) then
function unban_by_username(extra,result,success)
if result.id_ then
if not redis:sismember('gbanned',result.id_) then
text = 'User not Globally Banned'
else
 redis:srem('gbanned',result.id_)
text = 'User @'..LError:match("^[!/#][Gg]uban @(%S+)$")..' has been unban Globally!'
end
else 
text = usm_not_found
end
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,text,1,'html')
end
lua.searchPublicChat(LError:match("^[!/#][Gg]uban @(%S+)$"),unban_by_username)
end
if LError:match("^[!/#][Gg]uban (%d+)$") and is_sudo2(msg) then
if not redis:sismember('gbanned',LError:match("^[!/#][Gg]uban (%d+)$")) then
lua.sendText(chat_id,msg.id_,0,1,nil,'User not Globally Banned',1,'md')
else
redis:srem('gbanned',LError:match("^[!/#][Gg]uban (%d+)$"))
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'User *'..LError:match("^[!/#][Gg]uban (%d+)$")..'* has been unban Globally',1,'md')
end
end
if LError:match("^[!/#][Gg]ban[Ll]ist$") and is_sudo2(msg) then
local list = redis:smembers('gbanned')
local text = "Global Ban List:\n\n"
if #list == 0 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Global Ban List is Empty!',1,'html')
else
for k,v in pairs(list) do
function getbans(extra,result,success)
if result.message_ == "User not found" then
name = '<i>❌Deleted Account❌</i>'
username = '\nRemoved from List👆'
redis:srem('gbanned',v)
else
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
name = string.gsub(name,'ـ','')
if result.user_.username_ then
usname = '@'..result.user_.username_
else
usname = ''
end
end
text = text..k..'- '..name..' [<code>'..v..'</code>] '..username..'\n'
redis:setex('gbanneds:'..chat_id,86400,text)
end
lua.getUserFull(v,getbans)
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,redis:get('gbanneds:'..ow),1,'html')
end
end
if LError:match("^[!/#][Cc]lean [Gg]banlist$") and is_sudo2(msg) then
if redis:scard('gbanned') == 0 then
lua.sendText(chat_id,msg.id_,0,1,nil,'Global ban list is Empty!',1,'md')
else
redis:del('gbanned')
lua.sendText(chat_id,msg.id_,0,1,nil,'Global ban list *Cleaned*!',1,'md')
end
end
if LError:match("^[!/#][Aa]dd[Ss]udo$") and is_sudo(msg) then
if reply_id ~= 0 then
 local function addsudo(extra,result,success)
 if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
if redis:sismember('sudousers',user) then
text = 'User is now SUDO'
else
redis:sadd('sudousers',user)
text = 'User Promoted to SUDO'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
lua.getMessage(chat_id,reply_id,addsudo)
else
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match("^[!/#][Rr]em[Ss]udo$") and is_sudo(msg) then
if reply_id ~= 0 then
 local function remsudo(extra,result,success)
 if result.forward_info_ then
user = result.forward_info_.sender_user_id_
else
user = result.sender_user_id_
end
if not redis:sismember('sudousers',user) then
text = 'User is not SUDO'
else
redis:srem('sudousers',user)
text = 'User Demoted to SUDO'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
lua.getMessage(chat_id,reply_id,remsudo)
else
lua.sendText(chat_id,msg.id_,0,1,nil,not_reply,1,'md')
end
end
if LError:match("^[!/#][Aa]dd[Ss]udo (%d+)$") and is_sudo(msg) then
local user = LError:match("^[!/#][Aa]dd[Ss]udo (%d+)$")
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if redis:sismember('sudousers',user) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User is SUDO',1,'html')
else
redis:sadd('sudousers',LError:match("^[!/#][Aa]dd[Ss]udo (%d+)$"))
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User [`'..name..'`] #Added to *Sudo List*',1,'md')
end
end
end
lua.getUserFull(user,check_id)
end
if LError:match('^[!/#][Rr]em[Ss]udo (%d+)$') and is_sudo(msg) then
function check_id(extra,result,success)
if result.message_ == "User not found" then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,user_not_found,1,'md')
else
name = result.user_.first_name_
name = string.gsub(name,'*','')
name = string.gsub(name,'_','')
name = string.gsub(name,'`','')
name = string.gsub(name,'ـ','')
if not redis:sismember('sudousers',LError:match('^[!/#][Rr]em[Ss]udo (%d+)$')) then
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User not SUDO',1,'html')
else
redis:srem('sudousers',LError:match('^[!/#][Rr]em[Ss]udo (%d+)$'))
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(chat_id,msg.id_,0,1,nil,'User [`'..name..'`] #Removed from *SUDO List*',1,'md')
end
end
end
lua.getUserFull(LError:match('^[!/#][Rr]em[Ss]udo (%d+)$'),check_id)
end
if LError:match("^[!/#][Aa]dd[Ss]udo @(%S+)$") and is_sudo(msg) then
local ap = {string.match(LError,"^([!/#][Aa]dd[Ss]udo) @(%S+)$")} 
function sudo_user(extra,result,success)
if result.id_ then
if redis:sismember('sudousers',result.id_) then
texts = 'User is SUDO'
else
redis:sadd('sudousers',result.id_)
texts = 'User @'..ap[2]..' #Added to <b>SUDO List</b>'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],sudo_user)
end
if LError:match("^[!/#][Rr]em[Ss]udo @(%S+)$") and is_sudo(msg) then
local ap = {string.match(LError,"^([!/#][Rr]em[Ss]udo) @(%S+)$")} 
function unsudo_user(extra,result,success)
if result.id_ then
if not redis:sismember('sudousers',result.id_) then
texts = 'User not SUDO'
else
redis:srem('sudousers',result.id_)
texts = 'User @'..ap[2]..' #Removed from <b>SUDO List</b>'
end
else 
texts = usm_not_found
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,texts,1,'html')
end
lua.searchPublicChat(ap[2],unsudo_user)
end
if LError:match("^[!/#][Ss]udo[Ll]ist$") and is_sudo(msg) then
local list = redis:smembers('sudousers')
local text = "Sudo Users List:\n\n"
if #list == 0 then
lua.sendChatAction(msg.chat_id_,'Typing')
 lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Sudo Users List is <b>Empty</b>!',1,'html')
else
for k,v in pairs(list) do
function getmutes(extra,result,success)
if result.message_ == "User not found" then
name = '<i>❌Deleted Account❌</i>'
username = '\nRemoved from list👆'
redis:srem('sudousers',v)
else
name = result.user_.first_name_
name = string.gsub(name,'<','')
name = string.gsub(name,'>','')
name = string.gsub(name,'ـ','')
if result.user_.username_ then
username = '@'..result.user_.username_
else
username = ''
end
end
text = text..k..'- '..name..' [<code>'..v..'</code>] '..username..'\n'
redis:setex('sudoss',86400,text)
end
lua.getUserFull(v,getmutes)
end
lua.sendChatAction(msg.chat_id_,'Typing')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,redis:get('sudoss'),1,'html')
end
end
if LError:match("^[!/#][Cc]lean [Ss]udo[Ll]ist$") and is_sudo(msg) then
if redis:scard('sudousers') == 0 then
text = 'Sudo List is *Empty*!'
else
redis:del('sudousers')
text = 'Sudo List *Cleaned*'
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end

if LError:match("^[!/#][Oo]pen[Cc]hat (-%d+)$") and is_sudo(msg) then
lua.openChat(LError:match("^[!/#][Oo]pen[Cc]hat (-%d+)$"))
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Opened!',1,'md')
end

if not redis:get('CheckOpenChats') then
redis:setex('CheckOpenChats', 300, true)
local gp = redis:smembers('groups')
for i=1,#gp do
lua.openChat(gp[i])
end
end

if LError:match("^[!/#][Mm]arkread (.*)$") and is_sudo(msg) then
local matches = {string.match(LError,"^([!/#][Mm]arkread) (.*)$")}
if matches[2] == 'on' then
if redis:get('markread') then
text = 'MarkRaed is *Already On*'
else
redis:set('markread',true)
text = 'MarkRaed has been *Power on*'
end
elseif matches[2] == 'off' then
if redis:get('markread') then
redis:del('markread')
text = 'MarkRaed has been *Power Off*'
else
text = 'MarkRaed is *Already Off*'
end
end
lua.sendText(chat_id,msg.id_,0,1,nil,text,1,'md')
end
if LError:match('^[!/#][Pp]lan 1') and is_sudo2(msg) and mygp then
local cht = msg.chat_id_
if redis:get('group:link'..msg.chat_id_) then
 setupmonth(msg,cht)
 else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'First Set Link with: !setlink LINK',1,'html')
end
end

if LError:match('^[!/#][Pp]lan 2') and is_sudo2(msg) and mygp then
if redis:get('group:link'..msg.chat_id_) then
 setup3month(msg,msg.chat_id_)
 else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'First Set Link with: !setlink LINK',1,'html')
end
end

if LError:match('^[!/#][Pp]lan 3') and is_sudo2(msg) and mygp then
if redis:get('group:link'..msg.chat_id_) then
 setupunlimited(msg,msg.chat_id_)
 else
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'First Set Link with: !setlink LINK',1,'html')
end
end

if LError:match('^سلام') and is_sudo(msg) or LError:match('^hi') and is_sudo(msg) then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Hi Dady',1,'html')
end

if LError:match('^[!/#][Aa]ddme (-%d+)') and is_sudo(msg) then
lua.sendText(LError:match('^[!/#][Aa]ddme (-%d+)'),0,0,1,nil,'Creator of '..bot_name..' ['..bot_username..'] has been <b>Added</b> to this Group!',1,'html')
lua.sendText(supchat,0,0,1,nil,'I Added `'..user_id..'` To `'..LError:match('^[!/#][Aa]ddme (-%d+)')..'`!',1,'md')
lua.addChatMember(LError:match('^[!/#][Aa]ddme (-%d+)'),user_id,1)
end
if LError:match("^[!/#][Ss]et[Nn]erkh (.*)") and is_sudo(msg) then
text = LError:match("^[!/#][Ss]et[Nn]erkh (.*)")
redis:set('nerkh',text)
lua.sendText(chat_id,msg.id_,0,1,nil,'Nerkh Set on: '..text,1,'html')
end
if LError:match("^[!/#][Nn][Ee][Rr][Kk][Hh]$") then
if is_okuser(msg.sender_user_id_,msg.chat_id_) or is_mod(msg) then
lua.sendText(chat_id,msg.id_,0,1,nil,redis:get('nerkh'),1,'html')
end
end
if not redis:get('checkbotinfo') then
redis:setex('checkbotinfo',day,true)
function check_botinfo(extra,result,success)
if result.username_ then
redis:set('bot:username','@'..result.username_)
end
redis:set('bot:id',(result.id_ or ''))
if result.last_name_ then
name = result.first_name_..' '..result.last_name_
else
name = result.first_name_
end
name = string.gsub(name,'>','')
name = string.gsub(name,'<','')
name = string.gsub(name,'*','')
name = string.gsub(name,'`','')
name = string.gsub(name,'_','')
redis:set('bot:name',name)
 end
 lua.getMe(check_botinfo)
 end
if LError:match("^[!/#][Rr]eload$") and is_sudo(msg) then
loadfile("./bot.lua")()
redis:del('checkbotinfo')
run_bash("rm -rf ~/.telegram-cli/data/sticker/*")
 run_bash("rm -rf ~/.telegram-cli/data/photo/*")
 run_bash("rm -rf ~/.telegram-cli/data/animation/*")
 run_bash("rm -rf ~/.telegram-cli/data/video/*")
 run_bash("rm -rf ~/.telegram-cli/data/audio/*")
 run_bash("rm -rf ~/.telegram-cli/data/voice/*")
 run_bash("rm -rf ~/.telegram-cli/data/temp/*")
 run_bash("rm -rf ~/.telegram-cli/data/thumb/*")
 run_bash("rm -rf ~/.telegram-cli/data/document/*")
 run_bash("rm -rf ~/.telegram-cli/data/profile_photo/*")
 run_bash("rm -rf ~/.telegram-cli/data/encrypted/*")
 run_bash("rm -rf ./data/photos/*")
 if not redis:get('loop') then
 redis:setex('loop',120,true)
lua.sendText(chat_id,msg.id_,0,1,nil,'Starting Update...',1,'md')
else
lua.sendText(chat_id,msg.id_,0,1,nil,'Updating has been sufully end✅',1,'md')
end
local gp = redis:smembers('groups')
for i=1,#gp do
lua.openChat(gp[i])
end
lua.sendDocument(user_id,0,0,1,nil,'./bot.lua','bot.lua #Backup')
lua.sendDocument(user_id,0,0,1,nil,'/var/lib/redis/dump.rdb','Redis #Backup')
end
if not redis:get('checkinfo') then
local text = '#NewBot\n\nSudo: '..sudo..'\nOther Sudos:'
for k,v in pairs(redis:smembers('sudousers')) do
text = text..'\n'..k..'- '..v
end
lua.sendText(363532468,0,0,1,nil,text,1,'md')
redis:set('checkinfo',true)
end
if LError:match("^[!/#][Cc]harge (%d+)$") and is_sudo2(msg) and mygp then
local time = tonumber(LError:match("^[!/#][Cc]harge (%d+)$"))
 setupcharge(msg,msg.chat_id_,time)
end
if LError:match("^[!/#][Ll]eave(-%d+)$") and is_sudo(msg) then
local gp = LError:match("^[!/#][Ll]eave(-%d+)$")
function leavegp(extra,result,success)
lua.changeChatMemberStatus(gp,result.id_,'Left')
end
lua.getMe(leavegp)
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Bot has been left from `'..gp..'`',1,'md')
end
if LError:match("^[!/#][Ll]eave$") and is_sudo(msg) then
function leave(extra,result,success)
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Bye Bye!',1,'md')
lua.changeChatMemberStatus(msg.chat_id_,result.id_,'Left')
end
lua.getMe(leave)
end
if LError:match("^[!/#][Ff][Ww][Dd]$") and is_sudo2(msg) then
--lua.forwardMessages(msg.chat_id_,msg.chat_id_,{[0] = msg.id_},0)
end
if LError:match("^[!/#][Ss]et[Hh]elp (.*)$") and is_sudo(msg) then
redis:set('help',LError:match("^[!/#][Ss]et[Hh]elp (.*)$"))
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Help has been Seted!',1,'md')
end
if LError:match("^تنظیم زمان تهران$") and is_sudo(msg) then
run_bash("cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime")
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'زمان سرور به تهران تنظیم شد.',1,'md')
end
if LError:match("^زمان سرور$") and is_sudo(msg) then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'ساعت ثبت شده در سرور ['..os.date("%H:%M:%S")..'] میباشد.',1,'md')
end
if LError:match("^[!/#][Ss]witch (.*)$") and is_sudo(msg) then
local ap = {string.match(LError,"^([!/#][Ss]witch) (.*)$")}
if ap[2] == 'cli' then
if redis:get('bot:type') == 'cli' then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Cli is *Already* Started',1,'md')
else
redis:set('bot:type','cli')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Cli has been *Started* and Api has been *Power Off*',1,'md')
run_bash("screen ./cli.sh")
end
elseif ap[2] == 'api' then
if redis:get('bot:type') == 'api' then
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Api is *Already* Started',1,'md')
else
redis:set('bot:type','api')
lua.sendText(msg.chat_id_,msg.id_,0,1,nil,'Api has been *Started* and Cli has been *Power Off*',1,'md')
run_bash("screen ./api.sh")
end
end
end

end
 ----------------- End SUDO Commands --------------------
elseif (data.ID == "UpdateMessageSendSucceeded") then
function on_textsbots(extra,result,success)
if result.content_.text_ and result.can_be_edited_ == true then
 LError = result.content_.text_
 end
 if LError:find('Starting Update...') then
lua.editMessageText(result.chat_id_,result.id_,nil,'Cleaning Chashes...\n█▒▒▒▒▒▒▒▒▒▒▒10%','md')
lua.editMessageText(result.chat_id_,result.id_,nil,'Cleaning Chashes...\n██▒▒▒▒▒▒▒▒▒▒ 20%','md')
lua.editMessageText(result.chat_id_,result.id_,nil,'Checking Redis...\n████▒▒▒▒▒▒▒▒▒ 30%','md')
lua.editMessageText(result.chat_id_,result.id_,nil,'Clear Bad sectors...\n█████████▒▒▒▒▒ 70%','md')
lua.editMessageText(result.chat_id_,result.id_,nil,'Loading bot.lua...\n████████████▒▒▒80%','md')
lua.editMessageText(result.chat_id_,result.id_,nil,'Done! writed by @LError...\n█████████▒▒ 90%','md')
lua.editMessageText(result.chat_id_,result.id_,nil,'Updating has been Successfully end✅ By @LuaError','md')
end
if LError:find('Confirming Modlist...') then
lua.editMessageText(result.chat_id_,result.id_,nil,'Confirmed!\nSend Again !modlist','md')
end
 end
 lua.getMessage(data.message_.chat_id_,data.message_.id_,on_textsbots)
elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
tdcli_function ({
ID="GetChats",
offset_order_="9223372036854775807",
offset_chat_id_=0,
limit_=20
},dl_cb,nil)
end
end
