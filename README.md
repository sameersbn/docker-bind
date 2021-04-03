# windoac/bind

forked from [sameersbn/docker-bind](https://github.com/sameersbn/docker-bind)

Most of the setting should be same.

## new add feature for this forked

1. Supported cron. Will save the current crontab content/job when the container stops and load it when starts.
2. Option to run the bind(named) with option `-f` instead of `-g`

### 2. Option to run the bind(named) with option `-f` instead of `-g`

* `BIND_LOG_STDERR`: If BIND send the log to STDERR or not. Defaults to `true`. 
   If you do when to output log to file, set this to false.

## info

dockerhub forked from sameersbn/bind
https://hub.docker.com/r/sameersbn/bind

Dockerfile see
https://github.com/WindoC/docker-bind/blob/master/Dockerfile

docker-cmpose.yml example see
https://github.com/WindoC/docker-bind/blob/master/docker-compose.yml
