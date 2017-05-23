# KONG ➕ Openshift Deployment

![](/assets/kong.png)

Kong can easily be provisioned to Kubernetes cluster using the following steps:

1. **Initial setup**

    Install [hi-cli](https://github.com/hi-cli/hi-cli) and [hi-heketi](https://github.com/hi-cli/hi-heketi)
    ```bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/hi-cli/hi-cli/master/bin/install)"

    hi package install heketi

    ```

    Create PV and PVC
    ```bash
    hi heketi create pv size=4 pvc name=kong-database-claim uid=26
    ```


    Download or clone the following repo:

    ```bash
    git clone git@github.com:john-deng/kong-openshift.git
    cd kong-openshift

    oc process -f kong-template.yaml | oc create -f -
    ```
    