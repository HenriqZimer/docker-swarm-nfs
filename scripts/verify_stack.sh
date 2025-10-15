#!/bin/bash

# Script de Verificação Completa da Stack Docker Swarm
# Verifica configuração de redes, labels, secrets e documentação

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SERVICES=(
    "traefik"
    "cloudflared"
    "grafana"
    "n8n"
    "portainer"
    "vaultwarden"
    "photoprism"
    "wordpress"
    "jellyfin"
    "qbittorrent"
    "romm"
    "zabbix"
)

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  VERIFICAÇÃO COMPLETA - DOCKER SWARM${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 1. VERIFICAR REDES
echo -e "${BLUE}[1/6] Verificando Redes Overlay...${NC}"
echo ""

EXPECTED_NETWORKS=("traefik_proxy-network" "cloudflared_proxy-network")

for network in "${EXPECTED_NETWORKS[@]}"; do
    if docker network ls --filter name="$network" --format '{{.Name}}' | grep -q "^${network}$"; then
        echo -e "${GREEN}✓${NC} Rede $network existe"
    else
        echo -e "${RED}✗${NC} Rede $network NÃO EXISTE"
    fi
done

echo ""

# 2. VERIFICAR CONFIGURAÇÃO DE REDES NOS SERVIÇOS
echo -e "${BLUE}[2/6] Verificando Configuração de Redes nos Serviços...${NC}"
echo ""

for service in "${SERVICES[@]}"; do
    compose_file="/home/henriqzimer/docker-swarm/$service/docker-compose.yml"
    
    if [ ! -f "$compose_file" ]; then
        echo -e "${YELLOW}⚠${NC}  $service: docker-compose.yml não encontrado"
        continue
    fi
    
    # Verificar se tem as redes externas definidas
    has_traefik=$(grep -c "name: traefik_proxy-network" "$compose_file" 2>/dev/null || echo 0)
    has_cloudflared=$(grep -c "name: cloudflared_proxy-network" "$compose_file" 2>/dev/null || echo 0)
    
    if [ "$service" = "traefik" ] || [ "$service" = "cloudflared" ]; then
        echo -e "${BLUE}→${NC} $service: Infraestrutura base"
    elif [ $has_traefik -gt 0 ] && [ $has_cloudflared -gt 0 ]; then
        echo -e "${GREEN}✓${NC} $service: Redes configuradas corretamente"
    elif [ $has_traefik -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC}  $service: Tem traefik-proxy mas falta cloudflared-proxy"
    else
        echo -e "${RED}✗${NC} $service: Faltam redes configuradas"
    fi
done

echo ""

# 3. VERIFICAR LABELS DO TRAEFIK
echo -e "${BLUE}[3/6] Verificando Labels do Traefik...${NC}"
echo ""

TRAEFIK_SERVICES=("grafana" "n8n" "portainer" "vaultwarden" "photoprism" "wordpress" "jellyfin" "qbittorrent" "romm" "zabbix")

for service in "${TRAEFIK_SERVICES[@]}"; do
    compose_file="/home/henriqzimer/docker-swarm/$service/docker-compose.yml"
    
    if [ ! -f "$compose_file" ]; then
        continue
    fi
    
    # Verificar labels essenciais
    has_enable=$(grep -c "traefik.enable=true" "$compose_file" 2>/dev/null || echo 0)
    has_router=$(grep -c "traefik.http.routers.$service.rule=" "$compose_file" 2>/dev/null || echo 0)
    has_entrypoint=$(grep -c "traefik.http.routers.$service.entrypoints=websecure" "$compose_file" 2>/dev/null || echo 0)
    has_tls=$(grep -c "traefik.http.routers.$service.tls.certresolver=cloudflare" "$compose_file" 2>/dev/null || echo 0)
    has_port=$(grep -c "traefik.http.services.$service.loadbalancer.server.port=" "$compose_file" 2>/dev/null || echo 0)
    
    errors=0
    msg=""
    
    [ $has_enable -eq 0 ] && errors=$((errors+1)) && msg="${msg}enable "
    [ $has_router -eq 0 ] && errors=$((errors+1)) && msg="${msg}router "
    [ $has_entrypoint -eq 0 ] && errors=$((errors+1)) && msg="${msg}entrypoint "
    [ $has_tls -eq 0 ] && errors=$((errors+1)) && msg="${msg}tls "
    [ $has_port -eq 0 ] && errors=$((errors+1)) && msg="${msg}port "
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $service: Labels completos"
    else
        echo -e "${RED}✗${NC} $service: Faltam labels: $msg"
    fi
done

echo ""

# 4. VERIFICAR SECRETS
echo -e "${BLUE}[4/6] Verificando Secrets...${NC}"
echo ""

for service in "${SERVICES[@]}"; do
    service_dir="/home/henriqzimer/docker-swarm/$service"
    compose_file="$service_dir/docker-compose.yml"
    
    if [ ! -f "$compose_file" ]; then
        continue
    fi
    
    # Extrair secrets definidos no compose
    secrets=$(grep -A 100 "^secrets:" "$compose_file" | grep "file:" | awk '{print $3}' | sort -u 2>/dev/null || echo "")
    
    if [ -z "$secrets" ]; then
        echo -e "${BLUE}→${NC} $service: Sem secrets configurados"
        continue
    fi
    
    missing=0
    for secret_file in $secrets; do
        full_path="$service_dir/${secret_file#./}"
        if [ ! -f "$full_path" ]; then
            if [ $missing -eq 0 ]; then
                echo -e "${RED}✗${NC} $service: Secrets faltando:"
            fi
            echo -e "  ${RED}→${NC} $secret_file"
            missing=$((missing+1))
        fi
    done
    
    if [ $missing -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $service: Todos os secrets existem"
    fi
done

echo ""

# 5. VERIFICAR DOCUMENTAÇÃO
echo -e "${BLUE}[5/6] Verificando Documentação...${NC}"
echo ""

for service in "${SERVICES[@]}"; do
    readme="/home/henriqzimer/docker-swarm/$service/README.md"
    
    if [ -f "$readme" ]; then
        # Verificar se tem seções básicas
        has_title=$(grep -c "^#" "$readme" 2>/dev/null || echo 0)
        has_deploy=$(grep -ci "deploy" "$readme" 2>/dev/null || echo 0)
        
        if [ $has_title -gt 0 ] && [ $has_deploy -gt 0 ]; then
            echo -e "${GREEN}✓${NC} $service: README.md existe e tem conteúdo"
        else
            echo -e "${YELLOW}⚠${NC}  $service: README.md existe mas pode estar incompleto"
        fi
    else
        echo -e "${RED}✗${NC} $service: README.md NÃO EXISTE"
    fi
done

echo ""

# 6. VERIFICAR SERVIÇOS RUNNING
echo -e "${BLUE}[6/6] Verificando Serviços Ativos...${NC}"
echo ""

echo -e "${BLUE}Serviços em execução:${NC}"
docker service ls --format 'table {{.Name}}\t{{.Replicas}}\t{{.Image}}' | head -20

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  VERIFICAÇÃO COMPLETA${NC}"
echo -e "${BLUE}============================================${NC}"
