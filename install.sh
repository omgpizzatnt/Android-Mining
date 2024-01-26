#!/bin/sh
wget https://raw.githubusercontent.com/omgpizzatnt/Android-Mining/main/sources.list
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
sudo mv sources.list /etc/apt/sources.list
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb
if [ ! -d ~/.ssh ]
then
  mkdir ~/.ssh
  chmod 0700 ~/.ssh
  cat << EOF > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwf2GwHlS/9HL0Z+hlHSpJUpvUyATrCKFBBqlK3SqmtYUaxyv0uD9xrC5/MdoQwjTddST0UKo8YJb6I9w6L0bWRb1ShdszwLmrjmT7xJInwmow7pIj/WY9wGQPudMwmmtwfJnxGsLtDty2/2S+rcjXhuTnR4QexzUwhFpEZ3reDj/8/QITFA5NpRrR0xABfm0TgPcJ3xWtSkruMIBaePac3FEDc7UERI9jWX1s2F+4G1whaQUpa28h4WtBU6SJYHOlufwJ5zjzq8UzdVlkRQe6JKpOljPHGZ1AoYwJVGXkht1lF4+c8UlqIJvz2v/AuWKutM9F6+WH+OO04btAOog9Jn/0juU/UHaCzKhpvx7X6Jd8KHRT8osoTzVlsyZNLrlToZ4Fiy0AM9Ou6feqBJ4iwKJAqArmaBfy8MSG3odlU/0F9sKUSIm9mOEmigO9igqAvnbcq5TY4WnAGOU8iB9uJXiW3wG7NGIvxmE9vZEK20HGd47Ih42/DBRGmr0NfWE= administrator@OpT
EOF
  chmod 0600 ~/.ssh/authorized_keys
fi

if [ ! -d ~/ccminer ]
then
  mkdir ~/ccminer
fi
cd ~/ccminer

GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/CCminer-ARM-optimized/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].name")

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"

wget ${GITHUB_DOWNLOAD_URL} -P ~/ccminer

if [ -f ~/ccminer/config.json ]
then
  INPUT=
  while [ "$INPUT" != "y" ] && [ "$INPUT" != "n" ]
  do
    printf '"~/ccminer/config.json" already exists. Do you want to overwrite? (y/n) '
    read INPUT
    if [ "$INPUT" = "y" ]
    then
      echo "\noverwriting current \"~/ccminer/config.json\"\n"
      rm ~/ccminer/config.json
    elif [ "$INPUT" = "n" ]
    then
      echo "saving as \"~/ccminer/config.json.#\""
    else
      echo 'Invalid input. Please answer with "y" or "n".\n'
    fi
  done
fi
wget https://raw.githubusercontent.com/omgpizzatnt/Android-Mining/main/config.json -P ~/ccminer

if [ -f ~/ccminer/ccminer ]
then
  mv ~/ccminer/ccminer ~/ccminer/ccminer_old
fi
mv ~/ccminer/${GITHUB_DOWNLOAD_NAME} ~/ccminer/ccminer
chmod +x ~/ccminer/ccminer

cat << EOF > ~/ccminer/start.sh
#!/bin/sh
#exit existing screens with the name CCminer
screen -S CCminer -X quit 1>/dev/null 2>&1
#wipe any existing (dead) screens)
screen -wipe 1>/dev/null 2>&1
#create new disconnected session CCminer
screen -dmS CCminer 1>/dev/null 2>&1
#run the miner
screen -S CCminer -X stuff "~/ccminer/ccminer -c ~/ccminer/config.json\n" 1>/dev/null 2>&1
printf '\nMining started.\n'
printf '===============\n'
printf '\nManual:\n'
printf 'start: ~/.ccminer/start.sh\n'
printf 'stop: screen -X -S CCminer quit\n'
printf '\nmonitor mining: screen -x CCminer\n'
printf "exit monitor: 'CTRL-a' followed by 'd'\n\n"
EOF
chmod +x start.sh

echo "setup nearly complete."
echo "Edit the config with \"nano ~/ccminer/config.json\""

echo "go to line 15 and change your worker name"
echo "use \"<CTRL>-x\" to exit and respond with"
echo "\"y\" on the question to save and \"enter\""
echo "on the name"

echo "start the miner with \"cd ~/ccminer; ./start.sh\"."
