$port = 8000
$folder = $PSScriptRoot
if (-not $folder) { $folder = "C:\Users\osniv\Downloads\portafolio-final" }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "==========================================" -ForegroundColor Green
Write-Host " Servidor local activo en: http://localhost:$port/" -ForegroundColor Cyan
Write-Host " Presiona Ctrl + C en esta ventana para cerrar el servidor." -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Green
Start-Process "http://localhost:$port/"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $urlPath = [System.Uri]::UnescapeDataString($request.Url.LocalPath.TrimStart('/'))
        if ([string]::IsNullOrEmpty($urlPath) -or $urlPath -eq "/") { $urlPath = "index.html" }
        $filePath = Join-Path $folder $urlPath
        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = switch ($ext) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript" }
                ".jpg"  { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".png"  { "image/png" }
                ".mp4"  { "video/mp4" }
                default { "application/octet-stream" }
            }
            $response.ContentType = $mime
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $notFound = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.OutputStream.Write($notFound, 0, $notFound.Length)
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
