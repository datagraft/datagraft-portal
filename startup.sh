#!/bin/bash

until rails runner "exit 1 unless ActiveRecord::Base.connection.active?" 2>/dev/null >/dev/null; do sleep 1; done && rails server -b 0.0.0.0