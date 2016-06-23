#!/bin/bash

if [[ -z "$MBTS_MYSQL_USERNAME" || -z "$MBTS_MYSQL_PASSWORD" || -z "$MBTS_S3_BUCKET" ]]; then
    printf "\e[1;31mVARIABLES ARE NOT DEFINED!\e[00m Please check README.md\n"
    exit
fi

hash aws &> /dev/null
if [ $? -eq 1 ]; then
    printf "\e[1;31mCommand \`aws\` not found!\e[00m Please check README.md\n"
    exit
fi

# Timestamp (sortable AND readable)
stamp=`date +"%s - %A %d %B %Y @ %H%M"`

if [[ -z "$MBTS_MYSQL_HOST" ]]; then
    MBTS_MYSQL_HOST="127.0.0.1"
fi

# Get a list of database
databaseList=`mysql -h$MBTS_MYSQL_HOST -u$MBTS_MYSQL_USERNAME -p$MBTS_MYSQL_PASSWORD -e "SHOW DATABASES;" 2>/dev/null | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)"`
if [[ -z "$MBTS_MYSQL_DATABASES" ]]; then
    MBTS_MYSQL_DATABASES=databaseList
fi

if [[ ! -z "$MBTS_S3_PROFILE" ]]; then
    profileOption="--profile ${MBTS_S3_PROFILE}"
fi

printf "Dumping to \e[1;32m$MBTS_S3_BUCKET/$stamp/\e[00m\n"

for db in $MBTS_MYSQL_DATABASES; do
  filename="$stamp - $db.sql.gz"
  tmpfile="/tmp/$filename"
  object="$MBTS_S3_BUCKET/$stamp/$filename"

  printf "\e[1;34m$db\e[00m\n"

  echo $databaseList | grep $db > /dev/null

  if [ $? -eq 0 ]; then
    # Dump and zip
    printf "  creating \e[0;35m$tmpfile\e[00m\n"
    mysqldump -h$MBTS_MYSQL_HOST -u$MBTS_MYSQL_USERNAME -p$MBTS_MYSQL_PASSWORD --force --opt --databases "$db" 2>/dev/null | gzip -c > "$tmpfile"

    # Upload
    echo "  `aws s3 $profileOption cp "$tmpfile" "$object"`"

    # Delete
    rm -f "$tmpfile"
  else
    printf "  \e[0;35mdatabase does not exist!\e[00m\n"
  fi
done

# Cleanup old backups
if [[ ! -z "$MBTS_BACKUPS_RETAIN" ]]; then
  printf "Cleaning up old backups... \e[1;32mRetaining ONLY $MBTS_BACKUPS_RETAIN backups\e[00m\n"
  backups=`aws s3 $profileOption ls "$MBTS_S3_BUCKET/" | sed -n -e :a -e "1,$MBTS_BACKUPS_RETAIN!{P;N;D;};N;ba" | tr -d "PRE" | sed -e 's/^[[:space:]]*//' | tr " " "_"`
  if [[ ! -z "$backups" ]]; then
    for backup in $backups; do
      folder=`echo $backup | tr "_" " "`
      printf "  Deleting \e[0;35m$folder...\e[00m\n"
      aws s3 $profileOption rm --quiet --recursive "$MBTS_S3_BUCKET/$folder"
    done
  else
    printf "  Nothing to delete\n"
  fi
fi

printf "\e[1;32mDONE!\e[00m\n"