#!/usr/bin/env python3
"""
Script para corrigir warnings comuns de Markdown Lint
Corrige: MD022, MD032, MD031, MD034, MD036, MD040, MD047
"""

import re
import sys
from pathlib import Path
from typing import List

def fix_markdown(content: str) -> str:
    """Aplica correções de markdown lint"""
    lines = content.split('\n')
    new_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        prev_line = lines[i - 1] if i > 0 else ""
        next_line = lines[i + 1] if i + 1 < len(lines) else ""
        
        # MD022: Adicionar linha em branco ANTES de heading
        if line.startswith('#') and prev_line.strip() and not prev_line.strip() == "":
            if not prev_line.startswith('#') and not prev_line.startswith('---'):
                new_lines.append("")
        
        # MD032: Adicionar linha em branco ANTES de lista
        is_list = line.strip().startswith(('-', '*', '+', '✅', '❌', '⚠️')) or re.match(r'^\d+\.', line.strip())
        prev_is_list = prev_line.strip().startswith(('-', '*', '+', '✅', '❌', '⚠️')) or re.match(r'^\d+\.', prev_line.strip())
        
        if is_list and prev_line.strip() and not prev_is_list:
            if not prev_line.startswith('#') and not prev_line.strip() == "":
                new_lines.append("")
        
        # MD031: Adicionar linha em branco ANTES de code block
        if line.strip().startswith('```') or line.strip().startswith('````'):
            if prev_line.strip() and not prev_line.strip() == "":
                new_lines.append("")
        
        # MD040: Adicionar linguagem em code blocks
        if line.strip() == '```':
            # Se é abertura de code block sem linguagem, adicionar 'text'
            if i + 1 < len(lines) and not lines[i + 1].strip().startswith('```'):
                line = '```text'
        
        # MD034: Remover bare URLs (wrap em <>)
        if 'http://' in line or 'https://' in line:
            # Detectar URLs não envolvidas em markdown
            url_pattern = r'(?<![(\[<])https?://[^\s\])>]+'
            matches = re.finditer(url_pattern, line)
            for match in reversed(list(matches)):
                url = match.group()
                # Verificar se já não está em link markdown [texto](url)
                if not line[max(0, match.start()-1):match.start()] == '(':
                    line = line[:match.start()] + f'<{url}>' + line[match.end():]
        
        new_lines.append(line)
        
        # MD022: Adicionar linha em branco DEPOIS de heading
        if line.startswith('#') and next_line.strip() and not next_line.strip() == "":
            if not next_line.startswith('#') and not next_line.startswith('```') and not next_line.startswith('---'):
                new_lines.append("")
        
        # MD032: Adicionar linha em branco DEPOIS de lista
        next_is_list = next_line.strip().startswith(('-', '*', '+', '✅', '❌', '⚠️')) or re.match(r'^\d+\.', next_line.strip())
        
        if is_list and next_line.strip() and not next_is_list:
            if not next_line.startswith('#') and not next_line.strip() == "":
                new_lines.append("")
        
        # MD031: Adicionar linha em branco DEPOIS de code block (fechamento)
        if (line.strip() == '```' or line.strip() == '````') and i > 0:
            # Verificar se é fechamento
            if prev_line and not prev_line.strip().startswith('```'):
                if next_line.strip() and not next_line.strip() == "":
                    new_lines.append("")
        
        i += 1
    
    # MD047: Garantir newline no final
    result = '\n'.join(new_lines)
    if not result.endswith('\n'):
        result += '\n'
    
    return result

def process_file(file_path: Path) -> bool:
    """Processa um arquivo markdown"""
    try:
        # Ler conteúdo original
        with open(file_path, 'r', encoding='utf-8') as f:
            original = f.read()
        
        # Aplicar correções
        fixed = fix_markdown(original)
        
        # Salvar se houve mudanças
        if fixed != original:
            # Backup
            backup_path = file_path.with_suffix(file_path.suffix + '.lint_backup')
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(original)
            
            # Salvar corrigido
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed)
            
            return True
        return False
    except Exception as e:
        print(f"  ❌ Erro: {e}")
        return False

def main():
    base_path = Path("/home/henriqzimer/docker-swarm")
    
    print("🔧 Corrigindo warnings de Markdown Lint...")
    print("")
    
    # Encontrar todos os arquivos .md
    md_files = list(base_path.rglob("*.md"))
    
    # Filtrar arquivos git e node_modules
    md_files = [f for f in md_files if '.git' not in str(f) and 'node_modules' not in str(f)]
    
    fixed_count = 0
    for md_file in md_files:
        rel_path = md_file.relative_to(base_path)
        print(f"📝 {rel_path}...", end=" ")
        
        if process_file(md_file):
            print("✓ Corrigido")
            fixed_count += 1
        else:
            print("○ Sem mudanças")
    
    print("")
    print(f"✅ Processados {len(md_files)} arquivos ({fixed_count} modificados)")
    print("📁 Backups salvos em *.lint_backup")
    print("")
    print("Para remover backups:")
    print("  find /home/henriqzimer/docker-swarm -name '*.lint_backup' -delete")

if __name__ == "__main__":
    main()
