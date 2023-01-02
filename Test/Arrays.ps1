Set-StrictMode -Version Latest

# Creates an empty array
$Colours = @()

$Colours.GetType()

<# PowerShell treats the array as the size it starts off with, in this example 0
If items are added / removed from the array, PowerShell will destroy the array and recreate a new one with the new size
The more items in the array, the more demanding on performance #>
$Colours.IsFixedSize

# Creates and adds items to the array
$Colours = @('Red', 'Blue', 'Green')

# Retrieves the item at the relevant position within the array
$Colours[2]

# Adds items to the array
$Colours = $Colours + 'Orange'

$Colours += 'Purple', 'Orange'

# Removes items from the array

$Colours = $Colours -ne 'Purple'
$Colours

# Creates and adds items to the array list
$Colours = [System.Collections.ArrayList]@('Red', 'Blue', 'Green')

$Colours.GetType()

<# An array list is automatically resized by PowerShell depending on what methods are called
An array list is faster and better for performance #>
$Colours.IsFixedSize

# Adds an item to the array list and returns the index value
$Colours.Add('Orange')
$Colours

# Removes an item from the array list
$Colours.Remove('Purple')
$Colours

# Remove an item based on its index position
$Colours.RemoveAt(4)
$Colours

# Performance comparison of an array and array list

$Array = @()
$ArrayList = [System.Collections.ArrayList]@()

Measure-Command -Expression { @(0..50000).ForEach({$Array += $_})}
Measure-Command -Expression { @(0..50000).ForEach({$ArrayList.Add($_)})}





