# K8s Cluster Admin Access

 <link rel="stylesheet" type="text/css" href="css/image">

Give yourself full `k8s Cluster Access` with full `Admin rights` from your laptop.

## Types of access to k8s

There are three main categories of accesses in a k8s cluster:

- Admin access (full access for administrators)
- User access (limited access for other cluster users, usually limited to name space(s))
- Service account access (access allowing applications `Jenkins` to perfrom actions on the cluster)

### Admin access

Prerequisites:

1. In your master-node create a directory `client_certificates`.
2. Create a CertificateSigningRequest.

```sh
openssl genrsa -out home-admin.key 2048 # Generates ssl key
openssl req -new -key home-admin.key -out home-admin.csr -subj "/CN=home-admin" # Generates a Create a CertificateSigningRequest/ CSR
```

3. In the directory `client_certificates` pass the command.

```sh
tree
```

output
There are two files:

```xml
├── home-admin.crt
├── home-admin.csr
```

![Screenshot 1!](/Screenshots/Screenshots-1.png)

#### Place your request with k8s and verify

1. Create a script `csr-script.sh` and got to kubernetes [CSR instructions](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/) and paste the CSR manifest in the script.

![Screenshot 2!](/Screenshots/Screenshots-2.png)

2. Replace `request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVF` with your on which you need to generate from the `home-admin.csr`.

```sh
cat | base64 home-admin.csr | tr -d "\n" #to generate "request: key in base64 format.
```

![Screenshot 3!](/Screenshots/Screenshots-3.png)

3. Run the script and check.

```sh
kubectl get csr # the status of the certificate should be pending
```

4. Approve the CSR

```sh
kubectl certificate approve home-admin # now check again and the status should bee approved
```

5. Extract the certificate for `home-admin in text format decoded from base64`.

```sh
kubectl get csr home-admin -o jsonpath='{.status.certificate}'| base64 -d > home-admin.crt
```

- Now you should have the following files in the `client_certificates`:

```xml
.
├── csr-script.sh
├── home-admin.crt
├── home-admin.csr
└── home-admin.key
```

#### Create the home-admin certificate

1. Copy the existing certificate in `.kube/conf` to a separate location.
2. Open with a text editor and modify as follows.
3. You will see three certificates:

- `certificate-authority-data`
- `client-certificate-data`
- `client-key-data`

5. Keep the `certificate-authority-data` unchanged!

![Screenshot 4!](/Screenshots/Screenshots-4.png)

6. Under `server: https://192.x.x.x` change the following with `home-admin`.

![Screenshot 5!](/Screenshots/Screenshots-5.png)

7. Change - `client-certificate-data`and `client-key-data` by deleting the certificates.

![Screenshot 6!](/Screenshots/Screenshots-6.png)

8. Encode

```xml
├── home-admin.crt in format base64
├── home-admin.csr in format base64
```

Replace `client-certificate-data`and `client-key-data` with the newly generated ones.

```sh
  cat | base64 home.crt | tr -d "\n"
  cat | base64 home.key | tr -d "\n"

```

![Screenshot 7!](/Screenshots/Screenshots-7.png)

#### Create ClusterRole and ClusterRoleBinding

1. Create the ClusterRole and ClusterRoleBinding manifest `crole-crbinding.yaml`.

```xml
.
├── crole-crbinding.yaml
├── csr-script.sh
├── home-admin.crt
├── home-admin.csr
└── home-admin.key
```

2. Paste the content:

```sh
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: home-admin
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: home-admin
subjects:
- kind: User
  name: home-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: home-admin
  apiGroup: rbac.authorization.k8s.io
```

3. Check CR, CRB

```sh
kubectl get clusterrole
kubectl get clusterrolebinding
```

4. Move the new config file to your laptop `~/.kube/`.

- Make sure you have [kubectl installed](https://kubernetes.io/docs/tasks/tools/) and run from your laptop.

 ```sh
 kubectl get pods
 ```
