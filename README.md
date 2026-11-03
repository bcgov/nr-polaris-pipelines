# polaris-pipelines

## Polaris pipeline smoke test
`pipelines/polaris-pipeline-smoke-test/Jenkinsfile` checks that Jenkins can still run the Polaris deployment pipeline, for example after a Jenkins upgrade. It reads the application's secrets from Vault and tests Podman's authenticated pull-and-run path without deploying anything:

- The Broker JWT comes from the required `brokerJwt` parameter. The build fails if it is blank.
- The Polaris shared library loads, and stages run on an agent with the Polaris app label (`podman`)
- The pipeline opens a Broker intention using `scripts/intention-polaris-pipeline-smoke-test.json`
- Broker provisions a Vault token for the `configure` action, without a role ID
- The pipeline reads the service's Vault secret and checks a known value
- Broker provisions a separate tools token; the pipeline reads Artifactory credentials, logs in to the Docker remote, and pulls/runs a digest-pinned `hello-world` image
- The intention is closed after all checks
- The workspace is cleaned up

ORAS downloads, the infrastructure checkout, the `jenkins-apps` login and running Ansible with Podman are not tested.

Setup:
- Broker service `oscar/polaris-pipeline-smoke-test` with `development`, `test` and `production` service instances, connected to a Broker account set to "Require RoleId: No"
- Vault secrets `apps/<dev|test|prod>/oscar/polaris-pipeline-smoke-test/<environment>` (for example `apps/test/oscar/polaris-pipeline-smoke-test/test`) with the key `smoke_test_value` set to `not-a-secret`. Each run only reads the path for its `envLong`.
- Vault tools secret `apps/tools/oscar/polaris-pipeline-smoke-test` with `artifactory_username` and `artifactory_password`; the Broker account must be authorized to access this service's tools environment.
- A Jenkins job `oscar/polaris-pipeline-smoke-test` that runs this Jenkinsfile. The job's parameters are defined in the Jenkinsfile. Jenkins only adds them after the first build, so run it once, or add them to the job by hand.

For a manual test, use "Build with Parameters" and paste the account's Broker JWT into `brokerJwt`. `envLong` sets the intention's environment and which Vault secret is read (default `development`); the trigger workflow sends the environment it targets, along with `brokerJwt`. `githubRunId` is set by the trigger workflow and becomes part of the Broker event's trigger id; when blank, the build tag is used.

To check the Broker JWT, intention file and both Vault paths without Jenkins or Podman, run `BROKER_JWT=<jwt> scripts/test-polaris-pipeline-smoke-test.sh`. Set `ENV_LONG=test` or `ENV_LONG=production` to test another environment, and add `preflight` to only validate the intention without opening it.

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
