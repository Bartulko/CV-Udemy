# Zadanie zaliczeniowe Windows PowerShell
# Rok akademicki 2024/2025
# Imię i nazwisko: Bartłomiej Gocyla
#
# Dozwolone argumenty: f (pliki), d (katalogi), df (wszystko)

# Finalny skrypt 

# Parametry wejściowe z wartościami domyślnymi
param(
   $dir = $PWD,  # Domyślny katalog
   $e = "df"     # Domyślny tryb
)

# Sprawdzenie poprawności parametru 
if (!(Test-Path -Path $dir)) {
    Write-Host "Ścieżka nieprawidłowa!"
    return
}

# Sprawdzenie poprawności parametru $e
if ($e -notin @("f", "d", "df")) {
    Write-Host "Nieprawidłowy argument! Dozwolone: f (pliki), d (katalogi), df (wszystko)."
    return
}

# Wprowadzenie zmiennych
$rozmiarCalkowity = 0
$liczbaPlikow = 0
$liczbaKatalogow = 0
$liczbaElementow = 0
$sumaRozmiarowKatalogow = 0
$najwiekszyPlik = $null

# Pobranie elementów z katalogu
# -Force pozwala obejść pewne ograniczenia w dostępie do plików lub folderów.
$elementy = Get-ChildItem -Path $dir -Recurse -Force

foreach ($element in $elementy) {
    # Jeśli element jest plikiem
    if (-not $element.PsIsContainer -and ($e -eq "f" -or $e -eq "df")) {
        $rozmiarCalkowity += $element.Length
        $liczbaPlikow++
        $liczbaElementow++

        # Znalezienie największego pliku
        if ($najwiekszyPlik -eq $null -or $element.Length -gt $najwiekszyPlik.Length) {
            $najwiekszyPlik = $element
        }
    }
    # Jeśli element jest katalogiem
    elseif ($element.PsIsContainer -and ($e -eq "d" -or $e -eq "df")) {
        $liczbaKatalogow++
        $liczbaElementow++

        # Obliczanie rozmiaru katalogu
        $zawartosc = Get-ChildItem -Path $element.FullName -Force | Where-Object { -not $_.PsIsContainer }
        $rozmiarKatalogu = ($zawartosc | Measure-Object Length -Sum).Sum
        $sumaRozmiarowKatalogow += $rozmiarKatalogu
    }
}

# Obliczenia dodatkowych statystyk
$sredniaWielkoscPliku = if ($liczbaPlikow -gt 0) { [math]::Round(($rozmiarCalkowity / 1024) / $liczbaPlikow, 2) } else { 0 }
$sredniaPojemnoscKatalogu = if ($liczbaKatalogow -gt 0) { [math]::Round(($sumaRozmiarowKatalogow / 1024) / $liczbaKatalogow, 2) } else { 0 }
$procentPlikow = if ($liczbaElementow -gt 0) { [math]::Round(($liczbaPlikow / $liczbaElementow) * 100, 2) } else { 0 }
$rozmiar = $([math]::Round($rozmiarCalkowity / 1024, 2)) 

# Wyświetlenie wyników
Write-Host "-------------------------------------------------------------------------"
Write-Host "Statystyka dla katalogu: $dir (Tryb: $e)"
Write-Host "-------------------------------------------------------------------------"
Write-Host "1. Rozmiar całkowity: $rozmiar KB"
Write-Host "2. Liczba elementów: $liczbaElementow"
Write-Host "3. Średnia wielkość pliku: $sredniaWielkoscPliku KB"
Write-Host "4. Średnia pojemność katalogu: $sredniaPojemnoscKatalogu KB"
if ($najwiekszyPlik -ne $null) {
    Write-Host "5. Największy plik: $($najwiekszyPlik.Name) (Rozmiar: $([math]::Round($najwiekszyPlik.Length / 1024, 2)) KB)"
} else {
    Write-Host "5. Największy plik: Brak plików do wyświetlenia."
}
