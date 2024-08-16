# Auto Create Admin User

* Instructions:
1. In your master node `create a directory admin-user`
2. `cd to admin-user`
3. copy and run the script `admin-setup.sh`
4. you will be `prompted for admin name`
5. in the directory admin-user you should have:
 - ccr.yaml  
 - cert-gen.sh  
 - cr-crb.yaml  
 - <Your_Admin>.conf  
 - <Your_Admin>.crt 
 - <Your_Admin>.csr  
 - <Your_Admin>.key

* In your client machine:
1. create directory ~/.kube
2. cd to ~/.kube
3. copy with scp the <Your_Admin>.conf in `~.kube`

    ```sh
        scp your_user@192.168.1.x:/home/your_user/admin-certs/<Your_Admin>.conf .

    ```
3. rename <Your_Admin>.conf to config

    ```sh
        mv <Your_Admin>.conf config

    ```
4. Finally put `kubeconfig path` in `.bashrc` on the bottom of the configuration.

    ```sh
    echo "#Kubernetes config
    KUBECONFIG=~/.kube/debunker.conf" >> ~/.bashrc 

    ```
5. Check if present.

    ```sh
        cat ~/.bashrc

    ```
6. You should have access

    ```sh
        kubectl get pods -A
    ```