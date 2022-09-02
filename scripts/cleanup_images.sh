#! /bin/bash
profile="$1"

printf "\nGetting Regions\n"
regions=$(aws ec2 describe-regions --profile "nonprod" | jq .Regions[].RegionName -r | sort)
for region in $regions
do
  printf "\nGetting images not assiated to any instances for region $region \n"
  images=$(aws ec2 describe-images --profile "$profile" --region "$region" --owner "self" | jq -r .Images[].ImageId | sed 's/ //g' | sort | uniq)
  if [ -n "$images" ]
  then
    for img in $images
    do
      instance=$(aws ec2 describe-instances --profile "nonprod" --region $region --filter "Name=image-id,Values=$img" | jq -c .Reservations[].Instances[].ImageId | sed 's/ //g' |sort|uniq)
      if [ -z "$instance" ]
      then
        printf "$img\n"
        # aws ec2 deregister-image --image-id $img
      fi
    done
  fi
done
