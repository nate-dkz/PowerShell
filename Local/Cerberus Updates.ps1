hostname

Get-Service -Name 'Cerberus FTP Server' | ft -AutoSize

Get-Process -Name CerberusGUI | Select -Property Product, ProductVersion, Path -Unique | ft -AutoSize