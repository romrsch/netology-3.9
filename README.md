##  netology-3.9 


Установите Hashicorp Vault в виртуальной машине Vagrant/VirtualBox. Это не является обязательным для выполнения задания, но для лучшего понимания что происходит при выполнении команд (посмотреть результат в UI), можно по аналогии с netdata из прошлых лекций пробросить порт Vault на localhost:


#### insatall Valut

    - sudo apt update
    - sudo apt-get install jq
    - sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    - sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    - sudo apt-get update && sudo apt-get install vault


```
vault --version
	Vault v1.7.3 (5d517c864c8f10385bf65627891bc7ef55f5e827)
```

Запускаем Vault в dev режиме: 

```
vagrant@vagrant:~$ VAULT_UI=true vault server -dev -dev-listen-address="0.0.0.0:8200" -dev-root-token-id="root"
```
```
==> Vault server configuration:

             Api Address: http://0.0.0.0:8200
                     Cgo: disabled
         Cluster Address: https://0.0.0.0:8201
              Go Version: go1.15.13
              Listener 1: tcp (addr: "0.0.0.0:8200", cluster address: "0.0.0.0:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: info
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: inmem
                 Version: Vault v1.7.3
             Version Sha: 5d517c864c8f10385bf65627891bc7ef55f5e827

```
```
vagrant@vagrant:~$ export VAULT_ADDR='http://0.0.0.0:8200'
vagrant@vagrant:~$ vault status
```
```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.7.3
Storage Type    inmem
Cluster Name    vault-cluster-7d00a8c4
Cluster ID      b97bcf57-a7fe-af67-5ab2-3b40949a27a9
HA Enabled      false
vagrant@vagrant:~$

```
Создадим Root CA и Intermediate CA

#### generate the Root CA:

