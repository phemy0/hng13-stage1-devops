#Description: Automates setup, deployment, and configuration of a Dockerized app on a remote ubuntu Linux server 
#i am  deploying a Dockerized app from a GitHub repo to a remote Linux server using SSH, Docker, and Nginx.

#Step-by-Step Execution:
Before doing anything, gather all the necessary info
Git Repo URL : https://github.com/user/myapp.git
Personal Access Token (PAT)	Used to authenticate to GitHub:
Branch name	Default = main	main
SSH Username:	Username for remote server	 e.g ubuntu
Server IP address	: The remote host  Public IP	
SSH key path:	Your private SSH key
Application port: e.g 8000
###################################
STEP 1:
Open your terminal
change permission of the script file:chmod +x deploy.sh
run :./deploy.sh
repo will be clone using your PAT,move to the cloned folder and switch to the correct branch
############################################
STEP 2:
project get verified and ensure Dockerfile available
it connect to the remote server ,Prepare the Remote Server Environment
Update the system,install docker,Adds the user to the Docker groupand verify the installation
###############################
Application Deployment
###############################
Nginx Reverse Proxy Configuration
#################################
Deployment Validation
#################################
Accessing the Deployed App through :http://public_ip/demo
############################
