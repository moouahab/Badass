FROM debian:bookworm-slim

# Installer FRR + outils réseau
RUN apt-get update && apt-get install -y \
    frr frr-pythontools \
    iproute2 iputils-ping tcpdump \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Copier les fichiers de configuration
COPY daemons /etc/frr/daemons
COPY frr.conf /etc/frr/frr.conf

# Permissions nécessaires pour FRR
RUN chown -R frr:frr /etc/frr \
    && chmod 640 /etc/frr/*

# Démarrage propre
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-c", "/usr/lib/frr/frrinit.sh start && tail -f /dev/null"]
