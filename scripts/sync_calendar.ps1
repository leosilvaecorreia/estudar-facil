param(
  [string]$CalendarUrl = "https://calendar.google.com/calendar/ical/c_mcg63t49ip9n8t34onvsi0aur4%40group.calendar.google.com/public/basic.ics",
  [string]$OutputPath = "data/tarefas.json",
  [int]$DaysAhead = 45,
  [int]$LookbackDays = 14
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Net.Http

function Normalize-Text {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ""
  }

  $normalized = $Text
  $normalized = $normalized -replace "\\n", "`n"
  $normalized = $normalized -replace "\\,", ","
  $normalized = $normalized -replace "\\;", ";"
  $normalized = $normalized -replace "\\\\", "\"
  $normalized = $normalized -replace "<br\s*/?>", "`n"
  $normalized = $normalized -replace "</li>", "`n"
  $normalized = $normalized -replace "<li[^>]*>", "- "
  $normalized = $normalized -replace "<[^>]+>", " "
  $normalized = $normalized -replace "&nbsp;", " "
  $normalized = $normalized -replace "&gt;", ">"
  $normalized = $normalized -replace "&lt;", "<"
  $normalized = $normalized -replace "&amp;", "&"
  $normalized = $normalized -replace "\s+", " "
  $normalized = $normalized.Trim()

  return $normalized
}

function Parse-IcsDate {
  param([string]$Value)

  if ($Value -match '^\d{8}$') {
    return [datetime]::ParseExact($Value, "yyyyMMdd", $null)
  }

  if ($Value -match '^\d{8}T\d{6}Z$') {
    return [datetime]::ParseExact($Value, "yyyyMMdd'T'HHmmss'Z'", $null)
  }

  if ($Value -match '^\d{8}T\d{6}$') {
    return [datetime]::ParseExact($Value, "yyyyMMdd'T'HHmmss", $null)
  }

  return $null
}

function Get-FieldValue {
  param(
    [hashtable]$Event,
    [string[]]$Candidates
  )

  foreach ($candidate in $Candidates) {
    if ($Event.ContainsKey($candidate) -and -not [string]::IsNullOrWhiteSpace($Event[$candidate])) {
      return $Event[$candidate]
    }
  }

  return $null
}

function Get-Materia {
  param(
    [string]$Summary,
    [string]$Description
  )

  $text = (($Summary + " " + $Description).ToLowerInvariant())

  if ($text.Contains("língua portuguesa") -or $text.Contains("lingua portuguesa") -or $text.Contains("portugu") -or $text.Contains(" lp ") -or $text.StartsWith("lp") -or $text.StartsWith("lp-")) {
    return "Português"
  }

  if ($text.Contains("matem") -or $text.Contains("mat 4") -or $text.Contains("mat4") -or $text.StartsWith("mat ") -or $text.StartsWith("mat-")) {
    return "Matemática"
  }

  if ($text.Contains("hist") -or $text.Contains("histór") -or $text.Contains("histor") -or $text.StartsWith("hist ")) {
    return "História"
  }

  if ($text.Contains("geo") -or $text.Contains("geografia") -or $text.StartsWith("geo ")) {
    return "Geografia"
  }

  if ($text.Contains("prova de ci") -or $text.Contains("prova de cien") -or $text.Contains("ciências naturais") -or $text.Contains("ciencias naturais") -or $text.Contains("cien") -or $text.Contains("ciên") -or $text.Contains("cienc")) {
    return "Ciências"
  }

  if ($text.Contains("ingl") -or $text.Contains("english") -or $text.Contains("eng-") -or $text.Contains(" eng ") -or $text.StartsWith("eng ") -or $text.Contains("língua inglesa") -or $text.Contains("lingua inglesa")) {
    return "Inglês"
  }

  if ($text.Contains("ensino religioso") -or $text.Contains("religioso") -or $text.Contains("e. rel")) {
    return "Ensino Religioso"
  }

  if ($text.Contains("pensamento computacional") -or $text.Contains("pec ") -or $text.StartsWith("pec ") -or $text.StartsWith("pec-") -or $text.Contains(" pec-")) {
    return "Pensamento Computacional"
  }

  if ($text.Contains("projeto de leitura") -or $text.Contains("plic")) {
    return "Projeto de Leitura"
  }

  if ($text.Contains("prova de reda") -or $text.Contains(" reda") -or $text.StartsWith("red ") -or $text.StartsWith("red-") -or $text.Contains(" red ")) {
    return "Redação"
  }

  return "Geral"
}

