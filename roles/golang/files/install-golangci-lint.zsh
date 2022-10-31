#!/usr/bin/env zsh

source $HOME/.zshrc

curl -sSfL \
  https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
  sh -s -- -b $(go env GOROOT)/bin v1.46.2
