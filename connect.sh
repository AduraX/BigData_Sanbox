#!/usr/bin/env bash
eval `ssh-agent -s` # ssh-add -D # Remove all identities ==> Agent pid 5434
ssh-add -D  &&  ssh-add -k /home/adurax/.ssh/AWS_Key.pem # add your key to the SSH agent

echo -e "\nRuning Ansible code ..."
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i AnsibleInventory bdplat_pb.yml
echo -e "\n\nJupyter url:  http://ec2-13-229-180-103.ap-southeast-1.compute.amazonaws.com:8899"
ssh LogHost
