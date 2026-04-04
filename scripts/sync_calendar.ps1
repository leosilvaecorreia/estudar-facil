param(
  [string]$CalendarUrl = "https://calendar.google.com/calendar/ical/c_mcg63t49ip9n8t34onvsi0aur4%40group.calendar.google.com/public/basic.ics",
  [string]$OutputPath = "data/tarefas.json",
  [int]$DaysAhead = 45,
  [int]$LookbackDays = 14
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Net.Http

function Repair-Mojibake {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ""
  }

  $current = $Text
  $latin1 = [System.Text.Encoding]::GetEncoding(28591)
  $utf8 = [System.Text.Encoding]::UTF8
  $mojibakePattern = 'Ã[¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿]|Â[ ªº]|â€|âœ|ðŸ|ï»¿'

  if (-not ($current -match $mojibakePattern)) {
    return $current
  }

  for ($i = 0; $i -lt 3; $i++) {
    try {
      $bytes = $latin1.GetBytes($current)
      $candidate = $utf8.GetString($bytes)

      if ([string]::IsNullOrWhiteSpace($candidate) -or $candidate -eq $current) {
        break
      }

      $current = $candidate
    }
    catch {
      break
    }
  }

  return $current
}

function Normalize-Text {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ""
  }

  $normalized = Repair-Mojibake $Text
  $normalized = $normalized -replace '\\n', "`n"
  $normalized = $normalized -replace '\\,', ','
  $normalized = $normalized -replace '\\;', ';'
  $normalized = $normalized -replace '\\\\', ([string][char]92)
  $normalized = $normalized -replace '<br\s*/?>', "`n"
  $normalized = $normalized -replace '</li>', "`n"
  $normalized = $normalized -replace '<li[^>]*>', '- '
  $normalized = $normalized -replace '<[^>]+>', ' '
  $normalized = $normalized -replace '&nbsp;', ' '
  $normalized = $normalized -replace '&gt;', '>'
  $normalized = $normalized -replace '&lt;', '<'
  $normalized = $normalized -replace '&amp;', '&'
  $normalized = $normalized -replace '\s+', ' '
  $normalized = $normalized.Trim()

  return $normalized
}

function Normalize-KnownSchoolTerms {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ""
  }

  $normalized = $Text
  $normalized = $normalized -replace '2\?\s+CHAMADA', '2ª CHAMADA'
  $normalized = $normalized -replace 'L\?NGUA', 'LÍNGUA'
  $normalized = $normalized -replace 'MATEM\?TICA', 'MATEMÁTICA'
  $normalized = $normalized -replace 'REDA\?\?O', 'REDAÇÃO'
  $normalized = $normalized -replace 'CI\?NCIAS', 'CIÊNCIAS'
  $normalized = $normalized -replace 'HIST\?RIA', 'HISTÓRIA'
  return $normalized
}

