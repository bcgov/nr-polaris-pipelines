#!/bin/bash

# Cross-platform sed -i detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE=(-i '')
else
    SED_INPLACE=(-i)
fi

read -r -p "Enter the polaris library tag or branch (e.g., v1.2.3): " TAG || exit 1

find pipelines -type f -name 'Jenkinsfile' | while read -r file; do
    # Replace @Library('polaris') or @Library('polaris@...') with the new tag on the first line
    sed "${SED_INPLACE[@]}" "1s|@Library('polaris[^']*')|@Library('polaris@${TAG}')|" "$file"
    echo "Updated $file"
done