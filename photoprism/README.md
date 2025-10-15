# PhotoPrism - Docker Swarm

## 📸 Sobre o PhotoPrism

PhotoPrism é uma aplicação de gerenciamento de fotos auto-hospedada com IA para organizar, navegar e compartilhar sua coleção de fotos.

## 🚀 Deploy

```bash

# Deploy do serviço

cd /home/henriqzimer/docker-swarm/photoprism
docker stack deploy -c docker-compose.yml photoprism

```text

## 🔐 Acesso

- **URL**: <https://photoprism.henriqzimer.com.br>
- **Usuário**: `admin`
- **Senha**: Definida em `photoprism_admin_password.txt`

## 🔧 Configuração

### Secrets

- `photoprism_url.txt`: URL pública do PhotoPrism
- `photoprism_db_password.txt`: Senha do banco de dados MariaDB
- `photoprism_admin_password.txt`: Senha inicial do usuário admin

### Volumes NFS

- **Originals**: `/mnt/altaria/photos/originals` - Fotos originais (somente leitura)
- **Storage**: `/mnt/altaria/docker/photoprism/storage` - Thumbnails, cache e sidecar files
- **Import**: `/mnt/altaria/photos/import` - Pasta para importar novas fotos
- **Database**: `/mnt/altaria/docker/photoprism/db` - Dados do MariaDB

## ⚙️ Variáveis de Ambiente

### Configurações Gerais

- `PHOTOPRISM_AUTH_MODE=password` - Modo de autenticação
- `PHOTOPRISM_SITE_URL` - URL pública do serviço
- `PHOTOPRISM_ORIGINALS_LIMIT=50000` - Limite de fotos (MB)
- `PHOTOPRISM_HTTP_COMPRESSION=gzip` - Compressão HTTP

### Recursos de IA

- `PHOTOPRISM_DISABLE_TF=false` - TensorFlow habilitado
- `PHOTOPRISM_EXPERIMENTAL=false` - Features experimentais
- `PHOTOPRISM_DISABLE_FACES=false` - Reconhecimento facial habilitado
- `PHOTOPRISM_DISABLE_CLASSIFICATION=false` - Classificação automática

### Database

- `PHOTOPRISM_DATABASE_DRIVER=mysql`
- `PHOTOPRISM_DATABASE_SERVER=db:3306`
- `PHOTOPRISM_DATABASE_NAME=photoprism`
- `PHOTOPRISM_DATABASE_USER=photoprism`

## 📋 Primeira Configuração

1. Acesse <https://photoprism.henriqzimer.com.br>
2. Faça login com usuário `admin` e a senha definida
3. Configure:
   - **Settings** → **Library**: Configure pastas de origem
   - **Settings** → **Advanced**: Habilite features desejadas
4. Inicie indexação: **Library** → **Index**

## 🔍 Funcionalidades

### Organização Automática

- ✅ Reconhecimento facial
- ✅ Classificação por objetos e cenas
- ✅ Detecção automática de localizações
- ✅ Agrupamento por cores
- ✅ Detecção de qualidade

### Busca Avançada

- Busca por pessoas, objetos, locais
- Filtros por data, câmera, país, cidade
- Busca semântica (ex: "praia", "montanha")

### Compartilhamento

- Álbuns privados
- Links públicos com senha
- Suporte a WebDAV

## 📊 Recursos do Sistema

### Requisitos Mínimos

- **CPU**: 2+ cores
- **RAM**: 4GB
- **Storage**: Depende do tamanho da biblioteca

### Alocação Atual

- **CPU**: 2-4 cores
- **RAM**: 2GB-4GB
- **Storage**: NFS

## 🔧 Manutenção

### Comandos Úteis

```bash

# Ver logs

docker service logs photoprism_app -f

# Restart do serviço

docker service update --force photoprism_app

# Re-indexar biblioteca
# Via Web UI: Library → Index → Complete Rescan

# Backup do banco de dados

docker exec $(docker ps -q -f name=photoprism_db) \
  mysqldump -u photoprism -p photoprism > photoprism_backup.sql

```text

### Limpeza de Cache

```bash

# Limpar thumbnails (via container)

docker exec -it $(docker ps -q -f name=photoprism_app) \
  photoprism thumbs -f

```text

## 🔒 Segurança

- ✅ Acesso via HTTPS com Let's Encrypt
- ✅ Autenticação obrigatória
- ✅ Rede isolada para banco de dados
- ✅ Originals em modo somente leitura
- ✅ Middleware `web-chain` com rate limiting

## 📱 Aplicativos Móveis

PhotoPrism pode ser acessado via:

- **Web App** (Progressive Web App)
- **PhotoSync** (iOS/Android) - Para upload automático
- **WebDAV** - Integração com apps de galeria

## 🔗 Integração com Outros Serviços

### Importar de Outros Serviços

1. Coloque fotos em `/import`
2. Via Web UI: **Library** → **Import**
3. Escolha mover ou copiar arquivos

### Backup Automático

Configure backup automático da pasta `/storage` e do banco de dados para outro servidor NFS ou S3.

## 📖 Referências

- [PhotoPrism Documentation](https://docs.photoprism.app/)
- [Docker Setup Guide](https://docs.photoprism.app/getting-started/docker-compose/)
- [FAQ](https://docs.photoprism.app/getting-started/faq/)

## ⚠️ Notas Importantes

1. **Primeira Indexação**: Pode levar várias horas dependendo do tamanho da biblioteca
2. **Recursos de IA**: Requerem CPU/RAM adequados
3. **Originals Read-Only**: Protege fotos originais contra modificações acidentais
4. **MariaDB**: Recomendado sobre SQLite para melhor performance
