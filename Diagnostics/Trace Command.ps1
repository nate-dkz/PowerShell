$Path ='C:\Users\ND\Files\Data'
Trace-Command -Name ParameterBinding -Expression { Get-Item -Path $Path | Get-Acl } -PSHost