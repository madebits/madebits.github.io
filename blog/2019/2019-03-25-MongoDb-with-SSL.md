# MongoDb with SSL

2019-03-25

To set up MongoDb with self-signed certificates for SSL, we need to follow several [steps](https://www.cloudandheat.com/blog/deploy-a-mongodb-3-0-replica-set-with-x-509-authentication-and-self-signed-certificates/).

## Certificate Authority

We need to create a CA key which needs a password:

```bash
openssl genrsa -out mongoCA.key -aes256 8192
```

The key can be used to sign a self-create CA certificate `mongoCA.crt`, valid for 10 years:

```bash
openssl req -x509 -new -extensions v3_ca -key mongoCA.key -days 3650 -out mongoCA.crt
```

The information about CA needs to be filled here when asked to match company data. There is no requirement on a self-signed CA that the company information is correct or real.

CA files needs to be saved and `mongoCA.crt` needs to be distributed to clients. 

## Server Certificates

For each server where MongoDB runs we need to generate a separate certificate. 

The **subject** data of the certificate need to match those used in CA certificate. There is one more field in server certificate subject, the name **CN** that needs to match to the full machine domain name, as used in MongoDB connection string URL.

```bash
HOST_NAME="my.server.com"
SUBJECT="/C=DE/ST=Hessen/L=Frankfurt/O=Testorg/OU=Test/CN=$HOST_NAME"
```

We can generate the server certificate using these data. RSA key length should be >= 4096 bits. The command generates both private key and the public certificate parts:

```bash
openssl req -new -nodes -newkey rsa:8192 -subj "$SUBJECT" -keyout $HOST_NAME.key -out $HOST_NAME.csr
```

We need to sign the CRS file with CA certificate key. We make it valid for 10 years here:

```bash
openssl x509 -CA mongoCA.crt -CAkey mongoCA.key -CAcreateserial -req -days 3650 -in $HOST_NAME.csr -out $HOST_NAME.crt
```

MongoDB needs a PEM file that contains both the certificate private key and the signed CRT:

```
cat $HOST_NAME.key $HOST_NAME.crt > $HOST_NAME.pem 
```

Rest of files are not needed anymore after this point can be deleted: ` $HOST_NAME.csr`, `$HOST_NAME.key `, `$HOST_NAME.crt`. MongoDB only needs `$HOST_NAME.pem` file and `mongoCA.crt`.

## MongoDB Daemon Configuration

The following options can either be passed via parameters to `mongod --ssl --sslCAFile /config/certs/mongoCA.crt --sslPEMKeyFile /config/certs/mongoHost.pem` or via a configuration file `mongod -f /config/mongo.conf`:

```yaml
net:
  port: 27017
  ssl:
    mode: preferSSL
    PEMKeyFile: /config/certs/mongoHost.pem
    CAFile: /config/certs/mongoCA.crt
    allowConnectionsWithoutCertificates: true
```

We do not require clients present their certificate to server (MongoDB password authentication is enough for us).

If MongoDB is run via Docker, these files needs to be accessible to the container:

```bash
docker run --restart always -d -p 27021:27017 -v /data2/data/mongo/01/:/data/db/ -v /data2/data/config/mongo01/:/config/ --name mongo01 mongo:4.0 -f /config/mongo.conf --auth
```

## MongoDB Client Configuration

We have several options how to verify server SSL certificate in client depending on the driver used. The following code shows how we can verify certificate in C# driver:

```C#
var connectionStr="mongo://...?ssl=true"
var url = new MongoUrl(connectionStr);
var clientSettings = MongoClientSettings.FromUrl(url);
if (clientSettings.UseSsl)
{
    var caFile = (string)Config.Get("db.caFile"); // mongoCA.crt
    var caHash = (string)Config.Get("db.caHash");
    if (!string.IsNullOrWhiteSpace(caFile))
    {
        if (!System.IO.File.Exists(caFile))
        {
            throw new System.IO.FileNotFoundException($"Cannot find CaFile: [{caFile}]");
        }
        var hashes = (caHash ?? string.Empty).Split(',')
            .Select(_ => _.Trim().ToLowerInvariant())
            .Where(_ => !string.IsNullOrWhiteSpace(_))
            .ToList();
        var ca = new X509Certificate2(caFile);
        clientSettings.SslSettings = new SslSettings
        {
            ClientCertificates = new[] { ca },
            ServerCertificateValidationCallback = (sender, cert, chain, error) =>
            {
                if (hashes.Count() > 0)
                {
                    var hash = cert.GetCertHashString();
                    var ok hashes.Contains(hash.ToLowerInvariant());
                    return ok;
                }
                else
                {
                    var caMatch = false;
                    var hostMatch = false;
                    foreach (var c in chain.ChainElements)
                    {
                        if (c.Certificate.Equals(ca))
                        {
                            caMatch = true;
                        }
                        foreach(var s in url.Servers)
                        {
                            if (c.Certificate.Subject.Contains($"CN={s.Host},"))
                            {
                                hostMatch = true;
                                break;
                            }
                        }
                        if (caMatch && hostMatch)
                        {
                            break;
                        }
                    }
                    return caMatch && hostMatch;
                }
            }
        };
    }
}
var client = new MongoClient(clientSettings);
return client;
```

The code depending on whether SSL is used or not checks the validity of the server certificate either based on its thumb-print if configured, or via its chain information and host name.

Node.js driver can do something similar to chain / hostname verification if used as follows:

```js
var certFileBuf = fs.readFileSync('/mongoCA.crt');
var mongoUrl = 'mongodb://...?ssl=true';
var options = {
  server: { sslCA: certFileBuf, sslValidate: true }
};
const mongoClient = mongodb.MongoClient
this.client = await mongoClient.connect(mongoUrl, options);
```



