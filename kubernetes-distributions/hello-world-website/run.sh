#!/bin/bash

declare -a arr=()
len=${#arr[@]}
namespace=""
k8s_command="kubectl"   # Default kubectl command
action="apply"  # Default action

function apply {
   kubectl_cmd "apply -f deployment.yaml"
   kubectl_cmd "apply -f service.yaml"
}

function delete {
   kubectl_cmd "delete -f service.yaml"
   kubectl_cmd "delete -f deployment.yaml"
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
