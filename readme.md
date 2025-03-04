# SysReptor Installation Guide
This script automates the installation and setup of SysReptor on Kali Linux. It ensures that all dependencies are installed, configures Docker and Docker Compose, and sets up SysReptor for immediate use.
Main repository for SysReptor: https://github.com/syslifters/sysreptor/

## Quick Installation  
To install SysReptor automatically, run the following command:
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/vishalraj1444/sysreptor_install/main/install_sysreptor.sh)"
```

## Final Setup - Creating Superuser
At the end of the installation, you will be prompted to set up a superuser.
When prompted, Enter a password.

## Accessing SysReptor
Once the installation is complete, SysReptor will be accessible at:
```bash
http://<YOUR_IP>:1444/login/
```
