


#  

# Deploy OpenShift 4.X on Classic IBM Cloud Infrastructure or IC4G

##

## Introduction

The purpose of this tutorial is to install OpenShift 4.X on IBM Cloud Classic Infrastructure or on IBM Cloud for Government (IC4G) VSI&#39;s. By following this tutorial, you will get all the advantage of inheriting IaaS FedRAMP high controls from the IC4G infrastructure layer and use OpenShift to deploy container workloads on enterprise grade cloud. Enterprise customers will have complete control of the Management and Data Plane of OpenShift to manage the environment entirely as they have done on-premises. The organization that has invested in IBM Cloud Classic Infrastructure can reuse the techniques and knowledge to deploy OpenShift 4.X. The cost of standing OpenShift can be set to either hourly or monthly. Organizations can quickly scale OpenShift to meet dev, test, and prod use-case environments. It also provides the option to update OpenShift on an independent schedule to fit with a project timeline.

### Services used

This tutorial uses the following runtimes and services:

- [Virtual Servers](https://cloud.ibm.com/gen1/infrastructure/provision/vs?)

> **NOTE:** This tutorial may incur costs. Use the [Pricing Calculator](https://cloud.ibm.com/estimator/review) to generate a cost estimate based on your projected usage.

##  
## 	Architecture Diagram
<img src=images/ocp_vsi_architecture.png width="900"/>

#### Tasks performed by Playbook
1. Uses [SoftLayer API Python Client](https://softlayer-api-python-client.readthedocs.io/en/latest/) (scli) to order the CentOS VSI
2. Forces VSI to boot using the compiled Linux Kernel
3. Assigns IP address and reboot the VSI to:
	- Pull CoreOS image 
	- Ignition file
	- Install OpenShift Nodes

##  
## Before you begin

- Ansible uses [scli] (https://softlayer-api-python-client.readthedocs.io/en/latest/) to provision resources
- Git to clone source code repository.

> **NOTE:** In addition, contact your Infrastructure master user or account owner to get the following permissions:

> - Network VLAN ID which is a [NAT masquerade to Internet Private Network Uplink through Vyatta](https://cloud.ibm.com/docs/virtual-router-appliance?topic=solution-tutorials-nat-config-private)
> - [API Key](https://cloud.ibm.com/docs/iam?topic=iam-classic_keys)

##
## Prerequisites

This tutorial requires:

- Mac book or Linux desktop (CentOS or Redhat) to kick off the ansible playbook. Ensure [ansible is installed](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) by executing the following command.
```
   $ ansible --version
```
- Ensure [pip is installed](https://pip.pypa.io/en/stable/installing/) by executing the following command.
```
    $ pip --version
```
- Make sure the following packages are installed on Linux Centos/RedHat System
```
   $ yum install git gcc gcc-c++ python-devel cairo-devel gobject-introspection-devel cairo-gobject-devel ansible

 ```
- Make sure the following packages are installed on MacOS System
```
  $ brew install pygobject3 gtk+3 libffi python cairo pkg-config gobject-introspection atk glib
```
- Motion Pro VPN to access IBM Cloud or IC4G.
- Git to clone the source code
- [Private VLAN routed through Vyatta](https://cloud.ibm.com/docs/virtual-router-appliance?topic=virtual-router-appliance-routing-your-vlans) using [NAT masquerade to Internet](https://cloud.ibm.com/docs/virtual-router-appliance?topic=solution-tutorials-nat-config-private) for public internet access to pull down OpenShift binaries and updates.

Estimated time:
 The tasks in this tutorial should take about 1 hour of which the VSI provisioning and OpenShift install can take up to 45 minutes.

##  
## Steps

1. Clone the ansible playbook repo:

	```  
	$ git clone https://github.ibm.com/harsingh/OCP_4.X_VSI.git

    ```

2. Run the following command to validate all pre-reqs are installed

	```  
	$ cd OCP_4.X_VSI

	```
    ```
      For MAC OS run the following command
      $ export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"
    
     ```  
	```  
   	$ while read p; do pip install  --ignore-installed ${p}; done <artifacts/pip-req.txt

    ```
     
3. Copy the variable file:

	```  
	$ cp vars.yaml.template vars.yaml

    ```
4. Update the variables in var.yaml file
	```  
	$ vi vars.yaml

    ```

> ####### IBM CLOUD CLASSIC INFRASTRUCTURE OR IC4G INFORMATION 
> sl_username:"<infrastructure_username>"  
> sl_api_key:"<infrastructure_apikey>"  
> sl_endpoint_url:"<infrastrucre_services_url>"  
>   
> ####### IBM CLOUD CLASSIC INFRASTRUCTURE RESOURCE OR IC4G INFORMATION  
> sl_datacenter:"<infrastructure_datacenter_code>"  
> sl_private_vlan:"infrastructure_private_vlan_number"  
> sl_vlan_info:  
> vlan_first_ip:"<vlan_first_ip_address>"  
> vlan_last_ip:"<vlan_last_ip_address>"  
> netmask_cidr:"/<vlan_netmask>"  
>
> ####### OPENSHIFT INFORMATION  
> pullsecret:'<openshift_install_key>'  
>   
> ####### OPENSHIFT HOST INFO  
> base_domain:"<your_base_domain>"  
> base_domain_prefix:"<your_base_domain_geolocation>>"  
> sl_ocp_host_prefix:"<your_environment_name_identifer>  
>  

> **NOTE:**
>  Hint:

>   Make sure you <infrastructure_private_vlan_number> number status is “Route Through”

> <img src=images/gw_1.png width="800"/>

>  <img src=images/gw_2.png width="800"/>

>  <img src=images/gw_3.png width="800"/>

5. Execute the bash script to run the playbook
	```  
	$ chmod +x create_ocp_instance.sh delete_ocp_instance.sh

    ```

	```  
	$ ./create_ocp_instance.sh

    ```
##  
## Verify OpenShift install

In this section, you are going to verify the installed OpenShift to make sure it has been created successfully.

**Verify VM**

1. Log into IBM Cloud or IC4G
2. On the left side menu, click on **Infrastructure** to view the list of virtual server devices.
3. Click **Devices** -> **Device List** to find the server created. You should see your server device listed.

**Verify OpenShift**
1. The last task of the ansible playbook prints out a message with userid and password, as shown below
```
> TASK [validate_ic4g_ocp_servers : debug] **********************************************************************************************************************************************************
ok: [10.5X.9X.4X] => {
    "openshiftcomplete.stderr_lines": [
        "level=info msg=\"Waiting up to 30m0s for the cluster at https://api.wdc01.ibm.com:6443 to initialize...\"",
        "level=info msg=\"Waiting up to 10m0s for the openshift-console route to be created...\"",
        "level=info msg=\"Install complete!\"",
        "level=info msg=\"To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/opt/ocp4/auth/kubeconfig'\"",
        "level=info msg=\"Access the OpenShift web-console here: https://console-openshift-console.apps.wdc01.ibm.com\"",
        "level=info msg=\"Login to the console with user: kubeadmin, password: eXh7T-YkjJ6-VCXji-DfZXV\""
```
2. Add Helper node IP address to your DNS or /etc/hosts file for example

> <helpernode_ip_address> console-openshift-console.apps.<base_domain_prefix>.<base_domain> oauth-openshift.apps.<base_domain_prefix>.<base_domain>


3. Open a browser and type in the following URL and login in as with the OpenShift user id (kubeadmin, in this example).

> https://console-openshift-console.apps.<base_domain_prefix>.<base_domain>  

## Summary

Hopefully, you found this tutorial helpful and educational by deploying OpenShift 4.X on the virtual classic infrastructure layer. Once the OCP 4.X solution is deployed, it inherits all of the advantages of the IBM Cloud advantages; for example, Elasticity of CPU and Memory and Disk. The Ansible Playbook supports N number of worker nodes as part of the Cluster from day one install and the deployment inherits all the security features provided by CoreOS.


## Related links
- https://www.ibm.com/cloud
- https://www.ansible.com/
- https://cloud.ibm.com/docs/iaas-vpn?topic=iaas-vpn-getting-started
- https://docs.openshift.com/container-platform/4.3/release_notes/ocp-4-4-release-notes.html
- https://cloud.ibm.com/docs/virtual-router-appliance?topic=virtual-router-appliance-getting-started
