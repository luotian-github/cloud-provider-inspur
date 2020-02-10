# tab space is 4
# GitHub viewer defaults to 8, change with ?ts=4 in URL

# Vars describing project
NAME= cloud-provider-inspur
GIT_REPOSITORY= github.com/inspurcsg/cloud-provider-inspur
IMG?= registry.inspurcloud.cn:5000/csf/inspur-cloud-controller-manager

# Set defaults for needed vars in case version_info script did not set
# Revision set to number of commits ahead
VERSION							?= 0.0
COMMITS							?= 0
REVISION						?= $(COMMITS)
BUILD_LABEL						?= unknown_build
BUILD_DATE						?= $(shell date -u +%Y%m%d.%H%M%S)
GIT_SHA1						?= unknown_sha1
IMAGE_LABLE                     ?= $(BUILD_LABEL)

# default just build binary
default: go-build

# target for debugging / printing variables
print-%:
@echo '$*=$($*)'

# perform go build on project
go-build:
bin/cloud-provider-inspur

bin/cloud-provider-inspur:
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-w" -o bin/manager ./cmd/main.go

bin/.docker-images-build-timestamp:
bin/cloud-provider-inspur Makefile Dockerfile
docker build -q -t $(DOCKER_IMAGE_NAME):$(IMAGE_LABLE) -t dockerhub.inspurcloud.com/$(DOCKER_IMAGE_NAME):$(IMAGE_LABLE) . > bin/.docker-images-build-timestamp

publish:
test go-build
docker build -t ${IMG}  -f deploy/Dockerfile bin/
docker push ${IMG}

clean:
rm -rf bin/ && if -f bin/.docker-images-build-timestamp then docker rmi `cat bin/.docker-images-build-timestamp`

test:
fmt vet
go test -v -cover -mod=vendor ./pkg/...

fmt:
go fmt ./pkg/... ./cmd/... ./test/pkg/...

vet:
go vet ./pkg/... ./cmd/... ./test/pkg/...

.PHONY:
default all go-build clean install-docker test