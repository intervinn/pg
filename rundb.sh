#!/bin/bash
docker run --rm -p 5432:5432 -e "POSTGRES_PASSWORD=password" postgres:alpine
# im so tired of typing this every time
