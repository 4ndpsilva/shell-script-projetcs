#!/bin/bash
#=============================================================
#
#       FIILE: .../docker-imgs/funcions.sh
#
#       USAGE: source ./functions.sh
#
#       DESCRIPTION: Functions 
#
#=============================================================
#

STATUSLOG=logs/status.log
ACTIONLOG=logs/actions.log
IDLE_MSG="=====::...DISPONIVEL...::====="
NP=$#
USER=$2

function checkParams(){
  if [ ! "$NP" -gt 0 ]; then
    echo "Usage: ./$1.sh TAG (USER)"
    exit 1
  fi
}

function checkStatus() {
  if [ -f "$STATUSLOG" ] && [ ! "$(head -n 1 $STATUSLOG)" = $IDLE_MSG ]; then
    cat $STATUSLOG 1>&2
    exit 1
  fi
}

function setIdleStatus(){
  echo $IDLE_MSG > $STATUSLOG
}


function setBusyStatus(){
  checkStatus
  trap setIdleStatus EXIT
  if [ -z "$USER" ]; then
    echo "Executando $1. Iniciado em $(date). Aguarde..." > $STATUSLOG
  else
    echo "Usuario: $USER. Executando $1. Iniciado em $(date). Aguarde..." > $STATUSLOG
  fi
  lastaction=""
  if [ -f $ACTIONLOG ]; then
    lastactions=$(head -n 10 $ACTIONLOG)
  fi
  cat $STATUSLOG > $ACTIONLOG
  echo "$lastactions" >> $ACTIONLOG
}


function setEnvVars(){
  TAG=$1
  sed -i "s/^VERSION.*/VERSION=$TAG/g" .env
  source .env
  export $(cut -d= -f1 .env)
}


function clearImageIfNeeded(){
  oldHash=$1
  oldHashNoTag=$(docker images | grep '<none>' | grep $oldHash || true)
  if [ ! -z "$oldHashNoTag" ]
  then
    echo "Removendo imagem antiga: $oldHash ..." >> $LOGFILE
    docker rmi -f $oldHash >> $LOGFILE
  fi
}

function waitForHealthy(){
  container=$1
  echo "Esperando imagem docker subir..."
  while [ "$(docker ps | grep $container | grep healthy)" = "" ] 
  do
    sleep 5s
  done 
  unhealthy_container=$(docker ps | grep $container | grep 'unhealthy' || true)
  if [ ! -z "$unhealthy_container" ]; then
    docker stop $container
    docker start $container
    waitForHealthy $container
  fi
  echo "Imagem docker healthy!"
}

function postRun(){
  container=$1
  waitForHealthy $container
  sqlplus -s sys/gudiao@localhost:1521/MTR as sysdba @/matera/appl/matera-config/docker-db/post-run.sql
}



function getSistemVersions(){
    echo "
    set head off
    --
    select sa.nome_sub_sis, sa.patch from sd_patch_audit sa where sa.id_patch_audit in 
      (select max(id_patch_audit) from sd_patch_audit where nome_sub_sis = sa.nome_sub_sis   )
    order by patch desc;
    --
    exit;
  " | sqlplus -s sdbanco/sdbanco@localhost:1521/MTR
}


function getSistemDates(){
    echo "
    set head off
    --
    select id_sub_sistema, data_referencia from bc_sub_sistema;
    --
    exit;
  " | sqlplus -s sdbanco/sdbanco@localhost:1521/MTR
}

function getIbkDate(){
    echo "
    set head off
    --
    select valor from sdbanconet.bn_configuracao_sistema where configuracao_sistema_id = 12;
    --
    exit;
  " | sqlplus -s sdbanconet/sdbanconet@localhost:1521/MTR | grep '[0-9A].*'
}

