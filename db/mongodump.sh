#!/usr/bin/env bash

dt=`date '+%d-%m-%Y'`

mongodump --uri=mongodb://localhost/optimize --out dump_$dt


