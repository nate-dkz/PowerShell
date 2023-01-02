
$Name = '34*Nathan&()!%£$@,Darker?='

# Match text pattern in the variable
$Name | Select-String -Pattern "([A-Za-z'-]+)" -AllMatches

# Join the matched text pattern
($Name | Select-String -Pattern "([A-Za-z'-]+)" -AllMatches).Matches.Value -join ' '

$department = @('TechSupport', 'SalesEngineer', 'CustomerSupport')

$department | ForEach-Object { $_ -csplit '(?=[A-Z])' -ne '' -join ' ' }

