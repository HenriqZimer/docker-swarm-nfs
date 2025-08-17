# ☁️ Cloudflared - Tunnel Seguro

## 🔍 O que é o Cloudflared?

O Cloudflared é o cliente oficial da Cloudflare para tunnels:

- Conecta serviços locais à internet via Cloudflare
- Protege contra ataques DDoS automaticamente
- Elimina necessidade de portas abertas no firewall
- Fornece SSL/TLS automático
- Load balancing e failover
- Zero Trust Network Access
- Integração com Cloudflare Access

## 🏗️ Arquitetura do Deployment

```
┌─────────────────────┐    ┌─────────────────────┐
│   Cloudflared       │    │   Cloudflare Edge   │
│   (Tunnel Client)   │◄──►│   (Global Network)  │
│   Port: interno     │    │   443/80 público    │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│   Serviços Locais   │
│   (Grafana, N8N,    │
│   Portainer, etc.)  │
└─────────────────────┘
```

## 🔐 Configuração de Secrets

### Arquivo: `cloudflared_tunnel_token.txt`
**Descrição**: Token de autenticação para o tunnel do Cloudflare
**Exemplo**:

```text
eyJhIjoiNzM4NGNkNzMzY2I0Nzk2MWY3ODJiZGY0ZWE5MjkyMWYiLCJ0IjoiNjc4OWZlYzMtZjA4Mi00ZWJlLWI4MzItYjg5ZGI5OWE0NDgwIiwicyI6Ik1qSTFNVFF5TldNdE5EZG1ZUzAwTVRsbE5UazNOMlZrWVRKbE16YzBOV1E9In0%3D
```

**Como obter**:

### 1. Via Cloudflare Dashboard (Recomendado)
```bash
# 1. Acesse: https://dash.cloudflare.com/
# 2. Selecione seu domínio
# 3. Zero Trust > Access > Tunnels
# 4. Create a tunnel
# 5. Nome: "docker-swarm-tunnel"
# 6. Copie o token gerado
```

### 2. Via CLI (Avançado)
```bash
# Instalar cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Login
cloudflared tunnel login

# Criar tunnel
cloudflared tunnel create docker-swarm-tunnel

# Obter token
cloudflared tunnel token docker-swarm-tunnel
```

### Configuração do Tunnel

**Exemplo de configuração no dashboard**:
```yaml
# Public hostnames
grafana.empresa.com.br -> http://grafana:3000
n8n.empresa.com.br -> http://n8n_app:5678
portainer.empresa.com.br -> https://portainer:9443
vault.empresa.com.br -> http://vaultwarden:80
zabbix.empresa.com.br -> http://zabbix_web:8080
```

## 🚀 Comandos Úteis

```bash
# Ver secrets do Cloudflared
make secrets-show-cloudflared

# Acessar logs
make logs-cloudflared

# Restart do serviço
make stop-cloudflared && make deploy-cloudflared

# Verificar status do tunnel
docker exec cloudflared_tunnel cloudflared tunnel info
```

## 🔧 Configuração Inicial

### 1. Pré-requisitos
- Conta na Cloudflare (gratuita)
- Domínio adicionado na Cloudflare
- DNS gerenciado pela Cloudflare

### 2. Criar Tunnel
```bash
# Via dashboard:
# 1. Zero Trust > Access > Tunnels
# 2. Create a tunnel
# 3. Connector: Cloudflared
# 4. Name: docker-swarm
# 5. Save tunnel
```

### 3. Configurar Public Hostnames
```bash
# Para cada serviço:
# Public hostname: grafana.empresa.com.br
# Service: HTTP
# URL: http://grafana_app:3000
```

### Exemplo completo de configuração:
| Subdomain | Service Type | URL |
|-----------|--------------|-----|
| grafana.empresa.com.br | HTTP | http://grafana_app:3000 |
| n8n.empresa.com.br | HTTP | http://n8n_app:5678 |
| portainer.empresa.com.br | HTTP | http://portainer_app:9000 |
| vault.empresa.com.br | HTTP | http://vaultwarden_app:80 |
| zabbix.empresa.com.br | HTTP | http://zabbix_app:8080 |

## 🛡️ Segurança e Zero Trust

### Cloudflare Access
```bash
# Proteger aplicações com autenticação
# Zero Trust > Access > Applications
# Add application > Self-hosted
# Application domain: grafana.empresa.com.br
# Policy: Define quem pode acessar
```

## 📊 Monitoramento e Analytics

### Cloudflare Analytics
```bash
# Dashboard > Analytics & Logs
# Requests: Total de requisições
# Bandwidth: Tráfego consumido
# Threats: Ataques bloqueados
# Performance: Métricas de velocidade
```

### Logs em Tempo Real
```bash
# Verificar logs do cloudflared
docker service logs -f cloudflared_tunnel

# Verificar conectividade
docker exec cloudflared_tunnel cloudflared tunnel info

# Status das conexões
curl -H "CF-Access-Client-Id: [id]" \
     -H "CF-Access-Client-Secret: [secret]" \
     https://grafana.empresa.com.br/api/health
```

## 🚨 Troubleshooting

### Problemas Comuns

**Tunnel não conecta**:
```bash
# Verificar token
echo $TUNNEL_TOKEN | base64 -d

# Verificar DNS
nslookup grafana.empresa.com.br

# Verificar logs
docker service logs cloudflared_tunnel
```

**Erro 522 (Connection Timed Out)**:
```bash
# Verificar serviço local
curl -I http://grafana_app:3000

# Verificar rede Docker
docker network ls
docker network inspect docker-swarm_default
```

## 📚 Links Úteis

- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [Cloudflare Dashboard](https://dash.cloudflare.com/)
- [Status Page](https://www.cloudflarestatus.com/)
- [Community Forum](https://community.cloudflare.com/)
- [Cloudflared Releases](https://github.com/cloudflare/cloudflared/releases)
