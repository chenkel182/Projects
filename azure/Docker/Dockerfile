FROM ubuntu:17.10
LABEL name="SRE Tooling" \
      version="1.0"

ENV TERRAFORM_VERSION=0.11.11
ENV TERM=xterm
ENV PATH="$PATH:/usr/local/packer"
RUN \
  apt-get update && \
  apt-get install -y curl jq git unzip wget vim zsh && \
  cd /tmp && \
  curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
  apt-get install apt-transport-https lsb-release software-properties-common dirmngr -y && \
  wget https://releases.hashicorp.com/packer/0.12.0/packer_0.12.0_linux_amd64.zip && \
  unzip packer_0.12.0_linux_amd64.zip -d packer && \
  mv packer /usr/local/ && \
  export AZ_REPO=$(lsb_release -cs) && \
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" \
  >> /etc/apt/sources.list.d/azure-cli.list && \
  apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
  --keyserver packages.microsoft.com \
  --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
  apt-get update && \
  apt-get install azure-cli && \
  rm -rf /tmp/* && \
  rm -rf /var/cache/apk/*

# Install Zsh - comment out if you don't want to use zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
&& cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc  \
&& chsh -s /bin/zsh