# polaris-pipelines

## Polaris pipeline smoke test
`pipelines/polaris-pipeline-smoke-test/Jenkinsfile` checks that Jenkins can still run the Polaris deployment pipeline, for example after a Jenkins upgrade. It follows the same path as `app-oras` up to reading the application's secrets from Vault, without deploying anything:

- A build trigger passes a Broker JWT as the `brokerJwt` parameter. Jenkins stores no credentials for this test.
- The Polaris shared library loads, and stages run on an agent with the Polaris app label (`podman`)
- The pipeline opens a Broker intention using `scripts/intention-polaris-pipeline-smoke-test.json`
- Broker provisions a Vault token for the `configure` action, without a role ID
- The pipeline reads the service's Vault secret and checks a known value, then closes the intention
- The workspace is cleaned up

ORAS downloads, the infrastructure checkout, the `jenkins-apps` login and running Ansible with Podman are not tested.

Setup:
- Broker service `oscar/polaris-pipeline-smoke-test` with a `tools` service instance, connected to a Broker account set to "Require RoleId: No"
- Vault secret `apps/tools/oscar/polaris-pipeline-smoke-test` with the key `smoke_test_value` set to `not-a-secret`. This is the only Vault path the test reads.
- A Jenkins job `oscar/polaris-pipeline-smoke-test` that runs this Jenkinsfile. The job's parameters are defined in the Jenkinsfile. Jenkins only adds them after the first build, so run it once, or add them to the job by hand.

Trigger the job with the `brokerJwt` parameter. For a manual run, that is the only value needed. `githubRunId` is set by the trigger workflow and becomes part of the Broker event's trigger id; when blank, the build tag is used.

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
