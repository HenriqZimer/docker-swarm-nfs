# 🚀 Docker Swarm Services Management
# Makefile para gerenciar todos os serviços do Docker Swarm

.PHONY: help deploy stop restart status logs clean check-secrets backup restore secrets-load secrets-show secrets-backup secrets-restore secrets-sync

# Variáveis
SERVICES = grafana zabbix n8n vaultwarden portainer cloudflared harbor jenkins argocd
COMPOSE_FILES = $(foreach service,$(SERVICES),$(service)/docker-compose.yml)

# 📋 Help - Lista todos os comandos disponíveis
help:
	@echo "🚀 Docker Swarm Services Management"
	@echo "=================================="
	@echo ""
	@echo "📦 Deployment:"
	@echo "  make deploy          - Deploy todos os serviços"
	@echo "  make deploy-<service> - Deploy serviço específico (ex: make deploy-grafana)"
	@echo ""
	@echo "🛑 Stop/Start:"
	@echo "  make stop            - Para todos os serviços"
	@echo "  make stop-<service>  - Para serviço específico"
	@echo "  make restart         - Reinicia todos os serviços"
	@echo ""
	@echo "📊 Monitoramento:"
	@echo "  make status          - Status de todos os serviços"
	@echo "  make logs            - Logs de todos os serviços"
	@echo "  make logs-<service>  - Logs de serviço específico"
	@echo ""
	@echo "🔧 Manutenção:"
	@echo "  make clean           - Remove todos os serviços"
	@echo "  make prune           - Limpa volumes e redes órfãos"
	@echo "  make backup          - Backup de dados importantes"
	@echo ""
	@echo "🔐 Secrets:"
	@echo "  make check-secrets   - Verifica arquivos de secrets"
	@echo "  make secrets-load    - Carrega variáveis de ambiente"
	@echo "  make secrets-show    - Mostra secrets mascaradas"
	@echo "  make secrets-backup  - Backup do arquivo .env"
	@echo "  make secrets-restore - Restaura backup mais recente"
	@echo ""
	@echo "🏗️  Serviços disponíveis: $(SERVICES)"

# 📦 Deploy de todos os serviços
deploy: check-swarm
	@echo "🚀 Deployando todos os serviços..."
	./deploy_all_services.sh

# 📦 Deploy de serviços individuais
deploy-grafana: check-swarm
	@echo "📊 Deployando Grafana..."
	cd grafana && docker stack deploy -c docker-compose.yml grafana

deploy-zabbix: check-swarm
	@echo "📈 Deployando Zabbix..."
	cd zabbix && docker stack deploy -c docker-compose.yml zabbix

deploy-n8n: check-swarm
	@echo "🔄 Deployando N8N..."
	cd n8n && docker stack deploy -c docker-compose.yml n8n

deploy-vaultwarden: check-swarm
	@echo "🔒 Deployando Vaultwarden..."
	cd vaultwarden && docker stack deploy -c docker-compose.yml vaultwarden

deploy-portainer: check-swarm
	@echo "🐳 Deployando Portainer..."
	cd portainer && docker stack deploy -c docker-compose.yml portainer

deploy-cloudflared: check-swarm
	@echo "☁️  Deployando Cloudflared..."
	cd cloudflared && docker stack deploy -c docker-compose.yml cloudflared

deploy-harbor: check-swarm
	@echo "🚢 Deployando Harbor..."
	cd harbor && docker stack deploy -c docker-compose.yml harbor

deploy-jenkins: check-swarm
	@echo "⚙️ Deployando Jenkins..."
	cd jenkins && docker stack deploy -c docker-compose.yml jenkins

deploy-argocd: check-swarm
	@echo "🚀 Deployando ArgoCD..."
	cd argocd && docker stack deploy -c docker-compose.yml argocd

# 🛑 Stop de todos os serviços
stop:
	@echo "🛑 Parando todos os serviços..."
	@for service in $(SERVICES); do \
		echo "Parando $$service..."; \
		docker stack rm $$service 2>/dev/null || true; \
	done

# 🛑 Stop de serviços individuais
stop-grafana:
	@echo "🛑 Parando Grafana..."
	docker stack rm grafana

stop-zabbix:
	@echo "🛑 Parando Zabbix..."
	docker stack rm zabbix

stop-n8n:
	@echo "🛑 Parando N8N..."
	docker stack rm n8n

stop-vaultwarden:
	@echo "🛑 Parando Vaultwarden..."
	docker stack rm vaultwarden

stop-portainer:
	@echo "🛑 Parando Portainer..."
	docker stack rm portainer

stop-cloudflared:
	@echo "🛑 Parando Cloudflared..."
	docker stack rm cloudflared

stop-harbor:
	@echo "🛑 Parando Harbor..."
	docker stack rm harbor

stop-jenkins:
	@echo "🛑 Parando Jenkins..."
	docker stack rm jenkins

stop-argocd:
	@echo "🛑 Parando ArgoCD..."
	docker stack rm argocd

# 🔄 Restart de todos os serviços
restart: stop
	@echo "⏳ Aguardando serviços pararem..."
	sleep 10
	@$(MAKE) deploy

