#!/bin/bash
echo "Create a CertificateSigningRequest"

# Prompt for admin name
read -p "Enter the admin name: " ADMIN_NAME

# Generate key and create CSR
echo 'Generate key and create CSR'
openssl genrsa -out "${ADMIN_NAME}.key" 2048 
openssl req -new -key "${ADMIN_NAME}.key" -out ${ADMIN_NAME}.csr -subj "/CN=${ADMIN_NAME}/O=system:admin"

# Base64 encode CSR
echo "Base64 encode CSR"
CSR_Cert=$(cat "${ADMIN_NAME}.csr" | base64 | tr -d "\n")


# Create CertificateSigningRequest YAML
echo "Create CertificateSigningRequest YAML"
sudo bash -c "cat > ccr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: 
spec:
  request: 
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 8640000  # 100 days
  usages:
  - client auth
EOF
"

# Substitute admin name and CSR in YAML
echo "Substitute admin name and CSR in YAML"
sed -i "s/name: /name: $ADMIN_NAME/g" ccr.yaml
sed -i "s/request: /request: $CSR_Cert/g" ccr.yaml
kubectl apply -f ccr.yaml

# Display updated YAML
echo "Updated ccr.yaml:"
cat ccr.yaml
kubectl get csr

# Approve certificate for 100 days
echo 'Approve certificate for 100 days'
kubectl certificate approve $ADMIN_NAME
kubectl get csr
sleep 2

# Extract the certificate
echo 'Extract the certificate'
kubectl get csr "$ADMIN_NAME" -o jsonpath='{.status.certificate}' | base64 -d > "${ADMIN_NAME}.crt"
sleep 2

# Check Generated files
echo 'Check Generated files'
ls -la
sleep 5

cp ~/.kube/config .
mv config "${ADMIN_NAME}.conf"


Client_Cert_Data=$(cat ${ADMIN_NAME}.crt | base64 | tr -d "\n")
Client_Key_Data=$(cat ${ADMIN_NAME}.key | base64 | tr -d "\n")

sed -i "s/user: kubernetes-admin/user: ${ADMIN_NAME}/" ${ADMIN_NAME}.conf
sed -i "s/name: kubernetes-admin@kubernetes/name: ${ADMIN_NAME}@kubernetes/" ${ADMIN_NAME}.conf
sed -i "s/current-context: kubernetes-admin@kubernetes/current-context: ${ADMIN_NAME}@kubernetes/" ${ADMIN_NAME}.conf
sed -i "s/- name: kubernetes-admin/- name: ${ADMIN_NAME}/" ${ADMIN_NAME}.conf

sed -i "s/client-certificate-data: .*/client-certificate-data: ${Client_Cert_Data}/" ${ADMIN_NAME}.conf

sed -i "s/client-key-data: .*/client-key-data: ${Client_Key_Data}/" ${ADMIN_NAME}.conf

cat ${ADMIN_NAME}.conf
sleep 5

# Append to cr-crb.yaml file
sudo bash -c "cat >> cr-crb.yaml <<EOF
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: 
rules:
- apiGroups: [\"\"]
  resources: [\"*\"]
  verbs: [\"*\"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: 
subjects:
- kind: User
  name: 
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: 
  apiGroup: rbac.authorization.k8s.io
EOF
"

sed -i "s/name: /name: $ADMIN_NAME/g" cr-crb.yaml
