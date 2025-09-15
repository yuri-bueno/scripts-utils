#!/bin/bash
set -e

echo "==> Atualizando sistema e instalando dependências básicas..."
sudo apt update
sudo apt install -y git curl build-essential dkms perl wget fonts-powerline htop zsh nginx software-properties-common

# === ZSH ===
echo "==> Definindo Zsh como shell padrão..."
chsh -s $(which zsh)

# === Oh My Zsh ===
echo "==> Instalando Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# === Spaceship Prompt ===
echo "==> Instalando Spaceship Prompt..."
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="spaceship"/' ~/.zshrc

# === Zsh Autosuggestions ===
echo "==> Instalando Zsh Autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# === Zsh Syntax Highlighting ===
echo "==> Instalando Zsh Syntax Highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# === Atualiza plugins no .zshrc ===
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# === Fonte Powerline ===
echo "==> Instalando fonte Ubuntu Mono Powerline..."
mkdir -p ~/.fonts
git clone https://github.com/pdf/ubuntu-mono-powerline-ttf.git ~/.fonts/ubuntu-mono-powerline-ttf
fc-cache -fv

# === Docker + Docker Compose ===
echo "==> Instalando Docker e Docker Compose..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker

# === NGINX ===
echo "==> Ativando e habilitando NGINX..."
sudo systemctl enable nginx
sudo systemctl start nginx

# === Certbot (Let's Encrypt SSL) ===
echo "==> Instalando Certbot para Nginx..."
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
echo "Para gerar um certificado SSL para seu domínio:"

echo "==> Instalação concluída!"
echo "Zsh, Docker, Docker Compose, Nginx, htop e Certbot prontos para uso."
