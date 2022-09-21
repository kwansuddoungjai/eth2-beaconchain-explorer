GITCOMMIT=`git describe --always`
VERSION=$$(git describe 2>/dev/null || echo "0.0.0-${GITCOMMIT}")
GITDATE=`TZ=UTC git show -s --date=iso-strict-local --format=%cd HEAD`
BUILDDATE=`date -u +"%Y-%m-%dT%H:%M:%S%:z"`
PACKAGE=eth2-exporter
LDFLAGS="-X ${PACKAGE}/version.Version=${VERSION} -X ${PACKAGE}/version.BuildDate=${BUILDDATE} -X ${PACKAGE}/version.GitCommit=${GITCOMMIT} -X ${PACKAGE}/version.GitDate=${GITDATE} -s -w"

all: explorer stats frontend-data-updater

lint:
	golint ./...

test:
	go test -tags=blst_enabled ./...

explorer:
	rm -rf bin/
	mkdir -p bin/
	go run cmd/bundle/main.go
	go install github.com/swaggo/swag/cmd/swag@v1.8.3 && swag init --exclude bin,_gitignore,.vscode,.idea --parseDepth 1 -g ./handlers/api.go
	go build --ldflags=${LDFLAGS} -o bin/explorer cmd/explorer/main.go

chartshotter:
	go build --ldflags=${LDFLAGS} -o bin/chartshotter cmd/chartshotter/main.go

stats:
	go build --ldflags=${LDFLAGS} -o bin/statistics cmd/statistics/main.go

frontend-data-updater:
	go build --ldflags=${LDFLAGS} -o bin/frontend-data-updater cmd/frontend-data-updater/main.go