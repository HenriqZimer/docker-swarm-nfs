# 🔐 Vaultwarden - Gerenciador de Senhas

## 🔍 O que é o Vaultwarden?

O Vaultwarden é uma implementação não-oficial do servidor Bitwarden:

- Gerenciador de senhas self-hosted
- Interface web e apps móveis
- Sincronização entre dispositivos
- Geração de senhas seguras
- Cofres organizacionais
- Compartilhamento seguro
- Autenticação de dois fatores (2FA)

## 🏗️ Arquitetura do Deployment

```text
┌─────────────────────┐    ┌─────────────────────┐
│   Vaultwarden       │    │   PostgreSQL DB     │
│   (Senhas)          │◄──►│   (Dados Criptogr.) │
│   Port: 80          │    │   Port: 5432        │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│   NFS Storage       │
│   (Backups/Files)   │
│   /data/vaultwarden │
└─────────────────────┘

```text

## 🔐 Configuração de Secrets

### Arquivo: `vaultwarden_admin_token.txt`

**Descrição**: Token para acessar o painel administrativo
**Exemplo**:

```text
$argon2id$v=19$m=65540,t=3,p=4$randomsalthere1234567890

```text

**Como gerar**:

```bash

# Instalar argon2

sudo apt install argon2

# Gerar hash da senha admin

echo -n "MinhaSenh@Admin123" | argon2 "randomsalt" -e -id -k 65540 -t 3 -p 4

```text

**Recomendações**:

- Use senha forte (12+ caracteres)
- Regenere periodicamente
- Anote a senha original em local seguro

### Arquivo: `vaultwarden_database_url.txt`

**Descrição**: URL de conexão com PostgreSQL
**Exemplo**:

```text
postgresql://vaultwarden:SenhaDB@vaultwarden_db:5432/vaultwarden

```text

**Formato**: `postgresql://usuario:senha@host:porta/database`

### Arquivo: `vaultwarden_db_password.txt`

**Descrição**: Senha do usuário do banco PostgreSQL
**Exemplo**:

```text
Vaultw@rden2024!Pass

```text

**Recomendações**:

- Senha forte e única
- Diferente do admin token
- Use caracteres especiais

### Arquivo: `vaultwarden_domain.txt`

**Descrição**: Domínio principal do Vaultwarden
**Exemplo**:

```text
vault.empresa.com.br
senhas.meusite.com
passwords.organizacao.org

```text

### Arquivo: `vaultwarden_smtp_host.txt`

**Descrição**: Servidor SMTP para notificações
**Exemplo**:

```text
smtp.gmail.com
smtp.office365.com
smtp.empresa.com.br

```text

**Nota**: Apenas o hostname, porta é configurada automaticamente (587)

### Arquivo: `vaultwarden_smtp_username.txt`

**Descrição**: Usuário para autenticação SMTP
**Exemplo**:

```text
usuario@gmail.com
vault@empresa.com.br
senhas@meudominio.com

```text

### Arquivo: `vaultwarden_smtp_password.txt`

**Descrição**: Senha ou token de aplicativo SMTP
**Exemplo**:

```text
MinhaSenh@Email123
abcd efgh ijkl mnop

```text

**Para Gmail/Office365**: Use senhas de aplicativo específicas

### Arquivo: `vaultwarden_smtp_email.txt`

**Descrição**: Email remetente das notificações
**Exemplo**:

```text
vault@empresa.com.br
noreply@meusite.com
senhas@organizacao.org

```text

**Importante**: Deve ser o mesmo ou relacionado ao SMTP username

## 🚀 Comandos Úteis

```bash

# Ver secrets do Vaultwarden

make secrets-show-vaultwarden

# Acessar logs

make logs-vaultwarden

# Restart do serviço

make stop-vaultwarden && make deploy-vaultwarden

# Backup dos dados

make backup

```text

## 🔧 Configuração Inicial

1. **Primeiro Acesso**:
   - URL: `<https://{vaultwarden_domain.txt}/`>
   - Criar primeira conta (será admin automaticamente)

2. **Painel Admin**:
   - URL: `<https://{vaultwarden_domain.txt}/admin`>
   - Token: valor de `vaultwarden_admin_token.txt`

3. **Configurações Importantes**:
   - Desabilitar registros públicos
   - Configurar limites de usuários
   - Habilitar 2FA obrigatório
   - Configurar backups automáticos

## 👥 Gerenciamento de Usuários

### Via Painel Admin:

- **Convidar Usuários**: Envio de convites por email
- **Listar Usuários**: Ver todos os usuários registrados
- **Desativar Usuários**: Bloquear acesso temporariamente
- **Excluir Usuários**: Remover permanentemente

### Via Interface:

- **Organizações**: Compartilhamento entre equipes
- **Coleções**: Agrupamento de senhas
- **Permissões**: Controle granular de acesso

## 🔄 Backup e Restore

### Backup Automático:

```bash

# Configurado no Docker Compose
# Backup diário dos dados
# Retenção: 30 dias

```text

### Backup Manual:

```bash

# Backup do banco

docker exec vaultwarden_db pg_dump -U vaultwarden vaultwarden > backup.sql

# Backup dos arquivos

tar -czf vaultwarden-data.tar.gz /data/vaultwarden/

```text

## 🛡️ Segurança

### Recursos Ativados:

- ✅ Criptografia end-to-end
- ✅ HTTPS obrigatório
- ✅ 2FA disponível
- ✅ Admin token protegido
- ✅ Rate limiting
- ✅ Logs de auditoria

### Recomendações:

- 🔐 Force 2FA para todos usuários
- 🚫 Desabilite registros públicos
- 📧 Configure SMTP para notificações
- 🔄 Faça backups regulares
- 📊 Monitore logs de acesso

## 📧 Configuração de Email

O SMTP está configurado para:

- **Convites**: Novos usuários
- **Redefinição**: Senhas esquecidas
- **Notificações**: Login suspeito
- **Relatórios**: Backups e manutenção

## 🔍 Monitoramento

```bash

# Status do serviço

curl <https://vault.empresa.com.br/alive>

# Logs em tempo real

docker service logs -f vaultwarden_app

# Verificar conectividade DB

docker exec vaultwarden_db pg_isready

# Estatísticas de uso
# Via painel admin > Users

```text

## 📱 Apps Cliente

### Web:

- URL: `<https://{vaultwarden_domain.txt}/`>
- Compatível com todos navegadores

### Desktop:

- [Bitwarden Desktop](https://bitwarden.com/download/)
- Configure servidor: `<https://{vaultwarden_domain.txt}/`>

### Mobile:

- App Bitwarden (iOS/Android)
- Configure servidor personalizado

## 🔧 Manutenção

```bash

# Atualizar Vaultwarden

make stop-vaultwarden
docker service update --image vaultwarden/server:latest vaultwarden_app

# Limpar logs antigos

docker system prune -f

# Verificar espaço em disco

df -h /data/vaultwarden/

```text

## 📚 Links Úteis

- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Bitwarden Help](https://bitwarden.com/help/)
- [API Documentation](https://bitwarden.com/help/api/)
- [Security Audit](https://github.com/dani-garcia/vaultwarden/wiki/Security-Audit)
- [Docker Hub](https://hub.docker.com/r/vaultwarden/server)
