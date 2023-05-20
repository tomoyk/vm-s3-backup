# vm-s3-backup

This program provides config and contents backup from VM to Amazon S3.

## Files

- backup.sh: main code for backup
- password.conf: password file for mysql client
- systemd/s3-backup.service: systemd service file
- systemd/s3-backup.timer: systemd timer file

## Usage

1) Install AWS CLI

[Command Line Interface - AWS CLI - AWS](https://aws.amazon.com/cli/)

2) Create IAM user and setup AWS CLI using the IAM user

3) Create IAM role and assign this IAM role to the IAM user

Note that you can replace `<YOUR_BUCKETNAME>` and `<YOUR_IP_ADDRESS>` as your environment variable.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::<YOUR_BACKETNAME>",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "<YOUR_IP_ADDRESS>/32"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::<YOUR_BACKETNAME>/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "<YOUR_IP_ADDRESS>/32"
                }
            }
        }
    ]
}
```

4) Create mysql user and grants read-only permission

```
$ sudo mysql
mysql> CREATE USER 's3-backup'@'localhost' IDENTIFIED BY 'xxx';
mysql> GRANT SELECT,LOCK TABLES ON wordpress.* TO 's3-backup'@'localhost';
mysql> exit;
```

5) Execute a backup script for test

```
./backup.sh
```

6) Register a systemd timer

```
cp s3-backup.service /etc/systemd/system/
cp s3-backup.timer /etc/systemd/system/

systemctl start s3-backup
systemctl enable s3-backup

systemctl list-timers
```
