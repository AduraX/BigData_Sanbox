#!/usr/bin/env bash

aws s3 cp s3://{{hdp_Bucket}}/lib  {{arch_dir}}/ --recursive