function Get-Tipo {
  param(
    [string]$Summary,
    [string]$Description
  )

  $text = (($Summary + " " + $Description).ToLowerInvariant())

  if ($text -match '2\S*\s*chamada|miniteste|prova|teste|avaliação|avaliacao|simulado') {
    return "prova"
  }

  if ($text -match 'steam|felitroca|felicitá|felicita|recesso escolar|recesso|feriado|homenagem|volta às aulas|volta as aulas|exposição|exposicao|encerramento|feira|sábado|domingo|quinta-feira santa|sexta-feira santa|páscoa|pascoa') {
    return "evento"
  }

  if ($text -match 'tarefa|atividade|exercício|exercicio|página|pagina|caderno|leitura|pesquisa|trazer|folha|livro|homework|hw|para casa') {
    return "tarefa"
  }

  if ($text -match 'lembrete|aviso') {
    return "aviso"
  }

  return "evento"
}

function Get-Urgencia {
  param([datetime]$Prazo)

  $today = (Get-Date).Date
  $days = [int](($Prazo.Date - $today).TotalDays)

  if ($days -lt 0) { return "atrasado" }
  if ($days -eq 0) { return "hoje" }
  if ($days -eq 1) { return "amanha" }
  if ($days -le 7) { return "esta_semana" }
  return "proximos_dias"
}

function Get-NextSchoolDay {
  param([datetime]$BaseDate)

  $candidate = $BaseDate.Date.AddDays(1)

  while ($candidate.DayOfWeek -eq [System.DayOfWeek]::Saturday -or $candidate.DayOfWeek -eq [System.DayOfWeek]::Sunday) {
    $candidate = $candidate.AddDays(1)
  }

  return $candidate.Date
}

function Get-Prazo {
  param(
    [datetime]$EventDate,
    [string]$Description,
    [string]$Tipo
  )

  $baseDate = $EventDate.Date
  $text = $Description.ToLowerInvariant()

  if ($text -match '\bamanhã\b|\bamanha\b') {
    return $baseDate.AddDays(1)
  }

  if ($text -match '\bhoje\b') {
    return $baseDate
  }

  if ($Description -match '(?<!\d)(\d{1,2})/(\d{1,2})(?!\d)') {
    $day = [int]$matches[1]
    $month = [int]$matches[2]
    $year = $baseDate.Year

    try {
      $parsed = Get-Date -Year $year -Month $month -Day $day
      if ($parsed.Date -lt $baseDate.AddDays(-7)) {
        $parsed = $parsed.AddYears(1)
      }
      return $parsed.Date
    }
    catch {
      return $baseDate
    }
  }

  if ($Tipo -eq "tarefa") {
    return Get-NextSchoolDay -BaseDate $baseDate
  }

  return $baseDate
}

function Get-Titulo {
  param(
    [string]$Summary,
    [string]$Description,
    [string]$Tipo
  )

  $cleanSummary = Normalize-Text $Summary
  $cleanDescription = Normalize-Text $Description

  if ($Tipo -eq "prova") {
    return $cleanSummary
  }

  if ($Tipo -eq "evento" -or $Tipo -eq "aviso") {
    return $cleanSummary
  }

  if (-not [string]::IsNullOrWhiteSpace($cleanDescription)) {
    if ($Tipo -eq "tarefa") {
      return $cleanDescription
    }

    $endIndex = $cleanDescription.IndexOf(". ")
    if ($endIndex -gt 0) {
      return $cleanDescription.Substring(0, $endIndex + 1).Trim()
    }

    if ($cleanDescription.Length -gt 110) {
      return $cleanDescription.Substring(0, 110).Trim() + "..."
    }

    return $cleanDescription
  }

  return $cleanSummary
}

function Convert-IcsToEvents {
  param([string]$IcsContent)

  $lines = $IcsContent -split "`n"
  $unfolded = New-Object System.Collections.Generic.List[string]

  foreach ($rawLine in $lines) {
    $line = $rawLine.TrimEnd("`r")

    if (($line.StartsWith(" ")) -or ($line.StartsWith("`t"))) {
      if ($unfolded.Count -gt 0) {
        $unfolded[$unfolded.Count - 1] = $unfolded[$unfolded.Count - 1] + $line.Substring(1)
      }
    }
    else {
      $unfolded.Add($line)
    }
  }

  $events = New-Object System.Collections.Generic.List[hashtable]
  $current = $null

  foreach ($line in $unfolded) {
    if ($line -eq "BEGIN:VEVENT") {
      $current = @{}
      continue
    }

    if ($line -eq "END:VEVENT") {
      if ($null -ne $current) {
        $events.Add($current)
      }
      $current = $null
      continue
    }

    if ($null -eq $current) {
      continue
    }

    $separator = $line.IndexOf(":")
    if ($separator -lt 0) {
      continue
    }

    $name = $line.Substring(0, $separator)
    $value = $line.Substring($separator + 1)
    $current[$name] = $value
  }

  return $events
}

$outputFullPath = Join-Path (Get-Location) $OutputPath
$outputDir = Split-Path $outputFullPath -Parent

