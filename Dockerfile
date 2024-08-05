# Use a Docker image with Python 3.11
FROM python:3.11.7

# Set the working directory to /usr/src/app
WORKDIR /usr/src/app

# Create a virtual environment
RUN mkdir -p ~/.virtualenvs
RUN python -m venv ~/.virtualenvs/toodaloo
RUN . ~/.virtualenvs/toodaloo/bin/activate

# Copy wheel file to the working directory and install it
COPY ./build/dist/*.whl .
RUN pip install *.whl

# Expose port 8000
EXPOSE 8000

# run application and migrate database on startup in parallel
CMD ["/bin/sh", "-c", "PRODUCTION=true gunicorn toodaloo.wsgi & PRODUCTION=true toodaloo migrate"]