```
vault login root
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                root
token_accessor       Ju08zQKiUa29417ASaPW4kfF
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```
```
 vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
```
```
 vault write -format=json pki/root/generate/internal common_name="pki-ca-root" ttl=87600h | tee >(jq -r .data.certificate > ca.pem) >(jq -r .data.issuing_ca > issuing_ca.pem) >(jq -r .data.private_key > ca-key.pem)

```
```
 curl -s http://0.0.0.0:8200/v1/pki/ca/pem | openssl x509 -text
 ```
 ```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            16:36:0c:ca:7f:15:fe:73:84:26:53:28:55:0c:0e:95:60:54:cf:ee
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = pki-ca-root
        Validity
            Not Before: Jun 22 18:57:06 2021 GMT
            Not After : Jul 24 18:57:35 2021 GMT
        Subject: CN = pki-ca-root
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:a6:71:80:95:1d:32:e8:68:3a:06:e8:9b:e2:be:
                    a5:98:96:0e:5a:6e:7c:21:8e:fe:a8:17:d7:01:de:
                    cd:3c:5d:ff:70:82:b9:9a:ff:38:8d:22:30:d7:63:
                    57:c9:22:d4:ca:a6:e6:e5:bd:0f:25:a4:65:5e:af:
                    c3:27:c2:12:71:66:bb:19:07:ba:49:65:40:0b:b3:
                    e8:e2:69:6d:99:49:8e:11:0c:79:0f:d4:59:45:77:
                    4a:2f:d2:f1:c7:f7:2f:b8:03:f0:76:3b:0f:84:5d:
                    0e:ed:eb:38:e9:8d:4d:16:90:a1:7f:cf:02:00:21:
                    fb:1c:c1:9f:56:7a:f7:7d:aa:f6:8b:c0:0d:a9:a2:
                    ac:ba:5a:b2:31:9f:de:bf:5c:0f:69:44:57:16:a3:
                    40:c2:96:e7:aa:45:53:14:66:6a:ee:42:fa:e9:9f:
                    e1:88:82:13:05:e9:16:1e:7e:c0:0c:c9:11:40:39:
                    c8:70:23:87:1f:0f:0f:8f:5f:2e:7a:9c:d6:69:cf:
                    a9:b2:82:28:41:ca:31:29:7b:5b:00:8d:d2:62:25:
                    81:69:19:c8:62:2a:38:90:c2:f3:10:83:98:32:a7:
                    ad:04:34:1f:59:35:00:2a:3f:96:36:99:b3:83:35:
                    0e:7e:f0:ab:30:93:c6:26:cd:49:70:43:53:14:e1:
                    32:93
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Key Identifier:
                5D:82:E3:87:EE:0D:2A:31:CE:F1:49:7D:FE:33:B0:F1:85:86:4B:BB
            X509v3 Authority Key Identifier:
                keyid:5D:82:E3:87:EE:0D:2A:31:CE:F1:49:7D:FE:33:B0:F1:85:86:4B:BB

            X509v3 Subject Alternative Name:
                DNS:pki-ca-root
    Signature Algorithm: sha256WithRSAEncryption
         39:9d:7b:ba:31:53:fe:ae:2d:ef:c9:ef:25:ae:79:b6:c2:86:
         b0:9f:9e:17:98:b9:1e:c5:e5:79:3f:6d:13:09:17:60:d9:ec:
         b4:e4:42:77:3f:eb:93:2f:cb:6e:c2:86:06:7f:30:46:e3:b2:
         3d:03:a4:5f:f6:9d:30:79:9e:57:de:4f:9a:4b:9b:69:9a:81:
         75:64:5f:bf:48:95:91:ee:5d:66:04:08:80:7a:a2:73:d1:83:
         c7:d7:c4:2a:ca:a2:15:f4:27:8d:4e:e8:68:e2:49:6b:53:35:
         64:49:e0:4a:4f:7f:c8:7d:61:fb:70:41:9f:9f:46:f8:5c:fd:
         ba:49:79:c2:2b:d6:d5:b4:4f:6c:04:5c:23:f1:f4:a2:6b:c8:
         37:a1:ce:42:a7:0e:f4:b8:fc:07:79:5d:af:80:42:e5:0e:66:
         27:5a:81:ae:fd:87:cd:84:ef:74:02:7d:aa:3c:b7:9c:24:37:
         ab:60:92:da:fd:0f:7f:b2:bb:eb:90:6e:ff:de:ba:74:1e:37:
         4e:d2:6a:87:9d:44:d3:ca:76:e5:e4:ae:cc:c2:eb:ba:0c:bb:
         f3:77:2e:fb:51:ac:e6:5b:8e:93:8a:62:c8:3b:56:56:92:89:
         20:0a:30:1e:06:8b:32:9f:d9:51:e4:bb:05:91:c6:13:3f:8c:
         ab:df:c5:c6
-----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUFjYMyn8V/nOEJlMoVQwOlWBUz+4wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLcGtpLWNhLXJvb3QwHhcNMjEwNjIyMTg1NzA2WhcNMjEw
NzI0MTg1NzM1WjAWMRQwEgYDVQQDEwtwa2ktY2Etcm9vdDCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKZxgJUdMuhoOgbom+K+pZiWDlpufCGO/qgX1wHe
zTxd/3CCuZr/OI0iMNdjV8ki1Mqm5uW9DyWkZV6vwyfCEnFmuxkHukllQAuz6OJp
bZlJjhEMeQ/UWUV3Si/S8cf3L7gD8HY7D4RdDu3rOOmNTRaQoX/PAgAh+xzBn1Z6
932q9ovADamirLpasjGf3r9cD2lEVxajQMKW56pFUxRmau5C+umf4YiCEwXpFh5+
wAzJEUA5yHAjhx8PD49fLnqc1mnPqbKCKEHKMSl7WwCN0mIlgWkZyGIqOJDC8xCD
mDKnrQQ0H1k1ACo/ljaZs4M1Dn7wqzCTxibNSXBDUxThMpMCAwEAAaN7MHkwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFF2C44fuDSox
zvFJff4zsPGFhku7MB8GA1UdIwQYMBaAFF2C44fuDSoxzvFJff4zsPGFhku7MBYG
A1UdEQQPMA2CC3BraS1jYS1yb290MA0GCSqGSIb3DQEBCwUAA4IBAQA5nXu6MVP+
ri3vye8lrnm2woawn54XmLkexeV5P20TCRdg2ey05EJ3P+uTL8tuwoYGfzBG47I9
A6Rf9p0weZ5X3k+aS5tpmoF1ZF+/SJWR7l1mBAiAeqJz0YPH18QqyqIV9CeNTuho
4klrUzVkSeBKT3/IfWH7cEGfn0b4XP26SXnCK9bVtE9sBFwj8fSia8g3oc5Cpw70
uPwHeV2vgELlDmYnWoGu/YfNhO90An2qPLecJDerYJLa/Q9/srvrkG7/3rp0HjdO
0mqHnUTTynbl5K7Mwuu6DLvzdy77UazmW46TimLIO1ZWkokgCjAeBosyn9lR5LsF
kcYTP4yr38XG
-----END CERTIFICATE-----

```
подпишим Intermediate CA csr на сертификат для тестового домена netology.example.com

