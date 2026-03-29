$base = 'https://raw.githubusercontent.com/HindustanTimesLabs/shapefiles/master/state_ut'
$out  = 'D:\pro\interactive map\data\ac'
$ProgressPreference = 'SilentlyContinue'

$states = @(
  'andhrapradesh','arunachalpradesh','assam','bihar','chandigarh',
  'chhattisgarh','delhi','goa','gujarat','haryana','himachalpradesh',
  'jammukashmir','jharkhand','karnataka','kerala','madhyapradesh',
  'maharashtra','manipur','meghalaya','mizoram','nagaland','odisha',
  'puducherry','punjab','rajasthan','sikkim','tamilnadu','telangana',
  'tripura','uttarakhand','uttarpradesh','westbengal'
)

$jobs = @()
foreach ($s in $states) {
  $url  = "$base/$s/assembly/${s}_AC.json"
  $file = "$out\${s}_AC.json"
  if (Test-Path $file) { Write-Host "SKIP $s (exists)"; continue }
  $jobs += Start-Job -ScriptBlock {
    param($u,$f,$n)
    try {
      Invoke-WebRequest -Uri $u -OutFile $f -UseBasicParsing -TimeoutSec 120
      Write-Host "OK  $n"
    } catch { Write-Host "ERR $n : $_" }
  } -ArgumentList $url,$file,$s
}

Write-Host "Waiting for $($jobs.Count) downloads..."
$jobs | Wait-Job | Receive-Job
Write-Host "--- AC downloads complete ---"

# Download India district file
$distFile = 'D:\pro\interactive map\data\india_district.json'
if (-not (Test-Path $distFile)) {
  Write-Host "Downloading india_district.json ..."
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/HindustanTimesLabs/shapefiles/master/india/district/india_district.json' -OutFile $distFile -UseBasicParsing -TimeoutSec 120
  Write-Host "OK india_district.json"
} else { Write-Host "SKIP india_district.json (exists)" }

# Download Leaflet
$vendorDir = 'D:\pro\interactive map\vendor'
$lfCSS = "$vendorDir\leaflet.css"
$lfJS  = "$vendorDir\leaflet.js"
if (-not (Test-Path $lfCSS)) {
  Write-Host "Downloading leaflet.css ..."
  Invoke-WebRequest -Uri 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css' -OutFile $lfCSS -UseBasicParsing
  Write-Host "OK leaflet.css"
}
if (-not (Test-Path $lfJS)) {
  Write-Host "Downloading leaflet.js ..."
  Invoke-WebRequest -Uri 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js' -OutFile $lfJS -UseBasicParsing
  Write-Host "OK leaflet.js"
}

Write-Host "=== ALL DOWNLOADS DONE ==="
