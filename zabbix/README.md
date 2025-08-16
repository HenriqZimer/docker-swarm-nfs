# 📊 Zabbix - Monitoramento de Infraestrutura

## 🔍 O que é o Zabbix?

O Zabbix é uma plataforma de monitoramento empresarial:

- Monitoramento de servidores e aplicações
- Coleta de métricas em tempo real
- Alertas inteligentes e escalation
- Dashboards e visualizações
- Descoberta automática de recursos
- Análise de tendências e capacidade
- API completa para integração

## 🏗️ Arquitetura do Deployment

```
┌─────────────────────┐    ┌─────────────────────┐
│   Zabbix Server     │    │   PostgreSQL DB     │
│   (Core Engine)     │◄──►│   (Métricas/Config) │
│   Port: 10051       │    │   Port: 5432        │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐    ┌─────────────────────┐
│   Zabbix Web        │    │   Zabbix Agent      │
│   (Interface)       │    │   (Coleta Dados)    │
│   Port: 8080        │◄──►│   Port: 10050       │
└─────────────────────┘    └─────────────────────┘
```

## 🔐 Configuração de Secrets

### Arquivo: `zabbix_db_password.txt`
**Descrição**: Senha do banco PostgreSQL do Zabbix
**Exemplo**:

```text
Zabbix2024!DatabaseP@ss
```

**Recomendações**:

- Senha forte com 15+ caracteres
- Combine maiúsculas, minúsculas, números e símbolos
- Evite caracteres que podem conflitar com SQL
- Use gerador de senhas seguro

**Formato de senha segura**:
```text
# Exemplo de senha forte
Zb$2024!Secure#DB&Pass
```

## 🚀 Comandos Úteis

```bash
# Ver secrets do Zabbix
make secrets-show-zabbix

# Acessar logs
make logs-zabbix

# Restart do serviço
make stop-zabbix && make deploy-zabbix

# Verificar conectividade com agents
zabbix_get -s [agent_host] -k system.cpu.load
```

## 🔧 Configuração Inicial

### 1. Primeiro Acesso
- URL: `https://zabbix.empresa.com.br/`
- Usuário padrão: `Admin`
- Senha padrão: `zabbix`

### 2. Setup Inicial Obrigatório
1. **Alterar senha do Admin**:
   - Administration > Users > Admin
   - Trocar senha padrão

2. **Configurar Timezone**:
   - Administration > General > GUI
   - Default timezone: Sua timezone

3. **Configurar Email**:
   - Administration > Media types > Email
   - Configure SMTP settings

### 3. Configurações Essenciais

#### Email/SMTP Configuration
```bash
# Via interface web:
# Administration > Media types > Email
# SMTP server: smtp.office365.com
# SMTP port: 587
# Security: STARTTLS
# Authentication: Username and password
```

#### Descoberta de Rede
```bash
# Configuration > Discovery rules
# Adicionar ranges de IP para descoberta automática
# Exemplo: 192.168.1.1-254
```

## 🖥️ Instalação de Agents

### Linux Agent (Ubuntu/Debian)
```bash
# Instalar repositório
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
sudo apt update

# Instalar agent
sudo apt install zabbix-agent2

# Configurar
sudo nano /etc/zabbix/zabbix_agent2.conf
# Server=IP_DO_ZABBIX_SERVER
# ServerActive=IP_DO_ZABBIX_SERVER
# Hostname=nome-do-servidor

# Iniciar serviço
sudo systemctl enable zabbix-agent2
sudo systemctl start zabbix-agent2
```

### Windows Agent
```powershell
# Download do site oficial
# https://www.zabbix.com/download_agents

# Configurar via interface gráfica ou:
# C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf
# Server=IP_DO_ZABBIX_SERVER
# ServerActive=IP_DO_ZABBIX_SERVER
# Hostname=nome-do-servidor
```

### Docker Agent
```yaml
version: '3.8'
services:
  zabbix-agent:
    image: zabbix/zabbix-agent2:alpine-7.0-latest
    environment:
      ZBX_SERVER_HOST: "IP_DO_ZABBIX_SERVER"
      ZBX_SERVER_PORT: "10051"
      ZBX_HOSTNAME: "docker-host"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /dev:/host/dev:ro
    privileged: true
    pid: host
```

## 📊 Templates e Monitoramento

### Templates Padrão
- **Linux by Zabbix agent**: Monitoramento básico Linux
- **Windows by Zabbix agent**: Monitoramento básico Windows
- **Docker by Zabbix agent 2**: Containers Docker
- **Apache by HTTP**: Servidor web Apache
- **MySQL by Zabbix agent**: Banco MySQL/MariaDB
- **PostgreSQL by Zabbix agent**: Banco PostgreSQL

