/*
  # Create rooms table

  1. New Tables
    - `rooms`
      - `id` (uuid, primary key)
      - `name` (text, required) - Nama ruangan/poliklinik
      - `type` (text, required) - Jenis ruangan
      - `quota` (integer, default 0) - Kuota harian
      - `is_active` (boolean, default true)
      - Timestamps

  2. Security
    - Enable RLS on `rooms` table
    - Add policy for authenticated users
*/

CREATE TABLE IF NOT EXISTS rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL DEFAULT 'Poliklinik',
  quota integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Authenticated users can read rooms"
  ON rooms
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can manage rooms"
  ON rooms
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_rooms_name ON rooms(name);
CREATE INDEX IF NOT EXISTS idx_rooms_is_active ON rooms(is_active);

-- Create trigger for updated_at
CREATE TRIGGER update_rooms_updated_at 
  BEFORE UPDATE ON rooms 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO rooms (name, type, quota) VALUES
  ('Poliklinik Umum', 'Poliklinik', 20),
  ('Poliklinik Anak', 'Poliklinik', 15),
  ('Poliklinik Gigi', 'Poliklinik', 10),
  ('Poliklinik Mata', 'Poliklinik', 12),
  ('Poliklinik Kulit', 'Poliklinik', 8)
ON CONFLICT DO NOTHING;