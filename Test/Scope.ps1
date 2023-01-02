Write-Host "x = $x"

$x = 200

Write-Host "In the script, x is $x"

function ScopeTest {
    Write-Host "In the function, x is $x"

    $x = 300

    Write-Host "Now, x is $x in the function"
    
}

ScopeTest

Write-Host "At this point in the script, x is $x"