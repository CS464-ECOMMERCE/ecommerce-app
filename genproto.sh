#!/bin/bash

# PATH=$PATH:$(go env GOPATH)/bin
protodir=./proto
outdir=proto

protoc --proto_path=$protodir --go_out=./backend/$outdir --go_opt=paths=source_relative --go-grpc_out=./backend/$outdir --go-grpc_opt=paths=source_relative $protodir/ecommerce.proto

protoc --proto_path=$protodir --go_out=./product/$outdir --go_opt=paths=source_relative --go-grpc_out=./product/$outdir --go-grpc_opt=paths=source_relative $protodir/ecommerce.proto

protoc --proto_path=$protodir --go_out=./cart/$outdir --go_opt=paths=source_relative --go-grpc_out=./cart/$outdir --go-grpc_opt=paths=source_relative $protodir/ecommerce.proto

protoc-go-inject-tag -input=./backend/$outdir/ecommerce.pb.go
protoc-go-inject-tag -input=./product/$outdir/ecommerce.pb.go
protoc-go-inject-tag -input=./cart/$outdir/ecommerce.pb.go
