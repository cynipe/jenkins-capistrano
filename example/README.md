# jenkins-capistrano example

This is a example **batch** project with jekins-capistrano configs
which deploy and configure the following staff to the master-slave Jenkins:

* A job to execute the batch program
* A node to excute the job
* The batch program itself

## Deploy

### Development

```
$ script/deploy
```

### Staging

```
$ script/deploy staging
```

### Production

```
$ script/deploy production
```
