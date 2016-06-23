# MySQL Amazon S3 Backup
A simple script to backup your MySQL database(s) to Amazon S3 from your server.

# Prerequisites
#### 1. MySQL Client
A MySQL client is required to execute `mysql` & `mysqldump` commands
#### 2. AWS CLI
[AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) is a unified tool to manage your AWS services. This is used to upload files to Amazon S3.

- **Installing `aws` CLI**:
AWS recommends installation using `pip` which required root/admin priviledges. If you would like to install it locally, use the [Bundled Installer](http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os):
  ```
  $ curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
  $ unzip awscli-bundle.zip
  $ ./awscli-bundle/install -b ~/bin/aws
  $ chmod +x ~/bin/aws
  ```

- **Configure your `aws`**:
  ```
  $ aws configure
  ```
  [Learn more about AWS CLI profiles](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles)

# Script Installation
Clone / download this repository on your server. The `mysqlBackupToS3.sh` script is available inside the cloned folder. Make the script executable:
```
$ chmod +x mysqlBackupToS3.sh
```

# Setup & Configuration
The script runs on environment variables (no parameters need to be passed). Below two sections provied a list of required and optional variables.

## Environment Variables
### MySQL
- [**required**] `MBTS_MYSQL_USERNAME` (e.g., "db_user")
- [**required**] `MBTS_MYSQL_PASSWORD` (e.g., "mysql")
- [optional] `MBTS_MYSQL_HOST` (e.g., "127.0.0.1")
- [optional] `MBTS_MYSQL_DATABASES` (Separated by space: e.g., "databaseOne databaseTwo")

### Amazon S3
- [**required**] `MBTS_S3_BUCKET` (e.g., "s3://bucketName")
- [optional] `MBTS_S3_PROFILE` (e.g., "myS3Profile")

# Running the script
You can run the script in two ways:
#### 1. Global Environemnet variable
To export your environment variable, execute the following in your shell: `export VARIABLE_NAME="VALUE"`. To persist the variable, add them to `~/.bash_profile` file. After this, run:
```
$ ./mysqlBackupToS3.sh
```
#### 2. Local Environment variable
If you do not prefer exporting / storing the environment variable, use the following:
```
$ env MBTS_MYSQL_USERNAME="db_user" MBTS_MYSQL_PASSWORD="mysql" MBTS_S3_BUCKET="s3://bucketName" ./mysqlBackupToS3.sh
```

# Retention
The optional `MBTS_BACKUPS_RETAIN` environment variable determines number of backups to be retained in Amazon S3 bucket. This makes it possible to have monthly, weekly & daily backups as such:
#### Retain 7 daily backups
```
$ env MBTS_MYSQL_USERNAME="db_user" MBTS_MYSQL_PASSWORD="mysql" MBTS_BACKUPS_RETAIN=7 MBTS_S3_BUCKET="s3://bucketName/daily" ./mysqlBackupToS3.sh
```
#### Retain 1 monthly backup
```
$ env MBTS_MYSQL_USERNAME="db_user" MBTS_MYSQL_PASSWORD="mysql" MBTS_BACKUPS_RETAIN=1 MBTS_S3_BUCKET="s3://bucketName/monthly" ./mysqlBackupToS3.sh
```
_Please not that the number of files retained includes the lastest backup_

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