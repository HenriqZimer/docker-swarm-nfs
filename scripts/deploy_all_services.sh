#!/bin/bash

# 🚀 Script para deploy de todos os serviços com Docker Secrets
# Autor: Docker Swarm Setup
# Data: $(date)

set -e  # Parar em caso de erro

echo "🚀 ========================================"
echo "   DEPLOYANDO TODOS OS SERVIÇOS"
echo "   COM DOCKER SECRETS"
echo "========================================="
echo ""

# Verificar se está no Swarm
if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
    echo "❌ ERRO: Docker Swarm não está ativo!"
    exit 1
fi

# Verificar se secrets existem (não mais necessário com secrets locais)
echo "🔍 Verificando diretórios dos serviços..."

services=(
    "grafana"
    "zabbix" 
    "n8n"
    "vaultwarden"
    "portainer"
    "cloudflared"
    "jellyfin"
    "qbittorrent"
)

missing_services=()
for service in "${services[@]}"; do
    if [ ! -d "$service" ] || [ ! -f "$service/docker-compose.yml" ]; then
        missing_services+=("$service")
    fi
done

if [ ${#missing_services[@]} -gt 0 ]; then
    echo "❌ ERRO: Serviços faltando:"
    for service in "${missing_services[@]}"; do
        echo "   - $service (diretório ou docker-compose.yml não encontrado)"
    done
    echo ""
    exit 1
fi

echo "✅ Todos os serviços estão disponíveis"
echo ""

# Função para deploy com verificação
deploy_service() {
    local service_name=$1
    local description=$2
    
    echo "📦 Deployando $description..."
    
    # Verificar se o diretório do serviço existe (pasta pai do scripts)
    local base_dir="$(cd "$(dirname "$0")/.." && pwd)"
    cd "$base_dir"
    
    if [ ! -d "$service_name" ]; then
        echo "❌ ERRO: Diretório $service_name não encontrado"
        return 1
    fi
    
    cd "$service_name"
    
    if [ ! -f "docker-compose.yml" ]; then
        echo "❌ ERRO: docker-compose.yml não encontrado em $service_name"
        return 1
    fi
    
    docker stack deploy -c docker-compose.yml "$service_name"
    
    # Aguardar um pouco para o serviço iniciar
    sleep 3
    
    # Verificar se o serviço foi criado
    if docker service ls --filter "name=${service_name}_" --format "{{.Name}}" | grep -q "${service_name}_"; then
        echo "✅ $description deployado com sucesso"
    else
        echo "⚠️  $description pode ter problemas - verifique os logs"
    fi
    
    # Voltar para o diretório base
    cd "$base_dir"
    
    echo ""
}

echo "🚀 Iniciando deploy de todos os serviços..."
echo ""

# Deploy na ordem correta (dependências primeiro)
deploy_service "grafana" "Grafana (Monitoring)"
deploy_service "zabbix" "Zabbix (Monitoring)"
deploy_service "n8n" "N8N (Automation)"
deploy_service "vaultwarden" "Vaultwarden (Password Manager)"
deploy_service "portainer" "Portainer (Container Manager)"
deploy_service "cloudflared" "Cloudflared (Tunnel)"
deploy_service "jellyfin" "Jellyfin (Media Server)"
deploy_service "qbittorrent" "qBittorrent (Torrent Client)"

echo "🎉 ========================================"
echo "   DEPLOY CONCLUÍDO!"
echo "========================================="
echo ""

echo ""
echo "🔍 Verificando logs para possíveis erros:"
echo "Use os comandos abaixo para verificar logs específicos:"
echo ""
echo "docker service logs grafana_app"
echo "docker service logs grafana_db"
echo "docker service logs zabbix_app"
echo "docker service logs zabbix_server"
echo "docker service logs zabbix_db"
echo "docker service logs n8n_app"
echo "docker service logs vaultwarden_app"
echo "docker service logs portainer_app"
echo "docker service logs cloudflared_tunnel"
echo "docker service logs jellyfin_app"
echo "docker service logs qbittorrent_app"
echo ""

echo "📊 Status dos serviços:"
docker service ls

echo "✅ Deploy completo! Verifique os serviços nos domínios configurados."
