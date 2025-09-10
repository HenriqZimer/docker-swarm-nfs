# 🐳 Docker Swarm - Infraestrutura Completa de Serviços

![Docker Swarm](https://img.shields.io/badge/Docker-Swarm-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![TrueNAS](https://img.shields.io/badge/TrueNAS-NFS-0095D5?style=for-the-badge&logo=truenas&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)

## 📋 Visão Geral

Este projeto implementa uma infraestrutura completa de serviços usando **Docker Swarm**, com armazenamento centralizado via **TrueNAS NFS** e exposição segura através de **Cloudflare Tunnel**. A solução oferece alta disponibilidade, escalabilidade e gerenciamento simplificado de containers empresariais.

## 🏗️ Arquitetura da Infraestrutura

```
┌─────────────────────────────────────────────────────────────────┐
│                     🌐 CLOUDFLARE EDGE                          
│              (DDoS Protection, SSL, CDN, WAF)                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │ HTTPS (443/80)
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                 ☁️  CLOUDFLARE TUNNEL                           
│                    (Zero Trust Access)                          │
└─────────────────────┬───────────────────────────────────────────┘
                      │ Encrypted Tunnel
                      ▼
┌─────────────────────────────────────────────────────────────────────  ┐
│                     🐳 DOCKER SWARM CLUSTER                         
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   Grafana   │ │     N8N     │ │ Vaultwarden │ │ Portainer   │      │
│  │    :3000    │ │    :5678    │ │     :80     │ │    :9000    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   Zabbix    │ │   Harbor    │ │   Jenkins   │ │   ArgoCD    │      │
│  │    :8080    │ │    :9001    │ │    :9002    │ │    :9003    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘      │
│                                                                       │
│     📊 Monitoramento & Analytics    🚢 Container Registry            │
│     🔐 Gerenciamento de Secrets     ⚙️  CI/CD Automation             │
│     🔄 Workflow Automation          � GitOps Deployment              
└─────────────────────┬──────────────────────────────────────────────   ┘
                      │ NFS Mount
                      ▼
┌─────────────────────────────────────────────────────────────────  ┐
│                 💾 TRUENAS NFS SERVER                            
│                    192.168.1.105                                  │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              📁 Volumes Persistentes                          
│  │  • /grafana/app      - Dashboards & Plugins                 │  │
│  │  • /n8n/app          - Workflows & Executions               │  │
│  │  • /vaultwarden/app  - Senhas Criptografadas                │  │
│  │  • /portainer/app    - Configurações & Templates            │  │
│  │  • /zabbix/app       - Métricas & Histórico                 │  │
│  │  • /harbor/          - Imagens & Charts Registry            │  │
│  │  • /jenkins/home     - Jobs & Configurações CI/CD           │  │
│  │  • /argocd/config    - GitOps Configurations                │  │
│  │  • /*/db             - Bancos de Dados                      │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────  ┘
```

## 🛠️ Stack de Tecnologias

### 🐳 Orquestração de Containers
- **Docker Swarm**: Orquestração nativa do Docker
- **Docker Compose**: Definição declarativa de serviços
- **Docker Secrets**: Gerenciamento seguro de credenciais

### 📊 Serviços Principais
| Serviço | Versão | Porta | Descrição |
|---------|--------|-------|-----------|
| **Grafana** | latest | 3000 | Dashboards e visualização de dados |
| **N8N** | latest | 5678 | Automação de workflows e integrações |
| **Vaultwarden** | latest | 80 | Gerenciador de senhas (Bitwarden) |
| **Portainer** | latest | 9000 | Interface de gerenciamento Docker |
| **Zabbix** | 7.0-alpine | 8080 | Monitoramento de infraestrutura |
| **Cloudflared** | latest | - | Tunnel seguro para exposição |
| **Harbor** | v2.9.0 | 9001 | Registry Docker e Helm Charts |
| **Jenkins** | 2.426.1-lts | 9002 | CI/CD e automação de builds |
| **ArgoCD** | v2.8.4 | 9003 | GitOps e entrega contínua |

### 🗄️ Bancos de Dados
- **PostgreSQL 16-alpine**: Banco principal para todos os serviços
- Instâncias separadas por serviço para isolamento
- Backup automático e retenção configurável

### 💾 Armazenamento
- **TrueNAS Core/Scale**: Servidor NFS centralizado
- **ZFS**: Sistema de arquivos com snapshots e compressão
- **NFS v4**: Protocolo de rede para volumes persistentes

### 🌐 Rede e Segurança
- **Cloudflare Tunnel**: Exposição segura sem portas abertas
- **Cloudflare DNS**: Resolução de nomes e balanceamento
- **Zero Trust**: Controle de acesso granular
- **SSL/TLS**: Certificados automáticos via Cloudflare

## 🚀 Serviços Implementados

### 📊 Grafana - Dashboards e Analytics
- **URL**: `https://grafana.empresa.com.br`
- **Funcionalidades**:
  - Dashboards personalizáveis
  - Alertas em tempo real
  - Integração com múltiplas fontes de dados
  - Plugins e templates da comunidade
- **Autenticação**: SMTP + senha pré-configurada

### 🔄 N8N - Automação de Workflows
- **URL**: `https://n8n.empresa.com.br`
- **Funcionalidades**:
  - Automação visual de processos
  - Integração com 300+ APIs
  - Workflows baseados em triggers
  - Execução programada (cron)
- **Autenticação**: Basic Auth configurado

### 🔐 Vaultwarden - Gerenciador de Senhas
- **URL**: `https://vault.empresa.com.br`
- **Funcionalidades**:
  - Cofre de senhas criptografado
  - Sincronização entre dispositivos
  - Organizações e compartilhamento
  - Apps móveis e desktop
- **Autenticação**: Token admin + 2FA

### 🐳 Portainer - Gerenciamento Docker
- **URL**: `https://portainer.empresa.com.br`
- **Funcionalidades**:
  - Interface web para Docker Swarm
  - Deploy via templates
  - Monitoramento de recursos
  - Gestão de volumes e redes
- **Autenticação**: Hash bcrypt configurado

### 📈 Zabbix - Monitoramento Completo
- **URL**: `https://zabbix.empresa.com.br`
- **Funcionalidades**:
  - Monitoramento de infraestrutura
  - Coleta de métricas em tempo real
  - Alertas inteligentes
  - Discovery automático de recursos
- **Autenticação**: Admin/zabbix (alterar no primeiro acesso)

### 🚢 Harbor - Registry Docker e Helm
- **URL**: `https://harbor.empresa.com.br`
- **Funcionalidades**:
  - Registry Docker empresarial
  - Gerenciamento de Helm Charts
  - Escaneamento de vulnerabilidades
  - Políticas de segurança
  - Replicação de imagens
  - Interface web intuitiva
- **Autenticação**: admin/Harbor123!

### ⚙️ Jenkins - CI/CD Pipeline
- **URL**: `https://jenkins.empresa.com.br`
- **Funcionalidades**:
  - Pipelines de CI/CD automatizados
  - Integração com Git e Docker
  - Execução distribuída com agentes
  - Blue Ocean para visualização
  - +1800 plugins disponíveis
  - API REST completa
- **Autenticação**: admin/Jenkins123!

### 🚀 ArgoCD - GitOps Continuous Delivery
- **URL**: `https://argocd.empresa.com.br`
- **Funcionalidades**:
  - GitOps workflow nativo
  - Sincronização automática com Git
  - Rollback automático
  - Health checking de aplicações
  - RBAC granular
  - Multi-tenancy
- **Autenticação**: admin/ArgoCD123!

## 💾 Configuração TrueNAS NFS

### Preparação do Servidor NFS

#### 1. Configuração de Datasets
```bash
# No TrueNAS Web UI:
# Storage > Pools > [pool] > Add Dataset

# Datasets recomendados:
/mnt/pool/docker-swarm/
├── grafana/
├── n8n/
├── vaultwarden/
├── portainer/
├── zabbix/
├── harbor/
├── jenkins/
└── argocd/
```

#### 2. Configuração de Shares NFS
```bash
# Sharing > Unix (NFS) Shares
# Path: /mnt/pool/docker-swarm
# Network: 192.168.1.0/24
# Options: rw,sync,no_root_squash
```

#### 3. Serviços Necessários
```bash
# Services > NFS
# Enable: ✅ Start Automatically
# NFSv4: ✅ Enable
# Bind IP: 192.168.1.105
```

### Configuração no Docker Swarm

#### 1. Teste de Conectividade
```bash
# Testar montagem NFS
sudo mount -t nfs 192.168.1.105:/mnt/pool/docker-swarm /tmp/test
ls -la /tmp/test
sudo umount /tmp/test
```

#### 2. Volumes Docker
```yaml
# Exemplo de volume NFS no docker-compose.yml
volumes:
  grafana_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.105,rw,nfsvers=4
      device: ":/mnt/pool/docker-swarm/grafana"
```

## 🔐 Gerenciamento de Secrets

### Sistema Centralizado
O projeto utiliza um sistema centralizado de secrets com o arquivo `.env`:

```bash
# Estrutura de secrets por serviço
GRAFANA_ADMIN_PASSWORD=GrafanaAdmin123!
GRAFANA_DB_PASSWORD=GrafanaDB2024!
N8N_AUTH_PASSWORD=N8nAuth2024!
VAULTWARDEN_ADMIN_TOKEN=vault-admin-token-hash
PORTAINER_ADMIN_PASSWORD=portainer-bcrypt-hash
ZABBIX_DB_PASSWORD=ZabbixDB2024!
CLOUDFLARED_TUNNEL_TOKEN=cloudflare-tunnel-token
```

### Comandos Make para Secrets
```bash
# Ver todas as secrets
make secrets-show

# Ver secrets específicas
make secrets-show-grafana
make secrets-show-n8n

# Backup das secrets
make secrets-backup

# Sincronizar secrets com Docker
make secrets-sync
```

## 📦 Deploy e Gerenciamento

### Comandos Make Disponíveis

#### Deploy de Serviços
```bash
# Deploy completo
make deploy-all

# Deploy individual
make deploy-grafana
make deploy-n8n
make deploy-vaultwarden
make deploy-portainer
make deploy-zabbix
make deploy-cloudflared
```

#### Gerenciamento
```bash
# Parar serviços
make stop-all
make stop-grafana

# Ver logs
make logs-grafana
make logs-n8n

# Status do cluster
make status
```

#### Manutenção
```bash
# Backup completo
make backup

# Update de imagens
make update-all

# Limpeza do sistema
make cleanup
```

## 🌐 Configuração de DNS e Acesso

### URLs de Acesso
| Serviço | URL | Credenciais Padrão |
|---------|-----|-------------------|
| Grafana | https://grafana.empresa.com.br | admin / (ver secret) |
| N8N | https://n8n.empresa.com.br | Basic Auth |
| Vaultwarden | https://vault.empresa.com.br | Criar conta |
| Portainer | https://portainer.empresa.com.br | admin / (ver secret) |
| Zabbix | https://zabbix.empresa.com.br | Admin / zabbix |
| Harbor | https://harbor.empresa.com.br | admin / Harbor123! |
| Jenkins | https://jenkins.empresa.com.br | admin / Jenkins123! |
| ArgoCD | https://argocd.empresa.com.br | admin / ArgoCD123! |

## 🔧 Configuração Inicial

### 1. Pré-requisitos
```bash
# Docker Swarm inicializado
docker swarm init

# TrueNAS configurado com NFS
# Cloudflare com domínio adicionado
# Arquivo .env configurado
```

### 2. Clone e Setup
```bash
git clone https://github.com/HenriqZimer/docker-swarm.git
cd docker-swarm

# Configurar secrets
cp .env.example .env
nano .env

# Carregar secrets
make secrets-sync
```

### 3. Deploy Completo
```bash
# Deploy de todos os serviços
make deploy-all

# Verificar status
make status

# Verificar logs se necessário
make logs-grafana
```

## 🛡️ Segurança e Backup

### Recursos de Segurança
- ✅ **Cloudflare Protection**: DDoS, WAF, Rate Limiting
- ✅ **Zero Trust Access**: Controle granular de acesso
- ✅ **Docker Secrets**: Credenciais criptografadas
- ✅ **HTTPS Obrigatório**: SSL/TLS automático
- ✅ **Network Isolation**: Redes Docker isoladas
- ✅ **NFS Security**: Controle de acesso por IP

### Estratégia de Backup
```bash
# Backup automático via TrueNAS
# - Snapshots ZFS a cada hora
# - Retenção: 24 horas, 7 dias, 4 semanas
# - Replicação para storage externo

# Backup manual via Make
make backup  # Dados + configurações
make secrets-backup  # Apenas secrets
```

### Monitoramento
- **Zabbix**: Métricas de infraestrutura
- **Grafana**: Dashboards personalizados
- **Portainer**: Status dos containers
- **Cloudflare Analytics**: Tráfego e ataques

## 📊 Requisitos de Sistema

### Hardware Mínimo
- **CPU**: 2 cores / 4 threads
- **RAM**: 8GB (16GB recomendado)
- **Storage**: 60GB SSD local + NFS

### TrueNAS Requirements
- **CPU**: 2 cores mínimo
- **RAM**: 8GB (mais para ZFS cache)
- **Storage**: Pool ZFS com redundância

## 🔍 Troubleshooting

### Problemas Comuns

#### Serviços não iniciam
```bash
# Verificar secrets
make secrets-show

# Verificar logs
docker service logs [service_name]

# Verificar conectividade NFS
mount -t nfs 192.168.1.105:/mnt/pool/docker-swarm /tmp/test
```

#### Performance lenta
```bash
# Verificar recursos
docker stats

# Verificar storage NFS
df -h
iostat -x 1

# Verificar rede
iperf3 -c 192.168.1.105
```

#### Problemas de acesso
```bash
# Verificar tunnel Cloudflare
docker service logs cloudflared_tunnel

# Verificar DNS
nslookup grafana.empresa.com.br

# Verificar SSL
curl -I https://grafana.empresa.com.br
```

## 📚 Documentação Adicional

### READMEs Específicos
- [Grafana](/grafana/README.md) - Dashboards e visualização
- [N8N](/n8n/README.md) - Automação de workflows
- [Vaultwarden](/vaultwarden/README.md) - Gerenciador de senhas
- [Portainer](/portainer/README.md) - Gerenciamento Docker
- [Zabbix](/zabbix/README.md) - Monitoramento
- [Cloudflared](/cloudflared/README.md) - Tunnel seguro

### Links Úteis
- [Docker Swarm Docs](https://docs.docker.com/engine/swarm/)
- [TrueNAS Documentation](https://www.truenas.com/docs/)
- [Cloudflare Tunnel Guide](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🤝 Contribuição

Para contribuir com o projeto:

1. Fork o repositório
2. Crie uma branch feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**Desenvolvido com ❤️ usando Docker Swarm + TrueNAS + Cloudflare**
