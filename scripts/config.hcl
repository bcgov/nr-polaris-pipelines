vault {
  # This is the address of the Vault leader. The protocol (http(s)) portion
  # of the address is required.
  address = "https://knox.io.nrs.gov.bc.ca"

  # This is a Vault Enterprise namespace to use for reading/writing secrets.
  #
  # This value can also be specified via the environment variable VAULT_NAMESPACE.
  # namespace = ""

  # This is the token to use when communicating with the Vault server.
  # Like other tools that integrate with Vault, Consul Template makes the
  # assumption that you provide it with a Vault token; it does not have the
  # incorporated logic to generate tokens via Vault's auth methods.
  #
  # This value can also be specified via the environment variable VAULT_TOKEN.
  # It is highly recommended that you do not put your token in plain-text in a
  # configuration file.
  #
  # When using a token from Vault Agent, the vault_agent_token_file setting
  # should be used instead, as that will take precedence over this field.
  # token = ""

  # This tells Consul Template to load the Vault token from the contents of a file.
  # If this field is specified:
  # - by default Consul Template will not try to renew the Vault token, if you want it
  # to renew you will need to specify renew_token = true as below.
  # - Consul Template will periodically stat the file and update the token if it has
  # changed.
  # vault_agent_token_file = "/tmp/vault/agent/token"

  # This tells Consul Template that the provided token is actually a wrapped
  # token that should be unwrapped using Vault's cubbyhole response wrapping
  # before being used. Please see Vault's cubbyhole response wrapping
  # documentation for more information.
  unwrap_token = false

  # The default lease duration Consul Template will use on a Vault secret that
  # does not have a lease duration. This is used to calculate the sleep duration
  # for rechecking a Vault secret value. This field is optional and will default to
  # 5 minutes.
  # default_lease_duration = "60s"

  # The fraction of the lease duration of a non-renewable secret Consul
  # Template will wait for. This is used to calculate the sleep duration for
  # rechecking a Vault secret value. This field is optional and will default to
  # 90% of the lease time.
  # lease_renewal_threshold = 0.90

  # This option tells Consul Template to automatically renew the Vault token
  # given. If you are unfamiliar with Vault's architecture, Vault requires
  # tokens be renewed at some regular interval or they will be revoked. Consul
  # Template will automatically renew the token at half the lease duration of
  # the token. The default value is true, but this option can be disabled if
  # you want to renew the Vault token using an out-of-band process.
  #
  # Note that secrets specified in a template (using {{secret}} for example)
  # are always renewed, even if this option is set to false. This option only
  # applies to the top-level Vault token itself.
  # renew_token = true

  # This section details the retry options for connecting to Vault. Please see
  # the retry options in the Consul section for more information (they are the
  # same).
  retry {
    enabled = true
    attempts = 6
    backoff = "250ms"
    max_backoff = "1m"
  }

  # This section details the SSL options for connecting to the Vault server.
  # Please see the SSL options in the Consul section for more information (they
  # are the same).
  ssl {
    # ...
  }
}
