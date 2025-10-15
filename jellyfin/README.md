# Jellyfin Media Server - Docker Swarm

## 🎬 Sobre o Jellyfin

O Jellyfin é um servidor de mídia livre e de código aberto que permite organizar, transmitir e compartilhar sua coleção de filmes, programas de TV, música e fotos. É uma alternativa totalmente gratuita ao Plex.

## 🚀 Deploy

```bash

# Deploy do serviço

docker stack deploy -c docker-compose.yml jellyfin

```text

## 🔧 Configuração

### Acesso Inicial

- **URL**: <http://localhost:8096>
- **Setup inicial**: Siga o assistente de configuração na primeira execução
- **Sem necessidade de conta externa** (diferente do Plex)

### Estrutura de Volumes

- **Config**: `/mnt/altaria/docker/jellyfin/config` - Configurações do Jellyfin
- **Media**: `/mnt/altaria/downloads` - **MESMA PASTA DO qBittorrent** 
- **Cache**: `/mnt/altaria/docker/jellyfin/cache` - Cache de transcodificação

## 🌐 Acesso

- **URL Local**: <http://localhost:8096>
- **URL Externa**: Configure no Cloudflare Tunnel
- **HTTPS**: 8920 (opcional)
- **DLNA**: 1900/udp, 7359/udp

## 📋 Configuração Inicial

1. **Primeiro Acesso**:
   - Acesse <http://localhost:8096>
   - Crie conta de administrador
   - Configure idioma (Português)

2. **Configurar Bibliotecas**:
   - **Filmes**: `/media/movies` ou `/media/complete/movies`
   - **Séries**: `/media/tv-shows` ou `/media/complete/tv-shows`
   - **Música**: `/media/music` ou `/media/complete/music`

3. **Configurações Recomendadas**:
   - Habilitar transcodificação de hardware (se disponível)
   - Configurar metadados automáticos
   - Ajustar qualidade de streaming

## 🔗 Integração com qBittorrent

### Estrutura de Pastas Recomendada

Para melhor organização, configure no qBittorrent:

```text
/downloads/
├── incomplete/          # Downloads em andamento
├── complete/           # Downloads finalizados
│   ├── movies/         # Filmes
│   ├── tv-shows/       # Séries de TV
│   └── music/          # Música
└── watch/              # Pasta monitorada (opcional)

```text

### Configuração no qBittorrent

1. **Pasta padrão**: `/downloads/complete`
2. **Pasta incompleta**: `/downloads/incomplete`
3. **Mover automaticamente**: Habilitar para organizar por categoria

### Configuração no Jellyfin

1. Adicionar bibliotecas apontando para:
   - **Filmes**: `/media/complete/movies`
   - **TV**: `/media/complete/tv-shows`
   - **Música**: `/media/complete/music`

## 🔧 Manutenção

```bash

# Ver logs

docker service logs jellyfin_app

# Restart do serviço

docker service update --force jellyfin_app

# Parar serviço

docker stack rm jellyfin

# Limpar cache (se necessário)

docker exec -it $(docker ps -q -f name=jellyfin) rm -rf /cache/*

```text

## 📊 Recursos

- **CPU**: 1-6 cores (dependendo do uso de transcodificação)
- **RAM**: 1-4GB
- **Storage**: NFS para config, cache e mídia
- **Network**: Overlay encriptada + proxy network
- **Portas**: 8096 (HTTP), 8920 (HTTPS), 7359/udp, 1900/udp

## 🔒 Segurança

- Rede isolada para serviços de mídia
- Comunicação encriptada via overlay network
- Acesso via tunnel Cloudflare (HTTPS)
- Sem dependência de serviços externos
- Controle total sobre dados

## ⚡ Vantagens sobre o Plex

- **Totalmente gratuito** (sem limitações)
- **Código aberto** e transparente
- **Sem necessidade de conta externa**
- **Sem coleta de dados**
- **Transcodificação ilimitada**
- **Plugins e personalização**

## 🎯 Automação de Mídia

Para automatizar downloads e organização:

1. **qBittorrent** baixa para `/downloads/incomplete`
2. **Move automaticamente** para `/downloads/complete/[categoria]`
3. **Jellyfin** detecta novos arquivos automaticamente
4. **Metadados** baixados automaticamente

## 🔧 Troubleshooting

### Problemas Comuns

**Jellyfin não detecta novos arquivos:**


```bash

# Forçar rescan da biblioteca

curl -X POST "<http://localhost:8096/Library/Refresh">

```text

**Problemas de transcodificação:**
- Verificar se há recursos suficientes (CPU/RAM)
- Considerar usar hardware acceleration se disponível

**Permissões de arquivo:**
- Certificar que PUID/PGID estão corretos (1000:1000)
- Verificar permissões nas pastas NFS
