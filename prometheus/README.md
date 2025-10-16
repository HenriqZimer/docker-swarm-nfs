# Prometheus

Sistema de monitoramento e alertas com time-series database para Docker Swarm.

## 🚀 Serviços

- **Prometheus**: Sistema principal de monitoramento e coleta de métricas
- **Node Exporter**: Exportador de métricas do sistema operacional
- **cAdvisor**: Exportador de métricas de containers Docker

## 📋 Configuração

### Variáveis de Ambiente

Todas configuradas diretamente no `docker-compose.yml`:

- Timezone: `America/Sao_Paulo`
- Retenção de dados: 30 dias
- Tamanho máximo: 10GB

### Arquivo de Configuração

O arquivo `prometheus.yml` contém:

- Configuração de scrape targets
- Service discovery para Docker Swarm
- Integração com Traefik, Grafana e outros serviços

## 🌐 Acesso

- **URL**: <https://prometheus.henriqzimer.com.br>
- **Porta**: 9090 (interna)

## 📊 Métricas Coletadas

### Sistema (Node Exporter)

- CPU, Memória, Disco
- Network I/O
- Sistema de arquivos

### Containers (cAdvisor)

- Uso de recursos por container
- Network por container
- Filesystem por container

### Serviços

- Traefik (requisições, latência, certificados)
- Grafana (dashboards, usuários, queries)
- Docker Swarm (nodes, services, tasks)

## 🔧 Comandos Úteis

### Deploy

```bash
docker stack deploy -c docker-compose.yml prometheus
```

### Verificar Status

```bash
docker service ls | grep prometheus
```

### Ver Logs

```bash
docker service logs prometheus_app -f
docker service logs prometheus_node-exporter -f
docker service logs prometheus_cadvisor -f
```

### Remover Stack

```bash
docker stack rm prometheus
```

## 📁 Estrutura de Volumes

```plaintext
/mnt/altaria/docker/prometheus/
├── data/           # Dados do Prometheus (TSDB)
└── config/         # Configurações (prometheus.yml)
```

## 🔗 Integração com Grafana

Para visualizar as métricas no Grafana:

1. Acesse o Grafana
2. Vá em Configuration > Data Sources
3. Adicione Prometheus como data source
4. URL: `http://prometheus_app:9090`
5. Importe dashboards prontos do Grafana.com

### Dashboards Recomendados

- **Node Exporter Full**: ID 1860
- **Docker Swarm & Container Overview**: ID 609
- **Traefik 2**: ID 12250
- **cAdvisor**: ID 14282

## 🎯 Service Discovery

O Prometheus usa DNS-based service discovery para encontrar automaticamente:

- Serviços do Docker Swarm
- Exportadores (Node Exporter, cAdvisor)
- Aplicações que expõem métricas

## ⚙️ Recursos

### Limits

- CPU: 2.0 cores
- Memória: 2GB

### Reservations

- CPU: 0.5 cores
- Memória: 512MB

## 🔐 Segurança

- Acesso via HTTPS com certificado SSL (Traefik + Cloudflare)
- Rede isolada (monitoring-network)
- Middleware de segurança do Traefik

## 📝 Notas

- O Prometheus é deployado no manager node para acesso ao Docker socket
- Node Exporter e cAdvisor são deployados em modo global (todos os nodes)
- Retenção de dados configurada para 30 dias ou 10GB
- Integrado com Traefik para coleta de métricas HTTP
