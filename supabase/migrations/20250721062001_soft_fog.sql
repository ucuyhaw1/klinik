/*
  # Create registrations table (legacy support)

  1. New Tables
    - `registrations`
      - `id` (uuid, primary key)
      - `id_pendaftaran` (text, unique, auto-generated)
      - `no_antrian` (integer, auto-generated daily)
      - `tanggal` (date, default today)
      - `patient_id` (uuid, foreign key)
      - `status` (text, default 'Dalam Antrian')
      - Timestamps

  2. Security
    - Enable RLS on `registrations` table
    - Add policy for authenticated users
*/

CREATE TABLE IF NOT EXISTS registrations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pendaftaran text UNIQUE NOT NULL DEFAULT '',
  no_antrian integer NOT NULL DEFAULT 0,
  tanggal date DEFAULT CURRENT_DATE,
  patient_id uuid REFERENCES patients(id) ON DELETE CASCADE,
  status text DEFAULT 'Dalam Antrian' CHECK (status IN ('Dalam Antrian', 'Dalam Pemeriksaan', 'Selesai')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Authenticated users can manage registrations"
  ON registrations
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_registrations_id_pendaftaran ON registrations(id_pendaftaran);
CREATE INDEX IF NOT EXISTS idx_registrations_tanggal ON registrations(tanggal);
CREATE INDEX IF NOT EXISTS idx_registrations_patient_id ON registrations(patient_id);
CREATE INDEX IF NOT EXISTS idx_registrations_status ON registrations(status);
CREATE INDEX IF NOT EXISTS idx_registrations_created_at ON registrations(created_at);

-- Create trigger for updated_at
CREATE TRIGGER update_registrations_updated_at 
  BEFORE UPDATE ON registrations 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();