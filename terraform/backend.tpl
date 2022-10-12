terraform {
    backend "s3" {
        bucket  = "${BACKEND_S3_BUCKET_NAME}"
        key     = "${BACKEND_S3_FILE_NAME}"
        region  = "${BACKEND_S3_REGION}"
    }
}
