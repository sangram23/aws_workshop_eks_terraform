  #!/bin/bash -xe
  curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.14/2023-01-30/bin/linux/amd64/kubectl

  chmod +x ./kubectl &&   mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
  # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
  ARCH=amd64
  PLATFORM=$(uname -s)_$ARCH

  curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

  # (Optional) Verify checksum
  curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

  tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

  sudo mv /tmp/eksctl /usr/local/bin 
  sudo yum install git -y
  wget https://get.helm.sh/helm-v3.12.0-rc.1-linux-amd64.tar.gz
  tar -zxvf helm-v3.12.0-rc.1-linux-amd64.tar.gz
  sudo scp -rp linux-amd64/helm $HOME/bin/
  pip3 install --upgrade --user awscli
  sudo mv /usr/bin/aws /usr/bin/aws.bkp
  sudo ln -s /home/ec2-user/.local/bin/aws /usr/bin/aws
  
  sudo yum install squid -y
  sudo chkconfig squid on
  sudo service squid start
  #cat "acl all src 0.0.0.0/0" >> /etc/squid/squid.conf
  #http_access allow all
 #aws eks update-kubeconfig --region us-east-1 --name eks_airflow