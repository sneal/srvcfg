# Config Server Sample with Server Side Encryption

This is a very basic sample application that demonstrates how to use [server side encryption and decryption](https://docs.pivotal.io/spring-cloud-services/1-3/common/config-server/configuring-with-git.html#encryption-and-encrypted-values) with Pivotal Cloud Foundry Config Server.

## Create Config Server Instance

Create a config server instance using the included configuration json file.

```
$ cf create-service p-config-server standard srvcfg-config-server -c config-server.json
```

This creates a config server which serves up the properties stored in [this GitHub config repo](https://github.com/sneal/srvcfg-config.git). It also adds an encrypt key to the config server instance for encrypting secrets using the `/encrypt` endpoint and decrypting any secrets in the config repo [prefixed with `{cipher}`](https://docs.pivotal.io/spring-cloud-services/1-3/common/config-server/configuration-files.html#encrypted-configuration).

## Building and Deploying

```
$ mvn package
$ cf push -p target/srvcfg-0.0.1-SNAPSHOT.jar
```

After the application starts there are two endpoints you can hit which will return a message.

- /foo
- /foosecret

The foo endpoint will return `cloud` when running in PCF with the cloud profile and bound to the config server, otherwise it'll return the default of `bar`. This value comes from the foo property.

The foosecret endpoint will return `super secret secret` when running in PCF with the cloud profile and bound to the config server, otherwise it'll return the default of `not a secret`. This value comes from the foosecret property, which in the config repo is encrypted.

## Encrypting New Secrets

Encrypting a secret involves submitting the value you want to encrypt to the config server instance's /encrypt endpoint. This allows anyone who can authenticate with the config server to be able to encrypt (or decrypt) secrets.

### Software Prereqs

- Pivotal Cloud Foundry Config Server 1.3.3+
- [jq](https://stedolan.github.io/jq/)

To be able to authenticate to the UAA endpoint and get an OAUTH token for the config server we need to create a service key for the config server instance. Log in to Apps Manager and select the config server instance you want to work with. On the service's overview tab click the `Create Service Key` button. Enter a friendly name for the key, for example 'myservicekey'. Click `Create`. The new service key will be added to the list of service keys, now click on the service key in the list. This will show a json object similar to this one:

```
{
  "uri": "https://config-ff009fe5-a78b-423e-91f1-87e91b23ca04.cf.example.com",
  "client_secret": "AmtcJek2ttg7",
  "client_id": "p-config-server-34737bf1-02c4-47de-9743-e3892b0146d9",
  "access_token_uri": "https://p-spring-cloud-services.uaa.cf.example.com/oauth/token"
}
```

Copy and paste the displayed JSON object into a local file, for example `servicekey.json`. Now run the `encryptsecret.sh` script giving it the path to the servicekey json and the value to encrypt, for example:

```
$ ./encryptsecret.sh servicekey.json mysecretpassword
4d1e7d0805e08d71c954e022cda7499b3a81a889cdc340413a5ce1c57ade4cf2acaf7c652d4899ecb240b1738d386564
```

NOTE - If your using Windows you can run the encryptsecret.sh shell script from the [git bash terminal](https://git-for-windows.github.io/).

This will return `mysecretpassword` encrypted using the config server's encrypt endpoint. Take the encrypted text and paste it into the appropriate config file in your config repo. If placing into a Java properties file, it should be prefixed with `{cipher}`. For example:

```
fooSecret={cipher}4d1e7d0805e08d71c954e022cda7499b3a81a889cdc340413a5ce1c57ade4cf2acaf7c652d4899ecb240b1738d38656
```

## Creating a New Encrypt Key

Obviously you shouldn't use the encrypt key in this sample's config-server.json for anything you actually want to protect in the real world. You can create a new key using OpenSSL, I'm using version `OpenSSL 1.0.2k  26 Jan 2017`.

On OS X the following command generates a new 4096 bit key, strips the newline characters and places it into the clipboard.

```
$ openssl genpkey -algorithm RSA -outform PEM -pkeyopt rsa_keygen_bits:4096 | tr -d '\n' | pbcopy
```

NOTE - On Windows you can replace the `pbcopy` command with `clip` and run the above command using git bash shell.

With your new private key in your clipboard you can now paste it into your config-server.json file under `encrypt.key` and run your `cf create-service` command.
