#/bin/bash
# DEFAULTNAME='k8s_hardway_nodes_'
DEFAULTNAME=''
NODENAME=${DEFAULTNAME}$1
NODENAME=$(docker ps --format='{{ .Names }}' --filter name=${NODENAME})
[[ -n ${NODENAME} ]] &&  [[ $(echo ${NODENAME} | wc -w) -eq 1 ]] && \
docker exec -ti ${NODENAME} sh
