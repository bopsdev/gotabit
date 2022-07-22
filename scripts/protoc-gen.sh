#!/usr/bin/env bash

set -eo pipefail

# get protoc executions
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v1.16.0
go install github.com/bufbuild/buf/cmd/buf@v1.6.0
GO111MODULE=off go get github.com/cosmos/gogoproto/protoc-gen-gocosmos

echo "Generating gogo proto code"
cd proto
proto_dirs=$(find ./gotabit -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
  for file in $(find "${dir}" -maxdepth 1 -name '*.proto'); do
    if grep go_package $file &>/dev/null; then
      buf generate --template buf.gen.gogo.yaml $file
    fi
  done
done

cd ..

# move proto files to the right places
#
# Note: Proto files are suffixed with the current binary version.
cp -r github.com/bopsdev/gotabit/* ./

rm -rf github.com

go mod tidy
