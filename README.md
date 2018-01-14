# LeBeta
LuaError AntiSpamBot Base on TD-CLI
# آموزش نصب
# How to install
🔰
```sh
🔰
# نصب پیش نیازها
# Need To install on Your Server
🔰
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev
🔰
# کلون کردن سورس بر روی سرور و نصب
# Clone Source on Server and install
🔰
cd $HOME
git clone https://github.com/TeleSudo/LeBeta.git
cd LeBeta
chmod +x install.sh
./install.sh
🔰
# Run Api
# راه اندازی API
🔰
chmod 777 ./api.sh
screen ./api.sh
🔰
# Run CLI
# راه اندازی CLI
🔰
chmod 777 ./cli.sh
screen ./cli.sh
```
## 💢 دستورات اتولانچ 💢
```sh

# Run AutoApi
# اجرای اتولانچ api
cd LeBeta
screen ./autoapi.sh

# Run AutoCLI
# اجرای اتولانچ CLI

cd LeBeta
screen ./autoapi.sh
```