#### enable and configure an Intermediate CA
```
    vault secrets enable -path pki_int pki
```
Success! Enabled the pki secrets engine at: pki_int/
```
vault write -format=json pki_int/intermediate/generate/internal common_name="pki-ca-int" ttl=43800h | tee >(jq -r .data.csr > pki_int.csr) >(jq -r .data.private_key > pki_int.pem)
```
```
{
  "request_id": "a1ddf33d-35c5-7ed2-5fc1-7725d80dd7ed",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": {
    "csr": "
    -----BEGIN CERTIFICATE REQUEST-----
MIICgjCCAWoCAQAwFTETMBEGA1UEAxMKcGtpLWNhLWludDCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAO5l9qZWIsn5shgiieruZ03uSqLhKbq1xHkOGOq6
i1oRbYqDBJvkrPI7XwOid0pJo5Ojuah3CHPNVuVTHuISUUphitcQHwOW5XRCqD/4
X+1B07TRiqgyxIrNzRe82GPydkaymRJJDITtTYJLNsE+iX7IqiUxyP7XpDcCUGnH
vok3HFz/WkegpwDJAaV2IkJhAHkuqO2mk3No5bLOJOY0g64YEqZujxEpDToP97ty
Q/wIWxY4xYhuKJiybwdKc5IeUtqnBIm3DJtfDPGGxr1Mb8bgDfdtQpmdUVB8mUTa
mjJvCxi49auxIrQueuSD+/e/ONfzfNUmBQx/i8vj6ZdlRsECAwEAAaAoMCYGCSqG
SIb3DQEJDjEZMBcwFQYDVR0RBA4wDIIKcGtpLWNhLWludDANBgkqhkiG9w0BAQsF
AAOCAQEAEP0UU2y/fjYm859xiTkufMM8WOnJjaF6vSMVZA6+5hepk4CW2LHNpOXD
RQo80aAoqLv9RsV8le9r1qKBVf7JW0DW9T5Z368w2G7gVxVvJq7Wzch00FLG4CAC
/xVaBTOzwN785THm+A6xa4Do3am+MxExQnyT+Weube3FtXkLt7koP+TH9TT0ht5L
vIuo5BLcRiYXp3Q/ENSx7OiL45DD4KeIsIL9l/kWw2rinptPPrwmQsjhHiHlzFRj
thqIDH6yCbqG1X9ujKSoCU+FfkNOk8GVBHRW1xw6jYfS9GO8+WsdoaOgTIjIVfZc
h+/vTVH/bStPp04d8ZbzLusHNgWlgQ==
-----END CERTIFICATE REQUEST-----"
  },
  "warnings": null
}
```
```
vault write pki_int/intermediate/set-signed certificate=@pki_int.pem
```
```
Success! Data written to: pki_int/intermediate/set-signed
```
#### PKI Role

 ```
 vault login s.6ZlvUSO93OW4tlyTFOEkgnxl
```
```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.6ZlvUSO93OW4tlyTFOEkgnxl
token_accessor       GbxoEgaus0Yb57KbkNSuAeUE
token_duration       47h58m38s
token_renewable      true
token_policies       ["default" "pki_int"]
identity_policies    []
policies             ["default" "pki_int"]
```

