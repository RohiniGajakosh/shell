#!/bin/bash
installed_tools=("terraform" "docker" "aws" "gitlab-runner" "jenkins" "ansible")
EMAIL_TO="aaira8665@gmail.com"
TEMPLATE_FILE="email_template.html"
TEMP_EMAIL="/tmp/version_report.html"

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
        echo "Latest version of $tool: $latest_version"
        
        if [ "$current_version" != "$latest_version" ]; then
            sed -e "s/{{TOOL}}/$tool/g" \
                -e "s/{{CURRENT_VERSION}}/$current_version/g" \
                -e "s/{{LATEST_VERSION}}/$latest_version/g" \
                -e "s/{{DATE}}/$(date '+%Y-%m-%d %H:%M:%S')/g" \
                "$TEMPLATE_FILE" > "$TEMP_EMAIL"
            
            mail -s "$(echo -e "$tool Update Available\nContent-Type: text/html")" "$EMAIL_TO" < "$TEMP_EMAIL"
            echo "Email sent for $tool update"
        fi
        echo "-----------------------------"
    else
        echo "$tool is not installed."
    fi
done
