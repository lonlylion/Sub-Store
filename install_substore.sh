#!/bin/bash

# 获取本机 IP
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# 让用户输入端口号，默认是 25500
read -p "Please enter the port number you want to use (default: 25500): " PORT
PORT=${PORT:-25500}

# 更新系统包
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 和 npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# 安装 Git
echo "Installing Git..."
sudo apt install -y git

# 克隆新的 Sub-Store 仓库
echo "Cloning Sub-Store repository from the new URL..."
cd /opt
sudo git clone https://github.com/sub-store-org/Sub-Store.git
cd Sub-Store

# 安装项目依赖
echo "Installing project dependencies..."
sudo npm install

# 提示用户输入自定义信息
read -p "Please enter your secret key (default: your_secret_key): " SECRET_KEY
SECRET_KEY=${SECRET_KEY:-your_secret_key}

read -p "Please enter your access token (default: your_token): " ACCESS_TOKEN
ACCESS_TOKEN=${ACCESS_TOKEN:-your_token}

# 创建配置文件
echo "Creating configuration file..."
cat <<EOL | sudo tee config.json
{
  "port": $PORT,
  "secret": "$SECRET_KEY",
  "delayTime": 1000,
  "token": "$ACCESS_TOKEN",
  "isPreview": true
}
EOL

# 安装 pm2
echo "Installing pm2..."
sudo npm install -g pm2

# 启动 Sub-Store 服务
echo "Starting Sub-Store with pm2..."
pm2 start app.js --name sub-store

# 保存 pm2 配置和启用自启动
echo "Configuring pm2 to start on system boot..."
pm2 save
pm2 startup

# 开放防火墙端口
echo "Opening port $PORT..."
sudo ufw allow $PORT

# 启用防火墙
echo "Enabling UFW (firewall)..."
sudo ufw enable

# 显示访问信息
echo "Sub-Store has been successfully installed and is running."
echo "You can access it via http://$IP_ADDRESS:$PORT"
