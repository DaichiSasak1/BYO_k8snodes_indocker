#!/bin/bash
# link the all customed service

API_LOG='/var/log/kube-api.log' 
A_SUPPRESS_WORDS[0]='kube-controller-manager'
A_SUPPRESS_WORDS[1]='kube-scheduler'
A_SUPPRESS_WORDS[2]='coordination'
A_SUPPRESS_WORDS[3]='UserAgent.+kube-apiserver'
KUBELET_LOG='/var/log/kubelet.log' 
K_SUPPRESS_WORDS[0]='kube-controller-manager'
QFLG=1
WAIT_CMD='tail -f /dev/null'

function usage {
echo "usage: $(basename $0) [-a] [-k] [-q] [-h]
                          -a|--api-verbose     : verbose output to print API requests
                          -k|--kubelet-verbose : verbose output to print API requests for kubelet
                          -q|--quiet           : supress the atartup output (start ...)
                          -h|--help            : print this usage"
}

while [[ $# -gt 0 ]]; do
case $1 in
  --api-verbose|-a)
    WAIT_CMD="tail -f ${API_LOG} | grep httplog | egrep -v '$(IFS='|';echo "${A_SUPPRESS_WORDS[*]}")'"
    echo ${WAIT_CMD}
    shift 1
    ;;
  --kubelet-verbose|-k)
    WAIT_CMD="tail -f ${KUBELET_LOG} | grep httplog" #| egrep -v '$(IFS='|';echo "${K_SUPPRESS_WORDS[*]}")'"
    WAIT_CMD="tail -f ${KUBELET_LOG} | grep http"
    echo ${WAIT_CMD}
    shift 1
    ;;
  --quiet|-q)
    QFLG=0
    shift 1
    ;;
  --help|-h)
    usage; exit 1
    ;;
    *)
    echo "'$1' is not implemented"
    shift 1
    ;;
esac
done


while read svc sleepSec; do
[ -x ${svc} ] && {
[ ${QFLG} -ne 0 ] && echo " service '$(basename ${svc%.sh})' starting..."
/bin/bash ${svc} &
sleep ${sleepSec:-5}
[ ${QFLG} -ne 0 ] && echo "done. duration=${sleepSec:-5}"
}
done<<EOF
/exec/ETCD_SERVICE.sh 10
/exec/KUBE-API_SERVICE.sh 20
/exec/KUBE-CONTROLLER-MANAGER_SERVICE.sh
/exec/KUBE-SCHEDULER_SERVICE.sh
/exec/RBAC_AUTH.sh
/exec/CONTAINERD_SERVICE.sh 30
/exec/KUBELET_SERVICE.sh 20
/exec/KUBE-PROXY_SERVICE.sh
EOF

# /kube_nginx/NGINX
[ ! -f ${API_LOG} -a ! -f ${KUBELET_LOG} ] && WAIT_CMD='tail -f /dev/null'
echo "container Ready"
eval ${WAIT_CMD}
