# postgres-gcs-backup

This simple docker image have a few different flavors:

* `dump-0.1`: Does a dump of a postgresql DB and then uploads it to a GCS bucket.
* `restore-0.1`: Retrieve a prior dump from a GCS bucket and load it.

## Common env vars

This tool support all the [libpq env vars](https://www.postgresql.org/docs/9.1/static/libpq-envars.html).
The most interesting are:

* `PGHOST`
* `PGPORT`
* `PGDATABASE`
* `PGUSER`
* `PGPASSWORD`

## `postgres-gcs-backup:dump-0.1`

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
  postgres-gcs-backup:dump-0.1
```

## `postgres-gcs-backup:restore-0.1`

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
  postgres-gcs-backup:restore-0.1
  my_db-20181018131600.tar
```

## Service account & custom role

You can either give following roles to your service account:

* roles/storage.objectCreator
* roles/storage.objectViewer

Or create a dedicated role with following permissions:

* storage.objects.get
* storage.objects.list
* storage.objects.create

```bash
$ gcloud iam service-accounts create \
    --display-name "postgres-gcs-backup" \
    postgres-gcs-backup
$ # Create a Google role dedicated to the service account created above
$ gcloud iam roles create \
    PostgresGcsBackup \
    --description="Service account used by postgres-gcs-backup to upload backups to GCS" \
    --permissions=storage.objects.get,storage.objects.list,storage.objects.create \
    --stage=GA \
    --title="postgres-gcs-backup" \
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
$ # Finally, provision k8s with a secret containing the key-pair fetched above
$ kubectl create secret generic \
    postgres-gcs-backup-gcloud-sa \
    --from-file=service-account.json=gcloud-service-account.json \
    --namespace=taiga
```

## Automatic lifecycle management

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
