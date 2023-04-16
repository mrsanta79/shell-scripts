<h3 align='center'>Laravel Application Deployment Script</h3>

---

<h6 align='center'> This script will install and configure a LAMP stack for your Laravel application on your freshly installed Ubuntu server within minutes.</h6>

#### Features

```text
- Apache
- PHP (Any version available in ondrej/php repository)
- MariaDB (Optional)
- NodeJS (Any version through NVM)
- Python 3
- Certbot for SSL Certification generations
- PHP upload max file size and maximum ram allocation size increased to 512M
```

#### Prerequisites

What things you need to install the software and how to install them.

```text
- Freshly installed Ubuntu Server (Preferred 20.04 or greater)
- Make sure you have superuser (sudo) privilege.
```

#### Deployment

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/mrsanta79/shell-scripts/main/laravel-deploy/deploy.sh)"
```
