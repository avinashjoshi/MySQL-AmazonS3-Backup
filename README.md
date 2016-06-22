# MySQL Amazon S3 Backup
A simple script to backup your MySQL database(s) to Amazon S3 from your server.

# Prerequisites
- MySQL client - to execute `mysql` & `mysqldump` commands
- [AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) - a unified tool to manage your AWS services.

# Installation
Clone / download this repository on your server.

# Setup & Configuration
The script runs on environment variables (no parameters need to be passed). To export your environment variable, execute the following in your shell: `export VARIABLE_NAME="VALUE"`. To persist the variable, add them to `~/.bash_profile` file.

Below two sections provied a list of required and optional variables.

## MySQL
### Environment Variables
- [**required**] `MBTS_MYSQL_USERNAME` (e.g., "db_user")
- [**required**] `MBTS_MYSQL_PASSWORD` (e.g., "mysql")
- [optional] `MBTS_MYSQL_HOST` (e.g., "127.0.0.1")
- [optional] `MBTS_MYSQL_DATABASES` (Separated by space: e.g., "databaseOne databaseTwo")

## Amazon S3
### Configuration & Profiles
- [Configure your AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
- [Learn more about AWS CLI profiles](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles)

### Environment Variables
- [**required**] `MBTS_S3_BUCKET` (e.g., "s3://bucketName")
- [optional] `MBTS_S3_PROFILE` (e.g., "myS3Profile")

# Running your script
```
# Add the executable bit
chmod +x mysqlBackupToS3.sh
# Run the script to make sure it's all tickety boo
./mysqlBackupToS3.sh
```

# Recommendations
1. Run the script daily - add the following lines to your `crontab`:

    ```
    # Run the database backup script at 2am every day
    0 2 * * * bash /path/to/script/mysqlBackupToS3.sh >/dev/null 2>&1
    ```
    _Note: Crontab can be edited using `crontab -e` command._

2. It is recommended against cloning/downloading it on the webroot directories e.g., `public_html` or `www`
3. Create an AWS IAM user dedicated to only access the specific S3 backup bucket so that this user/key-pair cannot access other AWS services/resources.
    Here is an example policy:

    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::bucketName"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::bucketName/*"
                ]
            }
        ]
    }
    ```

# Contributing
If you happen to stumble upon a bug or would like a feature to be added, please feel free to `fork` the repository, `make fixes` and create a `pull request`.
You can also create an issue with a description to raise awareness of the bug.

- Create an issue [optional]
- Fork
- Mod, fix
- Pull request