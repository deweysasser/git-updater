FROM debian:jessie
MAINTAINER Dewey Sasser <dewey@sasser.com>
# Purpose:  Periodically update a path
RUN apt-get update
RUN apt-get -y install git gnupg rsync

ADD run.sh /run.sh
ADD root /root

# How long to sleep between checks
ENV SLEEP 300

# false to skip signature check.  anything else to require signature
# all files in /keys will be importing to gpg to check signatures
ENV SIGNED false

# Place to copy the git files if signature checks
ENV TARGET /volume

# Location for the GPG import keys
ENV KEYS /keys

ENTRYPOINT [ "/run.sh" ]