### Métricas Importantes

#### Sistema Operacional
```bash
# CPU
system.cpu.load[all,avg1]
system.cpu.util[,user,avg1]

# Memória
vm.memory.size[total]
vm.memory.size[available]

# Disco
vfs.fs.size[/,total]
vfs.fs.size[/,used]

# Rede
net.if.in[eth0]
net.if.out[eth0]
```

#### Aplicações
```bash
# Processos
proc.num[nginx]
proc.cpu.util[nginx]

# Logs
log[/var/log/nginx/access.log,ERROR]

# Portas
net.tcp.listen[80]
net.tcp.listen[443]
```

## 🚨 Configuração de Alertas

### 1. Media Types (Email)
```bash
# Administration > Media types
# Criar novo media type para Email/Slack/SMS
```

### 2. Users e User Groups
```bash
# Administration > User groups
# Criar grupos: Admins, Operadores, etc.
# Definir permissões por grupo
```

### 3. Actions
```bash
# Configuration > Actions > Trigger actions
# Condições: Por severity, por host group, etc.
# Operações: Enviar email, executar script, etc.
```

### Exemplo de Trigger
```bash
# Nome: High CPU usage
# Expression: last(/Linux/system.cpu.util[,user,avg1])>80
# Severity: High
# Description: CPU usage is above 80% for 5 minutes
```

## 📈 Dashboards

### Dashboard Global
- **Problems**: Problemas atuais
- **System status**: Status geral do Zabbix
- **Host availability**: Disponibilidade dos hosts
- **Top triggers**: Triggers mais frequentes

### Dashboard Personalizado
```bash
# Monitoring > Dashboard
# Adicionar widgets:
# - Graph (CPU, Memory, Disk)
# - Plain text (Status)
# - Problems (Alertas)
# - Map (Topologia)
```

### Widgets Úteis
- **Graph**: Gráficos de métricas
- **Problems**: Lista de problemas
- **Data overview**: Visão geral de dados
- **Clock**: Relógio mundial
- **URL**: Embed de outras ferramentas

## 🔧 Manutenção e Performance

### Housekeeping
```sql
-- Configurar retenção de dados
-- Administration > General > Housekeeping

-- História: 90 dias
-- Trends: 365 dias
-- Events: 365 dias
-- Audit: 365 dias
```

### Otimização do Banco
```sql
-- Verificar tamanho das tabelas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Fazer VACUUM regularmente
VACUUM ANALYZE;
```

### Performance Tuning
```bash
# zabbix_server.conf
StartPollers=30
StartPingers=10
StartTrappers=10
StartHTTPPollers=5
CacheSize=128M
HistoryCacheSize=64M
TrendCacheSize=32M
```

## 🛡️ Segurança

### Autenticação
- **Frontend**: LDAP, SAML, HTTP auth
- **API**: Token-based authentication
- **Agent**: PSK (Pre-Shared Keys)

### Configuração PSK
```bash
# Gerar chave PSK
openssl rand -hex 32 > /etc/zabbix/zabbix_agent2.psk

# zabbix_agent2.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK_ID_001
TLSPSKFile=/etc/zabbix/zabbix_agent2.psk
```

### User Permissions
```bash
# Administration > User groups
# Definir permissões granulares:
# - Host groups
# - Template access
# - Frontend access
```

## 🔍 Troubleshooting

### Problemas Comuns

**Agent não conecta**:
```bash
# Verificar firewall
sudo ufw allow 10050/tcp

# Testar conectividade
telnet zabbix_server 10051

# Verificar logs
tail -f /var/log/zabbix/zabbix_agent2.log
```

**Performance lenta**:
```bash
# Verificar cache hits
# Administration > Queue
# Verificar items em fila

# Ajustar configurações
# Administration > General > Other
```

**Banco de dados crescendo**:
```bash
# Verificar housekeeping
# Administration > General > Housekeeping

# Executar limpeza manual
# Administration > Queue > Housekeeping
```

## 📚 Links Úteis

- [Documentação Oficial](https://www.zabbix.com/documentation/7.0/)
- [Zabbix Share](https://share.zabbix.com/) - Templates da comunidade
- [API Documentation](https://www.zabbix.com/documentation/7.0/en/manual/api)
- [Best Practices](https://www.zabbix.com/documentation/7.0/en/manual/appendix/best_practices)
- [Community Forum](https://www.zabbix.com/forum/)
