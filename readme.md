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
![2025-03-05 00_43_03-kali-PENTESTING (04-03-2025  Updates )  Running  - Oracle VM VirtualBox](https://github.com/user-attachments/assets/09be1e9d-b983-4e27-89d7-a2436760f70b)


## Accessing SysReptor
Once the installation is complete, SysReptor will be accessible at:
```bash
http://<YOUR_IP>:1444/login/
```
<img width="1813" alt="image" src="https://github.com/user-attachments/assets/163a0df9-bc3e-4258-b1c3-39127d8c0c34" />