function Parse-IcsDate {
  param([string]$Value)

  if ($Value -match '^\d{8}$') {
    return [datetime]::ParseExact($Value, 'yyyyMMdd', $null)
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

function Get-CreatorEmail {
  param(
    [hashtable]$Event,
    [string]$Summary,
    [string]$Description
  )

  foreach ($key in $Event.Keys) {
    $keyText = [string]$key
    if ($keyText -notmatch '^(ORGANIZER|CREATOR|X-ORGANIZER|X-CREATOR|X-GOOGLE-ORGANIZER|X-GOOGLE-CREATOR)') {
      continue
    }

    $value = [string]$Event[$key]
    $combined = $keyText + ' ' + $value
    $emailMatch = [System.Text.RegularExpressions.Regex]::Match($combined, '(?i)[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}')
    if ($emailMatch.Success) {
      return $emailMatch.Value.ToLowerInvariant()
    }
  }

  $fallbackText = (Repair-Mojibake ($Summary + ' ' + $Description))
  $fallbackMatch = [System.Text.RegularExpressions.Regex]::Match($fallbackText, '(?i)[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}')
  if ($fallbackMatch.Success) {
    return $fallbackMatch.Value.ToLowerInvariant()
  }

  return ''
}

function Get-MateriaByTeacherRule {
  param(
    [string]$CreatorEmail,
    [string]$Summary,
    [string]$Description
  )

  if ($CreatorEmail -ne 'claudia.reis@csanl.com.br' -and $CreatorEmail -ne 'claudia.reis@csanl') {
    return $null
  }

  $text = (Repair-Mojibake ($Summary + ' ' + $Description)).ToLowerInvariant()
  if ($text -match 'science|sci\b|cien|ci[eê]ncias') {
    return 'Ciências'
  }

  return 'Inglês'
}

function Get-Materia {
  param(
    [string]$Summary,
    [string]$Description
  )

  $summaryText = (Repair-Mojibake $Summary).ToLowerInvariant()
  $text = (Repair-Mojibake ($Summary + ' ' + $Description)).ToLowerInvariant()

  if ($summaryText.Contains('plic') -or $text.Contains('projeto de leitura')) {
    return 'Projeto de Leitura'
  }

  if ($summaryText.Contains('emo') -or $summaryText.StartsWith('emo ') -or $summaryText.StartsWith('emo-') -or $text.Contains('emocionar')) {
    return 'Emocionar'
  }

  if ($text.Contains('lingua portuguesa') -or $text.Contains('portugu') -or $text.Contains(' lp ') -or $text.StartsWith('lp') -or $text.StartsWith('lp-')) {
    return 'Português'
  }

  if ($text.Contains('matem') -or $text.Contains('mat 4') -or $text.Contains('mat4') -or $text.StartsWith('mat ') -or $text.StartsWith('mat-')) {
    return 'Matemática'
  }

  if ($text.Contains('hist') -or $text.Contains('histor') -or $text.StartsWith('hist ')) {
    return 'História'
  }

  if ($text.Contains('geo') -or $text.Contains('geografia') -or $text.StartsWith('geo ')) {
    return 'Geografia'
  }

  if ($text.Contains('prova de ci') -or $text.Contains('prova de cien') -or $text.Contains('ciencias naturais') -or $text.Contains('cien') -or $text.Contains('cienc')) {
    return 'Ciências'
  }

  if ($text.Contains('ingles') -or $text.Contains('english') -or $text.Contains('eng-') -or $text.Contains(' eng ') -or $text.StartsWith('eng ') -or $text.Contains('lingua inglesa')) {
    return 'Inglês'
  }

  if ($text.Contains('activity book') -or $text.Contains('student book') -or $text.Contains('activity and student books')) {
    return 'Inglês'
  }

  if ($text.Contains('ensino religioso') -or $text.Contains('religioso') -or $text.Contains('e. rel')) {
    return 'Ensino Religioso'
  }

  if ($text.Contains('pensamento computacional') -or $text.Contains('pec ') -or $text.StartsWith('pec ') -or $text.StartsWith('pec-') -or $text.Contains(' pec-')) {
    return 'Pensamento Computacional'
  }

  if ($text.Contains('prova de reda') -or $text.Contains(' reda') -or $text.StartsWith('red ') -or $text.StartsWith('red-') -or $text.Contains(' red ')) {
    return 'Redação'
  }

  return 'Geral'
}

function Get-Tipo {
  param(
    [string]$Summary,
    [string]$Description
  )

  $summaryText = (Repair-Mojibake $Summary).ToLowerInvariant()
  $descriptionText = (Repair-Mojibake $Description).ToLowerInvariant()
  $text = ($summaryText + ' ' + $descriptionText).ToLowerInvariant()
  $homeworkPattern = 'tarefa|atividade|exercicio|leitura|pesquisa|trazer|folha|livro|homework|hw|para casa|pagina|caderno|finalizar|copiar|estudar|proxima aula|próxima aula|entrega|trabalho'
  $assessmentPattern = '2\S*\s*chamada|miniteste|prova|teste|avaliacao|avaliação|simulado'
  $looksLikeClassEntry = $summaryText -match '^(lp|mat|hist|geo|cien|eng|e\.\s*rel|pec|plic|red|emo)\b'

  if ($summaryText -match $assessmentPattern) {
    return 'prova'
  }

  if ($text -match 'steam|felitroca|felicita|feira liter|recesso escolar|recesso|feriado|homenagem|volta as aulas|exposicao|encerramento|sabado|domingo|quinta-feira santa|sexta-feira santa|pascoa') {
    return 'evento'
  }

  if ($looksLikeClassEntry -and $descriptionText -match $homeworkPattern) {
    return 'tarefa'
  }

  if ($descriptionText -match $homeworkPattern) {
    return 'tarefa'
  }

  if ($text -match 'lembrete|aviso') {
    return 'aviso'
  }

  return 'evento'
}

function Get-Urgencia {
  param([datetime]$Prazo)

  $today = (Get-Date).Date
  $days = [int](($Prazo.Date - $today).TotalDays)

  if ($days -lt 0) { return 'atrasado' }
  if ($days -eq 0) { return 'hoje' }
  if ($days -eq 1) { return 'amanha' }
  if ($days -le 7) { return 'esta_semana' }
  return 'proximos_dias'
}

function Get-NextSchoolDay {
  param([datetime]$BaseDate)

  $candidate = $BaseDate.Date.AddDays(1)

  while ($candidate.DayOfWeek -eq [System.DayOfWeek]::Saturday -or $candidate.DayOfWeek -eq [System.DayOfWeek]::Sunday) {
    $candidate = $candidate.AddDays(1)
  }

  return $candidate.Date
}

function Is-NonClassDayEvent {
  param(
    [string]$Summary,
    [string]$Description
  )

  $text = (Repair-Mojibake ($Summary + ' ' + $Description)).ToLowerInvariant()
  return $text -match 'recesso escolar|recesso|feriado|quinta-feira santa|sexta-feira santa|sem aula|nao havera aula|não haverá aula'
}

function Get-NonClassDates {
  param(
    [object[]]$Events,
    [datetime]$EarliestDate,
    [datetime]$LatestDate
  )

  $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

  foreach ($event in $Events) {
    $summary = Normalize-KnownSchoolTerms (Normalize-Text (Get-FieldValue -Event $event -Candidates @('SUMMARY')))
    $description = Normalize-KnownSchoolTerms (Normalize-Text (Get-FieldValue -Event $event -Candidates @('DESCRIPTION')))

    if (-not (Is-NonClassDayEvent -Summary $summary -Description $description)) {
      continue
    }

    $startRaw = Get-FieldValue -Event $event -Candidates @('DTSTART;VALUE=DATE', 'DTSTART')
    if ($null -eq $startRaw) {
      continue
    }

    $startDate = Parse-IcsDate $startRaw
    if ($null -eq $startDate) {
      continue
    }

    $endRaw = Get-FieldValue -Event $event -Candidates @('DTEND;VALUE=DATE', 'DTEND')
    $endDate = $null
    if ($endRaw) {
      $endDate = Parse-IcsDate $endRaw
    }

    $cursor = $startDate.Date
    $endExclusive = if ($null -ne $endDate) { $endDate.Date } else { $startDate.Date.AddDays(1) }
    if ($endExclusive -le $cursor) {
      $endExclusive = $cursor.AddDays(1)
    }

    while ($cursor -lt $endExclusive) {
      if ($cursor -ge $EarliestDate.Date -and $cursor -le $LatestDate.Date) {
        $null = $set.Add($cursor.ToString('yyyy-MM-dd'))
      }
      $cursor = $cursor.AddDays(1)
    }
  }

  return $set
}

function Get-ExplicitDates {
  param(
    [datetime]$EventDate,
    [string]$Description
  )

  $baseDate = $EventDate.Date
  $matches = [System.Text.RegularExpressions.Regex]::Matches(
    $Description,
    '(?<!\d)([0-3O]?\d)/([0-1]?\d)(?!\d)'
  )
  $matchesByMonthName = [System.Text.RegularExpressions.Regex]::Matches(
    $Description,
    '(?<!\d)([0-3O]?\d)\s+de\s+(janeiro|fevereiro|marco|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro)\b',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
  )
  $dates = New-Object System.Collections.Generic.List[datetime]
  $monthMap = @{
    'janeiro' = 1
    'fevereiro' = 2
    'marco' = 3
    'março' = 3
    'abril' = 4
    'maio' = 5
    'junho' = 6
    'julho' = 7
    'agosto' = 8
    'setembro' = 9
    'outubro' = 10
    'novembro' = 11
    'dezembro' = 12
  }

  foreach ($match in $matches) {
    $dayText = $match.Groups[1].Value.ToUpperInvariant().Replace('O', '0')
    $monthText = $match.Groups[2].Value.ToUpperInvariant().Replace('O', '0')

    try {
      $day = [int]$dayText
      $month = [int]$monthText
      $year = $baseDate.Year
      $parsed = Get-Date -Year $year -Month $month -Day $day

      if ($parsed.Date -lt $baseDate.AddDays(-7)) {
        $parsed = $parsed.AddYears(1)
      }

      if (-not $dates.Contains($parsed.Date)) {
        $dates.Add($parsed.Date)
      }
    }
    catch {
      continue
    }
  }

  foreach ($match in $matchesByMonthName) {
    $dayText = $match.Groups[1].Value.ToUpperInvariant().Replace('O', '0')
    $monthName = $match.Groups[2].Value.ToLowerInvariant()

    if (-not $monthMap.ContainsKey($monthName)) {
      continue
    }

    try {
      $day = [int]$dayText
      $month = [int]$monthMap[$monthName]
      $year = $baseDate.Year
      $parsed = Get-Date -Year $year -Month $month -Day $day

      if ($parsed.Date -lt $baseDate.AddDays(-7)) {
        $parsed = $parsed.AddYears(1)
      }

      if (-not $dates.Contains($parsed.Date)) {
        $dates.Add($parsed.Date)
      }
    }
    catch {
      continue
    }
  }

  return @($dates | Sort-Object)
}

function Get-Prazos {
  param(
    [datetime]$EventDate,
    [string]$Description,
    [string]$Tipo,
    [System.Collections.Generic.HashSet[string]]$NoClassDates
  )

  $baseDate = $EventDate.Date
  $text = (Repair-Mojibake $Description).ToLowerInvariant()
  $explicitDates = @(Get-ExplicitDates -EventDate $EventDate -Description $Description)

  if ($explicitDates.Count -gt 0) {
    return $explicitDates
  }

  if ($text -match '\bamanha\b') {
    return @($baseDate.AddDays(1))
  }

  if ($text -match '\bhoje\b') {
    return @($baseDate)
  }

  if ($Tipo -eq 'tarefa') {
    $candidate = Get-NextSchoolDay -BaseDate $baseDate
    while ($NoClassDates.Contains($candidate.ToString('yyyy-MM-dd'))) {
      $candidate = Get-NextSchoolDay -BaseDate $candidate
    }
    return @($candidate)
  }

  return @($baseDate)
}

function Get-Titulo {
  param(
    [string]$Summary,
    [string]$Description,
    [string]$Tipo
  )

  $cleanSummary = Normalize-KnownSchoolTerms (Normalize-Text $Summary)
  $cleanDescription = Normalize-KnownSchoolTerms (Normalize-Text $Description)

  if ($Tipo -eq 'prova') {
    return $cleanSummary
  }

  if ($Tipo -eq 'evento' -or $Tipo -eq 'aviso') {
    return $cleanSummary
  }

  if (-not [string]::IsNullOrWhiteSpace($cleanDescription)) {
    if ($Tipo -eq 'tarefa') {
      return $cleanDescription
    }

    $endIndex = $cleanDescription.IndexOf('. ')
    if ($endIndex -gt 0) {
      return $cleanDescription.Substring(0, $endIndex + 1).Trim()
    }

    if ($cleanDescription.Length -gt 110) {
      return $cleanDescription.Substring(0, 110).Trim() + '...'
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

    if (($line.StartsWith(' ')) -or ($line.StartsWith("`t"))) {
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
    if ($line -eq 'BEGIN:VEVENT') {
      $current = @{}
      continue
    }

    if ($line -eq 'END:VEVENT') {
      if ($null -ne $current) {
        $events.Add($current)
      }
      $current = $null
      continue
    }

    if ($null -eq $current) {
      continue
    }

    $separator = $line.IndexOf(':')
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
$noClassDates = Get-NonClassDates -Events $rawEvents -EarliestDate $earliestRelevantDate -LatestDate $limit
$items = New-Object System.Collections.Generic.List[object]

foreach ($event in $rawEvents) {
  $startRaw = Get-FieldValue -Event $event -Candidates @('DTSTART;VALUE=DATE', 'DTSTART')
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

  $summary = Normalize-KnownSchoolTerms (Normalize-Text (Get-FieldValue -Event $event -Candidates @('SUMMARY')))
  $description = Normalize-KnownSchoolTerms (Normalize-Text (Get-FieldValue -Event $event -Candidates @('DESCRIPTION')))
  $location = Normalize-Text (Get-FieldValue -Event $event -Candidates @('LOCATION'))
  $uid = Get-FieldValue -Event $event -Candidates @('UID')
  $tipo = Get-Tipo -Summary $summary -Description $description
  $combinedText = (Repair-Mojibake ($summary + ' ' + $description)).ToLowerInvariant()
  $creatorEmail = Get-CreatorEmail -Event $event -Summary $summary -Description $description

  if ($combinedText -match 'steam|felitroca|felicita|feira liter|recesso|feriado|homenagem|volta as aulas|exposicao|quinta-feira santa|sexta-feira santa|sabado de aleluia|pascoa') {
    $tipo = 'evento'
  }

  if ($tipo -eq 'evento' -and $combinedText -notmatch 'steam|felitroca|felicita|feira liter|recesso|feriado|homenagem|volta as aulas|exposicao|quinta-feira santa|sexta-feira santa|sabado de aleluia|pascoa' -and $combinedText -match 'para casa|homework|hw|atividade|exercicio|leitura|pesquisa|folha|pagina') {
    $tipo = 'tarefa'
  }

  $materia = Get-Materia -Summary $summary -Description $description
  $teacherMateriaOverride = Get-MateriaByTeacherRule -CreatorEmail $creatorEmail -Summary $summary -Description $description
  if ($tipo -eq 'tarefa' -and $null -ne $teacherMateriaOverride) {
    $materia = $teacherMateriaOverride
  }
  if ($combinedText -match 'steam|felitroca|felicita|feira liter|recesso|feriado|homenagem|volta as aulas|exposicao|quinta-feira santa|sexta-feira santa|sabado de aleluia|pascoa') {
    $materia = 'Geral'
  }

  $titulo = Get-Titulo -Summary $summary -Description $description -Tipo $tipo
  $prazos = @(Get-Prazos -EventDate $startDate -Description $description -Tipo $tipo -NoClassDates $noClassDates)

  foreach ($prazo in $prazos) {
    if ($prazo.Date -lt $today) {
      continue
    }

    $urgencia = Get-Urgencia -Prazo $prazo

    $items.Add([ordered]@{
      id = if ($prazos.Count -gt 1) { "$uid#$($prazo.ToString('yyyy-MM-dd'))" } else { $uid }
      tipo = $tipo
      materia = $materia
      titulo = $titulo
      descricao = $description
      resumo_original = $summary
      local = $location
      data_evento = $startDate.ToString('yyyy-MM-dd')
      prazo = $prazo.ToString('yyyy-MM-dd')
      urgencia = $urgencia
      fonte = 'google_calendar'
    })
  }
}

$orderedItems = $items |
  Sort-Object @{ Expression = 'prazo'; Ascending = $true }, @{ Expression = 'materia'; Ascending = $true }, @{ Expression = 'titulo'; Ascending = $true }

$payload = [ordered]@{
  gerado_em = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  calendario = [ordered]@{
    fonte = 'google_calendar_public_ics'
    nome = ('4' + [char]0x00BA + ' ano - Turma A')
    url = $CalendarUrl
    dias_considerados = $DaysAhead
    dias_retroativos = $LookbackDays
  }
  resumo = [ordered]@{
    total_itens = @($orderedItems).Count
    tarefas = @($orderedItems | Where-Object { $_.tipo -eq 'tarefa' }).Count
    provas = @($orderedItems | Where-Object { $_.tipo -eq 'prova' }).Count
    avisos = @($orderedItems | Where-Object { $_.tipo -eq 'aviso' }).Count
    eventos = @($orderedItems | Where-Object { $_.tipo -eq 'evento' }).Count
  }
  itens = @($orderedItems)
}

$json = $payload | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText($outputFullPath, $json, [System.Text.UTF8Encoding]::new($true))

$jsOutputPath = [System.IO.Path]::ChangeExtension($outputFullPath, '.js')
$jsPayload = 'window.__TAREFAS_DATA = ' + $json + ';'
[System.IO.File]::WriteAllText($jsOutputPath, $jsPayload, [System.Text.UTF8Encoding]::new($true))

Write-Output ('Arquivo gerado: ' + $outputFullPath)
Write-Output ('Itens processados: ' + @($orderedItems).Count)
