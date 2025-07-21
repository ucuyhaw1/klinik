/*
  # Create guarantors table

  1. New Tables
    - `guarantors`
      - `id` (uuid, primary key)
      - `name` (text, required) - Nama penjamin
      - `type` (text, required) - Jenis penjamin
      - `is_active` (boolean, default true)
      - Timestamps

  2. Security
    - Enable RLS on `guarantors` table
    - Add policy for authenticated users
*/

CREATE TABLE IF NOT EXISTS guarantors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE guarantors ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Authenticated users can read guarantors"
  ON guarantors
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage guarantors"
  ON guarantors
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_guarantors_name ON guarantors(name);
CREATE INDEX IF NOT EXISTS idx_guarantors_type ON guarantors(type);
CREATE INDEX IF NOT EXISTS idx_guarantors_is_active ON guarantors(is_active);

-- Create trigger for updated_at
CREATE TRIGGER update_guarantors_updated_at 
  BEFORE UPDATE ON guarantors 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO guarantors (name, type) VALUES
  ('BPJS Kesehatan', 'Pemerintah'),
  ('Mandiri Inhealth', 'Swasta'),
  ('Allianz', 'Swasta'),
  ('Prudential', 'Swasta'),
  ('Pribadi', 'Pribadi'),
  ('Perusahaan', 'Korporat')
ON CONFLICT DO NOTHING;