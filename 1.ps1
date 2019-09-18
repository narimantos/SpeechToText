param (
  [string]$path,
  [string]$file
    )
write-output $path\$file
#encode to wav and get only 1e channel audio
ffmpeg -i  $path\$file -acodec pcm_s16le -ar 16000 -ac 1 "$path\$file.wav"
#split the audio file each 58 seconds and output it like out00 
ffmpeg -i "$path\$file.wav" -f segment -segment_time 58 -c copy "$path\out%03d.wav"

Get-ChildItem "$path" -Filter "out*.wav" |
Foreach-Object {
  $content = Get-ItemProperty $_.FullName
  $json = gcloud ml speech recognize $content.Name  --language-code "nl-NL" --format="json";
  Write-Output( $json | ConvertFrom-Json | ForEach-Object {
    $_.results | ConvertTo-Json -Compress >> output.txt
  })
}