#### Create a Role
```
vault write pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"
vault write pki_int/issue/example-dot-com common_name="netology.example.com" ttl="24h"
```
```
{
  "certificate": 
  "-----BEGIN CERTIFICATE-----
MIID0DCCArigAwIBAgIUCHLzZsARupKtLb6Tp1UKzu8EPZswDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKcGtpLWNhLWludDAeFw0yMTA2MjIyMTA1MDdaFw0yMTA2
MjMyMTA1MzdaMB8xHTAbBgNVBAMTFG5ldG9sb2d5LmV4YW1wbGUuY29tMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoCCqyP4dDbZ+jmwnAQ4k1L9u2+mH
gTLN44eyQk22c4Fm6a/wgTBn62b/wUz7XIphXC56ax2mG/FSjqsEbrWlglVETTBw
hQoO5LxF4VyIaQ2s4Ib6fZNYtrSSftWxWTK52bgI6iIjKAfDPYIVODRVqv3zlVOp
tSpd9glfLwwqqyAsGrB+B7RwDg7lG4VFlpVxsFmTt5VbHP+aq2uAcLE7oOyYNGgh
q+lmtbgRvqWvFybp3nmeggDt5MZnyL5Ua4tq9lLeR9/tw3s1Bc4Ihdc99evul7bb
NYI4iVF6UXnTEB7jrFtY/f5BcI7wVF1L96tN8Gl1Pds4YVOCAXDeOcIZuwIDAQAB
o4IBDDCCAQgwDgYDVR0PAQH/BAQDAgOoMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggr
BgEFBQcDAjAdBgNVHQ4EFgQUhT9FCFK2BQurjxGoxcsb1sH0sdowHwYDVR0jBBgw
FoAUHVdOZhyZgLF3x/IOenJnsYFUXSYwPwYIKwYBBQUHAQEEMzAxMC8GCCsGAQUF
BzAChiNodHRwOi8vbG9jYWxob3N0OjgyMDAvdjEvcGtpX2ludC9jYTAfBgNVHREE
GDAWghRuZXRvbG9neS5leGFtcGxlLmNvbTA1BgNVHR8ELjAsMCqgKKAmhiRodHRw
Oi8vbG9jYWxob3N0OjgyMDAvdjEvcGtpX2ludC9jcmwwDQYJKoZIhvcNAQELBQAD
ggEBAM60BQUyBf/nnnMinWZ7oHbTmR+15LZxV80fvOQHGwPIyWxtNFVgKCYhVd7f
po+0aJWL+TenLCZHVAXn5cplKsteUOQVxggExw0/LU0aeD+CkPQmJ8YnCX54kYgh
KmQjJ7/QCY9d7Gn72+TYTnLEgkNR706IczfvCjSdaJNxIr9os2248kHxOsUCMUpS
97XVror9819zCkLhucmNrlFqziovjZu2OAYSmOzT64xUPh5/a9QM66kVlIWomfom
0nLq8R9aLAyOqcrOv4D4/dgu8yPQdU+oM9qgDn3iMv/7iucjWzNMlrwDIpnHaCHl
w1qStQ0+mHqLLSyGI9Oq6AZnMPA=
-----END CERTIFICATE-----",

"issuingCa": 
"-----BEGIN CERTIFICATE-----
MIIDMzCCAhugAwIBAgIUTuBVUp4ccaLp5d4+y6t4Rxtn0VAwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLcGtpLWNhLXJvb3QwHhcNMjEwNjIyMTk0MDIwWhcNMjEw
NzI0MTk0MDUwWjAVMRMwEQYDVQQDEwpwa2ktY2EtaW50MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEA7mX2plYiyfmyGCKJ6u5nTe5KouEpurXEeQ4Y6rqL
WhFtioMEm+Ss8jtfA6J3Skmjk6O5qHcIc81W5VMe4hJRSmGK1xAfA5bldEKoP/hf
7UHTtNGKqDLEis3NF7zYY/J2RrKZEkkMhO1Ngks2wT6JfsiqJTHI/tekNwJQace+
iTccXP9aR6CnAMkBpXYiQmEAeS6o7aaTc2jlss4k5jSDrhgSpm6PESkNOg/3u3JD
AhbFjjFiG4omLJvB0pzkh5S2qcEibcMm18M8YbGvUxvxuAN921CmZ1RUHyZRNqa
Mm8LGLj1q7EitC565IP797841/N81SYFDH+Ly+Ppl2VGwQIDAQABo3oweDAOBgNV
HQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUHVdOZhyZgLF3
x/IOenJnsYFUXSYwHwYDVR0jBBgwFoAUXYLjh+4NKjHO8Ul9/jOw8YWGS7swFQYD
VR0RBA4wDIIKcGtpLWNhLWludDANBgkqhkiG9w0BAQsFAAOCAQEAHVRCVjWKuHXj
UBOcZRlsfsW/d9Uc7RamRCaTNJ9NMfFkQWuv3Mg4ejGx2mBL/laiIKymGFXf+Byo
YjHbHwvqb+h6vLQN7CoJBEsP0hCiUqB5CSn5wnFwfG8o52XWhT6vUBBoOEz20Gkk
LWIqa7TV32lDPlaPMCjjNVj68ANPok8zxpBveBN6P23JB98t2hWUHDSYiHw9F6mb
w6p9e6kiyZvjws4TR4jcjpvVFS5sui9MyQJtQIula18rkFovQtZl5u/s31nHjT5s
h0GUQ+3LfGSbNsz7tV/nFlncGazZh3tFHYRH7yYMwQq6YXh1C6HG0WtLpwvXim9c
dwRi1l94Kg==
-----END CERTIFICATE-----",
  
"caChain": 
"-----BEGIN CERTIFICATE-----
MIIDMzCCAhugAwIBAgIUTuBVUp4ccaLp5d4+y6t4Rxtn0VAwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLcGtpLWNhLXJvb3QwHhcNMjEwNjIyMTk0MDIwWhcNMjEw
NzI0MTk0MDUwWjAVMRMwEQYDVQQDEwpwa2ktY2EtaW50MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEA7mX2plYiyfmyGCKJ6u5nTe5KouEpurXEeQ4Y6rqL
WhFtioMEm+Ss8jtfA6J3Skmjk6O5qHcIc81W5VMe4hJRSmGK1xAfA5bldEKoP/hf
7UHTtNGKqDLEis3NF7zYY/J2RrKZEkkMhO1Ngks2wT6JfsiqJTHI/tekNwJQace+
iTccXP9aR6CnAMkBpXYiQmEAeS6o7aaTc2jlss4k5jSDrhgSpm6PESkNOg/3u3JD
/AhbFjjFiG4omLJvB0pzkh5S2qcEibcMm18M8YbGvUxvxuAN921CmZ1RUHyZRNqa
Mm8LGLj1q7EitC565IP797841/N81SYFDH+Ly+Ppl2VGwQIDAQABo3oweDAOBgNV
HQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUHVdOZhyZgLF3
x/IOenJnsYFUXSYwHwYDVR0jBBgwFoAUXYLjh+4NKjHO8Ul9/jOw8YWGS7swFQYD
VR0RBA4wDIIKcGtpLWNhLWludDANBgkqhkiG9w0BAQsFAAOCAQEAHVRCVjWKuHXj
UBOcZRlsfsW/d9Uc7RamRCaTNJ9NMfFkQWuv3Mg4ejGx2mBL/laiIKymGFXf+Byo
YjHbHwvqb+h6vLQN7CoJBEsP0hCiUqB5CSn5wnFwfG8o52XWhT6vUBBoOEz20Gkk
LWIqa7TV32lDPlaPMCjjNVj68ANPok8zxpBveBN6P23JB98t2hWUHDSYiHw9F6mb
w6p9e6kiyZvjws4TR4jcjpvVFS5sui9MyQJtQIula18rkFovQtZl5u/s31nHjT5s
h0GUQ+3LfGSbNsz7tV/nFlncGazZh3tFHYRH7yYMwQq6YXh1C6HG0WtLpwvXim9c
dwRi1l94Kg==
-----END CERTIFICATE-----",
  
  "privateKey":
"-----BEGIN RSA PRIVATE KEY-----
  
MIIEowIBAAKCAQEAoCCqyP4dDbZ+jmwnAQ4k1L9u2+mHgTLN44eyQk22c4Fm6a/w
gTBn62b/wUz7XIphXC56ax2mG/FSjqsEbrWlglVETTBwhQoO5LxF4VyIaQ2s4Ib6
fZNYtrSSftWxWTK52bgI6iIjKAfDPYIVODRVqv3zlVOptSpd9glfLwwqqyAsGrB+
B7RwDg7lG4VFlpVxsFmTt5VbHP+aq2uAcLE7oOyYNGghq+lmtbgRvqWvFybp3nme
ggDt5MZnyL5Ua4tq9lLeR9/tw3s1Bc4Ihdc99evul7bbNYI4iVF6UXnTEB7jrFtY
/f5BcI7wVF1L96tN8Gl1Pds4YVOCAXDeOcIZuwIDAQABAoIBAQCfDNOWoRGqtUIv
pS141tuulhc/SE7X/eaTwg1F3nsDb90Q8TkqmTIfmEchcZ2a5bifH2tpSiHcT295
VlUowjSLqLYXFa4t9zej635dwtObxYGZ43ibkufjUqjQYuGtf70qjKoOJapV8J/1
UGhTU2hkV6rDAD7pPBPodpac3LDlF5TyB+c8nKvEm0c72C9Il5izdQnxQS0ao0uK
z3P1H4+j4+9YxTPdF7Pqp5h9lf2iJtb4vrXNS/7YYN4hjR1K7kYAjsteyYBwl1Ey
oUAFTSN00eMHalNZ1EiNRU+6DWF7U9Fk9qIDaeXIsRcNKhf/7tuAH71Xuorccbz8
t3LVZWOBAoGBAMAYAiAuiGsDJaRR5f4OQTiL4Ro8ht4EiaTm4E08L39DUAhzSOrm
u5uIIa1ODPLEI33jIv0+GEtmXeHlZRKcOoPAYDe0xSbnRtg/P3bjv0frIDeTBTD4
InaxtOxM4SZpVxdwxbpMCXek2WdCDD1bDr7/v4uOOMlrDpSMqWpu54K5AoGBANVm
NJNAcZxFjwHWTagdjdLZmg3LrfDLgUsRC7FIoMz+ve3eLJkj9SDGWXCIMtHwBM06
5jF3v/Bn8jQENn840q1ToN4U7QkD0K+rFOXcTtujdMG1xKgdkXThyCv8vhFjNl2M
kMdl3hmaSbgEwJkotoAYKpFYVH5p1vcGxfGmU5YTAoGACrjMVZODVcXFMhjIJ5gQ
F+Hm3JoIRRgnvqaMWoNDe2z8aJxWs5XRXusIRi4XFu3PtVUaPNxcasj58IPnUlSa
B4STWkiiwHskPym4lyA7Kv56u99e6M7QzaM5n/7iikxS6iIHR1C7Loxq/hJ3sG0G
s65+uIFltghdtfjr897g2TECgYA06aS7pk0FTJILCJI0zy8tSttR9GDqxesHK/DU
QofsjHWXl3FDf5D2UXg32O2Q9IycPrB5L5IeEAgUMb85iGNkqsnGhzXG+HU0OZ1y
6U98UmlO5r0eWkaIzrsNfRu7v/fo9kOnzXBmtMT2pecDkv69gEB9zYMV3TR6B+no
4y7ylQKBgCq6VLWEVz1apkL4uXE6OZW2eXEcRRDgO73HhqVhsPbJr9HO8aHP9ii8
ow5rilOAYca41+7geoDadgtuTRgBfhJshs0PNEIFS2+x+EmzeM1HWweSioHbnlZg
CztaOvQaYm9FsO7rHJ6rzaxz9Nd6p3DuWg1vsdBH266Jk2rFnVlD
-----END RSA PRIVATE KEY-----",
  "privateKeyType": "rsa",
  "serialNumber": "08:72:f3:66:c0:11:ba:92:ad:2d:be:93:a7:55:0a:ce:ef:04:3d:9b"
}
```

