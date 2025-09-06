#!/bin/bash

docker build -o - . | gzip > crun-binary.tar.gz
tar tvf crun-binary.tar.gz
