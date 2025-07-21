/*
  # Create doctors table

  1. New Tables
    - `doctors`
      - `id` (uuid, primary key)
      - `name` (text, required) - Nama dokter
      - `specialization` (text, required) - Spesialisasi
      - `room_id` (uuid, foreign key) - Ruangan tempat praktik
      - `is_active` (boolean, default true)
      - Timestamps

  2. Security
    - Enable RLS on `doctors` table
    - Add policy for authenticated users
*/

CREATE TABLE IF NOT EXISTS doctors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  specialization text NOT NULL,
  room_id uuid REFERENCES rooms(id) ON DELETE SET NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Authenticated users can read doctors"
  ON doctors
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage doctors"
  ON doctors
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_doctors_name ON doctors(name);
CREATE INDEX IF NOT EXISTS idx_doctors_room_id ON doctors(room_id);
CREATE INDEX IF NOT EXISTS idx_doctors_is_active ON doctors(is_active);

-- Create trigger for updated_at
CREATE TRIGGER update_doctors_updated_at 
  BEFORE UPDATE ON doctors 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (after rooms are created)
DO $$
DECLARE
  room_umum_id uuid;
  room_anak_id uuid;
  room_gigi_id uuid;
  room_mata_id uuid;
  room_kulit_id uuid;
BEGIN
  -- Get room IDs
  SELECT id INTO room_umum_id FROM rooms WHERE name = 'Poliklinik Umum' LIMIT 1;
  SELECT id INTO room_anak_id FROM rooms WHERE name = 'Poliklinik Anak' LIMIT 1;
  SELECT id INTO room_gigi_id FROM rooms WHERE name = 'Poliklinik Gigi' LIMIT 1;
  SELECT id INTO room_mata_id FROM rooms WHERE name = 'Poliklinik Mata' LIMIT 1;
  SELECT id INTO room_kulit_id FROM rooms WHERE name = 'Poliklinik Kulit' LIMIT 1;

  -- Insert doctors
  INSERT INTO doctors (name, specialization, room_id) VALUES
    ('dr. Sri Kartini Kussudiardjo, Sp.A', 'Spesialis Anak', room_anak_id),
    ('dr. Ahmad Wijaya, Sp.PD', 'Spesialis Penyakit Dalam', room_umum_id),
    ('dr. Siti Nurhaliza, Sp.KG', 'Spesialis Kedokteran Gigi', room_gigi_id),
    ('dr. Budi Santoso, Sp.M', 'Spesialis Mata', room_mata_id),
    ('dr. Maya Sari, Sp.KK', 'Spesialis Kulit dan Kelamin', room_kulit_id)
  ON CONFLICT DO NOTHING;
END $$;