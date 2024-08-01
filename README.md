# toodaloo

A simple to-do list application built using Django 5 and Python 3.11+.

## Development / Testing

Basic requirements:

- A Debian/Ubuntu based OS or environment.
- Python 3.11+ installed and is the default for `python3` command.

Local development and testing is done against a local sqlite database file that
is created when the project is initialized following the steps below.

### Environment Setup

Create an isolated virtual environment for the Python 3.11+ project. For example:

```shell
mkdir -p ~/.virtualenvs
python3 -m venv ~/.virtualenvs/toodaloo
```

Activate the virtual environment and install Python requirements:

```shell
source ~/.virtualenvs/toodaloo/bin/activate
pip install -r requirements.txt
```

Note that installing the `psycopg2` package _may_ require additional OS packages
be installed. For example:

```shell
sudo apt install libpq-dev python3-dev
```

### Django Application Setup

Apply database migrations:

```shell
./manage.py migrate
```

Initialize database cache (not required in production mode):

```shell
./manage.py createcachetable
```

Run local development server (not suitable for production):

```shell
./manage.py runserver
```

Visit http://127.0.0.1:8000 to use the web application. Sign up for an account,
login, and create, read, update or delete tasks.

### Running Tests

Run the tests with `pytest`:

```shell
pytest
```

Test reports can be found in the `build/reports/` directory. These reports can
be ingested by CI jobs.

### Running Static Analysis Checks

Ensure the code meets all quality standards:

```shell
black --check .
isort --check .
ruff check
```

If any of these commands fail, then there are issues that need to be fixed.

### Building a Package

Build the application into a distributable package (`whl` file):

```shell
python -m build --wheel --outdir build/dist
```

The output `whl` file will be in `build/dist`. This file can be installed with
`pip` on other systems or environments. For example:

```shell
pip install build/dist/toodaloo-1.0.0-py3-none-any.whl
```

## Production

On a production environment, install the `whl` package that was built above 
with `pip install`. Once installed, the `toodaloo` command should be available.

When running in production, the environment variable `PRODUCTION` must be set
to `true` on the system. To run commands explicitly you can also use:

```shell
PRODUCTION=true toodaloo
```

Production specific settings and there corresponding environment variable names
can be found in `toodaloo/toodaloo/settings/production.py`.

Environment variables must be set for PostgreSQL database credentials, and the 
Redis connection string.

### PostgreSQL Database

A PostgreSQL database must be created for the application to use. For example:

```sql
CREATE DATABASE toodaloo;
CREATE USER toodaloo WITH ENCRYPTED PASSWORD 'toodaloo';
GRANT ALL PRIVILEGES ON SCHEMA toodaloo TO toodaloo;
GRANT ALL PRIVILEGES ON DATABASE toodaloo TO toodaloo;
```

Pass the credentials, database name, host, and port to the Django application
using their corresponding environment variables.

### Redis

Redis is used by the Django application as a caching layer in production. 

Pass the full redis connection string to the Django application using the
corresponding environment variable.

### Django

Ensure the database is initialized, and the latest migrations are applied:

```shell
PRODUCTION=true toodaloo migrate
```

Run the application using `gunicorn`:

```shell
PRODUCTION=true gunicorn toodaloo.wsgi
```
