# Introduction
This file contains a collection of useful Command Prompt (MS-DOS) commands that I have compiled.

<details>
<summary><b><font size="+1">System</font></b></summary>
</br>

``chkdsk /f``

``sfc /scannow``

``DISM /Online /Cleanup-Image /CheckHealth``

``DISM /Online /Cleanup-Image /ScanHealth``

``DISM /Online /Cleanup-Image /RestoreHealth``

Restart into the BIOS.

``shutdown /r /fw /f /t 0``

Create a background service.
```
sc.exe Create "<service name>" 
binPath="<file path>" 
DisplayName="<service display name>"
```

Retrieve .NET Framework information.

``reg query "HKLM\SOFTWARE\Microsoft\Net Framework Setup\NDP" /s``

``assoc``

``powercfg``
</details>

<details>
<summary><b><font size="+1">Processes</font></b></summary>
</br>

``tasklist | findstr SCRIPT``

``taskkill /f /pid PID``
</details>

<details>
<summary><b><font size="+1">Network</font></b></summary>
</br>

Ping a host by sending an ICMP echo request to the target host and waiting for an ICMP echo reply.

``ping nathandarker.it``

Continuous ping until stopped.

``ping nathandarker.it /t``

Retrieve current TCP/IP network connections.

``netstat -ano -p tcp``

Displays all connections and listening ports and FQDN for remote addresses.

``netstat -af``

Displays the owning Process ID (PID) associated with each connection.

``netstat -o``

Shows network sent / receive statistics sent every 5 seconds.

``netstat -et 5``

Retrieve detailed information for all adapters.

``ipconfig /all``

``ipconfig | findstr DNS``

``ipconfig /release``

``ipconfig /renew``

``ipconfig /displaydns``

``ipconfig /displaydns | clip``

``ipconfig /flushdns``

``tracert nathandarker.it``

``nslookup nathandarker.it``

``nslookup nathandarker.it 8.8.8.8``

``nslookup -type=mx nathandarker.it``

Retrieve MAC address information for all adapters.

``getmac -v``

``route print``

``netsh wlan show wlanreport``

``netsh interface ip show addresses``

``netsh interface ip show address | findstr "IP Address"``

</details>

<details>
<summary><b><font size="+1">Files</font></b></summary>
</br>

Directory listing on a network drive.

``dir \\<host>\<file path>``


Search for files on a network drive.

``where /r \\<host>\<file path>``


Search for a specific file.

``dir /s <file>``


Search for a specific file without headers.

``dir /s /b <file>``
</details>

