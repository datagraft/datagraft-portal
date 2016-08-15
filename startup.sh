#!/bin/bash

until head -c 0 </dev/tcp/database-host/5432; do sleep 1; done && rails server -b 0.0.0.0