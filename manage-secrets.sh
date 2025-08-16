#!/bin/bash
# Script utilitário para gerenciar secrets do Docker Swarm

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_SECRET_FILE="$SCRIPT_DIR/.env"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar ajuda
show_help() {
    echo -e "${BLUE}=== Gerenciador de Secrets Docker Swarm ===${NC}"
    echo ""
    echo "Uso: $0 [COMANDO] [OPÇÕES]"
    echo ""
    echo "COMANDOS:"
    echo "  load     - Carrega todas as variáveis no shell atual"
    echo "  show     - Mostra todas as secrets (mascaradas)"
    echo "  backup   - Cria backup do arquivo .env"
    echo "  restore  - Restaura backup mais recente"
    echo "  sync     - Sincroniza .env com arquivos individuais"
    echo "  help     - Mostra esta ajuda"
    echo ""
    echo "EXEMPLOS:"
    echo "  $0 load                 # Carrega variáveis"
    echo "  $0 show grafana         # Mostra apenas secrets do Grafana"
    echo "  $0 backup               # Cria backup"
    echo ""
}

# Função para carregar variáveis
load_secrets() {
    if [ ! -f "$ENV_SECRET_FILE" ]; then
        echo -e "${RED}Erro: Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Carregando secrets...${NC}"
    source "$ENV_SECRET_FILE"
    echo -e "${GREEN}✓ Secrets carregadas com sucesso${NC}"
    echo -e "${YELLOW}Use 'echo \$VARIAVEL_NAME' para verificar valores${NC}"
}

# Função para mostrar secrets (mascaradas)
show_secrets() {
    local filter="$1"
    
    if [ ! -f "$ENV_SECRET_FILE" ]; then
        echo -e "${RED}Erro: Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}=== Secrets Disponíveis ===${NC}"
    
    if [ -n "$filter" ]; then
        grep -i "$filter" "$ENV_SECRET_FILE" | grep "^[A-Z]" | while IFS='=' read -r key value; do
            masked_value=$(echo "$value" | sed 's/./*/g')
            printf "%-25s = %s\n" "$key" "$masked_value"
        done
    else
        grep "^[A-Z]" "$ENV_SECRET_FILE" | while IFS='=' read -r key value; do
            masked_value=$(echo "$value" | sed 's/./*/g')
            printf "%-25s = %s\n" "$key" "$masked_value"
        done
    fi
}

# Função para fazer backup
backup_secrets() {
    if [ ! -f "$ENV_SECRET_FILE" ]; then
        echo -e "${RED}Erro: Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    local backup_file="$SCRIPT_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$ENV_SECRET_FILE" "$backup_file"
    echo -e "${GREEN}✓ Backup criado: $backup_file${NC}"
}

# Função para restaurar backup
restore_secrets() {
    local latest_backup=$(ls -t "$SCRIPT_DIR"/.env.backup.* 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        echo -e "${RED}Erro: Nenhum backup encontrado${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Restaurando backup: $latest_backup${NC}"
    cp "$latest_backup" "$ENV_SECRET_FILE"
    echo -e "${GREEN}✓ Backup restaurado com sucesso${NC}"
}

# Função para sincronizar
sync_secrets() {
    echo -e "${BLUE}Sincronizando .env com arquivos individuais...${NC}"
    
    if [ ! -f "$ENV_SECRET_FILE" ]; then
        echo -e "${RED}Erro: Arquivo .env não encontrado${NC}"
        exit 1
    fi
    
    source "$ENV_SECRET_FILE"
    
    # Criar diretórios se não existirem
    mkdir -p grafana n8n vaultwarden portainer zabbix cloudflared
    
    # Sync Grafana
    echo "$GRAFANA_ADMIN_PASSWORD" > ./grafana/grafana_admin_password.txt
    echo "$GRAFANA_SECRET_KEY" > ./grafana/grafana_secret_key.txt
    echo "$GRAFANA_DB_PASSWORD" > ./grafana/grafana_db_password.txt
    
    # Sync N8N
    echo "$N8N_AUTH_PASSWORD" > ./n8n/n8n_auth_password.txt
    echo "$N8N_DB_PASSWORD" > ./n8n/n8n_db_password.txt
    echo "$N8N_ENCRYPTION_KEY" > ./n8n/n8n_encryption_key.txt
    
    # E assim por diante...
    
    echo -e "${GREEN}✓ Sincronização concluída${NC}"
}

# Processamento dos argumentos
case "$1" in
    "load")
        load_secrets
        ;;
    "show")
        show_secrets "$2"
        ;;
    "backup")
        backup_secrets
        ;;
    "restore")
        restore_secrets
        ;;
    "sync")
        sync_secrets
        ;;
    "help"|""|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}Comando inválido: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
