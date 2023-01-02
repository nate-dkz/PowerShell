$SupportLevel = 2
switch ($SupportLevel) {
    1 { $Level = '1st Line Support' }
    2 { $Level = '2nd Line Support' }
    3 { $Level = '3rd Line Support' }
    Default { 'Unknown' }
}

$Level

$SupportLevel = 1

$Level = switch ($SupportLevel) {
    1 { '1st Line Support' ; break }
    2 { '2nd Line Support' }
    3 { '3rd Line Support' }
    1 { '1st Line Support' }
    Default { 'Unknown' }
}

$Level