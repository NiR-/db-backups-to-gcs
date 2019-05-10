VERSION ?= dev
FLAVORS ?= postgres mysql

.PHONY: build
build: build-dump build-restore

.PHONY: build-dump
build-dump:
	for flavor in $(FLAVORS); do \
		docker build \
			--target dump \
			--build-arg IMAGE_VERSION=$(VERSION) \
			-t akerouanton/db-backups-to-gcs:$${flavor}-dump-$(VERSION) $${flavor}; \
	done

.PHONY: build-restore
build-restore:
	for flavor in $(FLAVORS); do \
		docker build \
			--target dump \
			--build-arg IMAGE_VERSION=$(VERSION) \
			-t akerouanton/db-backups-to-gcs:$${flavor}-dump-$(VERSION) $${flavor}; \
	done

.PHONY: push
push:
ifeq (dev,$(VERSION))
	@echo "You have to specify a version to push."
	@exit 1
endif
	for flavor in '$(FLAVORS)'; do \
		docker push akerouanton/db-backups-to-gcs:$$(flavor)-dump-$(VERSION); \
		docker push akerouanton/db-backups-to-gcs:$$(flavor)-restore-$(VERSION); \
	done
