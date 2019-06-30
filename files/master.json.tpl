{
  "datacenter":"${environment}",
  "primary_datacenter":"${environment}",
  "acl_default_policy":"allow",
  "acl_down_policy":"allow",
  "acl_master_token":"${token}",
  "encrypt":"${encryption_key}",
  "disable_remote_exec": true,
  "recursors" : [ "8.8.8.8" ],
  "addresses" : {
     "http": "0.0.0.0",
      "dns": "0.0.0.0"
  },
  "ports" : {
    "dns" : 53
  }
}

