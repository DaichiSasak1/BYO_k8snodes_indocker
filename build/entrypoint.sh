#!/bin/bash
# link the all customed service
while read svc sleepSec; do
[ -x ${svc} ] && {
echo " service '$(basename ${svc%.sh})' starting..."
/bin/bash ${svc} &
sleep ${sleepSec:-5}
echo "done. duration=${sleepSec:-5}"
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

tail -f /dev/null
