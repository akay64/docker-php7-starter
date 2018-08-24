#!/usr/bin/env bash
# turns on cron process and php

cron -f &
exec php-fpm