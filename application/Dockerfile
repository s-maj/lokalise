FROM  public.ecr.aws/docker/library/python:3.10-slim

EXPOSE 8000

COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock

RUN apt-get update \
    && pip install --no-cache-dir pipenv \
    && pipenv install --system --deploy

COPY app /app

RUN useradd -ms /bin/bash uvicorn \
    && chown uvicorn /app

WORKDIR /app
USER uvicorn

CMD ["uvicorn", "main:app", "--proxy-headers", "--host", "0.0.0.0", "--port", "8000"]