# 📊 Status de todos os serviços
status:
	@echo "📊 Status dos serviços Docker Swarm:"
	@echo "===================================="
	docker service ls
	@echo ""
	@echo "📦 Stacks ativas:"
	docker stack ls

# 📋 Logs de todos os serviços
logs:
	@echo "📋 Logs dos serviços:"
	@echo "===================="
	@for service in $(SERVICES); do \
		echo ""; \
		echo "📋 Logs de $$service:"; \
		echo "-------------------"; \
		docker service logs $${service}_app --tail 10 2>/dev/null || \
		docker service logs $${service}_tunnel --tail 10 2>/dev/null || \
		echo "Serviço $$service não encontrado"; \
	done

# 📋 Logs de serviços específicos
logs-grafana:
	@echo "📋 Logs do Grafana:"
	docker service logs grafana_app --tail 50 -f

logs-zabbix:
	@echo "📋 Logs do Zabbix:"
	docker service logs zabbix_server --tail 50 -f

logs-n8n:
	@echo "📋 Logs do N8N:"
	docker service logs n8n_app --tail 50 -f

logs-vaultwarden:
	@echo "📋 Logs do Vaultwarden:"
	docker service logs vaultwarden_app --tail 50 -f

logs-portainer:
	@echo "📋 Logs do Portainer:"
	docker service logs portainer_app --tail 50 -f

logs-cloudflared:
	@echo "📋 Logs do Cloudflared:"
	docker service logs cloudflared_tunnel --tail 50 -f

logs-harbor:
	@echo "📋 Logs do Harbor:"
	docker service logs harbor_core --tail 50 -f

logs-jenkins:
	@echo "📋 Logs do Jenkins:"
	docker service logs jenkins_jenkins --tail 50 -f

logs-argocd:
	@echo "📋 Logs do ArgoCD:"
	docker service logs argocd_argocd-server --tail 50 -f

# 🧹 Limpeza completa
clean:
	@echo "🧹 Removendo todos os serviços..."
	@$(MAKE) stop
	@echo "⏳ Aguardando limpeza..."
	sleep 5
	@echo "✅ Limpeza concluída"

# 🧹 Limpeza de volumes e redes órfãos
prune:
	@echo "🧹 Limpando volumes e redes órfãos..."
	docker system prune -f
	docker volume prune -f
	docker network prune -f

# 🔐 Verificar arquivos de secrets
check-secrets:
	@echo "🔐 Verificando arquivos de secrets..."
	@echo "===================================="
	@missing=0; \
	for service in $(SERVICES); do \
		if [ "$$service" != "cloudflared" ]; then \
			echo "Verificando $$service..."; \
			for file in $$service/*.txt; do \
				if [ -f "$$file" ]; then \
					echo "  ✅ $$file"; \
				else \
					echo "  ❌ $$file (não encontrado)"; \
					missing=1; \
				fi; \
			done; \
		fi; \
	done; \
	if [ $$missing -eq 0 ]; then \
		echo "✅ Todos os secrets estão OK"; \
	else \
		echo "❌ Alguns secrets estão faltando"; \
	fi

# 🔐 Comandos de gerenciamento de secrets
secrets-load:
	@echo "🔑 Carregando variáveis de ambiente..."
	@./manage-secrets.sh load

secrets-show:
	@echo "👁️  Mostrando secrets (mascaradas)..."
	@./manage-secrets.sh show

secrets-show-grafana:
	@echo "📊 Secrets do Grafana:"
	@./manage-secrets.sh show grafana

secrets-show-n8n:
	@echo "🔄 Secrets do N8N:"
	@./manage-secrets.sh show n8n

secrets-show-vaultwarden:
	@echo "🔒 Secrets do Vaultwarden:"
	@./manage-secrets.sh show vaultwarden

secrets-backup:
	@echo "💾 Fazendo backup das secrets..."
	@./manage-secrets.sh backup

secrets-restore:
	@echo "🔄 Restaurando backup das secrets..."
	@./manage-secrets.sh restore

secrets-sync:
	@echo "🔄 Sincronizando .env com arquivos individuais..."
	@./manage-secrets.sh sync

# 💾 Backup de dados importantes
backup:
	@echo "💾 Criando backup..."
	@mkdir -p backup/$(shell date +%Y%m%d_%H%M%S)
	@echo "Fazendo backup dos arquivos de configuração..."
	@cp -r */docker-compose.yml backup/$(shell date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@cp -r */*.txt backup/$(shell date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
	@echo "✅ Backup criado em backup/$(shell date +%Y%m%d_%H%M%S)/"

# 🔧 Verificações internas
check-swarm:
	@if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then \
		echo "❌ ERRO: Docker Swarm não está ativo!"; \
		echo "Execute: docker swarm init"; \
		exit 1; \
	fi

# 📊 Informações do sistema
info:
	@echo "📊 Informações do Docker Swarm:"
	@echo "==============================="
	docker info --format 'Swarm: {{.Swarm.LocalNodeState}}'
	@echo ""
	@echo "🖥️  Nodes:"
	docker node ls
	@echo ""
	@echo "🔐 Secrets:"
	docker secret ls
	@echo ""
	@echo "🌐 Networks:"
	docker network ls --filter driver=overlay

# 🎯 Comandos padrão
all: deploy
