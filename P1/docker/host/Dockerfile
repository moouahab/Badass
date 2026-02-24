FROM alpine:3.20

# busybox est déjà présent sur Alpine, mais on ajoute des outils utiles
RUN apk add --no-cache busybox-extras iproute2 iputils tcpdump bash

# Important: aucune IP configurée ici
CMD ["sh"]
