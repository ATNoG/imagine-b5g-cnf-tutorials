#!/bin/bash

declare -a arr=("hello-world-website" "dummy-message-api")
len=${#arr[@]}
namespace=""
k8s_command="kubectl"   # Default kubectl command
action="apply"  # Default action

function apply {
   # Loop through the array in reverse order
   for i in "${arr[@]}"
   do
      echo "Running $i"
      cd $i
      bash run.sh -n "$namespace" -k "$k8s_command"
      cd ..
   done
   kubectl_cmd "apply -f ingress.yaml"
}

function delete {
   kubectl_cmd "delete -f ingress.yaml"
   # Loop through the array in reverse order
   for (( i=$len-1; i>=0; i-- ))
   do
      echo "Running ${arr[i]}"
      cd "${arr[i]}"
      bash run.sh -d -n "$namespace" -k "$k8s_command"
      cd ..
   done
}

# Function to conditionally add the namespace to kubectl commands
function kubectl_cmd {
   local cmd=$1
   if [[ -n "$namespace" ]]; then
      $k8s_command $cmd --namespace=$namespace
      # echo "$k8s_command $cmd --namespace=$namespace"
   else
      $k8s_command $cmd
      # echo "$k8s_command $cmd"
   fi
}

function usage {
   echo "Usage: $0 [options]"
   echo "Options:"
   echo "   -d                   Delete the resources"
   echo "   -n <namespace>       The namespace to run the kubectl commands in"
   echo "   -k <kubectl command> The kubectl command to run (default: kubectl)"
   exit 1
}



# MAIN

# Parse command-line arguments
while getopts "n:k:d" opt; do
   case ${opt} in
      n )
         namespace=$OPTARG
         ;;
      k )
         k8s_command=$OPTARG
         ;;
      d )
         action="delete"
         ;;
      h )
         usage
         ;;
      \? )
         usage
         echo "Invalid option: -$OPTARG" 1>&2
         exit 1
         ;;
   esac
done

# Run the action
$action
