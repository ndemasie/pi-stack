#!/bin/bash

function generate_container_table_row() {
  local container="$1"
  local conf_file_path="./containers/${container}/.conf"
  [ -f $conf_file_path ] && source $conf_file_path

  : ${image:=$container}; [ ! -z $doc_image_link ] && image="[${image}](${doc_image_link})"
  : ${name:=$container}; [ ! -z $doc_name_link ] && name="[${name}](${doc_name_link})"
  desc=${doc_description:-}
  notes=${doc_notes:-}

  echo "| $image | $name | $desc | $notes |\n"
}

function generate_container_table() {
  readarray -t containers < <(find containers -maxdepth 1 -path 'containers/[^\.]*' -type d -printf '%P\n' | sort)

  container_table="| Image | Name | Description | Notes |\n"
  container_table+="| --- | --- | --- | --- |\n"
  for container in "${containers[@]}"; do
    container_table+=$(generate_container_table_row $container)
  done
  echo $container_table
}


function generate_package_table_row() {
  local pkg="$1"
  local conf_file_path="./packages/${pkg}/.conf"
  [ -f $conf_file_path ] && source $conf_file_path
  
  : ${cmd:=$pkg}
  : ${name:=$pkg}; [ ! -z $name_link ] && name="[${name}](${name_link})"
  desc=${description:-}
  echo "| $cmd | $name | $desc |\n"
}

function generate_package_table() {
  readarray -t packages < <(find packages -mindepth 1 -maxdepth 1 -type d -printf '%P\n' | sort)

  pkg_table="| Command | Name | Description |\n"
  pkg_table+="| --- | --- | --- |\n"
  for package in "${packages[@]}"; do
    pkg_table+=$(generate_package_table_row $package)
  done
  echo ${pkg_table}
}

awk \
  -v ct="$(generate_container_table)" \
  -v pt="$(generate_package_table)" \
  '{
    gsub(/<!-- insert-container-table -->/,ct)
    gsub(/<!-- insert-package-table -->/,pt)
  }1' \
  readme_template.md > README.md