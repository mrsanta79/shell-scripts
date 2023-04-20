<h2 align='center'>Laravel Virtual Host Local Script</h2>

<h3 align='center'>This script creates a local vhost for your Laravel application using Apache2 web server. This script was inspired by Laravel Valet.</h3>

### Features

```text
- Create and access any laravel application with a unique domain name in your local environment.
- Create or Delete a vhost within seconds.
- <your_domain_name>.test
```

### Prerequisites

```text
- Ubuntu / Debian Based OS
- Make sure you have superuser (sudo) privilege.
- PHP
- 'libapache2-mod-php<version>' Extension
```

### Deployment

###### Create
```sh
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/mrsanta79/shell-scripts/main/laravel-vhost-local/create.sh)"
```

###### Delete
```sh
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/mrsanta79/shell-scripts/main/laravel-vhost-local/delete.sh)"
```
