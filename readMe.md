# Pemrosesan Citra Ranah Frekuensi (MATLAB GUI)
oleh Nawaf Amjad Rizqi A. Ismail - 18223073

> **Deskripsi Proyek**
> Program ini merupakan perangkat lunak pemrosesan citra digital berbasis *Graphical User Interface* (GUI) interaktif yang dirancang khusus untuk memfasilitasi eksperimen, visualisasi, dan analisis manipulasi citra dalam ranah frekuensi (Frequency Domain). Dibangun menggunakan MATLAB, program ini memungkinkan transformasi instan dari ranah spasial ke frekuensi menggunakan Fast Fourier Transform (FFT) beserta analisisnya.

---

## Fitur & Metode Penapisan

Program ini menangani berbagai jenis degradasi citra dengan mengimplementasikan lima kategori metode pemrosesan utama:

- **1. Image Smoothing (Low-Pass Filter)**
    - Menghaluskan citra dan mereduksi *Gaussian noise*.
    - **Tipe Filter:** Ideal, Gaussian, dan Butterworth.
- **2. Image Sharpening (High-Pass Filter)**
    - Mengekstraksi informasi garis tepi citra (*edge detection*).
    - **Tipe Filter:** Ideal, Gaussian, dan Butterworth.
- **3. Brightness Adjustment**
    - Memanipulasi kecerahan global citra.
    - Bekerja secara langsung dengan mengalikan nilai komponen *Direct Current* (DC) di titik pusat frekuensi nol dengan *Scale Factor*.
- **4. Periodic Noise Restoration**
    - Menghilangkan derau berpola berulang/harmonik.
    - **Metode:** 
        - *Bandreject Filter*: Memblokir frekuensi pada rentang pita melingkar.
        - *Notch Reject Filter*: Melubangi interferensi frekuensi secara spesifik pada koordinat $(u_k, v_k)$.
- **5. Motion Blur Restoration**
    - Melakukan dekonvolusi efek pergerakan optis (kamera goyang/objek bergerak).
    - **Metode:**
        - *Inverse Filtering*: Pembalikan langsung dengan kontrol *clipping threshold*.
        - *Wiener Filtering*: Pendekatan adaptif menggunakan konstanta rasio redaman *Noise-to-Signal* ($K$).

---

## Panduan Penggunaan (User Guide)

### Persiapan Sistem
1. Pastikan **MATLAB** (disarankan versi R2019a ke atas) sudah terinstal.
2. Pastikan *Image Processing Toolbox* telah aktif di MATLAB Anda.

### Langkah Menjalankan GUI
1. Buka MATLAB dan arahkan *Current Folder* ke direktori proyek ini.
2. Jalankan file utama GUI (misalnya: `main_gui.m` atau `app.mlapp` bergantung format akhir Anda) melalui *Command Window* atau tombol *Run*.
3. Antarmuka GUI akan terbuka, menampilkan panel kontrol dan panel visualisasi.

### Alur Pemrosesan Citra
1. **Muat Citra:** Klik tombol **Input Citra** pada panel kontrol kiri untuk memilih gambar yang terdegradasi.
2. **Pilih Metode:** Tentukan metode penapisan pada menu *dropdown* (misal: *Low-Pass Filter*).
3. **Pilih Tipe:** Tentukan karakteristik batas filter (Ideal / Gaussian / Butterworth).
4. **Atur Parameter:** Sesuaikan parameter spesifik yang muncul (seperti $D_0$, *Orde*, *Scale Factor*, *Length*, *Theta*, dll.).
5. **Eksekusi:** Klik **Terapkan/Proses**.
6. **Analisis:** Perhatikan panel visualisasi kanan. GUI akan menampilkan perbandingan wujud spasial dan spektrum Fourier untuk:
    - Citra Masukan
    - Citra Hasil Restorasi
    - Citra Referensi (jika ada)

---

## Metrik Evaluasi

Program ini secara otomatis menghitung matriks evaluasi objektif untuk menakar akurasi restorasi terhadap citra acuan/referensi:
*   **MSE (Mean Squared Error):** Semakin kecil nilainya (mendekati 0), semakin mirip hasil restorasi dengan citra asli.
*   **PSNR (Peak Signal-to-Noise Ratio):** Semakin tinggi nilainya, semakin baik kualitas citra yang dihasilkan.