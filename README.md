#Description: Automates setup, deployment, and configuration of a Dockerized app on a remote ubuntu Linux server 
#i am  deploying a Dockerized app from a GitHub repo to a remote Linux server using SSH, Docker, and Nginx.

⚙️ Conceptual Architecture
┌──────────────────────────────┐
│        Local Machine         │
│ ──────────────────────────── │
│ 1. git clone repo            │
│ 2. Verify Docker files       │
│ 3. scp project → server      │
└─────────────┬────────────────┘
              │ SSH / SCP
              ▼
┌──────────────────────────────┐
│        Remote Server         │
│ ──────────────────────────── │
│ 4. Install Docker + Nginx    │
│ 5. Build & run container     │
│ 6. Nginx reverse proxy       │
│ 7. Serve app on port 80      │
└─────────────┬────────────────┘
              │ HTTP
              ▼
┌──────────────────────────────┐
│          Browser             │
│ ──────────────────────────── │
│ User accesses:               │
│ http://<server-ip>/          │
│ → Nginx → Docker container   │
└──────────────────────────────┘

#Step-by-Step  script Execution:
                    ┌───────────────────────────┐
                │ STEP 1: Collect Parameters │
                │ GitHub URL, PAT, SSH key   │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 2: Clone Repository   │
                │ → git clone / git pull     │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 3: Verify Docker File │
                │ Check for Dockerfile       │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 4: SSH to Server      │
                │ Test SSH + Docker presence │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 5: Prepare Server     │
                │ Install Docker, Compose,   │
                │ and Nginx                 │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 6: Deploy App         │
                │ Copy files → docker build  │
                │ or docker-compose up       │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 7: Configure Nginx    │
                │ Reverse proxy → port 80    │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 8: Validate App       │
                │ docker ps / curl / browser │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 9: Log & Fix Errors   │
                │ Record issues manually     │
                └─────────────┬─────────────┘
                              │
                              ▼
                ┌───────────────────────────┐
                │ STEP 10: Re-run or Cleanup │
                │ Stop, remove, rebuild app  │
                └───────────────────────────┘
            

#################################
Accessing the Deployed App through :http://public_ip/demo
############################
