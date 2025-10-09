# qBittorrent - Docker Swarm

## 📥 Sobre o qBittorrent

O qBittorrent é um cliente BitTorrent gratuito e de código aberto, com interface web para gerenciamento remoto.

## 🚀 Deploy

```bash
# Deploy do serviço
docker stack deploy -c docker-compose.yml qbittorrent
```

## 🔧 Configuração

### Credenciais Personalizadas

As credenciais são configuradas via Docker Secrets:

- **Usuário**: Arquivo `qbittorrent_username.txt`
- **Senha**: Arquivo `qbittorrent_password.txt`

```bash
# Editar credenciais
echo "meuusuario" > qbittorrent_username.txt
echo "minhasenhasegura123!" > qbittorrent_password.txt
```

**IMPORTANTE**: 
- O qBittorrent não suporta nativamente variáveis de ambiente para credenciais
- As credenciais personalizadas são aplicadas através de configuração de arquivo
- Após mudanças nas credenciais, reinicie o serviço:

```bash
docker service update --force qbittorrent_app
```

### Credenciais Padrão (se não configurar secrets)

- **Usuário**: `admin`
- **Senha**: Temporária gerada no primeiro boot (veja os logs)

```bash
# Ver logs para obter senha inicial
docker service logs qbittorrent_app
```

### Estrutura de Volumes

- **Config**: `/mnt/altaria/docker/qbittorrent/config` - Configurações do qBittorrent
- **Downloads**: `/mnt/altaria/downloads` - Pasta de downloads

## 🌐 Acesso

- **URL Local**: http://localhost:8080
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
```

## 📊 Recursos

- **CPU**: 1-4 cores
- **RAM**: 512MB-2GB
- **Storage**: NFS para config e downloads
- **Network**: Overlay encriptada + proxy network
- **Portas**: 8080 (Web UI), 6881 (BitTorrent)

## 🔒 Segurança

- Rede isolada para serviços de mídia
- Comunicação encriptada via overlay network
- Acesso via tunnel Cloudflare (HTTPS)
- **Credenciais personalizadas via Docker Secrets**
- Configuração segura sem exposição de senhas em variáveis de ambiente

## 📝 Secrets do Docker Swarm

Os seguintes secrets são utilizados:

- `qbittorrent_username`: Nome de usuário para login
- `qbittorrent_password`: Senha para login

```bash
# Atualizar secrets (requer restart do serviço)
echo "novousuario" > qbittorrent_username.txt
echo "novasenha123!" > qbittorrent_password.txt
docker service update --force qbittorrent_app
```

## 🔗 Integração com Plex

Para organizar downloads automaticamente para o Plex:

1. Configure pasta de downloads: `/downloads/complete`
2. Crie estrutura de pastas:
   - `/downloads/complete/movies`
   - `/downloads/complete/tv-shows`
   - `/downloads/complete/music`
3. Configure no qBittorrent para mover automaticamente