if (-not (Test-Path $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$httpClient = [System.Net.Http.HttpClient]::new()
$httpClient.Timeout = [TimeSpan]::FromSeconds(30)
try {
  $bytes = $httpClient.GetByteArrayAsync($CalendarUrl).GetAwaiter().GetResult()
}
finally {
  $httpClient.Dispose()
}

$icsContent = [System.Text.Encoding]::UTF8.GetString($bytes)
$rawEvents = Convert-IcsToEvents -IcsContent $icsContent

$today = (Get-Date).Date
$earliestRelevantDate = $today.AddDays(-1 * $LookbackDays)
$limit = $today.AddDays($DaysAhead)
$items = New-Object System.Collections.Generic.List[object]

foreach ($event in $rawEvents) {
  $startRaw = Get-FieldValue -Event $event -Candidates @("DTSTART;VALUE=DATE", "DTSTART")
  if ($null -eq $startRaw) {
    continue
  }

  $startDate = Parse-IcsDate $startRaw
  if ($null -eq $startDate) {
    continue
  }

  if ($startDate.Date -lt $earliestRelevantDate -or $startDate.Date -gt $limit) {
    continue
  }

  $summary = Normalize-Text (Get-FieldValue -Event $event -Candidates @("SUMMARY"))
  $description = Normalize-Text (Get-FieldValue -Event $event -Candidates @("DESCRIPTION"))
  $location = Normalize-Text (Get-FieldValue -Event $event -Candidates @("LOCATION"))
  $uid = Get-FieldValue -Event $event -Candidates @("UID")
  $tipo = Get-Tipo -Summary $summary -Description $description
  $combinedText = ($summary + " " + $description).ToLowerInvariant()
  if ($combinedText -match 'steam|felitroca|felicitÃ¡|felicita|feira liter|recesso|feriado|homenagem|volta Ã s aulas|volta as aulas|exposiÃ§Ã£o|exposicao|quinta-feira santa|sexta-feira santa|sÃ¡bado de aleluia|pÃ¡scoa|pascoa') {
    $tipo = "evento"
  }
  if ($tipo -eq "evento" -and $combinedText -notmatch 'steam|felitroca|felicitÃ¡|felicita|feira liter|recesso|feriado|homenagem|volta Ã s aulas|volta as aulas|exposiÃ§Ã£o|exposicao|quinta-feira santa|sexta-feira santa|sÃ¡bado de aleluia|pÃ¡scoa|pascoa' -and $combinedText -match 'para casa|homework|hw|atividade|exercÃ­cio|exercicio|leitura|pesquisa|folha|pÃ¡gina|pagina') {
    $tipo = "tarefa"
  }
  $materia = Get-Materia -Summary $summary -Description $description
  if ($combinedText -match 'steam|felitroca|felicitÃ¡|felicita|feira liter|recesso|feriado|homenagem|volta Ã s aulas|volta as aulas|exposiÃ§Ã£o|exposicao|quinta-feira santa|sexta-feira santa|sÃ¡bado de aleluia|pÃ¡scoa|pascoa') {
    $materia = "Geral"
  }
  $prazo = Get-Prazo -EventDate $startDate -Description $description -Tipo $tipo
  if ($prazo.Date -lt $today) {
    continue
  }
  $urgencia = Get-Urgencia -Prazo $prazo
  $titulo = Get-Titulo -Summary $summary -Description $description -Tipo $tipo

  $items.Add([ordered]@{
    id = $uid
    tipo = $tipo
    materia = $materia
    titulo = $titulo
    descricao = $description
    resumo_original = $summary
    local = $location
    data_evento = $startDate.ToString("yyyy-MM-dd")
    prazo = $prazo.ToString("yyyy-MM-dd")
    urgencia = $urgencia
    fonte = "google_calendar"
  })
}

$orderedItems = $items |
  Sort-Object @{ Expression = "prazo"; Ascending = $true }, @{ Expression = "materia"; Ascending = $true }, @{ Expression = "titulo"; Ascending = $true }

$payload = [ordered]@{
  gerado_em = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
  calendario = [ordered]@{
    fonte = "google_calendar_public_ics"
    nome = "4º ano - Turma A"
    url = $CalendarUrl
    dias_considerados = $DaysAhead
    dias_retroativos = $LookbackDays
  }
  resumo = [ordered]@{
    total_itens = @($orderedItems).Count
    tarefas = @($orderedItems | Where-Object { $_.tipo -eq "tarefa" }).Count
    provas = @($orderedItems | Where-Object { $_.tipo -eq "prova" }).Count
    avisos = @($orderedItems | Where-Object { $_.tipo -eq "aviso" }).Count
    eventos = @($orderedItems | Where-Object { $_.tipo -eq "evento" }).Count
  }
  itens = @($orderedItems)
}

$json = $payload | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText($outputFullPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output ("Arquivo gerado: " + $outputFullPath)
Write-Output ("Itens processados: " + @($orderedItems).Count)
