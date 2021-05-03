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
  readarray -t container_list < <(find containers -maxdepth 1 -path 'containers/[^\.]*' -type d -printf '%P\n' | sort)

  container_table="| Image | Name | Description | Notes |\n"
  container_table+="| --- | --- | --- | --- |\n"
  for container in "${container_list[@]}"; do
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
  readarray -t package_list < <(find packages -mindepth 1 -maxdepth 1 -type d -printf '%P\n' | sort)

  pkg_table="| Command | Name | Description |\n"
  pkg_table+="| --- | --- | --- |\n"
  for package in "${package_list[@]}"; do
    pkg_table+=$(generate_package_table_row $package)
  done

  echo $pkg_table
}

container_table=$(generate_container_table)
packages_table=$(generate_package_table)

echo -e ${container_table}

# table="| Image | Name | Description | Notes |\n"
# table+="| --- | --- | --- | --- |\n"
# table+="| $img1 | $name1 | $desc1 | $notes1 |\n"
# table+="| $img2 | $name2 | $desc2 | $notes2 |\n"
# table+="| $img3 | $name3 | $desc3 | $notes3 |\n"

# cat <(head -n 9 readme_template.md) $(echo -e ${container_table}) <(tail -n +10 readme_template.md)

# sed -i \
#   --expression="{r $container_table}" \
#   "./readme_template.md" > "README.md"
