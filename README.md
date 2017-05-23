# KONG ➕ Openshift Deployment

![](/assets/kong.png)

Kong can easily be provisioned to Openshift cluster using the following steps:

1. **Initial setup**

    Install [hi-cli](https://github.com/hi-cli/hi-cli) and [hi-heketi](https://github.com/hi-cli/hi-heketi)
    ```bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/hi-cli/hi-cli/master/bin/install)"

    hi package install heketi

    ```

    Download or clone the following repo:

    ```bash
    git clone git@github.com:john-deng/kong-openshift.git
    cd kong-openshift    
    ```

    Create Openshift Project and edit supplemental-group and uid-range

    ```bash
    oc new-project gateway-dev

    oc edit ns gateway-dev
    ```
    ![](/assets/original-ns.png) => ![](/assets/modified-ns.png)

    Edit hi.conf, modify heketi_password and heketi_cli_server
    ```bash
    vim hi.conf
    ```
    ![](/assets/hi-conf.png)

    Create PV and PVC
    ```bash
    hi heketi create pv size=4 pvc name=kong-database-claim uid=26
    ```

    ![](/assets/create-pvc.png)

    Check if pvc is created

    ```bash
    oc get pvc
    ```

    ![](/assets/check-pvc.png)

    Enable Container Images that Require Root

    ```bash
    oc adm policy add-scc-to-user anyuid system:serviceaccount:gateway-dev:default
    ```

    Deploy Kong
    ```bash
    oc process -f kong-template.yaml -v PROJECT_NAME=gateway-dev -v KONG_DASHBOARD_PASSWORD=password | oc create -f -
    ```

    ![](/assets/kong-deployment.png)


    The last step, expose service
    ```bash
    oc expose svc/kong-dashboard

    oc expose svc/kong-admin
    
    oc expose svc/kong-proxy
    ```

2. **Usage**

    Scale up Kong

    ![](/assets/kong-view.png)

    Open Kong dashboard, after exposed svc/kong-dashboard, you should able to open dashboard on your web browser.

    ![](/assets/kong-dashboard-view.png)

    Setting Kong node URL

    ![](/assets/kong-dashboard-conf.png)

    Add API to gateway

    Assume that you've deployed the spring-boot app 'appname' which expose port 8080, then fill below form and proess SAVE button.
    * Name: project-name-app-name-api
    * Uris: /project-name/app-name/api/
    * Upstream url: http://appname.projectname.svc.cluster.local:8080/projectname/appname/api/

    ![](/assets/kong-dashboard-add-api.png)

    Now you can check your api 
    ```bash
    http http://kong-proxy-gateway-dev.openshift-subdomain.com/projectname/appname/api/health
    ```

    ![](/assets/http-check-gateway-health.png)