Для автоматического подтягивания сертификата из Vault воспользуемся ***consul-template*** 
#### Install Consult
```
wget https://releases.hashicorp.com/consul-template/0.26.0/consul-template_0.26.0_linux_amd64.zip
sudo apt-get install unzip
unzip consul-template_0.26.0_linux_amd64.zip
sudo mv -v consul-template /usr/local/bin
```

```
root@vagrant:/etc/consul-template.d# systemctl start consul-template.service
root@vagrant:/etc/consul-template.d# systemctl status consul-template.service
● consul-template.service - consul-template
     Loaded: loaded (/etc/systemd/system/consul-template.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-06-23 07:16:14 UTC; 4s ago
   Main PID: 18142 (consul-template)
      Tasks: 7 (limit: 1074)
     Memory: 1.6M
     CGroup: /system.slice/consul-template.service
             └─18142 /usr/local/bin/consul-template -config=/etc/consul-template.d/pki-demo.hcl


sudo apt update
sudo apt install snapd
sudo snap install ngrok

ngrok http 8200
```

#### NGINX

```
root@vagrant:/home/vagrant/vault# systemctl status nginx.service
```
```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-06-23 08:08:23 UTC; 8s ago
       Docs: man:nginx(8)
    Process: 22869 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 22880 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 22881 (nginx)
      Tasks: 2 (limit: 1074)
     Memory: 2.6M
     CGroup: /system.slice/nginx.service
             ├─22881 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             └─22882 nginx: worker process

Jun 23 08:08:23 vagrant systemd[1]: Starting A high performance web server and a reverse proxy server...
Jun 23 08:08:23 vagrant systemd[1]: Started A high performance web server and a reverse proxy server.
```


