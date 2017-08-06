## Quick Deploy & Teardown

To deploy, execute the deploy.sh script. The will create an S3 bucket with open read permissions,
upload the necessary templates and scripts, and initiate stack deployment.

To teardown the stack, execute the delete.sh script. This will empty the deployment bucket,
delete the bucket, and initiate stack deletion.

## Topics

#### Creating a topic:
On a Zookeeper node (or Broker node in the case a separate Zookeeper node was not created),
run the following:
```
/opt/confluent-3.2.1/bin/kafka-topics --create \
    --zookeeper localhost:2181 \
    --replication-factor <integer replication factor for each partition in the topic> \
    --partitions <integer number of partitions for the topic> \
    --topic <your topic>
```

#### Listing topics
```
/opt/confluent-3.2.1/bin/kafka-topics --list \
    --zookeeper localhost:2181
```

## Notes

- The S3 bucket containing the nodegroup template and script must be
configured with read permissions for the EC2 instances in the kafka cluster.
For development, the bucket can be configured with public read permissions
by using the following bucket policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-deployments/*"
        }
    ]
}
```
