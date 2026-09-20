param (
    [string]$OutputFile = "$PSScriptRoot\activity.md"
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host "[*] Starting UCalgary BioSci First-Year Activity Update..." -ForegroundColor Cyan

$now = Get-Date
$todayStr = $now.ToString("yyyy-MM-dd HH:mm:ss")
$todayDate = $now.Date

# 1. Fetch live events from UCalgary LiveWhale Events API
$liveEventsUrl = "https://events.ucalgary.ca/live/json/events/max/100"
$liveEvents = @()

try {
    Write-Host "[*] Querying UCalgary Live Events Feed..." -ForegroundColor Gray
    $response = Invoke-RestMethod -Uri $liveEventsUrl -Method Get -TimeoutSec 15
    if ($response) {
        $liveEvents = $response
        Write-Host "[+] Retrieved $($liveEvents.Count) live campus events." -ForegroundColor Green
    }
} catch {
    Write-Warning "Could not reach live events API: $($_.Exception.Message). Proceeding with curated schedule."
}

# 2. Filter Live Events for Relevant Student Categories
$relevantKeywords = @("science", "biology", "undergraduate", "student", "career", "study", "international", "mentor", "tfdl", "research", "exam", "advising", "wellness", "workshop")
$filteredLiveEvents = @()

foreach ($ev in $liveEvents) {
    $evTitle = if ($ev.title) { [string]$ev.title } else { "" }
    $evDesc = if ($ev.description) { [string]$ev.description } else { "" }
    $evLoc = if ($ev.location) { [string]$ev.location } else { if ($ev.location_title) { [string]$ev.location_title } else { "TBD / Online" } }
    $evUrl = if ($ev.url) { [string]$ev.url } else { "https://events.ucalgary.ca" }
    
    $cats = ""
    if ($ev.event_types) { $cats += ($ev.event_types -join " ") }
    if ($ev.tags) { $cats += " " + ($ev.tags -join " ") }
    
    $fullText = ("$evTitle $evDesc $cats $evLoc").ToLower()
    
    $isMatch = $false
    foreach ($kw in $relevantKeywords) {
        if ($fullText.Contains($kw)) {
            $isMatch = $true
            break
        }
    }
    
    if ($isMatch) {
        $cleanDesc = $evDesc -replace '<[^>]+>', ''
        $cleanDesc = $cleanDesc -replace '[\r\n\t]+', ' '
        if ($cleanDesc.Length -gt 150) {
            $cleanDesc = $cleanDesc.Substring(0, 147) + "..."
        }
        $filteredLiveEvents += [PSCustomObject]@{
            Title    = $evTitle
            Date     = $ev.date
            Location = $evLoc
            Url      = $evUrl
            Summary  = $cleanDesc
        }
    }
}

# 3. Curated Academic & Department Calendar for 1st Year BioSci (2026-2027)
$curatedActivities = @(
    @{
        Date        = "2026-09-08"
        Category    = "Academic Milestone"
        Title       = "Fall 2026 Lectures Begin"
        Location    = "Campus-wide"
        Description = "First day of classes for Fall 2026 term."
        Urgency     = "Passed"
    },
    @{
        Date        = "2026-09-14 to 2026-09-18"
        Category    = "Student Life / Clubs"
        Title       = "SU Fall Clubs Week 2026"
        Location    = "MacEwan Student Centre (North Courtyard)"
        Description = "Sign up for Biology Students' Association (BSA), Science Undergraduate Society (SUS), and Pre-Health clubs."
        Urgency     = "Passed"
    },
    @{
        Date        = "2026-09-18"
        Category    = "Academic Milestone"
        Title       = "Last Day to Drop / Swap Fall 2026 Courses"
        Location    = "My UCalgary Portal"
        Description = "Last day to drop courses without financial penalty and receive tuition refund. Last day to add or swap classes."
        Urgency     = "Passed"
    },
    @{
        Date        = "2026-09-25"
        Category    = "Financial Deadline"
        Title       = "Fall 2026 Tuition & Fee Payment Deadline"
        Location    = "My UCalgary > My Financials"
        Description = "Tuition and general fees deadline for Fall 2026. Late fees apply after this date."
        Urgency     = "Critical"
    },
    @{
        Date        = "2026-10-01"
        Category    = "Scholarships & Awards"
        Title       = "UCalgary Admissions & Prestige Awards Applications Open"
        Location    = "my.ucalgary.ca"
        Description = "Admissions and entrance prestige award portals open for subsequent cycle."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-10-01"
        Category    = "Department Activity"
        Title       = "BSA BIO 241 Midterm 1 Exam Prep & Review Session"
        Location    = "Science Theatres (ST) / Zoom"
        Description = "Hosted by Biology Students' Association. Peer review of cellular biology and past exam questions."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-10-08"
        Category    = "Faculty of Science"
        Title       = "Science Internship Program (SIP) - 1st Year Exploration Session"
        Location    = "Science B (SB) / Virtual"
        Description = "Learn how to prepare in Year 1 to qualify for 8-to-16 month paid industry internships in Year 3."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-10-15"
        Category    = "Support / Advising"
        Title       = "Faculty of Science Peer Mentorship Check-in & Study Skills"
        Location    = "Taylor Institute for Teaching and Learning"
        Description = "Meet senior biology mentors for advice on managing biology lab reports and chemistry tutorials."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-10-22"
        Category    = "Department Activity"
        Title       = "BSA 'Meet the Biology Professors' Research Night"
        Location    = "MacEwan Conference Centre / Science Theatres"
        Description = "Faculty members present ongoing research in ecology, genetics, and cellular biology. Key for finding summer supervisors!"
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-11-08 to 2026-11-14"
        Category    = "Academic Milestone"
        Title       = "Fall Term Break (Reading Week)"
        Location    = "No classes"
        Description = "Fall break. Ideal time to catch up on lab write-ups and study for second midterms."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-11-19"
        Category    = "Undergraduate Research"
        Title       = "UREX Summer Research Awards Info Session (Faculty of Science)"
        Location    = "Virtual / Science B"
        Description = "Workshop on finding a supervisor and drafting research proposals for the $7,500 summer research award (open to international students)."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-11-26"
        Category    = "Department Activity"
        Title       = "BSA BIO 241 Midterm 2 Prep & Mock Practical"
        Location    = "Science Theatres"
        Description = "Review session focused on genetics, cell division, and microscope practical skills."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-12-01"
        Category    = "Scholarships & Awards"
        Title       = "High School Prestige Awards Application Deadline"
        Location    = "Student Centre"
        Description = "Deadline for incoming prestige awards (e.g. $20,000/yr International Entrance Scholarship)."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-12-09"
        Category    = "Academic Milestone"
        Title       = "Fall 2026 Lectures End & Course Withdrawal Deadline"
        Location    = "Campus-wide"
        Description = "Last day of classes for Fall 2026. Last day to officially withdraw from a Fall course with a 'W' grade."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2026-12-12 to 2026-12-22"
        Category    = "Academic Milestone"
        Title       = "Fall 2026 Final Examination Period"
        Location    = "As per Student Centre Exam Schedule"
        Description = "Final exams for BIO 241, CHEM 201/209, MATH 249/265, and option courses."
        Urgency     = "Upcoming"
    },
    @{
        Date        = "2027-01-11"
        Category    = "Academic Milestone"
        Title       = "Winter 2027 Lectures Begin"
        Location    = "Campus-wide"
        Description = "Start of Winter 2027 term (BIO 243 - Organismal Biology, CHEM 203, etc.)."
        Urgency     = "Future"
    },
    @{
        Date        = "2027-01-22"
        Category    = "Academic Milestone"
        Title       = "Winter 2027 Course Drop / Swap Deadline"
        Location    = "My UCalgary Portal"
        Description = "Last day to drop Winter classes without fee penalty."
        Urgency     = "Future"
    },
    @{
        Date        = "2027-02-05"
        Category    = "Undergraduate Research"
        Title       = "UREX Summer Research Awards Application Deadline"
        Location    = "Signature Learning Portal"
        Description = "Deadline to submit student-supervisor joint research proposal for summer 2027 funding (up to $7,500)."
        Urgency     = "Future"
    },
    @{
        Date        = "2027-03-01"
        Category    = "Scholarships & Awards"
        Title       = "High School General Entrance Awards Deadline"
        Location    = "My UCalgary > My Financials"
        Description = "Application deadline for university-wide and Faculty of Science entrance awards."
        Urgency     = "Future"
    },
    @{
        Date        = "2027-05-01"
        Category    = "Scholarships & Awards"
        Title       = "Continuing Undergraduate Awards Deadline (Year 2 Funding)"
        Location    = "My UCalgary > Apply for Undergraduate Awards"
        Description = "CRITICAL: Annual competition for continuing scholarships including Biological Sciences specific awards."
        Urgency     = "Future"
    }
)

# Build content array
$out = [System.Collections.ArrayList]::new()

[void]$out.Add("# University of Calgary: First-Year Biological Sciences Activities & Event Tracker")
[void]$out.Add("")
[void]$out.Add("> **Tracking Scope:** Academic Year 2026-2027")
[void]$out.Add("> **Faculty / Department:** Faculty of Science -- Department of Biological Sciences")
[void]$out.Add("> **Target:** 1st-Year International & Domestic BSc Students")
[void]$out.Add("> **Last Updated:** $todayStr")
[void]$out.Add("> **Auto-Update Status:** Active daily background tracker")
[void]$out.Add("")
[void]$out.Add("---")
[void]$out.Add("")
[void]$out.Add("## Immediate Priorities & Upcoming Deadlines (Next 30 Days)")
[void]$out.Add("")
[void]$out.Add("| Date | Category | Activity / Milestone | Details & Action |")
[void]$out.Add("| :--- | :--- | :--- | :--- |")

$upcomingCutoff = $todayDate.AddDays(30)
$immediates = @($curatedActivities | Where-Object { 
    $firstDate = ($_.Date -split " ")[0]
    if ($firstDate -match '^\d{4}-\d{2}-\d{2}$') {
        $parsed = [datetime]::ParseExact($firstDate, 'yyyy-MM-dd', $null)
        return ($parsed -ge $todayDate -and $parsed -le $upcomingCutoff)
    }
    return $false
})

if ($immediates.Count -eq 0) {
    $immediates = @($curatedActivities | Where-Object { $_.Urgency -eq "Upcoming" -or $_.Urgency -eq "Critical" } | Select-Object -First 4)
}

foreach ($item in $immediates) {
    [void]$out.Add("| **$($item.Date)** | $($item.Category) | **$($item.Title)** | $($item.Description) |")
}

[void]$out.Add("")
[void]$out.Add("---")
[void]$out.Add("")
[void]$out.Add("## Biological Sciences & Faculty of Science Master Schedule (2026-2027)")
[void]$out.Add("")
[void]$out.Add("This timeline integrates academic deadlines, Biology Students' Association (BSA) review sessions, undergraduate research milestones, and financial deadlines:")
[void]$out.Add("")
[void]$out.Add("| Date | Category | Event / Milestone | Details & Location | Status |")
[void]$out.Add("| :--- | :--- | :--- | :--- | :---: |")

foreach ($item in $curatedActivities) {
    $badge = switch ($item.Urgency) {
        "Passed"   { "[Done]" }
        "Critical" { "[CRITICAL]" }
        "Upcoming" { "[Upcoming]" }
        Default    { "[Scheduled]" }
    }
    [void]$out.Add("| $($item.Date) | $($item.Category) | **$($item.Title)** | $($item.Description) *($($item.Location))* | $badge |")
}

[void]$out.Add("")
[void]$out.Add("---")
[void]$out.Add("")
[void]$out.Add("## Live Campus Events & Student Workshops (From UCalgary Live Feed)")
[void]$out.Add("")
[void]$out.Add("Dynamic listings refreshed from the University of Calgary event portal (`events.ucalgary.ca`):")
[void]$out.Add("")
[void]$out.Add("| Date | Event Title | Location | Summary & Link |")
[void]$out.Add("| :--- | :--- | :--- | :--- |")

if ($filteredLiveEvents.Count -gt 0) {
    $displayEvents = $filteredLiveEvents | Select-Object -First 12
    foreach ($ev in $displayEvents) {
        $cleanTitle = ($ev.Title -replace '\|', '-').Trim()
        $cleanLoc = ($ev.Location -replace '\|', '-').Trim()
        $cleanSum = ($ev.Summary -replace '\|', '-').Trim()
        [void]$out.Add("| **$($ev.Date)** | [$cleanTitle]($($ev.Url)) | $cleanLoc | $cleanSum |")
    }
} else {
    [void]$out.Add("| Daily | Student Success Workshops | TFDL / Online | Visit [events.ucalgary.ca](https://events.ucalgary.ca) for daily campus listings. |")
}

[void]$out.Add("")
[void]$out.Add("---")
[void]$out.Add("")
[void]$out.Add("## Essential Student Resource Hubs")
[void]$out.Add("")
[void]$out.Add('1. **Biology Students Association (BSA):**')
[void]$out.Add('   * **Office:** Science Theatres (ST) 032')
[void]$out.Add('   * **Services:** BIO 241 & BIO 243 exam review sessions, lab coat sales, dissection kits, biology mixers.')
[void]$out.Add('   * **Website/Socials:** bsaucalgary.ca / Instagram: @bsaucalgary')
[void]$out.Add('2. **Faculty of Science Undergraduate Student Centre (USC):**')
[void]$out.Add('   * **Location:** Science B (SB) 149')
[void]$out.Add('   * **Services:** Degree planning, major requirements, science advising, Science Internship Program (SIP).')
[void]$out.Add('3. **Student Success Centre (SSC):**')
[void]$out.Add('   * **Location:** Taylor Family Digital Library (TFDL) 3rd Floor')
[void]$out.Add('   * **Services:** Peer-assisted study sessions (PASS), lab report writing support, study strategy coaching.')
[void]$out.Add('4. **International Student Services (ISS):**')
[void]$out.Add('   * **Location:** MacEwan Student Centre (MSC) 275')
[void]$out.Add('   * **Services:** Immigration advising (study permits/work authorization), Global Cafe, social orientation.')
[void]$out.Add('')
[void]$out.Add('---')
[void]$out.Add('')
[void]$out.Add('## Automation Information')
[void]$out.Add('*This file is generated automatically on a daily basis by update_activities.ps1.*')

[System.IO.File]::WriteAllLines($OutputFile, $out, [System.Text.Encoding]::UTF8)

Write-Host "[+] Successfully generated $OutputFile" -ForegroundColor Green
Write-Host "[+] Curated activities written: $($curatedActivities.Count)" -ForegroundColor Green
Write-Host "[+] Live campus events included: $($filteredLiveEvents.Count)" -ForegroundColor Green
