# Welcome to the Labs website of JUMPSEC.com

To checkout the website head over to [https://labs.jumpsec.com/ ↗](https://labs.jumpsec.com/)

## Hextra Starter Template

We are using hextra as a base template for our Hugo based website.
[🌐 Demo ↗](https://imfing.github.io/hextra-starter-template/)

## Local Development

Pre-requisites: [Git ↗](https://git-scm.com), [Docker ↗](https://www.docker.com/get-started/)

### 1. Download the code

```sh
git clone https://github.com/JumpsecLabs/JumpsecLabs.git
```

If your local copy is outdated and you did not change any files:

```sh
cd JumpsecLabs

git pull origin main
```

### 2. (Optional) Configure the environment

You can edit the `dev.env` file to change the dev server behaviour,
the following environment variables are available:

* `HUGO_VERSION` is the Hugo release version to use (default: same as deploy version).
* `HUGO_PORT` is the port the local server will listen on (default: 9000).
* `HUGO_UID` is the UID that the dev server process will be run as (default: 1000).
* `HUGO_GID` is the GID that the dev server process will be run as (default: 1000).

### 3. Start the development server

The dev environment uses [Docker Compose](https://docs.docker.com/compose/).

```sh
cd JumpsecLabs

docker compose --env-file dev.env up --build
```

Once running, with default settings, the Labs website will be available
at [http://localhost:9000/](http://localhost:9000/).

To stop the instance just press CTRL-C.
