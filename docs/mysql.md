## MySQL flavor

### `akerouanton/db-backups-to-gcs:mysql-dump-0.2`

Required env vars:

* `GCLOUD_SERVICE_ACCOUNT_KEY_FILE`
* `MYSQL_HOST`
* `MYSQL_USER`
* `MYSQL_PASSWORD` or `MYSQL_PWD` or `MYSQL_PWD_FILE`
* `MYSQL_DATABASE`
* `BUCKET_NAME`

With Docker:

```bash
docker run --rm \
  --env GCLOUD_SERVICE_ACCOUNT_KEY_FILE=/gcloud-sa.json
  --env BUCKET_NAME=db-backup
  --volume ./gcloud-sa.json:/gcloud-sa.json:ro
  akerouanton/db-backups-to-gcs:mysql-dump-0.2
  --single-transaction --quick
```

### `akerouanton/db-backups-to-gcs:mysql-restore-0.2`

With Docker:

```bash
docker run --rm -it \
  --env GCLOUD_SERVICE_ACCOUNT_KEY_FILE=/gcloud-sa.json
  --env BUCKET_NAME=db-backup
  --volume ./gcloud-sa.json:/gcloud-sa.json:ro
  akerouanton/db-backups-to-gcs:mysql-restore-0.2
  my_db-20181018131600.tar.gz
```
