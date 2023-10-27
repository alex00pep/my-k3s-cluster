FROM alpine/ansible
ENV ANSIBLE_VERSION 2.9.17

RUN apk --no-cache add --update openssh curl sudo sshpass && \
    rm -rf /var/cache/apk/*


# Installing K3s and K3ssup into the management container, using Arkade
RUN curl -sSL https://get.arkade.dev | sudo sh
RUN arkade get kubectl; sudo install $HOME/.arkade/bin/kubectl /usr/local/bin/
RUN arkade get helm; sudo install $HOME/.arkade/bin/helm /usr/local/bin/
RUN arkade get k3sup; sudo install $HOME/.arkade/bin/k3sup /usr/local/bin/

# Create group and pi user 
RUN addgroup -S pi && adduser -D -h /home/pi -s /bin/bash -G pi -u 1001 pi
USER pi
WORKDIR /home/pi
RUN echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
CMD ["ansible", "--version"]