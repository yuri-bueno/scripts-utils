#!/bin/bash
set -euo pipefail

# ===== Definindo cores =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

USER_NAME="${SUDO_USER:-$USER}"  # Usuário que executou o script
USER_HOME=$(eval echo "~$USER_NAME")

echo -e "${BLUE}==> Atualizando sistema e instalando dependências básicas...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential dkms perl wget htop zsh nginx ca-certificates lsb-release gnupg fonts-powerline

# === ZSH ===
echo -e "${BLUE}==> Definindo Zsh como shell padrão para $USER_NAME...${NC}"
chsh -s "$(which zsh)" "$USER_NAME"

echo -e "${BLUE}==> Instalando Oh My Zsh para $USER_NAME...${NC}"
export RUNZSH=no
sudo -u "$USER_NAME" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ZSH_CUSTOM=${ZSH_CUSTOM:-"$USER_HOME/.oh-my-zsh/custom"}

# === Powerlevel10k Prompt ===
echo -e "${BLUE}==> Instalando Powerlevel10k para $USER_NAME...${NC}"
sudo -u "$USER_NAME" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
sudo -u "$USER_NAME" sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$USER_HOME/.zshrc"

# === Zsh Autosuggestions ===
echo -e "${BLUE}==> Instalando Zsh Autosuggestions...${NC}"
sudo -u "$USER_NAME" git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# === Zsh Syntax Highlighting ===
echo -e "${BLUE}==> Instalando Zsh Syntax Highlighting...${NC}"
sudo -u "$USER_NAME" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# === Atualiza plugins no .zshrc ===
sudo -u "$USER_NAME" sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$USER_HOME/.zshrc"

# === Fonte Powerlevel10k recomendada ===
echo -e "${BLUE}==> Instalando fonte MesloLGS NF para Powerlevel10k...${NC}"
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.local/share/fonts"
sudo -u "$USER_NAME" curl -Lo "$USER_HOME/.local/share/fonts/MesloLGS_NF_Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
sudo -u "$USER_NAME" curl -Lo "$USER_HOME/.local/share/fonts/MesloLGS_NF_Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
sudo -u "$USER_NAME" curl -Lo "$USER_HOME/.local/share/fonts/MesloLGS_NF_Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
sudo -u "$USER_NAME" curl -Lo "$USER_HOME/.local/share/fonts/MesloLGS_NF_Bold_Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -fv

# === Docker + Docker Compose ===
echo -e "${BLUE}==> Instalando Docker e Docker Compose...${NC}"

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER_NAME"

sudo systemctl enable docker
sudo systemctl start docker

# === NGINX ===
echo -e "${BLUE}==> Ativando e habilitando NGINX...${NC}"
sudo systemctl enable nginx
sudo systemctl start nginx

# === Certbot (Let's Encrypt SSL) ===
echo -e "${BLUE}==> Instalando Certbot para Nginx...${NC}"
sudo apt install -y certbot python3-certbot-nginx

# === Gerar DH Param para maior segurança TLS (só se não existir) ===
if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
    echo -e "${YELLOW}==> Gerando DH Param (pode demorar um pouco)...${NC}"
    sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
fi

echo -e "${GREEN}==> Instalação concluída! Seu sistema está pronto para uso.${NC}"
