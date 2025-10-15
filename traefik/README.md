# Traefik - Proxy Reverso e Load Balancer para Docker Swarm

Este diretório contém a configuração do Traefik v3.1 otimizada para Docker Swarm como proxy reverso e load balancer.

## 🚀 Características

- **Modo Global**: Traefik roda em todos os nós manager do Swarm
- **Sem Volumes Locais**: Usa configs do Docker Swarm para alta disponibilidade
- **SSL Automático**: Certificados Let's Encrypt via Cloudflare DNS Challenge
- **Load Balancing**: Distribuição automática de carga entre réplicas
- **Health Checks**: Monitoramento contínuo da saúde do serviço
- **Métricas Prometheus**: Exposição de métricas para monitoramento
- **HTTP/3 Support**: Suporte para o protocolo HTTP/3 (QUIC)

## 📋 Pré-requisitos

1. Docker Swarm inicializado
2. Credenciais do Cloudflare configuradas
3. Rede `cloudflared_proxy-network` criada (se usar Cloudflare Tunnel)

## 🔧 Configuração

### 1. Configurar Secrets

Crie os arquivos de secrets com suas credenciais:

```bash

# Email do Cloudflare

echo "seu-email@dominio.com" > cloudflare_email.txt

# API Key do Cloudflare (Global API Key ou Token com permissões de DNS)

echo "sua-api-key" > cloudflare_api_key.txt

# Autenticação do Dashboard (formato htpasswd)
# Gerar com: htpasswd -nb admin sua-senha

echo "admin:hash-senha" > traefik_dashboard_auth.txt

```text

### 2. Deploy do Stack

```bash
docker stack deploy -c docker-compose.yml traefik

```text

### 3. Verificar Status

```bash

# Ver serviços

docker service ls | grep traefik

# Ver logs

docker service logs -f traefik_traefik

# Ver tarefas

docker service ps traefik_traefik

```text

## 🌐 Como Expor Serviços

Para expor um serviço através do Traefik no Swarm, adicione labels ao serviço:

### Exemplo Básico

```yaml
services:
  myapp:
    image: myapp:latest
    networks:

      - traefik_proxy-network

    deploy:
      labels:

        - "traefik.enable=true"
        - "traefik.http.routers.myapp.rule=Host(`myapp.exemplo.com`)"
        - "traefik.http.routers.myapp.entrypoints=websecure"
        - "traefik.http.routers.myapp.tls.certresolver=cloudflare"
        - "traefik.http.services.myapp.loadbalancer.server.port=8080"


```text

### Exemplo com Middlewares

```yaml
deploy:
  labels:

    - "traefik.enable=true"
    - "traefik.http.routers.myapp.rule=Host(`myapp.exemplo.com`)"
    - "traefik.http.routers.myapp.entrypoints=websecure"
    - "traefik.http.routers.myapp.tls.certresolver=cloudflare"
    - "traefik.http.routers.myapp.middlewares=web-chain@file"
    - "traefik.http.services.myapp.loadbalancer.server.port=8080"
    
    # Configurações de Load Balancer

    - "traefik.http.services.myapp.loadbalancer.sticky.cookie=true"
    - "traefik.http.services.myapp.loadbalancer.sticky.cookie.name=lb_cookie"
    - "traefik.http.services.myapp.loadbalancer.healthcheck.path=/health"
    - "traefik.http.services.myapp.loadbalancer.healthcheck.interval=30s"


```text

## 🔒 Middlewares Disponíveis

Os seguintes middlewares estão pré-configurados em `dynamic.yml`:

### Chains (Conjuntos de Middlewares)

- **`web-chain@file`**: Headers de segurança + compressão + rate limit médio + retry
- **`api-chain@file`**: Headers de segurança + CORS + rate limit médio + retry
- **`admin-chain@file`**: Headers de segurança + autenticação básica + rate limit restrito
- **`public-chain@file`**: Headers de segurança + compressão + rate limit relaxado + retry

### Middlewares Individuais

- **`security-headers@file`**: Headers de segurança (HSTS, XSS, etc.)
- **`compression@file`**: Compressão gzip/brotli
- **`rate-limit-strict@file`**: 50 req/min (burst 100)
- **`rate-limit-medium@file`**: 100 req/min (burst 200)
- **`rate-limit-relaxed@file`**: 200 req/min (burst 400)
- **`retry@file`**: Retry automático (3 tentativas)
- **`cors-headers@file`**: Headers CORS para APIs
- **`admin-auth@file`**: Autenticação básica
- **`internal-whitelist@file`**: IP whitelist para redes privadas

### Uso em Labels

```yaml

# Usando uma chain

- "traefik.http.routers.myapp.middlewares=web-chain@file"

# Usando múltiplos middlewares

- "traefik.http.routers.myapp.middlewares=security-headers@file,compression@file,rate-limit-medium@file"


```text

## 📊 Monitoramento

### Dashboard

Acesse o dashboard do Traefik em: `<https://traefik.henriqzimer.com.br`>

