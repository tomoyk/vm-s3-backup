#!/bin/bash -ex

### Create mysql user
#
# 1) CREATE USER 's3-backup'@'localhost' IDENTIFIED BY 'xxx';
# 2) GRANT SELECT,LOCK TABLES ON wordpress.* TO 's3-backup'@'localhost';

cd `dirname $0`
declare current=$(date +%Y-%m-%dT%H:%M:%S)
declare LOG_FILENAME="run.${current}.log"
log () {
  echo -e "$(date +'%Y-%m-%d %H:%M:%S')\t$(hostname):\t$1" | tee -a "$LOG_FILENAME"
}

declare tmp_dir=$(mktemp -d tmp.XXXXXX)
declare mysql_user="s3-backup"
declare mysql_database="wordpress"
declare mysql_host="localhost"
log "Create mariadb dump"
mysqldump --defaults-extra-file=password.conf \
  -u ${mysql_user} -h ${mysql_host} ${mysql_database} > ${tmp_dir}/mariadb.dump

declare -A backup_targets=(
  ["conf_nginx"]="/etc/nginx/"
  ["conf_php-fpm"]="/etc/php/8.1/fpm/"
  ["conf_mariadb"]="/etc/mysql/"
  ["conf_exim"]="/etc/exim4/"
  ["dump_mariadb"]="$PWD/$tmp_dir"
  ["site_var-www"]="/var/www/"
  ["site_koyama.me"]="/home/deploy-portfolio/www/"
  ["site_wiki.koyama.me"]="/home/deploy-wiki/www/"
  ["site_resume"]="/home/deploy-resume/www/"
)
for key in ${!backup_targets[@]}
do
  target_path=${backup_targets[$key]}
  log "Copy: key=$key target_path=$target_path"
  aws s3 cp $target_path s3://gcp-free1-backup/${current}/${key}/ --recursive || true
done

# aws s3 ls s3://gcp-free1-backup/${current}/
log "Delete tmp_dir"
rm -rf "$PWD/$tmp_dir"
