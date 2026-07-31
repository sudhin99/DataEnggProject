Apache Airflow 3 Standalone Installation Guide: Step-by-Step Setup for Local Development (Without Docker)

Apache Airflow is a powerful open-source platform for programmatically authoring, scheduling, and monitoring workflows. Originally developed by Airbnb and now an Apache Software Foundation project, Airflow has become the de facto standard for orchestrating complex data pipelines and managing dependencies between tasks.

With the release of Apache Airflow 3.0, the platform takes a significant leap forward. This major version brings substantial improvements in performance, developer experience, and overall stability. Airflow 3 introduces a modernized architecture with faster task execution, an enhanced user interface, and better resource management. The new version also drops support for older Python versions, requiring Python 3.9 or higher, which allows the codebase to leverage modern Python features and optimizations.

Press enter or click to view image in full size

Apache Airflow
Important Note for Windows Users
Before we proceed with the installation, there’s a critical point that Windows users must understand: Apache Airflow does not run natively on Windows operating systems. This is due to Airflow’s core dependencies on Unix-based system calls and libraries that are not available in the Windows environment.

If you’re using Windows 11 (or Windows 10), you have two options:

Use WSL2 (Windows Subsystem for Linux) — Recommended approach that provides a genuine Linux environment within Windows
Use Docker Desktop — Run Airflow in containers, which internally uses WSL2
This guide will walk you through setting up WSL2 first for Windows users, ensuring you have a proper Linux environment before installing Airflow. For Ubuntu users, you can skip directly to the installation steps.

For Ubuntu users running natively, skip Part 1 and proceed directly to Part 2.

Part 1: Setting Up WSL2 on Windows 11
Step 1: Enable WSL2
Open PowerShell as Administrator and run:

# Enable WSL
wsl --install

# Set WSL2 as default
wsl --set-default-version 2
Step 2: Install Ubuntu-22.04 LTS
After WSL is installed, you can install a specific Ubuntu distribution. We’ll use Ubuntu 22.04 LTS, which is a long-term support version that’s stable and well-tested.

Get Nabil Raihan’s stories in your inbox
Join Medium for free to get updates from this writer.

Enter your email
Subscribe

Remember me for faster sign in

In the same PowerShell Administrator window:

# Install Ubuntu on WSL2
wsl --install -d Ubuntu-22.04
Step 3: Launch Ubuntu
Launch Ubuntu using command line:

wsl -d Ubuntu-22.04
Create your user account when prompted:

Enter new UNIX username: yourusername
New password: yourpass
Retype new password: yourpass
You should now see:

yourusername@COMPUTERNAME:~$
Verify Ubuntu installation:

lsb_release -a
Output should show:

Distributor ID: Ubuntu
Description:    Ubuntu 22.04.x LTS
Release:        22.04
Codename:       jammy
Installation Complete! Your WSL2 environment with Ubuntu 22.04 is now ready. You can proceed to install Apache Airflow 3 in the next section.

Part 2: Installing Python with pyenv
What is Pyenv?
Pyenv is a Python version management tool that allows you to easily install and switch between multiple Python versions on your system. Instead of relying on the system Python (which may be outdated or require root access to modify), pyenv lets you install any Python version in your home directory without interfering with system packages.

Step 1: Install Pyenv Dependencies
Before installing pyenv, install the required build dependencies:

sudo apt update 
sudo apt install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
Step 2: Install Pyenv
Install pyenv using the official installer:

curl -fsSL https://pyenv.run | bash
Step 3: Configure Pyenv in Shell
Add pyenv to your shell configuration:

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
Reload your shell configuration:

source ~/.bashrc
Step 4: Verify Pyenv Installation
pyenv --version
Output should show:

pyenv 2.x.x
Step 5: Install Python 3.11
pyenv install 3.11.9
Step 6: Set Python 3.11 as Global Version
pyenv global 3.11.9
Verify Python installation:

python --version
Output should show:

Python 3.11.9
Part 3: Installing Apache Airflow 3
Step 1: Create Project Directory
Create a dedicated directory for your Airflow project:

mkdir ~/airflow-dev
cd ~/airflow-dev
Step 2: Create Virtual Environment
Create a Python virtual environment to isolate Airflow dependencies:

python -m venv airflow-venv
Activate the virtual environment:

source airflow-venv/bin/activate
Your terminal prompt should now show (airflow-venv):

(airflow-venv) yourusername@COMPUTERNAME:~/airflow-dev$
Step 3: Upgrade pip
Upgrade pip to the latest version:

pip install --upgrade pip
Step 4: Set Airflow Home Directory
Set the AIRFLOW_HOME environment variable:

export AIRFLOW_HOME=~/airflow-dev
Make it permanent by adding to .bashrc:

echo 'export AIRFLOW_HOME=~/airflow-dev' >> ~/.bashrc
Reload your shell configuration:

source ~/.bashrc
Step 5: Install Apache Airflow 3
Install Airflow with constraint file to ensure package compatibility:

pip install apache-airflow==3.0.0 --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.0.0/constraints-3.11.txt"
Step 6: Run Airflow in standalone mode
airflow standalone
Step 7: Access the Airflow Web UI
http://localhost:8080
Press enter or click to view image in full size

To view your credentials, open the simple_auth_manager_passswords.json.generated file.

cat ~/airflow-dev/simple_auth_manager_passwords.json.generated
By default, you’ll see 77 example DAGs that you can explore to learn how Airflow works.

Press enter or click to view image in full size

Conclusion
You’ve successfully set up Apache Airflow 3 on your local development environment. Whether you’re using Windows with WSL2 or native Ubuntu, you now have a powerful workflow orchestration platform ready for building and testing data pipelines.

Remember that this standalone setup is ideal for development and learning. For production deployments, consider using more robust configurations with separate database servers, executor types (like CeleryExecutor or KubernetesExecutor), and proper monitoring solutions.

Happy orchestrating!