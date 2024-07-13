
write-host ""
write-host "what would you like to do?"
write-host ""
write-host "    A) Collect new Baseline?"
write-host ""
write-host "    B) Being monitoring files with saved Baseline?"
write-host ""

$response = Read-Host -Prompt "please enter 'A' or 'B'"


function Calculate-file-hash($filepath) {
   $filehash =  Get-FileHash -path $filepath -Algorithm SHA512
   return $filehash
}

Function Erase-baseline-if-already-exists() {
     $baselineExists = Test-path -path .\baseline.txt
     
     if ($baselineExists) {
     # Delete it
     Remove-item -path .\baseline.txt   
   }
}

if ($response -eq "A".ToUpper()) {
    # Delete baseline.txt if it already exists
    Erase-baseline-if-already-exists

    # calculate Hash from the target files and store in baseline.txt
    # Collect all files in the target folder
    $files = Get-ChildItem -path .\files
   
    #for each file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-file-hash $f.Fullname 
        "$($hash.path)|$($hash.Hash)" | Out-file -FilePath .\baseline.txt -Append   
    }
  

} 
elseif ($response -eq "B".ToUpper()) {

  $fileHashDictionary = @{}
    
   # Load file|hash from baseline.txt and store them in a dictionary
     $filePathsAndHashes = Get-Content -path .\baseline.txt

     foreach ($f in $filePathsAndHashes) {
       $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

      # Begin (Continuously) monitoring files with saved baseline
         While ($true) { 
           Start-Sleep -Seconds 1

           $files = Get-ChildItem -path .\files

    
       # For each file, calculate the hash, and write to baseline.txt
        foreach ($f in $files) {
              $hash = Calculate-file-hash $f.Fullname 
              #"$($hash.path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append   
   
              # Notify if a new file has been created
               if ($fileHashDictionary[$hash.path] -eq $null) {
                   # A new files has been Created!
                    Write-Host "$($hash.path) has been created" -ForegroundColor Cyan
               
               }
               else { 

                    # Notify if a new file has been changed
                     if ($fileHashDictionary[$hash.path] -eq $hash.hash) {
                        # The file has not changed
                        
                
                }
                else {     
                       
                     # File file has been compromised!, notify the user
                      Write-Host "$($hash.path) has changed!!!" -ForegroundColor Yellow
            }
        }
    }
                  

                    # Check for deleted files
                   foreach ($key in $fileHashDictionary.Keys) {
                    $baselineFileStillExists = Test-Path -Path $key
                     if (-Not $baselineFileStillExists) {
                         Write-Host "$($key) has been deleted!" -ForegroundColor Red
            
                }
            }
        }  
    } 
      
      
      

                
                 
      
          

