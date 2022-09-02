#! /bin/bash
profile="$1"

printf "\nGetting Regions\n"
regions=$(aws ec2 describe-regions --profile "nonprod" | jq .Regions[].RegionName -r | sort)
for region in $regions
do
  printf "\nGetting  unused volumes for region $region \n"
  volumes=$(aws ec2 describe-volumes --profile "nonprod" --region $region --filters Name=status,Values=available | jq -r .Volumes[].VolumeId | sed 's/ //g' | sort | uniq)
  if [ -n "$volumes" ]
  then
    for volume in $volumes
    do
        printf "$volume \n"
        # aws ec2 delete-volume --volume-id $volume --dry-run
    done
  fi
done
