/*
  # Create Clinic Management System Schema

  1. New Tables
    - `patients` - Data pasien dengan semua informasi pribadi dan kontak
    - `rooms` - Data ruangan/poliklinik 
    - `doctors` - Data dokter dengan spesialisasi
    - `payment_methods` - Metode pembayaran
    - `guarantors` - Data penjamin
    - `patient_visits` - Data kunjungan pasien
    - `registrations` - Data pendaftaran pasien (legacy support)

  2. Functions
    - `generate_rekam_medik()` - Generate nomor rekam medik otomatis
    - `generate_id_pendaftaran()` - Generate ID pendaftaran otomatis
    - `generate_no_antrian()` - Generate nomor antrian harian
    - `get_remaining_quota()` - Hitung sisa kuota ruangan per hari

  3. Security
    - Enable RLS pada semua tabel
    - Policies untuk authenticated users
    - Indexes untuk performa query