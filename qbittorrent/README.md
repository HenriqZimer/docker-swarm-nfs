# qBittorrent - Docker Swarm

## 📥 Sobre o qBittorrent

O qBittorrent é um cliente BitTorrent gratuito e de código aberto, com interface web para gerenciamento remoto.

## 🚀 Deploy

```bash

# Deploy do serviço

docker stack deploy -c docker-compose.yml qbittorrent

```text

## 🔧 Configuração

### ⚠️ Limitação: Senha de Admin

**O qBittorrent (imagem linuxserver) NÃO suporta:**
- ❌ Variáveis de ambiente para senha de admin
- ❌ Docker secrets para autenticação
- ❌ Configuração automática de credenciais

### Credenciais Padrão (Primeira Inicialização)

- **Usuário**: `admin`
- **Senha**: Temporária gerada automaticamente (veja nos logs)

```bash

# Ver logs para obter senha temporária inicial

docker service logs qbittorrent_app | grep -i "temporary password"

```text

A saída será algo como:

```text
The WebUI administrator username is: admin
The WebUI administrator password was not set. A temporary password is provided for this session: xYz123ABC

```text

### Como Definir Senha Permanente

**Método 1: Via Interface Web (Recomendado)**
1. Acesse <https://qbittorrent.henriqzimer.com.br>
2. Faça login com usuário `admin` e a senha temporária dos logs
3. Vá em **Tools** → **Options** → **Web UI**
4. Em **Authentication**, defina:
   - Username: `admin` (ou outro de sua preferência)
   - Password: Sua senha forte
5. Clique em **Save**

**Método 2: Editar Arquivo de Configuração Manualmente**


```bash

# 1. Acesse o container

docker exec -it $(docker ps -q -f name=qbittorrent) sh

# 2. Edite o arquivo de configuração

vi /config/qBittorrent/qBittorrent.conf

# 3. Procure pela seção [Preferences]
# 4. Modifique ou adicione as linhas:
# WebUI\Username=admin
# WebUI\Password_PBKDF2=@ByteArray(...)

# 5. Reinicie o serviço

exit
docker service update --force qbittorrent_app

```text

### Estrutura de Volumes

- **Config**: `/mnt/altaria/docker/qbittorrent/config` - Configurações do qBittorrent
- **Downloads**: `/mnt/altaria/downloads` - Pasta de downloads

## 🌐 Acesso

- **URL Local**: <http://localhost:8080>
- **URL Externa**: Configure no Cloudflare Tunnel

## 📋 Configuração Inicial

1. Acesse a interface web
2. Faça login com credenciais padrão
3. Altere a senha padrão em Ferramentas > Opções > Web UI
4. Configure pasta de downloads padrão: `/downloads`
5. Configure limites de velocidade conforme necessário
6. Habilite VPN se disponível

## 🔧 Configurações Recomendadas

### Downloads

- **Pasta padrão**: `/downloads/complete`
- **Pasta incompleta**: `/downloads/incomplete`
- **Pasta assistida**: `/downloads/watch`

### Conexão

- **Porta**: 6881 (TCP/UDP)
- **Habilitar UPnP/NAT-PMP**: Sim
- **Habilitar DHT**: Sim
- **Habilitar PEX**: Sim
- **Habilitar LSD**: Sim

### Limites

- **Global**: Configure conforme sua banda
- **Por torrent**: Configure conforme necessário

## 🔧 Manutenção

```bash

# Ver logs

docker service logs qbittorrent_app

# Restart do serviço

docker service update --force qbittorrent_app

# Parar serviço

docker stack rm qbittorrent

```text

## 📊 Recursos

- **CPU**: 1-4 cores
- **RAM**: 512MB-2GB
- **Storage**: NFS para config e downloads
- **Network**: Overlay encriptada + proxy network
- **Portas**: 8080 (Web UI), 6881 (BitTorrent)

## 🔒 Segurança

- Rede isolada para serviços de mídia
- Comunicação encriptada via overlay network
- Acesso via Traefik com HTTPS (certificado Let's Encrypt)
- Acesso via Cloudflare Tunnel
- Middleware `web-chain` com rate limiting e security headers
- ⚠️ **Senha deve ser configurada manualmente via interface web**

## ⚙️ Configurações Recomendadas de Segurança

Após definir sua senha via interface web:

1. **Web UI** (Tools → Options → Web UI):
   - ✅ Enable CSRF protection
   - ✅ Enable Host header validation
   - ✅ Enable clickjacking protection
   - ✅ Session timeout: 3600 seconds

2. **Connection** (Tools → Options → Connection):
   - ✅ Use random port on startup: Disabled (usar porta fixa 6881)
   - ✅ Enable UPnP/NAT-PMP: Yes (se necessário)

3. **BitTorrent** (Tools → Options → BitTorrent):
   - ✅ Privacy: Enable anonymous mode
   - ✅ Torrent Queueing: Limit active torrents

## 🔐 Backup da Configuração

Para fazer backup das suas configurações (incluindo senha):

```bash

# Backup do arquivo de configuração

docker exec $(docker ps -q -f name=qbittorrent) \
  cat /config/qBittorrent/qBittorrent.conf > qBittorrent.conf.backup

# Para restaurar

docker cp qBittorrent.conf.backup \
  $(docker ps -q -f name=qbittorrent):/config/qBittorrent/qBittorrent.conf

docker service update --force qbittorrent_app

```text

## 🔗 Integração com Plex

Para organizar downloads automaticamente para o Plex:

1. Configure pasta de downloads: `/downloads/complete`
2. Crie estrutura de pastas:
   - `/downloads/complete/movies`
   - `/downloads/complete/tv-shows`
   - `/downloads/complete/music`
3. Configure no qBittorrent para mover automaticamente
