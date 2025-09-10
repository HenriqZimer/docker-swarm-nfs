#!/bin/bash

# Script para formatar e organizar arquivos Docker Compose
# Uso: ./format-docker-files.sh

set -e

echo "🐳 Formatando arquivos Docker Compose..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar se prettier está disponível
if ! command -v prettier &> /dev/null; then
    warning "Prettier não encontrado. Instalando..."
    npm install -g prettier
fi

# Encontrar e formatar arquivos Docker Compose
log "Procurando arquivos Docker Compose..."

# Formatar arquivos docker-compose
find . -name "docker-compose*.yml" -o -name "docker-compose*.yaml" | while read -r file; do
    log "Formatando: $file"
    prettier --write "$file"
    success "✓ $file formatado"
done

# Formatar outros arquivos YAML
find . -name "*.yml" -o -name "*.yaml" | grep -v node_modules | while read -r file; do
    if [[ "$file" != *"docker-compose"* ]]; then
        log "Formatando YAML: $file"
        prettier --write "$file"
        success "✓ $file formatado"
    fi
done

# Validar arquivos Docker Compose
log "Validando arquivos Docker Compose..."

find . -name "docker-compose*.yml" | while read -r file; do
    log "Validando: $file"
    if docker-compose -f "$file" config --quiet; then
        success "✓ $file válido"
    else
        warning "⚠ Problemas encontrados em: $file"
    fi
done

echo ""
success "🎉 Formatação concluída!"
echo ""
log "Para formatar automaticamente ao salvar, certifique-se de que as extensões recomendadas estão instaladas:"
echo "  - redhat.vscode-yaml"
echo "  - esbenp.prettier-vscode"
echo "  - ms-azuretools.vscode-docker"
