#!/bin/bash

# ==============================================================================
# GUIA DE REFERÊNCIA RÁPIDA DE SHELL SCRIPTING PARA DEVOPS
#
# Este script é um resumo funcional dos conceitos essenciais de Shell
# Scripting abordados, servindo como um "cheat sheet" para consulta rápida.
#
# Autor: Lucas Yuki
# Data: 18/07/2025
# ==============================================================================


# ------------------------------------------------------------------------------
# SEÇÃO 1: COMANDOS ESSENCIAIS E MANIPULAÇÃO DE SAÍDA
# ------------------------------------------------------------------------------

# 1.1 - Requisição HTTP com cURL para Health Check
# Faz uma requisição a um domínio, suprime a saída de progresso (--silent),
# descarta o corpo da resposta (/dev/null) e imprime apenas o código de status HTTP.
echo "Exemplo de Health Check com cURL:"
curl --write-out "%{http_code}\n" --silent --output /dev/null https://www.google.com


# 1.2 - Capturando a Saída de um Comando em uma Variável
# A sintaxe $(... ) executa o comando e captura sua saída padrão.
timestamp_atual=$(date "+%F %T")
echo "Timestamp capturado: $timestamp_atual"


# 1.3 - Monitoramento de Disco com 'df', 'grep' e 'awk'
# O pipe '|' conecta a saída de um comando à entrada de outro.
#   - df -h: Mostra o uso do disco de forma legível por humanos (Human-readable).
#   - grep '/$': Filtra a linha que termina ($) com uma barra (/), geralmente a partição raiz.
#   - awk '{print $5}': Pega a linha filtrada e imprime apenas a 5ª coluna (o percentual de uso).
echo "Uso da partição raiz:"
uso_disco=$(df -h | grep '/$' | awk '{print $5}')
echo "$uso_disco"


# ------------------------------------------------------------------------------
# SEÇÃO 2: AUTOMAÇÃO COM CRON
# ------------------------------------------------------------------------------

# O 'cron' é um daemon que executa tarefas agendadas (cron jobs).

# Comandos úteis do cron:
#   - service cron status: Verifica se o serviço do cron está em execução.
#   - sudo service cron start: Inicia o serviço do cron.
#   - sudo crontab -e: Edita o arquivo de cron jobs do usuário root.
#   - crontab -l: Lista os cron jobs do usuário atual.

# Exemplo de linha para adicionar ao crontab:
# Executa o script a cada 2 minutos.
# ┌───────────── minuto (0 - 59)
# │ ┌───────────── hora (0 - 23)
# │ │ ┌───────────── dia do mês (1 - 31)
# │ │ │ ┌───────────── mês (1 - 12)
# │ │ │ │ ┌───────────── dia da semana (0 - 6) (Domingo=0 ou 7)
# │ │ │ │ │
# * /2 * * * * /caminho/para/seu/script.sh >> /caminho/para/seu/log.log 2>&1
#
# '>>' anexa a saída ao log. '2>&1' redireciona a saída de erro (2) para a saída padrão (1).


# ------------------------------------------------------------------------------
# SEÇÃO 3: SCRIPT RECURSIVO PARA VERIFICAR ARQUIVOS
# ------------------------------------------------------------------------------

# Este script demonstra funções, recursão, parâmetros e condicionais.

# --- VALIDAÇÕES DE ENTRADA ---
# É uma boa prática validar os argumentos ANTES de executar a lógica principal.

