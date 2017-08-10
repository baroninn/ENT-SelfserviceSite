function Write-Host {
    param ($Object)
    
    throw 'found helper!'

    Write-Verbose $Object
}