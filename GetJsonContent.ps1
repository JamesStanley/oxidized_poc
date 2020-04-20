param
(
    [Parameter(Mandatory=$false)]
    $dir

)

if(!$dir){
  $dir = "."
}

Get-ChildItem $dir -Filter *.json | 

      Foreach-Object {
          $content = Get-Content $_.FullName | ConvertFrom-Json
          Get-Content -Raw -Path $_.FullName | ConvertFrom-Json
      }