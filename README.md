# EKS

- [EKS](#eks)
  - [1. Requirements](#1-requirements)
  - [2. Deploy](#2-deploy)
  - [3. Destroy](#3-destroy)
  - [4. Cleanup deploy files](#4-cleanup-deploy-files)

## 1. Requirements

Create a .secrets file with the bucket name:

```shell
BACKEND_S3_BUCKET_NAME=<bucket_name>
```

Also, make sure you have created the `~/.aws/credentials` file with your AWS keys and region.

## 2. Deploy

```shell
make deploy
```

## 3. Destroy

```shell
make destroy
```

## 4. Cleanup deploy files
```shell
make cleanup
```
