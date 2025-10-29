# polaris-pipelines

## Update Jenkins pipeline repo to use the new library tag
Pipelines reference the shared library in Jenkinsfiles, for example:

  @Library('polaris@v1.0.0')

After the new shared library tag is generated, update Jenkins pipeline repo to point to the new shared library tag (v1.0.0).

Recommended approach:
1. Run the script scripts/update_polaris_library_tag.sh to replace the library tag for all Jenkinsfile. 
```
   cd /path/to/nr-polaris-pipelines
   ./scripts/update_polaris_library_tag.sh
   Enter the polaris library tag or branch (e.g., v1.2.3): v1.0.0
```
2. Commit and push the changes, then run the pipeline to validate.

3. Publish a new release for the Jenkins pipeline repository — either create it with the GitHub CLI or draft and publish it via the GitHub web UI.
