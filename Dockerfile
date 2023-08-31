FROM alpine/ansible
ENV ANSIBLE_VERSION 2.9.17

RUN apk --no-cache add --update openssh curl sudo sshpass && \
    rm -rf /var/cache/apk/*


# Installing K3s and K3ssup into the management container, using Arkade
RUN curl -sSL https://get.arkade.dev | sudo sh
RUN arkade get kubectl; sudo install $HOME/.arkade/bin/kubectl /usr/local/bin/
RUN arkade get k3sup; sudo install $HOME/.arkade/bin/k3sup /usr/local/bin/
RUN ssh-keygen -b 4086 -t rsa -f $HOME/.ssh/id_rsa -q -N ""