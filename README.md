# db-backups-to-gcs

* [postgresql](#postgresql)
* [Configure GCS](#configure-gcs)

## postgresql

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
  my_db-20181018131600.tar
```

## Configure GCS

You can either give following roles to your service account:

* `roles/storage.objectCreator`
* `roles/storage.objectViewer`

Or create a dedicated role with following permissions:

* `storage.objects.get`
* `storage.objects.list`
* `storage.objects.create`

```bash
$ gcloud iam service-accounts create \
    --display-name "db-backups-to-gcs" \
    db-backups-to-gcs
$ # Create a Google role dedicated to the service account created above
$ gcloud iam roles create \
    DbBackupsToGcs \
    --description="Service account used by db-backups-to-gcs to upload backups to GCS" \
    --permissions=storage.objects.get,storage.objects.list,storage.objects.create \
    --stage=GA \
    --title="db-backups-to-gcs" \
    --project <project-id>
$ # Retrieve the email address of the dedicated service account
$ gcloud iam service-accounts list
$ # Bind the role to the prior service account
$ gcloud projects add-iam-policy-binding \
    <project_id> \
    --member=serviceAccount:<service_account_email_address> \
    --role=projects/<project_id>/roles/PostgresGcsBackup
$ # Retrieve the key-pair associated to the prior service account to authenticate
$ # against Google APIs
$ gcloud iam service-accounts keys create \
    gcloud-service-account.json \
    --iam-account=<service_account_email_address>
```

### Automatic lifecycle management

Dumps can be automatically deleted or moved to another storage class, after
some time, thanks to [GCS lifecycle policy](https://cloud.google.com/storage/docs/lifecycle)
mechanism. Here's an example:

```bash
$ cat backup-lifecycle.json
{
    "lifecycle": {
        "rule": [
            {
                "action": {"type": "Delete"},
                "condition": {
                    "age": 30
                }
            }
        ]
    }
}
$ gsutil lifecycle set backups-lifecycle.json gs://db-backups
```
