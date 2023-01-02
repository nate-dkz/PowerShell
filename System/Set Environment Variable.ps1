# Set user environment variable
[System.Environment]::SetEnvironmentVariable('Firefox', 'C:\Program Files\Mozilla Firefox\firefox.exe', [System.EnvironmentVariableTarget]::User)

# Set system environment variable
[System.Environment]::SetEnvironmentVariable('VSCode', 'C:\Users\Nathan\AppData\Local\Programs\Microsoft VS Code\Code.exe', [System.EnvironmentVariableTarget]::Machine)