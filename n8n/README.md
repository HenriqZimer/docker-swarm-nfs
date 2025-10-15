# 🔄 N8N - Automação de Workflows

## 🔍 O que é o N8N?

O N8N é uma plataforma de automação de workflows que permite:

- Conectar diferentes aplicações e serviços
- Criar automações sem código (low-code)
- Processar dados entre sistemas
- Automatizar tarefas repetitivas
- Integrar APIs de forma visual
- Executar workflows baseados em triggers

## 🏗️ Arquitetura do Deployment

```text
┌─────────────────────┐    ┌─────────────────────┐
│   N8N App           │    │   PostgreSQL DB     │
│   (Workflows)       │◄──►│   (Execuções)       │
│   Port: 5678        │    │   Port: 5432        │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│   N8N Worker        │
│   (Processamento)   │
│   Background Jobs   │
└─────────────────────┘

```text

## 🔐 Configuração de Secrets

### Arquivo: `n8n_auth_password.txt`

**Descrição**: Senha para autenticação básica ou usuário owner
**Exemplo**:


```text
N8nP@ssw0rd2024!

```text

**Recomendações**:
- Senha forte com 12+ caracteres
- Combine maiúsculas, minúsculas, números e símbolos

### Arquivo: `n8n_db_password.txt`

**Descrição**: Senha do banco PostgreSQL do N8N
**Exemplo**:


```text
N8nDatabase#Secure2024

```text

**Recomendações**:
- Diferente da senha de auth
- Use caracteres especiais
- Mantenha alta complexidade

### Arquivo: `n8n_encryption_key.txt`

**Descrição**: Chave para criptografar credenciais e dados sensíveis
**Exemplo**:


```text
n8n-encryption-key-very-long-and-secure-string-2024

```text

**Recomendações**:
- String aleatória de 32+ caracteres
- Nunca altere após configuração inicial
- Use gerador de chaves seguro

### Arquivo: `n8n_host.txt`

**Descrição**: Domínio principal do N8N
**Exemplo**:


```text
n8n.empresa.com.br
automation.meusite.com
workflows.organizacao.org

```text

### Arquivo: `n8n_webhook_url.txt`

**Descrição**: URL base para webhooks do N8N
**Exemplo**:


```text
<https://n8n.empresa.com.br/>
<https://automation.meusite.com/>
<https://workflows.organizacao.org/>

```text

**Importante**: Sempre termine com `/`

### Arquivo: `n8n_smtp_host.txt`

**Descrição**: Servidor SMTP para notificações
**Exemplo**:


```text
smtp.gmail.com
smtp.office365.com
smtp.empresa.com.br

```text

**Nota**: Apenas o hostname, sem porta

### Arquivo: `n8n_smtp_username.txt`

**Descrição**: Usuário para autenticação SMTP
**Exemplo**:


```text
usuario@gmail.com
n8n@empresa.com.br
automation@meudominio.com

```text

### Arquivo: `n8n_smtp_password.txt`

**Descrição**: Senha ou token de aplicativo SMTP
**Exemplo**:


```text
MinhaSenh@Email123
abcd efgh ijkl mnop

```text

**Para Gmail/Office365**: Use senhas de aplicativo

### Arquivo: `n8n_smtp_sender.txt`

**Descrição**: Nome e email do remetente
**Exemplo**:


```text
"N8N Automação <n8n@empresa.com.br>"
"Sistema de Workflows <automation@site.com>"
"N8N Bot <bot@organizacao.org>"

```text

**Formato**: `"Nome <email@dominio.com>"`

### Arquivo: `n8n_trusted_domains.txt`

**Descrição**: Domínios confiáveis para CORS
**Exemplo**:


```text
empresa.com.br,*.empresa.com.br,localhost
meusite.com,*.meusite.com
organizacao.org,*.organizacao.org,app.organizacao.org

```text

**Formato**: Lista separada por vírgulas

## 🚀 Comandos Úteis

```bash

# Ver secrets do N8N

make secrets-show-n8n

# Acessar logs

make logs-n8n

# Restart do serviço

make stop-n8n && make deploy-n8n

# Backup das automações

make backup

```text

## 🔧 Configuração Inicial

1. **Primeiro Acesso**:
   - URL: Valor de `n8n_webhook_url.txt`
   - Método: Basic Auth ou Owner setup
   - Credenciais: conforme configuração

2. **Configurar Credenciais**:
   - Acesse Settings > Credentials
   - Configure APIs que será usadas
   - Use variáveis de ambiente quando possível

3. **Criar Primeiro Workflow**:
   - Use templates disponíveis
   - Configure triggers (webhook, schedule, etc.)
   - Teste execuções manuais

## 📊 Tipos de Workflows

### Triggers Comuns:

- **Webhook**: Para receber dados externos
- **Schedule**: Execução programada (cron)
- **Manual**: Execução sob demanda
- **Email**: Triggered por emails

### Nós Populares:

- **HTTP Request**: Chamar APIs
- **Email Send**: Enviar emails
- **Database**: Consultar/inserir dados
- **Conditional**: Lógica condicional
- **Function**: JavaScript personalizado

## 🛡️ Segurança

- ✅ Credenciais criptografadas
- ✅ Basic Auth configurado
- ✅ HTTPS via proxy reverso
- ✅ Webhooks seguros
- ✅ Domínios confiáveis limitados
- ⚠️ Configure IP whitelist se necessário

## 📧 Configuração de Email

O SMTP está configurado para:

- **Notificações**: Erros em workflows
- **Relatórios**: Resumos de execução
- **Alertas**: Falhas críticas

## 🔍 Monitoramento

```bash

# Ver execuções

docker service logs n8n_app

# Verificar workers

docker service ls | grep n8n

# Status de workflows

curl <https://n8n.empresa.com.br/healthz>

```text

## 📚 Links Úteis

- [Documentação Oficial](https://docs.n8n.io/)
- [Node Library](https://docs.n8n.io/integrations/)
- [Workflow Templates](https://n8n.io/workflows/)
- [Community Forum](https://community.n8n.io/)
- [API Documentation](https://docs.n8n.io/api/)
