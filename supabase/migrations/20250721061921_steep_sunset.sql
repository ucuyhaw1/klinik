/*
  # Create patients table

  1. New Tables
    - `patients`
      - `id` (uuid, primary key)
      - `rekam_medik` (text, unique, auto-generated)
      - `nama_lengkap` (text, required)
      - `jenis_identitas` (text, required)
      - `nomor_identitas` (text, required)
      - `tempat_lahir` (text, required)
      - `tanggal_lahir` (date, required)
      - `jenis_kelamin` (text, required)
      - Personal info fields (optional)
      - Address fields
      - Contact info
      - Responsible person info
      - `foto_rontgen` (text, optional)
      - Timestamps

  2. Security
    - Enable RLS on `patients` table
    - Add policy for authenticated users to manage patient data
*/

CREATE TABLE IF NOT EXISTS patients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rekam_medik text UNIQUE NOT NULL DEFAULT '',
  nama_lengkap text NOT NULL,
  jenis_identitas text NOT NULL,
  nomor_identitas text NOT NULL,
  tempat_lahir text NOT NULL,
  tanggal_lahir date NOT NULL,
  jenis_kelamin text NOT NULL,
  golongan_darah text DEFAULT '',
  status_perkawinan text DEFAULT '',
  nama_suami text DEFAULT '',
  nama_ibu text NOT NULL,
  pendidikan text DEFAULT '',
  pekerjaan text DEFAULT '',
  kewarganegaraan text DEFAULT '',
  agama text DEFAULT '',
  suku text DEFAULT '',
  bahasa text DEFAULT '',
  alamat text NOT NULL,
  rt text DEFAULT '',
  rw text DEFAULT '',
  provinsi text DEFAULT '',
  kabupaten text DEFAULT '',
  kecamatan text DEFAULT '',
  kelurahan text DEFAULT '',
  kode_pos text DEFAULT '',
  telepon text NOT NULL,
  hubungan_penanggung_jawab text NOT NULL,
  nama_penanggung_jawab text NOT NULL,
  telepon_penanggung_jawab text NOT NULL,
  foto_rontgen text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Authenticated users can manage patients"
  ON patients
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_patients_rekam_medik ON patients(rekam_medik);
CREATE INDEX IF NOT EXISTS idx_patients_nama_lengkap ON patients(nama_lengkap);
CREATE INDEX IF NOT EXISTS idx_patients_created_at ON patients(created_at);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_patients_updated_at 
  BEFORE UPDATE ON patients 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();