VERSION ?= dev

.PHONY: build
build: build-dump build-restore

.PHONY: build-dump
build-dump:
	docker build --target dump -t akerouanton/postgres-gcs-backup:dump-$(VERSION) .

.PHONY: build-restore
build-restore:
	docker build --target restore -t akerouanton/postgres-gcs-backup:restore-$(VERSION) .

.PHONY: push
push:
ifeq (dev,$(VERSION))
	@echo "You have to specify a version to push."
	@exit 1
endif
	docker push akerouanton/postgres-gcs-backup:dump-$(VERSION)
	docker push akerouanton/postgres-gcs-backup:restore-$(VERSION)