```
root@vagrant:/home/vagrant/vault# openssl x509 -in /etc/nginx/certs/yet.crt -noout -text -purpose
```
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            43:2f:a2:70:4b:2a:99:73:18:64:3b:e0:c9:f5:61:92:31:55:37:45
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = pki-ca-int
        Validity
            Not Before: Jun 22 10:27:43 2021 GMT
            Not After : Jun 22 10:30:13 2021 GMT
        Subject: CN = example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:d6:58:1e:59:4f:98:87:49:d1:d1:5e:37:12:99:
                    12:6a:aa:3e:20:ac:3e:ea:76:58:10:f7:37:02:62:
                    ba:41:17:d5:1b:20:fe:aa:23:f7:d1:24:e0:27:de:
                    92:79:bf:df:41:b3:4c:a8:37:7c:87:31:8a:3a:13:
                    d1:ec:2b:a5:18:d2:fe:e8:66:1b:00:94:61:81:58:
                    6e:cb:7d:8f:5f:03:01:48:a0:33:ea:a9:6d:08:ca:
                    32:d2:4b:33:84:d7:36:e7:99:98:e4:7e:6a:dd:1c:
                    66:06:00:90:a9:67:71:e1:dd:5b:f9:40:34:f4:7c:
                    b1:9e:e8:d4:ac:ce:7a:9d:f5:3d:db:ab:c9:a9:5d:
                    ac:e6:af:4d:a0:d8:23:19:47:15:7d:ab:df:6f:a0:
                    42:bd:91:2e:4b:70:06:72:b7:5f:5f:13:d9:5b:57:
                    5d:96:ce:e3:80:5c:5b:4d:af:4a:83:a7:78:e2:6e:
                    71:46:8f:56:d3:85:d7:ba:c1:ae:87:31:78:eb:b6:
                    46:65:f2:ce:bf:b8:53:42:9e:6e:d1:c9:54:99:e7:
                    8f:43:ad:59:31:81:a9:38:8c:ea:34:cc:4f:3a:b4:
                    4a:4d:95:fd:93:ec:e1:fb:ad:bf:a6:26:6b:ba:f3:
                    f8:54:f9:8c:23:a8:54:c7:15:b4:f1:4a:94:b4:52:
                    2a:3f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment, Key Agreement
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Subject Key Identifier:
                62:DB:93:3E:05:FF:3B:62:56:7E:B2:89:2D:01:2A:D6:8F:71:10:D2
            X509v3 Authority Key Identifier:
                keyid:C1:4D:58:9F:A3:55:C6:8B:98:F5:D8:40:AD:F8:6F:67:67:E1:4B:7D

            Authority Information Access:
                CA Issuers - URI:http://127.0.0.1:8200/v1/pki_int/ca

            X509v3 Subject Alternative Name:
                DNS:example.com
            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://127.0.0.1:8200/v1/pki_int/crl

    Signature Algorithm: sha256WithRSAEncryption
         57:76:73:33:0c:6f:49:68:66:fa:85:07:90:6c:30:f9:79:d6:
         91:ca:35:76:7e:e1:18:50:75:47:f6:65:6a:76:40:e0:a0:cd:
         de:51:d4:3c:fa:05:78:99:e2:70:1a:80:67:f5:75:9f:b2:95:
         91:c5:5a:72:95:fa:49:8b:18:6c:5a:8f:f0:2e:e0:a8:82:44:
         a0:36:54:15:dc:8d:2e:c0:95:67:d8:2b:13:39:be:84:16:e7:
         99:9e:e5:27:60:76:6f:5a:84:98:81:d1:ea:02:c4:be:af:98:
         47:c3:f4:e5:3c:43:3b:36:23:75:b1:f4:25:95:4d:b6:93:83:
         51:fc:01:59:db:56:03:9f:07:5c:b3:57:2b:fd:f3:fa:68:64:
         0f:61:75:de:ec:ec:eb:75:68:78:73:92:ff:91:97:b3:d9:e2:
         f8:06:f4:ff:d8:c8:23:d4:ba:ef:65:09:c2:bc:3a:2e:a2:f1:
         da:f8:9e:63:4e:b3:35:30:70:89:ef:c7:f5:84:8e:6f:fc:76:
         38:b2:ec:ee:47:e0:d2:44:2e:99:68:16:1f:48:46:44:bc:dc:
         1d:5d:05:5e:ec:80:3d:1d:ae:00:94:06:1f:dd:64:b3:bf:85:
         23:50:1f:44:82:a9:94:73:9a:55:3b:a4:fc:1d:f2:f5:83:32:
         f3:9b:33:b9
