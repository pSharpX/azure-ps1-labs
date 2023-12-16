$Musicians = @(
    [PSCustomObject]@{
        Name = "Christian"
        LastName = "Rivera"
        Role = "Singer"
        Age = 30
        Country = "PERU"
        Gender = "M"
        Genre = "Rock"
        Band = "Muse"
    }
    [PSCustomObject]@{
        Name = "Chris"
        LastName = "Cornell"
        Role = "Singer"
        Age = 40
        Country = "US"
        Gender = "M"
        Genre = "Rock"
        Band = "Audioslave"
    }
    [PSCustomObject]@{
        Name = "Chester"
        LastName = "Bennington"
        Role = "Singer"
        Age = 35
        Country = "US"
        Gender = "M"
        Genre = "Rock"
        Band = "Linkin Park"
    }
    [PSCustomObject]@{
        Name = "Gustavo"
        LastName = "Cerati"
        Role = "Singer"
        Age = 35
        Country = "Argentina"
        Gender = "M"
        Genre = "Rock"
        Band = "Soda Sterio"
    }
    [PSCustomObject]@{
        Name = "Dominic"
        LastName = "Howard"
        Role = "Drummer"
        Age = 42
        Country = "UK"
        Gender = "M"
        Genre = "Rock"
        Band = "Muse"
    }
    [PSCustomObject]@{
        Name = "Will"
        LastName = "Champion"
        Role = "Drummer"
        Age = 45
        Country = "UK"
        Gender = "M"
        Genre = "Rock"
        Band = "Coldplay"
    }
)

$MusiciansName = $Musicians | Select-Object -ExpandProperty Name
"Musicians Name: " + $MusiciansName

$EnglishMusicians = $Musicians | Where-Object { $_.Country -eq "UK" } | Select-Object -ExpandProperty Name
"English Musicians: " + $EnglishMusicians