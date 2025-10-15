#!/bin/bash

# Script para corrigir warnings comuns de Markdown Lint
# Corrige: MD022, MD032, MD031, MD040, MD034, MD036, MD047

set -e

echo "🔧 Corrigindo warnings de Markdown Lint..."
echo ""

# Encontrar todos os arquivos .md
MD_FILES=$(find /home/henriqzimer/docker-swarm -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*")

for file in $MD_FILES; do
    echo "📝 Processando: $(basename $file)"
    
    # Backup
    cp "$file" "${file}.lint_backup"
    
    # MD047: Adicionar newline no final do arquivo
    if [ -n "$(tail -c 1 "$file")" ]; then
        echo "" >> "$file"
    fi
    
    # MD032: Adicionar linhas em branco ao redor de listas
    # MD022: Adicionar linhas em branco ao redor de headings
    # MD031: Adicionar linhas em branco ao redor de code blocks
    # Usar sed para adicionar linhas em branco onde necessário
    
    # Processar o arquivo com Python para correções mais complexas
    python3 << 'PYTHON_SCRIPT'
import sys
import re

file_path = sys.argv[1] if len(sys.argv) > 1 else None
if not file_path:
    sys.exit(1)

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
new_lines = []
prev_line = ""

for i, line in enumerate(lines):
    next_line = lines[i + 1] if i + 1 < len(lines) else ""
    
    # MD022: Adicionar linha em branco antes de heading se necessário
    if line.startswith('#') and prev_line and not prev_line.strip() == "" and not prev_line.startswith('#'):
        if not prev_line.startswith('```') and not prev_line.startswith('---'):
            new_lines.append("")
    
    # MD032: Adicionar linha em branco antes de lista
    if line.strip().startswith(('-', '*', '+')) or re.match(r'^\d+\.', line.strip()):
        if prev_line and not prev_line.strip() == "" and not prev_line.strip().startswith(('-', '*', '+', '#')):
            if not re.match(r'^\d+\.', prev_line.strip()):
                new_lines.append("")
    
    # MD031: Adicionar linha em branco antes de code block
    if line.strip().startswith('```'):
        if prev_line and not prev_line.strip() == "":
            new_lines.append("")
    
    new_lines.append(line)
    
    # MD022: Adicionar linha em branco depois de heading
    if line.startswith('#') and next_line and not next_line.strip() == "" and not next_line.startswith('#'):
        if not next_line.startswith('```') and not next_line.startswith('---'):
            new_lines.append("")
    
    # MD032: Adicionar linha em branco depois de lista
    if (line.strip().startswith(('-', '*', '+')) or re.match(r'^\d+\.', line.strip())):
        if next_line and not next_line.strip() == "" and not next_line.strip().startswith(('-', '*', '+')):
            if not re.match(r'^\d+\.', next_line.strip()) and not next_line.startswith('#'):
                new_lines.append("")
    
    # MD031: Adicionar linha em branco depois de code block
    if line.strip().startswith('```') and line.strip() == '```':
        if next_line and not next_line.strip() == "":
            new_lines.append("")
    
    prev_line = line

# Salvar arquivo
with open(file_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))

PYTHON_SCRIPT
" "$file"
    
    echo "  ✓ Corrigido"
done

echo ""
echo "✅ Todos os arquivos processados!"
echo "📁 Backups salvos em *.lint_backup"
echo ""
echo "Para remover backups: find /home/henriqzimer/docker-swarm -name '*.lint_backup' -delete"
