Set-StrictMode -Version Latest

# Stores the hashtable in a variable
$Users = @{
    'Nathan Darker' = 'n.darker'
    'John Jones'    = 'j.jones'
    'Kelly Harris'  = 'k.harris'
}

# Retrieves the members of the hashtable displaying the methods and properties availble
$Users | Get-Member

# Returns the type of object
$Users.GetType()

# Retrieves the keys
$Users.Keys

# Retrieves the values
$Users.Values

# Retrieving specific values from a hashtable
$Users['John Jones']
$Users.'Nathan Darker'

# Add items to a hashtable
$Users.Add('Rachel Lowe', 'r.lowe')
$Users

# Change items in a hashtable

$Users.'Rachel Lowe' = 'rachel.lowe'
$Users['Rachel Lowe'] = 'r.lowe'
$Users

# Removes items from a hashtable
$Users.ContainsKey('John Jones')
$users.Remove('John Jones')
$Users

# Create a custom object
$Users = New-Object -TypeName PSCustomObject

# Adds properties and values to the custom object
Add-Member -InputObject $Users -MemberType NoteProperty -Name 'Name' -Value 'Nathan Darker'
Add-Member -InputObject $Users -MemberType NoteProperty -Name 'UserName' -Value 'n.darker'
$Users

$Users = [PSCustomObject]@{
    Name     = 'Nathan Darker'
    UserName = 'n.darker'
}
$Users

# Retrieves the members of the hashtable displaying the methods and properties availble
$Users | Get-Member





