#!/bin/bash

# 오류 발생 시 스크립트 즉시 중단
set -e

# 컬러 출력용 함수
print_step() {
  echo -e "\n\033[1;34m==> $1\033[0m"
}

# print_step "1. Terraform 초기화"
terraform init

# # print_step "2. Terraform 변경사항 계획(plan)"
terraform plan

# print_step "3. Terraform 적용(apply)"
terraform apply -auto-approve

# print_step "4. Output 값 확인"
# terraform output

REGION=$(terraform output -raw region)
VPC_ID=$(terraform output -raw vpc_id)
BASTION_IP=$(terraform output -raw bastion_public_ip)
HOSTS=$(terraform output -json server_names | jq -r '.[] | select(. != "bastion")')
PRIVATE_DOMAIN=$(terraform output -raw private_hosted_zone_name)

echo -e "\n\033[1;32mRegion                   : $REGION\033[0m"
echo -e "\033[1;32mVPC ID                   : $VPC_ID\033[0m"
echo -e "\033[1;32mBastion Server Public IP : $BASTION_IP\033[0m"

# sed -i.bak '/^Host bastion$/,/^$/d' ~/.ssh/config 2>/dev/null
rm -f ~/.ssh/config


cat <<EOF >> ~/.ssh/config
Host bastion
  HostName ${BASTION_IP}
  User ec2-user
  IdentityFile ~/.ssh/terraform-key.pem
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF


echo -e "\033[1;32mServer Lists             : "[ ${HOSTS} ]"\033[0m"
# 각 내부 호스트 설정 반복 추가
for HOST in ${HOSTS}; do
cat <<EOF >> ~/.ssh/config

Host ${HOST}
  HostName ${HOST}.${PRIVATE_DOMAIN}
  User ec2-user
  IdentityFile ~/.ssh/terraform-key.pem
  ProxyJump bastion
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF
done

ssh-keyscan -H $BASTION_IP >> ~/.ssh/known_hosts
scp -r ./certs/letsencrypt bastion:/home/ec2-user/ # If Use WebServer
scp  ~/.ssh/terraform-key.pem mgmt:/home/ec2-user/
