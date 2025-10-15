# ROMM - ROM Manager

## Configuração de Provedores de Metadados

O ROMM está configurado com a combinação recomendada: **Hasheous + IGDB + SteamGridDB + Retroachievements**

### 📋 Como obter as API Keys

#### 1. IGDB (Internet Game Database) - OBRIGATÓRIO

**O que fornece**: Metadados, capa, screenshots, jogos relacionados

**Como obter**:
1. Acesse o [Twitch Developer Portal](https://dev.twitch.tv/console/apps)
2. Faça login com sua conta Twitch (você precisa ter 2FA ativado)
3. Clique em "Register Your Application"
4. Preencha o formulário:
   - **Name**: `romm-<hash-aleatório>` (ex: `romm-3fca6fd7f94dea4a05d029f654c0c44b`)
   - **OAuth Redirect URLs**: `<http://localhost`>
   - **Category**: `Application Integration`
   - **Client Type**: `Confidential`
5. Clique em "Create"
6. Copie o **Client ID** e o **Client Secret**
7. Cole no arquivo correspondente:


   ```bash
   echo "SEU_CLIENT_ID" > romm_igdb_client_id.txt
   echo "SEU_CLIENT_SECRET" > romm_igdb_client_secret.txt

```text

⚠️ **IMPORTANTE**: O nome precisa ser único! Se falhar silenciosamente, tente outro nome.

---

#### 2. SteamGridDB - RECOMENDADO

**O que fornece**: Arte de capa de alta qualidade alternativa

**Como obter**:
1. Acesse [SteamGridDB](https://www.steamgriddb.com/)
2. Faça login com sua conta Steam
3. Vá em [Preferences > API](https://www.steamgriddb.com/profile/preferences/api)
4. Copie a API Key
5. Cole no arquivo:


   ```bash
   echo "SUA_API_KEY" > romm_steamgriddb_api_key.txt

```text

---

#### 3. Retroachievements - RECOMENDADO

**O que fornece**: Progresso de conquistas/achievements

**Como obter**:
1. Crie uma conta em [Retroachievements](https://retroachievements.org/)
2. Faça login e vá em [Settings](https://retroachievements.org/settings)
3. Gere uma API Key
4. Copie a chave e cole no arquivo:


   ```bash
   echo "SUA_API_KEY" > romm_retroachievements_api_key.txt

```text

**Configuração adicional**:
- Após configurar, cada usuário precisa definir seu username do Retroachievements no perfil do ROMM
- Uma aba "Achievements" aparecerá nos detalhes dos jogos

---

#### 4. Hasheous - JÁ ATIVADO

**O que fornece**: Correspondência baseada em hash, proxy de dados do IGDB

✅ Já está ativado através da variável `HASHEOUS_API_ENABLED=true`
- Não requer API key
- Fornece correspondência rápida baseada em hash
- Faz proxy de títulos, descrições e capas do IGDB

---

### 🔧 Provedores Alternativos (Opcionais)

#### ScreenScraper (Alternativa ao IGDB)

**O que fornece**: Metadados, capas, screenshots, manuais

**Como obter**:
1. Crie conta em [ScreenScraper.fr](https://www.screenscraper.fr/membreinscription.php)
2. Use seu username e senha nos arquivos de secrets

#### MobyGames (Pago)

⚠️ **AVISO**: Agora é um [serviço pago](https://www.mobygames.com/info/api/#non-commercial)
- Recomendamos usar ScreenScraper ou Hasheous em vez disso

---

## 🚀 Deploy

Após configurar os secrets, faça o deploy:

```bash
docker stack deploy -c docker-compose.yml romm

```text

## 📊 Verificar Status

```bash
docker stack services romm
docker service logs romm_app --tail 50

```text

## 🔗 Links Úteis

- [Documentação Oficial](https://docs.romm.app/latest/)
- [Provedores de Metadados](https://docs.romm.app/latest/Getting-Started/Metadata-Providers/)
- [Estrutura de Pastas](https://docs.romm.app/latest/Getting-Started/Folder-Structure/)
- [Plataformas Suportadas](https://docs.romm.app/latest/Platforms-and-Players/Supported-Platforms/)
- [Discord Oficial](https://discord.gg/P5HtHnhUDH)

---

## 📝 Arquitetura Atual

### Serviços:

- **romm_app**: Worker node (Suicune) - 1 réplica
- **romm_db**: Manager node (Entei) - 1 réplica

### Volumes NFS:

- `db_data`: altaria.henriqzimer.com.br:/mnt/altaria/docker/romm/db
- `redis_data`: altaria.henriqzimer.com.br:/mnt/altaria/docker/romm/redis
- `resources_data`: altaria.henriqzimer.com.br:/mnt/altaria/docker/romm/resources
- `library_data`: slowbro.henriqzimer.com.br:/mnt/slowbro/library
- `assets_data`: altaria.henriqzimer.com.br:/mnt/altaria/docker/romm/assets
- `config_data`: altaria.henriqzimer.com.br:/mnt/altaria/docker/romm/config

### Redes:

- `retro-network`: Overlay encriptada
- `proxy-network`: Cloudflared (externa)

### Recursos:

- **App**: 0.5-2.0 CPU, 1-4GB RAM
- **DB**: 0.25-1.0 CPU, 512MB-1GB RAM
