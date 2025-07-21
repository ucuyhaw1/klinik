/*
  # Create patient_visits table

  1. New Tables
    - `patient_visits`
      - `id` (uuid, primary key)
      - `id_pendaftaran` (text, unique, auto-generated)
      - `no_antrian` (integer, auto-generated daily)
      - `tanggal` (date, default today)
      - `patient_id` (uuid, foreign key)
      - `room_id` (uuid, foreign key)
      - `doctor_id` (uuid, foreign key)
      - `payment_method_id` (uuid, foreign key)
      - `guarantor_id` (uuid, foreign key)
      - `pengantar_pasien` (text, required)
      - `telepon_pengantar` (text, required)
      - `status` (text, default 'Dalam Antrian')
      - Timestamps

  2. Security
    - Enable RLS on `patient_visits` table
    - Add policy for authenticated users
*/

CREATE TABLE IF NOT EXISTS patient_visits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pendaftaran text UNIQUE NOT NULL DEFAULT '',
  no_antrian integer NOT NULL DEFAULT 0,
  tanggal date DEFAULT CURRENT_DATE,
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  room_id uuid REFERENCES rooms(id) ON DELETE SET NULL,
  doctor_id uuid REFERENCES doctors(id) ON DELETE SET NULL,
  payment_method_id uuid REFERENCES payment_methods(id) ON DELETE SET NULL,
  guarantor_id uuid REFERENCES guarantors(id) ON DELETE SET NULL,
  pengantar_pasien text NOT NULL,
  telepon_pengantar text NOT NULL,
  status text DEFAULT 'Dalam Antrian' CHECK (status IN ('Dalam Antrian', 'Dalam Pemeriksaan', 'Selesai')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE patient_visits ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Authenticated users can manage patient visits"
  ON patient_visits
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_patient_visits_id_pendaftaran ON patient_visits(id_pendaftaran);
CREATE INDEX IF NOT EXISTS idx_patient_visits_tanggal ON patient_visits(tanggal);
CREATE INDEX IF NOT EXISTS idx_patient_visits_patient_id ON patient_visits(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_visits_room_id ON patient_visits(room_id);
CREATE INDEX IF NOT EXISTS idx_patient_visits_doctor_id ON patient_visits(doctor_id);
CREATE INDEX IF NOT EXISTS idx_patient_visits_status ON patient_visits(status);
CREATE INDEX IF NOT EXISTS idx_patient_visits_created_at ON patient_visits(created_at);

-- Create trigger for updated_at
CREATE TRIGGER update_patient_visits_updated_at 
  BEFORE UPDATE ON patient_visits 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();