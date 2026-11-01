.PHONY: all build bundle run clean zip

all: bundle

build:
	swift build -c release

bundle:
	./bundle.sh

run: bundle
	open Cafaine.app

zip: bundle
	zip -r -y Cafaine-macos.zip Cafaine.app
	@echo "Created Cafaine-macos.zip"

clean:
	rm -rf .build Cafaine.app Cafaine-macos.zip
