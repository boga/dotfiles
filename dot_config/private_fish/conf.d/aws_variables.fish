if status --is-login
    set -x AWS_VAULT_KEYCHAIN_NAME login
    # https://github.com/99designs/aws-vault/blob/master/USAGE.md#environment-variables

    # default is 1h, which is awkward
    set -x AWS_SESSION_TOKEN_TTL 12h
end