function getFrontEndVersion(){
  folder=$1
  grep -ir build.version= /matera/appl/$folder/WEB-INF/classes/META-INF/* | sed 's/^.*build.version=\(.*\)$/\1/g'
}

function getSistemInfo(){
  SISTEMS="
Emprestimos..... SDEMP sdempgsx
Cadastro_Central SDBANCO sdbanco
Cobranca........ SDCOBR sdcobr-gsx
Renda_Fixa...... SDOPEN sdopen
Conta_Corrente.. SDCONTA2 sdconta
Cartoes......... CARTOES cartoes
Convenios....... CONVENIO convenios
Liquidacao_Fin.. SDTES sdtes
Compensacao..... SDCOMPE2 sdcompe
Garantias....... GARANTIAS2 garantias
"

  VERSIONS=$(getSistemVersions)
  DATES=$(getSistemDates)

  OLD_IFS=$IFS
  IFS="
"
  echo "------------------------------------------------------------------------------------------------"
  echo "| sistema		| data		| versao Banco		| versao Front		|"
  echo "------------------------------------------------------------------------------------------------"

  for SISTEM in $SISTEMS; do
    IFS=""
    #echo $VERSIONS | grep $(echo $SISTEM | cut -d" " -f1) 
    name=$(echo $SISTEM | cut -d" " -f1)
    dbname=$(echo $SISTEM | cut -d" " -f2)
    fname=$(echo $SISTEM | cut -d" " -f3)


    dbversion=$(echo $VERSIONS | grep ${dbname}\\s | awk '{ print $2 }')
    feversion=$(getFrontEndVersion $fname)
    sdate=$(echo $DATES | grep ${dbname}\\s | awk '{ print $2 }')
    echo "| $name	| $sdate	| $dbversion	| $feversion	|"

    IFS="
"
  done
  ibk_date=$(getIbkDate)
  echo "-------------------------------------------------------------------------------------------------"
  echo "| IBK............. 	| $ibk_date	| "
  echo "----------------------------------------"
  IFS=$OLD_IFS
}



function writeStatus(){

SLOG=$1
OLD=$IFS
IFS='
'

if [ ! -f "$STATUSLOG" ] || [ "$(head -n 1 $STATUSLOG)" = $IDLE_MSG ]; then

  ## health state
  echo "" > $SLOG
  echo "STATUS:"  >> $SLOG
  echo $(docker ps | awk 'BEGIN { FS="\\s{2,}" } /dbtest/ { print $5 }') >> $SLOG

  ## base image
  echo "" >> $SLOG
  echo "BASE IMAGE:"  >> $SLOG

  currenthash=$(docker images | awk '/current/ { print $1 }') 
  for item in $(docker history $currenthash | tail -n +2)
  do
    basehash=$(echo $item | awk '{ print $1 }')
    basetag=$(docker images | awk "BEGIN { FS=\"\\\\s{2,}\"  } /c6bank\/database.*$basehash/ { print \$2 }")
    if [ ! -z "$basetag" ]; then
      echo $basetag >> $SLOG
      break
    fi
  done

  ## tag, if is there
  echo "" >> $SLOG
  echo "TAGS:"  >> $SLOG
  for imagehash in $(docker images | tail -n +2 | awk 'BEGIN { FS="\\s{2,}" }  /local\/database/ { print $3 }' | uniq )
  do
    tags=$(docker images | awk "BEGIN { FS=\"\\\\s{2,}\"  } /local\/database.*$imagehash/ { print \$2 }")
    echo $imagehash --\> $tags >> $SLOG
  done

  if [ -f $ACTIONLOG ]; then
    echo "" >> $SLOG
    echo "ACTIONS HISTORY:"  >> $SLOG
    cat $ACTIONLOG | sed 's|Executando ||g' | sed 's|Aguarde...||g' >> $SLOG
  fi

  echo "" >> $SLOG

  # Informacoes dos sistemas
  echo "" >> $SLOG
  echo "Sistems Info:"  >> $SLOG
  getSistemInfo >> $SLOG
  
  # basic server
  echo "" >> $SLOG
  echo "Basic Server instances:"  >> $SLOG
  echo "$(docker ps --format '{{.Names}}' | grep 'basic-server')" >> $SLOG

  echo "" >> $SLOG

else

  cat $STATUSLOG > $SLOG

fi

IFS=$OLD

}

function verifyAvailableSpace(){
  PARTITION=$2
    
  if [ ! -z $PARTITION ]; then
    EXIST_PARTITION=$(df | awk '/${PARTITION}/ { print $4 }' | sed -n 1p)

    if [ -z $EXIST_PARTITION ]; then
      echo "A partição informada não existe" >&2
      exit 1
    fi
  else
    PARTITION="boot"
  fi
exit 1
  #Obtem espaço disponível na partição /ebs
  AVAILABLE_SPACE=$(df | awk '/${PARTITION}/ { print $4 }')

  #Conversão de Gigabyte para Kilobyte
  REQUIRED_SPACE=$(($1 * 1024 * 1024))

  if [ $REQUIRED_SPACE -gt $AVAILABLE_SPACE ]; then
    echo "Espaço em disco insuficiente" >&2
    exit 1
  fi
}