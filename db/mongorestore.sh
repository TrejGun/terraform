#!/usr/bin/env bash

mongorestore --uri=mongodb://localhost --drop $1
