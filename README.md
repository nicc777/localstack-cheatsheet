# localstack-cheatsheet

Cheatsheet I use myself for testing new AWS development locally using [_localstack_](https://www.localstack.cloud/).

# Start a clean environment

Run the following command and follow the instructions:

```shell
./install-or-upgrade.sh
```

All tooling will be installed locally. When you have run `. ./use_localstack` you should also be in the Python virtual environment and the AWS CLI and localstack clients you just installed should be used. You can verify by running:

```shell
# Assuming your are in the local repository directory from where you run the install script and $PWD is now that directory...

which python3
# $PWD/venv/bin/python3

which localstack
# $PWD/venv/bin/localstack

which aws
# aws: aliased to $PWD/opt/bin/aws
```