Credenciais: definidas em `traefik_dashboard_auth.txt`

### Métricas Prometheus

As métricas estão disponíveis em: `<http://<traefik-ip>>:8080/metrics`

Integre com Prometheus adicionando ao `prometheus.yml`:

```yaml
scrape_configs:

  - job_name: 'traefik'

    static_configs:

      - targets: ['traefik:8080']


```text

### Health Check

Endpoint de health check: `<http://<traefik-ip>>:8080/ping`

## 🔄 Load Balancing

O Traefik distribui automaticamente o tráfego entre todas as réplicas de um serviço:

```yaml
services:
  myapp:
    image: myapp:latest
    networks:

      - traefik_proxy-network

    deploy:
      replicas: 3  # 3 réplicas para load balancing
      labels:

        - "traefik.enable=true"
        - "traefik.http.routers.myapp.rule=Host(`myapp.exemplo.com`)"
        - "traefik.http.services.myapp.loadbalancer.server.port=8080"
        
        # Algoritmo de load balancing (padrão: round-robin)
        # Opções: wrr (weighted round robin), drr (dynamic round robin)

        - "traefik.http.services.myapp.loadbalancer.passhostheader=true"
        
        # Sticky sessions (opcional)

        - "traefik.http.services.myapp.loadbalancer.sticky.cookie=true"
        - "traefik.http.services.myapp.loadbalancer.sticky.cookie.name=server_id"
        - "traefik.http.services.myapp.loadbalancer.sticky.cookie.secure=true"
        - "traefik.http.services.myapp.loadbalancer.sticky.cookie.httpOnly=true"
        
        # Health checks

        - "traefik.http.services.myapp.loadbalancer.healthcheck.path=/health"
        - "traefik.http.services.myapp.loadbalancer.healthcheck.interval=10s"
        - "traefik.http.services.myapp.loadbalancer.healthcheck.timeout=3s"


```text

## 🛡️ Segurança

### TLS/SSL

- **Certificados automáticos** via Let's Encrypt
- **DNS Challenge** via Cloudflare (não requer portas abertas)
- **TLS 1.2 e 1.3** suportados
- **Ciphers modernos** para melhor segurança
- **HTTP/3** habilitado

### Headers de Segurança

Todos os middlewares incluem headers de segurança:

- HSTS (HTTP Strict Transport Security)
- X-Content-Type-Options
- X-Frame-Options
- X-XSS-Protection
- Referrer-Policy
- Permissions-Policy

### Rate Limiting

Proteção contra DDoS e abuso com diferentes níveis:

- Estrito: 50 req/min
- Médio: 100 req/min
- Relaxado: 200 req/min

## 🔧 Troubleshooting

### Verificar logs

```bash
docker service logs -f traefik_traefik

```text

### Ver configuração atual

```bash

# Acessar container

docker exec -it $(docker ps -q -f name=traefik_traefik) sh

# Ver configuração

cat /etc/traefik/dynamic.yml

```text

### Certificados SSL não gerando

1. Verificar credenciais do Cloudflare
2. Verificar DNS apontando para o servidor
3. Verificar logs: `docker service logs traefik_traefik | grep acme`

### Serviço não sendo detectado

1. Verificar se o serviço está na rede `traefik_proxy-network`
2. Verificar se tem `traefik.enable=true`
3. Verificar se a porta está correta: `traefik.http.services.X.loadbalancer.server.port`
4. Para Swarm mode, verificar se as labels estão em `deploy.labels` e não em `labels`

### Testar conectividade

```bash

# Testar HTTP redirect

curl -I <http://seu-dominio.com>

# Testar HTTPS

curl -I <https://seu-dominio.com>

# Verificar certificado

openssl s_client -connect seu-dominio.com:443 -servername seu-dominio.com

```text

## 📚 Recursos Adicionais

- [Documentação Oficial do Traefik](https://doc.traefik.io/traefik/)
- [Traefik no Docker Swarm](https://doc.traefik.io/traefik/providers/docker/#docker-swarm-mode)
- [Configuração de Middlewares](https://doc.traefik.io/traefik/middlewares/overview/)
- [Certificados SSL](https://doc.traefik.io/traefik/https/acme/)

## 📝 Notas Importantes

1. **Modo Global**: Traefik roda em todos os managers (não usa volumes locais)
2. **Certificados**: Armazenados em `/tmp/acme.json` (regenerados se perdidos)
3. **Configuração**: Usa configs do Swarm (não volumes)
4. **Rede**: Serviços devem estar na rede `traefik_proxy-network`
5. **Labels**: Devem estar em `deploy.labels` para Swarm mode

## 🔄 Atualizações

Para atualizar o Traefik:

```bash

# Atualizar a imagem no docker-compose.yml
# Depois fazer o update do serviço

docker service update --image traefik:v3.2 traefik_traefik

# Ou redesploy do stack

docker stack deploy -c docker-compose.yml traefik

```text
