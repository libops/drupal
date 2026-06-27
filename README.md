# Drupal Docker Template

LibOps Docker Compose template for running a Composer-managed [Drupal](https://www.drupal.org/) site with Traefik, MariaDB, Solr, and the LibOps Drupal PHP/nginx image.

## Requirements

- [sitectl](https://sitectl.libops.io/install) installed on the host that will run the site.
- Docker with the Compose v2 plugin installed on the same host.

## Quick start

Create a new Drupal site from this template:

```bash
sitectl create drupal/default \
  --template-repo https://github.com/libops/drupal \
  --path ./my-drupal-site \
  --type local \
  --checkout-source template \
  --default-context
```

The site is served through Traefik at `http://localhost`. The first boot installs Drupal from the checked-in configuration.

## Basic operations with sitectl

Run these from the generated checkout, or add `--context <name>` when operating from elsewhere.

```bash
# Start or update the Compose stack
sitectl compose up --remove-orphans -d

# Check the site and context configuration
sitectl healthcheck
sitectl validate

# Update image tags or pin a full image reference
sitectl image set --tag drupal=nginx-1.30.3-php84
sitectl image set --image drupal=libops/drupal:nginx-1.30.3-php84@sha256:...

# Enable local development bind mounts
sitectl set dev-mode enabled
sitectl converge

# Switch TLS modes
sitectl traefik tls mkcert --domain drupal.localhost
sitectl traefik tls letsencrypt --email ops@example.org

# Trust an upstream load balancer or reverse proxy
sitectl set reverse-proxy enabled --trusted-ip 203.0.113.10/32
sitectl converge

# Raise upload limits for larger files
sitectl set upload-limits enabled --max-upload-size 2G --upload-timeout 10m
sitectl converge
```

See the [Drupal sitectl plugin docs](https://sitectl.libops.io/plugins/drupal) for Drush helpers, development mode, sync operations, login links, and Drupal-specific jobs.

## Makefile

The Makefile is intentionally small. It only keeps Drupal-specific targets that are not core sitectl operations:

```bash
make rollout
make clean
make test
make lint
```

Use `sitectl compose ...`, `sitectl traefik ...`, and `sitectl set ...` directly for normal stack operations.

## Template notes

- `traefik` is the only published ingress.
- `drupal` is built from this repository and based on the LibOps Drupal PHP/nginx image.
- `mariadb` stores application data.
- `solr` provides search.
- Secrets are generated into `./secrets/`.

Drupal code is Composer-managed. Custom modules and themes belong under `web/modules/custom` and `web/themes/custom`.

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. The Drupal recommended project is licensed separately under the GNU General Public License v2; see `LICENSE.drupal-recommended-project`.
