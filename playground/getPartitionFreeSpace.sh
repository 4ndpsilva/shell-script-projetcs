#!/bin/bash

function getPartitionFreeSpace(){
  REQUIRED_FREE_SPACE=90;
  if [ ! -z "$1" ]; then
    freespace=$(df -ah --output=avail $1 | grep "[0-9.,]*[G|M|K]");
  else
    freespace=$(df -ah --output=avail /ebs | grep "[0-9.,]*[G|M|K]");
  fi
  echo $freespace
}

getPartitionFreeSpace