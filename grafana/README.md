# 📊 Grafana - Monitoramento e Visualização

## 🔍 O que é o Grafana?

O Grafana é uma plataforma de observabilidade e visualização de dados que permite:
- Criar dashboards interativos e informativos
- Conectar múltiplas fontes de dados (Prometheus, InfluxDB, PostgreSQL, etc.)
- Configurar alertas baseados em métricas
- Compartilhar dashboards entre equipes
- Monitorar infraestrutura e aplicações em tempo real

## 🏗️ Arquitetura do Deployment

```
┌─────────────────────┐    ┌─────────────────────┐
│   Grafana App       │    │   PostgreSQL DB     │
│   (Dashboard)       │◄──►│   (Configurações)   │
│   Port: 3000        │    │   Port: 5432        │
└─────────────────────┘    └─────────────────────┘
           │
           ▼
┌─────────────────────┐
│   SMTP Server       │
│   (Notificações)    │
│   smtp.office365.com│
└─────────────────────┘
```

## 🔐 Configuração de Secrets

### Arquivo: `grafana_admin_password.txt`
**Descrição**: Senha do usuário administrador padrão do Grafana
**Exemplo**:
```
MinhaSenh@Super5egur@123
```
**Recomendações**:
- Use no mínimo 12 caracteres
- Combine letras, números e símbolos
- Evite senhas óbvias ou dicionário

### Arquivo: `grafana_secret_key.txt`
**Descrição**: Chave secreta para criptografia de sessões e cookies
**Exemplo**:
```
SW2YcwTIb9zpOOhoPsMm
```
**Recomendações**:
- String aleatória de 20+ caracteres
- Use geradores de senha seguros
- Nunca reutilize em outros serviços

### Arquivo: `grafana_db_password.txt`
**Descrição**: Senha do banco PostgreSQL do Grafana
**Exemplo**:
```
GrafanaDB#2024$Secure
```
**Recomendações**:
- Diferente da senha de admin
- Use caracteres especiais
- Mantenha complexidade alta

### Arquivo: `grafana_smtp_host.txt`
**Descrição**: Servidor SMTP para envio de emails
**Exemplo**:
```
smtp.gmail.com:587
smtp.office365.com:587
smtp.empresa.com.br:587
```
**Formatos aceitos**:
- `servidor:porta`
- Porta 587 (STARTTLS) ou 465 (SSL)

### Arquivo: `grafana_smtp_username.txt`
**Descrição**: Nome de exibição para emails enviados
**Exemplo**:
```
Grafana Monitoramento
Sistema de Alertas
Grafana Empresa
```

### Arquivo: `grafana_smtp_password.txt`
**Descrição**: Senha ou token de aplicativo para SMTP
**Exemplo**:
```
MinhaSenh@Email123
xyzw abcd efgh ijkl
```
**Para Office365/Gmail**:
- Use senhas de aplicativo específicas
- Não use senha principal da conta

### Arquivo: `grafana_smtp_email.txt`
**Descrição**: Endereço de email remetente
**Exemplo**:
```
grafana@empresa.com.br
monitoramento@meudominio.com
alertas@organizacao.org
```

### Arquivo: `grafana_domain.txt`
**Descrição**: Domínio principal do Grafana
**Exemplo**:
```
grafana.empresa.com.br
monitoring.meusite.com
dashboards.organizacao.org
```

### Arquivo: `grafana_domain_url.txt`
**Descrição**: URL completa de acesso ao Grafana
**Exemplo**:
```
https://grafana.empresa.com.br
https://monitoring.meusite.com
https://dashboards.organizacao.org
```

## 🚀 Comandos Úteis

```bash
# Ver secrets do Grafana
make secrets-show-grafana

# Acessar logs
make logs-grafana

# Restart do serviço
make stop-grafana && make deploy-grafana

# Backup das configurações
make backup
```

## 🔧 Configuração Inicial

1. **Primeiro Acesso**: 
   - URL: Valor de `grafana_domain_url.txt`
   - Usuário: `admin`
   - Senha: Valor de `grafana_admin_password.txt`

2. **Configurar Data Sources**:
   - Prometheus: `http://prometheus:9090`
   - PostgreSQL: Configurar conforme necessário

3. **Importar Dashboards**:
   - Use IDs do Grafana.com (ex: 1860, 3662)
   - Ou crie dashboards personalizados

## 📧 Configuração de Alertas

O SMTP está configurado para enviar notificações:
- **Remetente**: Valor de `grafana_smtp_email.txt`
- **Nome**: Valor de `grafana_smtp_username.txt`
- **Servidor**: Valor de `grafana_smtp_host.txt`

## 🛡️ Segurança

- ✅ Senhas via Docker Secrets
- ✅ Banco PostgreSQL isolado
- ✅ HTTPS configurado via proxy reverso
- ✅ Sessões criptografadas
- ⚠️ Configure LDAP/OAuth se necessário

## 📚 Links Úteis

- [Documentação Oficial](https://grafana.com/docs/)
- [Dashboard Gallery](https://grafana.com/grafana/dashboards/)
- [Alerting Guide](https://grafana.com/docs/grafana/latest/alerting/)
- [SMTP Configuration](https://grafana.com/docs/grafana/latest/administration/configuration/#smtp)
