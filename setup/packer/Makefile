.PHONY: all
all: build/tsx-desktop/tsx-desktop.ova

build/ubuntu1804/ubuntu1804.ova: ubuntu1804.json
	packer build -force ubuntu1804.json

build/tsx/tsx.ova: ubuntu1804-tsx.json build/ubuntu1804/ubuntu1804.ova ../ubuntu-setup-tsx.sh
	packer build -force ubuntu1804-tsx.json

build/tsx-desktop/tsx-desktop.ova: ubuntu1804-tsx-desktop.json build/tsx/tsx.ova scripts/*.sh ../ubuntu-setup-desktop.sh
	packer build -force ubuntu1804-tsx-desktop.json

.PHONY: clean

clean:
	rm -rf build/*
