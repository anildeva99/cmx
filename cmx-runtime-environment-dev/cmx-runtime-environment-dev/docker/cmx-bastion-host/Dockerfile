# !!! Note: based on a public image. Should change this.
FROM cloudposse/bastion:0.4.4

# !!! Note: Remove these and configure MFA if desired:
ENV MFA_PROVIDER=""
ADD rootfs/etc/ssh/sshd_config /etc/ssh/sshd_config

RUN adduser -D bastion && passwd -d bastion && \
    mkdir /home/bastion/.ssh && chown bastion:nogroup /home/bastion/.ssh && chmod 700 /home/bastion/.ssh
VOLUME /home/bastion/.ssh

# !!! Note: Expecting /startup.sh script to be supplied outside of the image, likely by the container runtime (k8s)
ENTRYPOINT /startup.sh; /init
