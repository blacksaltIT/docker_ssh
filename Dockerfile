FROM ubuntu:16.04

RUN apt-get update && apt-get install -y openssh-server libnss-wrapper
RUN chmod 777 -R /var/run /home

ENV RSA_PUBKEY=
ENV RSA_PRIVKEY=
ENV AUTHORIZED_KEYS=
ENV SSH_USERNAME=user
ENV POSTPROCESS_CONFIG_SCRIPT=

COPY entrypoint.sh /bin/

EXPOSE 10022
USER 123456
CMD [ "/bin/entrypoint.sh" ]