# 1. Garante que exatamente UM argumento foi passado para o script.
if [ $# -ne 1 ]; then
    echo "Erro: Número de argumentos inválido."
    echo "Uso: $0 <caminho_do_diretorio>"
    exit 1
fi

# 2. Garante que o argumento passado é um DIRETÓRIO existente.
#    - '!': Operador de negação (NÃO).
#    - '-d': Testa se o caminho é um Diretório.
#    - "$1": O primeiro argumento. As aspas protegem contra nomes com espaços.
if [ ! -d "$1" ]; then
    echo "Erro: O diretório '$1' não foi encontrado."
    exit 1
fi


# --- DEFINIÇÃO DAS FUNÇÕES ---

# Função para verificar conflitos de merge em UM único arquivo.
function verificar_conflito() {
    # 'local' cria uma variável com escopo privado para a função. Essencial!
    local arquivo="$1"
    # '-q' (quiet) suprime a saída do grep. '-E' ativa expressões regulares estendidas.
    if grep -q -E '<<<<<<<|=======|>>>>>>>' "$arquivo"; then
        echo "Inconsistência encontrada no arquivo: $arquivo"
    fi
}

# Função RECURSIVA para explorar um diretório.
function verificar_diretorio() {
    local diretorio="$1"
    local item # Declara a variável de loop como local

    # Itera sobre cada item DENTRO do diretório.
    # O curinga '*' é expandido pelo shell para a lista de todos os itens.
    for item in "$diretorio"/*; do
        # Testa se o item atual é um ARQUIVO regular.
        if [ -f "$item" ]; then
            verificar_conflito "$item"
        # Testa se o item atual é um DIRETÓRIO.
        elif [ -d "$item" ]; then
            # Se for um diretório, a função chama a si mesma (recursão).
            verificar_diretorio "$item"
        fi
    done
}

# Caso queira usar o while ao invés do for, pode fazer o seguinte:

# function verificar_diretorio(){
#   local diretorio="$1"
#   local arquivos=("$diretorio"/*)
#   local i=0
#   local arquivo
#   while [ $i -lt ${#arquivos[@]} ]; do           # ${#arquivos[@]} serve para pegar o tamanho do array
#       arquivo="${arquivos[$i]}"
#       if test -f "$arquivo"; then
#           verificar_conflito "$arquivo"
#       elif
#           verificar_diretorio "$arquivo"
#       fi
#       ((i++))                                 # Adiciona 1 para o valor i
#   done
# }

# --- PONTO DE ENTRADA DO SCRIPT ---
echo "Iniciando verificação no diretório: $1"
verificar_diretorio "$1"
echo "Verificação concluída."

#========================================================================================

# monitoramento dos processos com consumo de memória
#!/bin/bash

# Definimos o caminho para o arquivo de saída
output_file="/caminho/do/seu/diretorio/top_processes_$(date +\%Y\%m\%d_\%H\%M).txt"

# Listamos os 15 processos com maior consumo de memória e salvamos no arquivo de saída
ps -e -o pid,%mem --sort=-%mem | head -n 16 > "$output_file"

#=======================================================================================

# utilização do comando ps para listar processos em execução da CPU

#!/bin/bash
echo "Top 5 processos por uso de CPU:"
ps aux --sort=-%cpu | head -n 6

#=======================================================================================

# Para o monitoramento de memória, substituir "cpu" por "mem"
##!/bin/bash
echo "Top 5 processos por uso de memória:"
ps aux --sort=-%mem | head -n 6

#=======================================================================================

# Verificar se o servidor web está em execução

#!/bin/bash
processo="nginx"
if pgrep $processo > /dev/null; then      # Uso de pgrep para não encontrar o comando grep nginx na resposta
  echo "$processo está em execução."
else
  echo "$processo não está em execução."
fi

#=======================================================================================

# Identificação de logs com processo de erro

tail -n 10 /var/log/syslog | grep "error"
#        î___Note que esse valor é a quantidade de linhas que serão mostradas do log de erro

#=======================================================================================

# Caso queira monitorar e gravar as mensagens de erros em um arquivo, o seguinte script pode ser utilizado:

#!/bin/bash
echo "Mensagens de erro - $(date)" >> /caminho/do/log_monitorado.txt
tail -n 5 /var/log/syslog | grep "error" >> /caminho/do/log_monitorado.txt

#=======================================================================================

# ==============================================================================
# FIM DO GUIA
# ==============================================================================
