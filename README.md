# vmssdevops
Deployment of a Python3 based web app (Flask and uWSGI) with NGINX on Azure Virtual Machine Scale Sets using Azure DevOps

## Aim:
To set the CI/CD pipeline using Azure DevOps for deploying a Python3 based web app on Azure Virtual Machine Scale Sets (VMSS).

## Working:

### Azure VMSS setup:
An Azure Standard Load Balancer (SLB) will provide the external facing endpoint. This SLB will have the VMSS instances in its backend pool. The VMSS instances will have the Python3 (Flask and uWSGI) based web application which will serve the requests to the outside world using NGINX. There is also an Azure Storage account and the Images. The Image resource will be created dynamically.

In my demo application my Resource Group looks like below:

![Resource Group](/images/mssdevops2-rg.png)

### Python3 (Flask and uWSGI) and NGINX setup:
The entire setup of NGINX and Python3 (including Flask and uWSGI) will be deployed on the Ubuntu 18.04 based VMSS instances. 
The web application logic will be in Python3 web app written using the Flask framework. uWSGI will be the application server and NGINX will be the reverse proxy. 

Link referred for the Flask and uWSGI set up along with NGINX is -- https://www.gab.lc/articles/flask-nginx-uwsgi/ 

The relevant files are explained as below:

![Code and set up files](/images/codefiles.png)

app.py: Web application logic
wsgi.py: uWSGI file
app.ini: uWSGI configuration file
my_app.service: uWSGI startup file
my_app: NGINX site configuration file. In this file, replace my IP address with the IP address/domain name of your SLB.
setupscript.sh: Shell script used by the CD pipeline of Azure DevOps to prepare the Managed Image which will be later on used by the VMSS.

### Azure DevOps setup:

#### Azure Repository:
The repository used will be Azure Repo. It will have the code and setup files.

#### CI pipeline:
![CI pipleline_1](/images/cipipeline1.png)
![CI pipleline_2](/images/cipipeline2.png)
CI pipeline will have the Publish Artifact task. The field 'path to publish' will be my_app. The option of 'Enable continuous integration' (under the Trigger tab) should be checked.

#### CD pipeline:
![CD/Release pipeline](/images/cdpipeline.png)
The artifact used will be the files published by the CI pipeline to the drop folder. The CD trigger should be enabled.

##### Stage 1
![Stage 1_1](/images/stage1_1.png)
Stage1 will make use of the task 'Azure VM scale set deployment'. This task has two steps - first is to 'Build immutable machine image' and second is 'Azure VMSS: update with immutable machine image' which is to update VMSS using this built image. The second task '' has a known issue so we will disable that task and make use of another task 'Azure CLI' to perform the update of the VMSS with the newly built image.

![Stage1_2](/images/stage1_2.png)
Fill the fields with the relevant information of the Azure Storage and VMSS details. The 'Deployment script' field should have the value setupscript.sh since it has the set up steps.

##### Build immutable machine image
![Build immutable image task](/images/Stage1_immutable.png)
![Build immutable image task](/images/Stage1_immutable2.png)
Select the Task version as 1.* and check the checkbox for Managed VM disk image. I have put in the image name as the buildid. Select the base image as Ubuntu 18.04 and 'Image URL or Name'.


##### Azure CLI
![az-cli task](/images/stage1_azcli.png)
Select the task version as 1.* and select script location as 'Inline Script'. In the box of 'Inline Script' enter the snippet mentioned in the file cdinlinescript. The snippet should have your subscription id, VMSS name and resource group information.


### Flow
The code push to the Azure Repo will trigger the CI pipeline. The CI pipeline will publish the code and setup files to the deop location. The CD pipeline will be triggered on publishing of these files. The CD pipeline will create an image will all the desired configuration as mentioned in setupscript.sh and then will update the VMSS with this newly built image.






