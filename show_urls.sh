#!/bin/bash

# 🌐 Script para mostrar URLs de acesso de todos os serviços
# Autor: Docker Swarm Setup
# Data: $(date)

echo "🌐 ================================================"
echo "   URLS DE ACESSO DOS SERVIÇOS"
echo "   Docker Swarm Infrastructure"
echo "================================================"
echo ""

# Verificar se está no Swarm
if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
    echo "❌ ERRO: Docker Swarm não está ativo!"
    exit 1
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 MONITORAMENTO & ANALYTICS${NC}"
echo "=================================="
echo -e "• ${GREEN}Grafana${NC}     - ${CYAN}http://localhost:3000${NC}     - admin / (ver grafana_admin_password.txt)"
echo -e "• ${GREEN}Zabbix${NC}      - ${CYAN}http://localhost:8080${NC}     - Admin / zabbix"
echo ""

echo -e "${BLUE}🔄 AUTOMAÇÃO & CI/CD${NC}"
echo "=================================="
echo -e "• ${GREEN}N8N${NC}         - ${CYAN}http://localhost:5678${NC}     - Basic Auth (ver secrets)"
echo -e "• ${GREEN}Jenkins${NC}     - ${CYAN}http://localhost:9002${NC}     - admin / Jenkins123!"
echo -e "• ${GREEN}ArgoCD${NC}      - ${CYAN}http://localhost:9003${NC}     - admin / ArgoCD123!"
echo -e "• ${GREEN}ArgoCD HTTPS${NC} - ${CYAN}https://localhost:9443${NC}    - admin / ArgoCD123!"
echo ""

echo -e "${BLUE}🔒 SEGURANÇA & GESTÃO${NC}"
echo "=================================="
echo -e "• ${GREEN}Vaultwarden${NC} - ${CYAN}http://localhost:80${NC}       - Criar conta"
echo -e "• ${GREEN}Harbor${NC}      - ${CYAN}http://localhost:9001${NC}     - admin / Harbor123!"
echo ""

echo -e "${BLUE}🐳 GERENCIAMENTO${NC}"
echo "=================================="
echo -e "• ${GREEN}Portainer${NC}   - ${CYAN}http://localhost:9000${NC}     - admin / (ver secret)"
echo ""

echo -e "${BLUE}🎬 MÍDIA & ENTRETENIMENTO${NC}"
echo "=================================="
echo -e "• ${GREEN}Jellyfin${NC}     - ${CYAN}http://localhost:8096${NC}      - Setup inicial via interface web"
echo -e "• ${GREEN}qBittorrent${NC} - ${CYAN}http://localhost:8080${NC}     - admin / (ver logs para senha inicial)"
echo ""

echo -e "${BLUE}📋 STATUS DOS SERVIÇOS${NC}"
echo "=================================="

# Verificar status dos serviços
services=(
    "grafana"
    "zabbix" 
    "n8n"
    "vaultwarden"
    "portainer"
    "cloudflared"
    "harbor"
    "jenkins"
    "argocd"
    "jellyfin"
    "qbittorrent"
)

for service in "${services[@]}"; do
    if docker stack services "$service" &>/dev/null; then
        replicas=$(docker service ls --filter name="$service" --format "{{.Replicas}}" | head -1)
        if [[ "$replicas" =~ ^[1-9] ]]; then
            echo -e "• ${GREEN}✅ $service${NC} - $replicas"
        else
            echo -e "• ${RED}❌ $service${NC} - $replicas"
        fi
    else
        echo -e "• ${RED}❌ $service${NC} - Não deployado"
    fi
done

echo ""
echo -e "${YELLOW}💡 DICAS:${NC}"
echo "• Use 'make status' para ver status detalhado"
echo "• Use 'make logs-<service>' para ver logs específicos"
echo "• Use 'make deploy-<service>' para deployar serviço específico"
echo "• Use 'make stop-<service>' para parar serviço específico"
echo ""

echo -e "${PURPLE}🔗 INTEGRAÇÃO ENTRE SERVIÇOS:${NC}"
echo "• Jenkins → Harbor (Push de imagens)"
echo "• Jenkins → ArgoCD (Deploy automático)" 
echo "• ArgoCD → Harbor (Pull de imagens)"
echo "• Grafana ← Zabbix (Dashboards de monitoramento)"
echo "• N8N ↔ Todos (Automação e integrações)"
echo "• qBittorrent → Jellyfin (Downloads automáticos para biblioteca de mídia)"
echo ""

echo -e "${CYAN}🌍 Para expor via Cloudflare Tunnel:${NC}"
echo "Adicione no arquivo cloudflared/docker-compose.yml:"
echo "  - hostname: harbor.seudominio.com"
echo "    service: http://harbor_proxy:8080"
echo "  - hostname: jenkins.seudominio.com"  
echo "    service: http://jenkins_jenkins:8080"
echo "  - hostname: argocd.seudominio.com"
echo "    service: http://argocd_argocd-server:8080"
echo "  - hostname: jellyfin.seudominio.com"
echo "    service: http://jellyfin_app:8096"
echo "  - hostname: qbittorrent.seudominio.com"
echo "    service: http://qbittorrent_app:8080"
echo ""
