#!/bin/bash

read -p "Enter the polaris library tag or branch (e.g., v1.2.3): " TAG

find pipelines -type f -name 'Jenkinsfile' | while read -r file; do
    # Replace @Library('polaris') or @Library('polaris@...') with the new tag on the first line
    sed -i "1s|@Library('polaris[^']*')|@Library('polaris@${TAG}')|" "$file"
    echo "Updated $file"
done