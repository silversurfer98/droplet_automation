# configure sops

- If u create age key, get the public from its
- set that value to env variable
```bash
 export SOPS_AGE_RECIPIENTS=agePubKey
 or
 export SOPS_AGE_RECIPIENTS=$(cat ~/sops-key/key.txt |grep -oP "public key: \K(.*)")
```
- once this is exported we can just encrypt any file like this `sops -e -i file.yaml`
- similarly decrypt using `sops -d -i file.yaml`
- if we are in this state we can use terraform's sops provider to directly decrypt the sensitive data