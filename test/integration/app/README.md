# Minimal InSpec Profile with interitance

put this directory into ``test/integration/inspec/profiles/nvtkaszpir-kf-app``

## Verify a profile

InSpec ships with built-in features to verify a profile structure.
Check if you have all dependencies:

```bash
$ inspec check test/integration/inspec/profiles/nvtkaszpir-kf-app/ --profiles-path=test/integration/inspec/
```

## Execute a profile

To run a profile on a local machine use `inspec exec /path/to/profile`.

```bash
$ inspec check test/integration/inspec/profiles/nvtkaszpir-kf-app -t ssh://192.168.121.242:22 --user=vagrant --key-files=.vagrant/machines/app/libvirt/private_key --sudo --profiles-path=test/integration/inspec/
```

