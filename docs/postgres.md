# Postgres flavor

* [Common env vars][#common-env-vars]
* [`akerouanton/db-backups-to-gcs:postgres-dump-0.2`](#akerouanton-db-backups-to-gcs-postres-dump-02)

### Common env vars

This tool support all the [libpq env vars](https://www.postgresql.org/docs/9.1/static/libpq-envars.html).
The most interesting are:

* `PGHOST`
* `PGPORT`
* `PGDATABASE`
* `PGUSER`
* `PGPASSWORD`

### `akerouanton/db-backups-to-gcs:postgres-dump-0.2`

Following env vars are required:

* `GCLOUD_SERVICE_ACCOUNT_KEY_FILE`
* `BUCKET_NAME`

With Docker:

```bash
docker run --rm -it \
  --env PGHOST=db
  --env PGDATABASE=my_db
  --env PGUSER=admin
  --env PGPASSWORD=my_password
  --env GCLOUD_SERVICE_ACCOUNT_KEY_FILE=/gcloud-sa.json
  --env BUCKET_NAME=db-backup
  --volume ./gcloud-sa.json:/gcloud-sa.json:ro
  akerouanton/db-backups-to-gcs:postgres-dump-0.2
```

### `akerouanton/db-backups-to-gcs:postgres-restore-0.2`

Following env vars are required:

* `GCLOUD_SERVICE_ACCOUNT_KEY_FILE`
* `BUCKET_NAME`

With Docker:

```bash
docker run --rm -it \
  --env PGHOST=db
  --env PGDATABASE=my_db
  --env PGUSER=admin
  --env PGPASSWORD=my_password
  --env GCLOUD_SERVICE_ACCOUNT_KEY_FILE=/gcloud-sa.json
  --env BUCKET_NAME=db-backup
  --volume ./gcloud-sa.json:/gcloud-sa.json:ro
  akerouanton/db-backups-to-gcs:postgres-restore-0.2
  my_db-20181018131600.tar.gz
```
