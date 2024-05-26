# khanzaupdater

Kode skrip batch Windows yang mengotomatisasi proses pembaruan [SIMRS Khanza](https://github.com/mas-elkhanza/SIMRS-Khanza) Desktop dengan sekali klik. 

## cara kerja

1. <b>Membaca Informasi Versi</b>: Mengambil data versi terbaru dari direktori sumber melalui file `info.json`.
2. <b>Mengecek Versi</b>: Menghentikan program jika versi SIMRS sudah up-to-date (diperiksa berdasarkan komentar pada shortcut yang dibuat secara otomatis).
3. <b>Menyalin File</b>: Menyalin file dari direktori sumber ke direktori target.
4. <b>Membuat Shortcut</b>: Membuat shortcut aplikasi di desktop pengguna.
5. <b>Membersihkan</b>: Menghapus shortcut yang tidak sesuai dengan versi terbaru dan direktori versi lama sesuai dengan pengaturan variabel COUNT_OF_LATEST_VERSION_TO_KEEP.

## how to use

### 1. Installation

- Letakkan `info.json` dan `logo.ico` simrs kamu pada direktori sumber seperti contoh berikut:

```bash
# source directory

\\192.168.1.234\Shared\AllKhanza
│
├── info.json
├── logo.ico
│
└── simrs khanza 26052024
|   ├── Aplikasi.bat
|   ├── more
│
└── simrs khanza 13072023
    ├── Aplikasi.bat
    ├── more
```

- Letakkan `update.bat` pada direktori target seperti contoh berikut:

```bash
# target directory

C:\Users\jhon\AllKhanza
│
├── update.bat
│
└── simrs khanza 13072023
    ├── Aplikasi.bat
    ├── more
```
Pada direktori target, biarkan file dan folder lain apa adanya karena akan diatur otomatis saat `update.bat` dijalankan. Jika sebelumnya sudah ada folder SIMRS, pastikan penamaannya mengandung string 'simrs' (insensitive) dan tanggal berformat `ddmmyyyy`. Setelah setup awal, folder dan penamaannya akan diatur otomatis oleh `update.bat`.

### 2. setup
setup `info.json`:

```
{
    "NEW_VERSION": "26052024",
    "SOURCE_NEW_KHANZA_FOLDER": "simrs khanza 26052024",
    "COUNT_OF_LATEST_VERSION_TO_KEEP": 3
}
```

- NEW_VERSION: Format tanggal `ddmmyyyy`.
- SOURCE_NEW_KHANZA_FOLDER: Nama folder SIMRS Khanza terbaru sesuai dengan versi.
- COUNT_OF_LATEST_VERSION_TO_KEEP: semua folder pada target direktori akan dihapus sejumlah lebih dari (>) nilai dari variabel ini.

setup `update.bat`, variabel setting:

```
@REM SETTING
set "ROOT_SOURCE_DIR=\\192.168.1.234\Shared\AllKhanza"

@REM SETTING
set "TARGET_DIR=%~dp0simrs khanza %NEW_VERSION%"
set "SHORTCUT_NAME=SIMRS Khanza %NEW_VERSION%.lnk"
```

- Pastikan penamaan `TARGET_DIR` mengandung string 'simrs' (insensitive) dan tanggal berformat `ddmmyyyy`. Lakukan penyesuain pada variabel lainya jika diperlukan, hati-hati dengan beberapa variabel yang dapat berpengaruh kepada sistem.

### 3. jalankan

Jalankan `update.bat` dengan double click. Skrip akan dijalankan sampai selesai. Selanjutnya setiap ada pembaruan pada SIMRS kamu hanya perlu mengedit `info.json`. Buat shortcut di desktop untuk `update.bat` jika perlu, hanya dengan sekali klik SIMRS akan terupdate.