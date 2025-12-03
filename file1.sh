<<Comment 
here i am creating a bash script to get the tool versions of the following tools:
To get the latest release version for each tool installed on the system need to refer to their official release APIs:
1. Terraform → Official HashiCorp Checkpoint API
2. Docker → Official Docker GitHub release API
3. AWS CLI → AWS GitHub release API
4. GitLab Runner → GitLab Runner GitHub release API
Comment

# Ansible, docker , aws , gitlab, jenkins, terraform, kubernetes, helm, python, bash, linux

##!/bin/bash
# tools=(terraform docker aws gitlab-runner jenkins  ansible)
# for tool in "${tools[@]}"; do
#     if ! command -v $tool &> /dev/null; then
#         echo "$tool could not be found"
#     fi
#     echo "Checking version for $tool"
#     case $tool in
#         terraform)
#             terraform --version | head -n 1
#             ;;
#         docker)
#             docker --version | awk '{print $1 " "  $3}' | sed 's/,//'
#             ;;
#         aws)
#             aws --version | awk '{print $1 " "  $3}' | sed 's/,//'
#             ;;
#         gitlab-runner)
#             gitlab-runner --version | head -n 1
#             ;;
#         jenkins)
#             jenkins --version
#             ;;   
#         ansible)
#             ansible --version | head -n 1
#             ;;     
#     esac
#     echo "-----------------------------"
# done

#!/bin/bash
installed_tools=("terraform" "docker" "aws" "gitlab-runner" "jenkins" "ansible")
# latest_versions {
#     "terraform": "https://checkpoint-api.hashicorp.com/v1/check/terraform",
#     "docker": "https://api.github.com/repos/docker/docker-ce/releases/latest",
#     "aws": "https://api.github.com/repos/aws/aws-cli/releases/latest",
#     "gitlab-runner": "https://api.github.com/repos/gitlab-org/gitlab-runner/releases/latest",
#     "jenkins": "https://api.github.com/repos/jenkinsci/jenkins/releases/latest",
#     "ansible": "https://api.github.com/repos/ansible/ansible/releases/latest"
# }
for tool in "${installed_tools[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "$tool is installed."
        case $tool in
            terraform)
                current_version=$(terraform --version | head -n 1 | awk '{print $2}'| sed 's/v//')
                latest_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version | head -n 2)
                ;;
            docker)
                current_version=$(docker --version | awk '{print $3}' | sed 's/,//')
                latest_version=$(curl -s https://api.github.com/repositories/7691631/releases/latest | jq -r .tag_name | sed 's/docker-v//')
                ;;
            aws)
                current_version=$(aws --version | awk '{print $1}' | cut -d/ -f2)
                latest_version=$(curl -s https://awscli.amazonaws.com/v2/latest/version.txt | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
                ;;
            gitlab-runner)
                current_version=$(gitlab-runner --version | head -n 1 | awk '{print $2}')
                latest_version=$( curl -s https://gitlab.com/api/v4/projects/250833/repository/tags | jq -r '.[0].name' | sed 's/v//')
                ;;
            jenkins)
                current_version=$(jenkins --version)
                latest_version=$(curl -s ${latest_versions["jenkins"]} | jq -r '.tag_name' | sed 's/v//')
                ;;
            ansible)
                current_version=$(ansible --version | head -n 1 | awk '{print $2}')
                latest_version=$(curl -s ${latest_versions["ansible"]} | jq -r '.tag_name' | sed 's/v//')
                ;;
        esac
        echo "Current version of $tool: $current_version"
        if [ "$current_version" != "$latest_version" ]; then
            echo "A new version of $tool is available!" | mail -s "$tool Update Notification" aaira8665@gmail.com #to send notification if new version is available sending mail
        fi
        echo "Latest version of $tool: $latest_version"
        echo "-----------------------------"
    else
        echo "$tool is not installed."
    fi
done

