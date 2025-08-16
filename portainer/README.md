# 🐳 Portainer - Gerenciamento de Containers

## 🔍 O que é o Portainer?

O Portainer é uma plataforma de gerenciamento para Docker e Kubernetes:

- Interface web para gerenciar containers
- Visualização de recursos e estatísticas
- Deploy de aplicações via templates
- Gerenciamento de volumes e redes
- Controle de acesso baseado em roles
- Monitoramento em tempo real
- Gestão de Docker Swarm clusters

## 🏗️ Arquitetura do Deployment

```
┌─────────────────────┐    ┌─────────────────────┐
│   Portainer         │    │   Docker Socket     │
│   (Management UI)   │◄──►│   (Container Mgmt)  │
│   Port: 9000        │    │   /var/run/docker   │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│   Portainer Agent   │
│   (Swarm Nodes)     │
│   Port: 9001        │
└─────────────────────┘
```

## 🔐 Configuração de Secrets

### Arquivo: `portainer_admin_password.txt`
**Descrição**: Senha hash para o usuário admin do Portainer
**Exemplo**:

```text
$2b$12$randomhashexamplehere1234567890abcdef
```

**Como gerar**:

```bash
# Método 1: htpasswd (recomendado)
htpasswd -nbB admin "MinhaSenh@Admin123" | cut -d ":" -f 2

# Método 2: Usando Docker
docker run --rm httpd:alpine htpasswd -nbB admin "MinhaSenh@Admin123" | cut -d ":" -f 2

# Método 3: Python
python3 -c "import bcrypt; print(bcrypt.hashpw(b'MinhaSenh@Admin123', bcrypt.gensalt()).decode())"
```

**Recomendações**:

- Use senha forte (12+ caracteres)
- Combine maiúsculas, minúsculas, números e símbolos
- Mude a senha regularmente
- Use hash bcrypt com cost 12+

## 🚀 Comandos Úteis

```bash
# Ver secrets do Portainer
make secrets-show-portainer

# Acessar logs
make logs-portainer

# Restart do serviço
make stop-portainer && make deploy-portainer

# Verificar agentes conectados
docker service ls | grep portainer
```

## 🔧 Configuração Inicial

### 1. Primeiro Acesso
- URL: `https://portainer.empresa.com.br:9443/`
- Usuário: `admin`
- Senha: A senha original usada para gerar o hash

### 2. Configuração do Environment
- **Local**: Docker local (automático)
- **Docker Swarm**: Cluster atual (automático)
- **Remote**: Adicionar outros Docker hosts

### 3. Configurações Importantes
- **Settings > Authentication**: Configurar LDAP/OAuth se necessário
- **Settings > Registries**: Adicionar registries privados
- **Settings > Teams**: Criar equipes e roles
- **Settings > Settings**: Configurar logs e timeouts

## 👥 Gerenciamento de Usuários

### Usuários Locais

```bash
# Via interface web:
# Users > Add user
# Definir: Username, Password, Role
```

### Teams e Roles

- **Administrator**: Acesso total
- **Standard User**: Acesso limitado aos próprios containers
- **Read-only**: Apenas visualização
- **Custom**: Permissões específicas

### Integrações

- **LDAP**: Active Directory
- **OAuth**: Google, GitHub, Microsoft
- **SAML**: Single Sign-On

## 🏗️ Templates e Deploy

### App Templates
- WordPress
- MySQL/PostgreSQL
- Nginx
- Redis
- Elasticsearch
- E muitos outros...

### Stacks (Docker Compose)
```yaml
# Exemplo de stack personalizada
version: '3.8'
services:
  app:
    image: nginx:latest
    ports:
      - "8080:80"
    deploy:
      replicas: 2
```

### Custom Templates
```json
{
  "type": 3,
  "title": "Minha App",
  "description": "Aplicação personalizada",
  "categories": ["web"],
  "platform": "linux",
  "logo": "https://...",
  "repository": {
    "url": "https://github.com/user/repo",
    "stackfile": "docker-compose.yml"
  }
}
```

## 📊 Monitoramento e Logs

### Dashboard Principal
- **Containers**: Status e estatísticas
- **Services**: Health checks e replicas
- **Nodes**: CPU, Memory, Disk usage
- **Networks**: Conectividade
- **Volumes**: Utilização de storage

### Logs em Tempo Real
```bash
# Via interface:
# Containers > [container] > Logs
# Services > [service] > Logs

# Via CLI:
docker service logs -f [service_name]
```

### Estatísticas
- CPU e Memory usage
- Network I/O
- Disk I/O
- Container lifecycle events

## 🔧 Configurações Avançadas

### Edge Agent
Para gerenciar Docker hosts remotos:

```bash
# Instalar no host remoto
docker run -d \
  --name portainer_edge_agent \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  portainer/agent:latest
```

### Registry Management
- Adicionar registries privados
- Configurar autenticação
- Pull automático de imagens

### Webhook Endpoints
```bash
# Webhook para redeploy
curl -X POST \
  "https://portainer.empresa.com.br:9443/api/webhooks/[webhook_id]"
```

## 🛡️ Segurança

### Recursos Ativados
- ✅ HTTPS obrigatório
- ✅ Autenticação robusta
- ✅ Role-based access control
- ✅ Docker socket security
- ✅ Session management
- ✅ Audit logs

### Boas Práticas
- 🔐 Use senhas fortes e 2FA quando disponível
- 👥 Implemente least privilege access
- 🔍 Monitore logs de acesso regularmente
- 🔄 Atualize regularmente
- 🚫 Nunca exponha na internet sem proteção

## 🔧 Manutenção

### Backup
```bash
# Backup dos dados do Portainer
docker run --rm \
  -v portainer_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/portainer-backup.tar.gz -C /data .
```

### Restore
```bash
# Restore dos dados
docker run --rm \
  -v portainer_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/portainer-backup.tar.gz -C /data
```

### Updates
```bash
# Atualizar Portainer
make stop-portainer
docker service update --image portainer/portainer-ce:latest portainer_app
```

## 🔍 Troubleshooting

### Problemas Comuns

**Agent não conecta**:
```bash
# Verificar conectividade
telnet [agent_host] 9001

# Verificar logs do agent
docker logs portainer_agent
```

**Interface lenta**:
```bash
# Verificar recursos
docker stats portainer_app

# Limpar dados antigos
# Via interface: Settings > System > Prune
```

**Erro de permissão**:
```bash
# Verificar socket Docker
ls -la /var/run/docker.sock

# Verificar grupos
groups $USER
```

## 📚 Links Úteis

- [Documentação Oficial](https://docs.portainer.io/)
- [App Templates](https://github.com/portainer/templates)
- [Community Templates](https://github.com/Qballjos/portainer_templates)
- [API Documentation](https://app.swaggerhub.com/apis/portainer/portainer-ce)
- [GitHub Repository](https://github.com/portainer/portainer)
