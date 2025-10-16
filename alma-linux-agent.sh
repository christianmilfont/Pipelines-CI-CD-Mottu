
# Execute em sua VM Linux Free

# Organização
AZDEVOPS_URL="https://dev.azure.com/MOTTU-CICD/"
# PAT
AZDEVOPS_TOKEN=""
#
AGENT_POOL="Default"

# Nome de usuário que executará o agente (deve já existir na VM) - Altere conforme necessidade
AGENT_USER="admlnx"

# Diretório de instalação do agente
AGENT_DIR="/home/$AGENT_USER/myagent"

# URL do pacote do agente (ajuste versão se necessário) - updt 2025 Outubro
AGENT_PACKAGE_URL="https://download.agent.dev.azure.com/agent/4.263.0/vsts-agent-linux-x64-4.263.0.tar.gz"

set -e

# 1. Atualizar sistema
echo "-- Atualizando sistema..."
sudo dnf update -y

# 2. Instalar ferramentas
echo "-- Instalando ferramentas e algumas dependências do Agente (pré load)..."
sudo dnf install -y curl wget tar git jq libicu unzip nano openssl krb5-libs zlib

# 3. Criar diretório do agente e ajustar permissões
echo "-- Preparando diretório do agente em $AGENT_DIR..."
sudo mkdir -p "$AGENT_DIR"
sudo chown "$AGENT_USER":"$AGENT_USER" "$AGENT_DIR"

# 4. Baixar e extrair o agente
echo "-- Baixando Azure DevOps Agent..."
sudo -u "$AGENT_USER" wget -q "$AGENT_PACKAGE_URL" -O "$AGENT_DIR/agent.tar.gz"
echo "-- Extraindo pacote..."
sudo -u "$AGENT_USER" tar xzf "$AGENT_DIR/agent.tar.gz" -C "$AGENT_DIR"
sudo -u "$AGENT_USER" rm "$AGENT_DIR/agent.tar.gz"

# 5. Instalar dependências do agente
echo "-- Ajustando permissões dos arquivos..."
sudo chown -R "$AGENT_USER":"$AGENT_USER" "$AGENT_DIR"

echo "-- Instalando dependências do agente..."
cd "$AGENT_DIR"
sudo ./bin/installdependencies.sh

# 6. Configurar o agente no modo não interativo
# Esse comando configura o agente de build de forma não interativa (sem perguntas na tela), se conectando ao seu Azure DevOps usando o token de acesso pessoal (PAT) e:
# - Registra automaticamente o agente na organização e pool definidos (MOTTU-CICD, Default).
# - Usa o hostname da máquina + "-agent" como nome do agente.

Cria o agente diretamente na interface do DevOps, dentro do pool escolhido.
echo "-- Configurando agente como $AGENT_USER..."
sudo -u "$AGENT_USER" bash -c "
  cd \"$AGENT_DIR\" &&
  ./config.sh \
    --unattended \
    --url \"$AZDEVOPS_URL\" \
    --auth PAT \
    --token \"$AZDEVOPS_TOKEN\" \
    --pool \"$AGENT_POOL\" \
    --agent \"$(hostname)-agent\" \
    --acceptTeeEula \
    --work \"_work\" \
    --replace
"

# 7. Instalar e iniciar como serviço systemd
echo "-- Instalando como serviço systemd..."
sudo ./svc.sh install
echo "-- Iniciando serviço..."
sudo ./svc.sh start

# 8. Verificar status
echo "-- Verificando status do serviço..."
sleep 3
sudo ./svc.sh status

# 9. Informações finais
echo
echo "=== CONFIGURAÇÃO CONCLUÍDA COM SUCESSO ==="
echo "Diretório do agente: $AGENT_DIR"
echo "Pool: $AGENT_POOL"
echo
echo "Comandos de gerenciamento:"
echo "  cd $AGENT_DIR && sudo ./svc.sh status     # Ver status"
echo "  cd $AGENT_DIR && sudo ./svc.sh stop       # Parar"
echo "  cd $AGENT_DIR && sudo ./svc.sh start      # Iniciar"
echo "  cd $AGENT_DIR && sudo ./svc.sh restart    # Reiniciar"
echo
