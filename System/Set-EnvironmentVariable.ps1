$Application = 'VsCode'
$FilePath = 'C:\Users\User\AppData\Local\Programs\Microsoft VS Code\Code.exe'

# Set user environment variable
[System.Environment]::SetEnvironmentVariable($Application, $FilePath, [System.EnvironmentVariableTarget]::User)

# Set system environment variable
[System.Environment]::SetEnvironmentVariable($Application, $FilePath, [System.EnvironmentVariableTarget]::Machine)