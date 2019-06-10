# Install traefik

Traefik is configured to use let's encrypt. For that traefik needs access to the Azure DNS zone. A service account gets created by `06-install-traefik.sh`.

Note there are two traefik instances deployed, each managing different annotations:
- `ingressClass: traefik-dr`: so that we can test the cluster without having to switch the production DNS. For that we deploy mock ingresses (see `mock-ingresses`)
- (default) `ingressClass: traefik`