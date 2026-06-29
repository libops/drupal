# Drupal Docker Template

The Drupal Docker Template gives you a Docker Compose repository for running a Composer-managed [Drupal](https://www.drupal.org/) site. It includes Traefik, MariaDB, Solr, and the LibOps Drupal PHP/nginx image, and is designed to be managed with [`sitectl-drupal`](https://github.com/libops/sitectl-drupal).

Docs:

- [Managed application architecture](https://sitectl.libops.io/apps)
- [Drupal sitectl plugin](https://sitectl.libops.io/plugins/drupal)

## Requirements

- [sitectl](https://sitectl.libops.io/install) installed on the host that will run the site.
- [`sitectl-drupal`](https://github.com/libops/sitectl-drupal) installed for Drupal create, validation, healthcheck, and helper commands.
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

## Local image build

The `drupal` service builds this checkout on top of the LibOps Drupal base image. The Dockerfile copies Composer lockfiles and assets before local modules, themes, config, and rootfs additions so Docker can reuse dependency layers when only site customizations change. Local builds use the platform selected by the Docker CLI and do not push images.

## Basic Operations

Run these from the generated checkout, or add `--context <name>` when operating from elsewhere.

Start or update the stack with [`sitectl compose`](https://sitectl.libops.io/commands/compose):

```bash
sitectl compose up --remove-orphans -d
```

Check the site and context configuration with [`sitectl healthcheck`](https://sitectl.libops.io/commands/healthcheck) and [`sitectl validate`](https://sitectl.libops.io/commands/validate):

```bash
sitectl healthcheck
sitectl validate
```

Update image tags or pin a full image reference with [`sitectl image`](https://sitectl.libops.io/commands/image):

```bash
sitectl image set --tag drupal=nginx-1.30.3-php84
sitectl image set --image drupal=libops/drupal:nginx-1.30.3-php84@sha256:...
```

Enable local development bind mounts with [`sitectl set`](https://sitectl.libops.io/commands/set), then apply the component change with [`sitectl converge`](https://sitectl.libops.io/commands/converge):

```bash
sitectl set dev-mode enabled
sitectl converge
```

Publish a domain, switch HTTP/TLS mode, configure Let's Encrypt, trust upstream proxies, or tune upload limits with the `ingress` component:

```bash
sitectl set ingress enabled --mode https-default --domain drupal.localhost
sitectl set ingress enabled --mode https-letsencrypt --domain drupal.example.org --acme-email ops@example.org
sitectl set ingress enabled --trusted-ip 203.0.113.10/32 --max-upload-size 2G --upload-timeout 10m
sitectl converge
```

See the [Drupal sitectl plugin docs](https://sitectl.libops.io/plugins/drupal) for Drush helpers, development mode, sync operations, login links, and Drupal-specific jobs.

## Makefile

The Makefile is intentionally small. It only keeps Drupal-specific targets that are not core sitectl operations:

```bash
sitectl deploy
make clean
make test
make lint
```

Use `sitectl compose ...` and `sitectl set ...` directly for normal stack operations.

## Template notes

- `traefik` is the only published ingress.
- `drupal` is built from this repository and based on the LibOps Drupal PHP/nginx image.
- `mariadb` stores application data.
- `solr` provides search.
- Secrets are generated into `./secrets/`.

Drupal code is Composer-managed. Custom modules and themes belong under `web/modules/custom` and `web/themes/custom`.

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. The Drupal recommended project is licensed separately under the GNU General Public License v2; see `LICENSE.drupal-recommended-project`.
