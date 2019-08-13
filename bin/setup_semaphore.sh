#!/usr/bin/env bash

sem connect col.semaphoreci.com API_TOKEN

sem create secret dockerhub-secrets \
  -e DOCKER_USERNAME=colharris \
  -e DOCKER_PASSWORD=DOCKERHUB_PASSWORD
