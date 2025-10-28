# polaris-pipelines

## Update Jenkins pipeline repo to use the new library tag
Pipelines reference the shared library in Jenkinsfiles, for example:

  @Library('polaris@v1.0.0')

After the new tag is generated, update pipeline repo to point to the new tag (v1.0.0).

Recommended approach:
1. Run the script scripts/update_polaris_library_tag.sh to replace the library tag for all Jenkinsfile. 
```
   cd /path/to/nr-polaris-pipelines
   ./scripts/update_polaris_library_tag.sh
   Enter the polaris library tag or branch (e.g., v1.2.3): v1.0.0
```
2. Commit and push the changes, then run the pipeline to validate.

3. Create a GitHub release (requires GitHub CLI) on Jenkins pipeline repo or use GitHub web side draft a new release to publish a new release