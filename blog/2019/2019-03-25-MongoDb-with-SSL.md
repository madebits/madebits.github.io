# SSL for MongoDb and RabbitMQ

2019-03-25

<!--- tags: mongodb, rabbitmq -->

Use of self-signed certificates for SSL provides freedom generate as many of them as needed conveniently on our own and it comes handy for internal infrastructure. I show here how to enable SSL from both [MongoDb](https://docs.mongodb.com/manual/tutorial/configure-ssl/) and [RabbitMQ](https://www.rabbitmq.com/ssl.html) using same certificate. Only server is authenticated to clients via SSL, any client can be connected to servers if credentials are known to client (so we rely here on having long *passwords* for clients).

## SSL for MongoDb 

To set up MongoDb with self-signed certificates for SSL, we need to follow several [steps](https://www.cloudandheat.com/blog/deploy-a-mongodb-3-0-replica-set-with-x-509-authentication-and-self-signed-certificates/).

### Certificate Authority

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

### Server Certificates

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

```bash
cat $HOST_NAME.key $HOST_NAME.crt > $HOST_NAME.pem 
```

Rest of files are not needed anymore after this point can be deleted: ` $HOST_NAME.csr`, `$HOST_NAME.key `, `$HOST_NAME.crt`. MongoDB only needs `$HOST_NAME.pem` file and `mongoCA.crt`.

To view *thumb-print* of the server certificate we can use:

```
# hostMongo.pem is `$HOST_NAME.pem`
openssl x509 -noout -fingerprint -sha256 -inform pem -in hostMongo.pem
```

### MongoDB Daemon Configuration

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
docker run --restart always -d -p 27021:27017 -v /data/mongo/01/:/data/db/ -v /data/config/mongo01/:/config/ --name mongo01 mongo:4.0 -f /config/mongo.conf --auth
```

A MongoDB user needs to be created before --auth` flag is set:

```
use admin

db.createUser({ user: "myAdmin", pwd: "password", roles: [ { role: "root", db: "admin" } ] } );
```

### MongoDB Client Configuration

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

The code depending on whether SSL is used or not checks the validity of the server certificate either based on its thumb-print if configured, or via its chain information and host name. In production code, `SslSettings` needs to be cached.

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

## SSL for RabbitMQ

Setting up [TLS](https://www.rabbitmq.com/ssl.html) for RabbitMQ is similar to the MongoDB setup above. We can reuse the CA authority certificate and if RabbitMQ is on same machine as MongoDB server, we can also share the server certificate.

Let assume, we use the following command to start RabbitMQ:

```
docker run --restart always -d --hostname my-rabbit -p 5774:5671 -p 15774:15671 -v /data/rmq/03/:/var/lib/rabbitmq/mnesia/rabbit\@my-rabbit -v /data/config/rabbit03/:/config -e RABBITMQ_CONFIG_FILE='/config/rabbitmq' --name rmq03 rabbitmq:3.7.14-management
```

Then we can activate management plugin and add an admin user as follows:

```
docker exec -i -t rmq03 /bin/bash

rabbitmq-plugins enable rabbitmq_shovel rabbitmq_shovel_management

rabbitmqctl add_user admin password
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
```

Then we need to set up in `/data/config/rabbit03` a file named `rabbitmq.conf` with following information (`certs` folder is copied or linked under `/data/config/rabbit03`):

```
loopback_users.guest = true
listeners.tcp.default = 5672
hipe_compile = false
#management.listener.port = 15672

listeners.ssl.default = 5671
ssl_options.cacertfile = /config/certs/mongoCA.crt
ssl_options.certfile   = /config/certs/mongoHost.pem
ssl_options.keyfile    = /config/certs/mongoHost.pem
ssl_options.verify     = verify_none
ssl_options.fail_if_no_peer_cert = false

management.listener.ssl = true
management.ssl.port       = 15671
management.ssl.cacertfile = /config/certs/mongoCA.crt
management.ssl.certfile   = /config/certs/mongoHost.pem
management.ssl.keyfile    = /config/certs/mongoHost.pem
```

We merged above for MongoDB both private and public keys in `mongoHost.pem` so we can use same file in both places. The non-SSL TPC port is useful for `rabbitmqctl`, but we do not map it to host.

We can access also RabbitMQ Management via web using SSL if configured as shown above, but given SSL is self-signed, we have to accept the connection manually when using `https://server:15774` in browser. In this case, we may want to look at the certificate thumb-print manually in browser to make sure it matches out server ones, before we enter the login credentials.

### RabbitMQ Client Configuration

For .NET, the RabbitMQ client configuration to use SSL is simple:

```
var url = new Uri(Ctx.Get("rmq"));
var factory = new ConnectionFactory()
{
    Uri = url,
    RequestedHeartbeat = 15,
    NetworkRecoveryInterval = TimeSpan.FromSeconds(5),
    AutomaticRecoveryEnabled = true,
};
var query = url.ParseQueryString();
if ((query.ContainsKey("ssl") && (query["ssl"] == "true")) {
    var caFile = (string)Config.Get("db.caFile");
    if (string.IsNullOrWhiteSpace(caFile) || !File.Exists(caFile))
    {
        throw new FileNotFoundException($"Rmq: Cannot find CaFile: [{caFile}]");
    }
    var ca = new X509Certificate2(caFile);
    factory.Ssl = new SslOption {
        ServerName = url.Host,
        Enabled = true,
        //Certs = new X509CertificateCollection(new [] { ca }),
        CertificateValidationCallback = (sender, cert, chain, error) =>
        {
            var caMatch = false;
            var hostMatch = false;
            foreach (var c in chain.ChainElements)
            {
                if (c.Certificate.Equals(ca))
                {
                    caMatch = true;
                }
                if (c.Certificate.Subject.Contains($"CN={url.Host},"))
                {
                    hostMatch = true;
                }

                if (caMatch && hostMatch)
                {
                    break;
                }
            }
            return caMatch && hostMatch;
        }
    };
}

Connection = factory.CreateConnection();
```

I have extended RabbitMQ URL format to contain `ssl=true`, to mimic the MongoDB one, and I am using this [helper class](https://stackoverflow.com/questions/2884551/get-individual-query-parameters-from-uri) to parse URL parameters:

```
public static class UriExtensions
{
    private static readonly Regex _regex = new Regex(@"[?&](\w[\w.]*)=([^?&]+)", RegexOptions.Compiled);

    public static IReadOnlyDictionary<string, string> ParseQueryString(this Uri uri)
    {
        var match = _regex.Match(uri.PathAndQuery);
        var parameters = new Dictionary<string, string>();
        while (match.Success)
        {
            parameters.Add(match.Groups[1].Value, match.Groups[2].Value);
            match = match.NextMatch();
        }
        return parameters;
    }
}
```

In Node.js, the official `amqplib` driver provides an example:

```
const url = require('url')
const amqp = require('amqplib')

const rmqUrl = 'amqp://user:passsword@server:5774/myVhost?heartbeat=240&connection_timeout=5&ssl=true';

const rmq = new url.URL(rmqUrl)
let opts = {}
if(rmq.searchParams.get('ssl') === 'true') {
    opts = { ca: [fs.readFileSync('/mongoCA.crt')] }
}
let conn = await amqp.connect(rmqUrl, opts)
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-03-10-How-To-Speak-Like-A-Leader.md'>How To Speak Like A Leader</a></ins>