Certificate purposes:
SSL client : Yes
SSL client CA : No
SSL server : Yes
SSL server CA : No
Netscape SSL server : Yes
Netscape SSL server CA : No
S/MIME signing : No
S/MIME signing CA : No
S/MIME encryption : No
S/MIME encryption CA : No
CRL signing : No
CRL signing CA : No
Any Purpose : Yes
Any Purpose CA : Yes
OCSP helper : Yes
OCSP helper CA : No
Time Stamp signing : No
Time Stamp signing CA : No
```

---

```
curl -s http://0.0.0.0:8200/v1/pki/ca/pem > pki_ca.pem

vagrant@vagrant:~/vault$
vagrant@vagrant:~/vault$ cat pki_ca.pem

-----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUFjYMyn8V/nOEJlMoVQwOlWBUz+4wDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLcGtpLWNhLXJvb3QwHhcNMjEwNjIyMTg1NzA2WhcNMjEw
NzI0MTg1NzM1WjAWMRQwEgYDVQQDEwtwa2ktY2Etcm9vdDCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKZxgJUdMuhoOgbom+K+pZiWDlpufCGO/qgX1wHe
zTxd/3CCuZr/OI0iMNdjV8ki1Mqm5uW9DyWkZV6vwyfCEnFmuxkHukllQAuz6OJp
bZlJjhEMeQ/UWUV3Si/S8cf3L7gD8HY7D4RdDu3rOOmNTRaQoX/PAgAh+xzBn1Z6
932q9ovADamirLpasjGf3r9cD2lEVxajQMKW56pFUxRmau5C+umf4YiCEwXpFh5+
wAzJEUA5yHAjhx8PD49fLnqc1mnPqbKCKEHKMSl7WwCN0mIlgWkZyGIqOJDC8xCD
mDKnrQQ0H1k1ACo/ljaZs4M1Dn7wqzCTxibNSXBDUxThMpMCAwEAAaN7MHkwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFF2C44fuDSox
zvFJff4zsPGFhku7MB8GA1UdIwQYMBaAFF2C44fuDSoxzvFJff4zsPGFhku7MBYG
A1UdEQQPMA2CC3BraS1jYS1yb290MA0GCSqGSIb3DQEBCwUAA4IBAQA5nXu6MVP+
ri3vye8lrnm2woawn54XmLkexeV5P20TCRdg2ey05EJ3P+uTL8tuwoYGfzBG47I9
A6Rf9p0weZ5X3k+aS5tpmoF1ZF+/SJWR7l1mBAiAeqJz0YPH18QqyqIV9CeNTuho
4klrUzVkSeBKT3/IfWH7cEGfn0b4XP26SXnCK9bVtE9sBFwj8fSia8g3oc5Cpw70
uPwHeV2vgELlDmYnWoGu/YfNhO90An2qPLecJDerYJLa/Q9/srvrkG7/3rp0HjdO
0mqHnUTTynbl5K7Mwuu6DLvzdy77UazmW46TimLIO1ZWkokgCjAeBosyn9lR5LsF
kcYTP4yr38XG
-----END CERTIFICATE-----

vagrant@vagrant:~/vault$
```

```
vagrant@vagrant:~/vault/tmp$ curl --cacert /home/vagrant/vault/tmp/pki_ca.pem --insecure -v https://netology.example.com 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
```
```
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=example.com
*  start date: Jun 22 10:27:43 2021 GMT
*  expire date: Jun 22 10:30:13 2021 GMT
*  issuer: CN=pki-ca-int
*  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x561297d73c60)
* Connection state changed (MAX_CONCURRENT_STREAMS == 128)!
* Connection #0 to host netology.example.com left intact
```
