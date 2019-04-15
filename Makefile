VERSION ?= dev

.PHONY: build
build: build-dump build-restore

.PHONY: build-dump
build-dump:
	docker build \
		--target dump \
		--build-arg IMAGE_VERSION=$(VERSION) \
		-t akerouanton/db-backups-to-gcs:postgres-dump-$(VERSION) postgres
	docker build \
		--target dump \
		--build-arg IMAGE_VERSION=$(VERSION) \
		-t akerouanton/db-backups-to-gcs:mysql-dump-$(VERSION) mysql

.PHONY: build-restore
build-restore:
	docker build \
		--target restore \
		--build-arg IMAGE_VERSION=$(VERSION) \
		-t akerouanton/db-backups-to-gcs:postgres-restore-$(VERSION) postgres
	docker build \
		--target restore \
		--build-arg IMAGE_VERSION=$(VERSION) \
		-t akerouanton/db-backups-to-gcs:mysql-restore-$(VERSION) mysql

.PHONY: push
push:
ifeq (dev,$(VERSION))
	@echo "You have to specify a version to push."
	@exit 1
endif
	docker push akerouanton/db-backups-to-gcs:postgres-dump-$(VERSION)
	docker push akerouanton/db-backups-to-gcs:postgres-restore-$(VERSION)
	docker push akerouanton/db-backups-to-gcs:mysql-dump-$(VERSION)
	docker push akerouanton/db-backups-to-gcs:mysql-restore-$(VERSION)
