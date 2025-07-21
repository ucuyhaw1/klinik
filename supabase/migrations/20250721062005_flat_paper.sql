/*
  # Create utility functions

  1. Functions
    - `generate_rekam_medik()` - Generate nomor rekam medik otomatis (6 digit)
    - `generate_id_pendaftaran()` - Generate ID pendaftaran (RJ + YYYYMMDD + 3 digit)
    - `generate_no_antrian()` - Generate nomor antrian harian
    - `get_remaining_quota()` - Hitung sisa kuota ruangan per hari

  2. Security
    - Functions dapat diakses oleh authenticated users
*/

-- Function to generate rekam medik number
CREATE OR REPLACE FUNCTION generate_rekam_medik()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  next_number integer;
  rekam_medik_number text;
BEGIN
  -- Get the next sequence number
  SELECT COALESCE(MAX(CAST(rekam_medik AS integer)), 0) + 1 
  INTO next_number 
  FROM patients 
  WHERE rekam_medik ~ '^[0-9]+$';
  
  -- Format as 6-digit number
  rekam_medik_number := LPAD(next_number::text, 6, '0');
  
  RETURN rekam_medik_number;
END;
$$;

-- Function to generate ID pendaftaran
CREATE OR REPLACE FUNCTION generate_id_pendaftaran()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  today_str text;
  next_number integer;
  id_pendaftaran text;
BEGIN
  -- Get today's date in YYYYMMDD format
  today_str := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
  
  -- Get the next sequence number for today
  SELECT COALESCE(MAX(CAST(RIGHT(id_pendaftaran, 3) AS integer)), 0) + 1
  INTO next_number
  FROM patient_visits
  WHERE id_pendaftaran LIKE 'RJ' || today_str || '%'
  
  UNION ALL
  
  SELECT COALESCE(MAX(CAST(RIGHT(id_pendaftaran, 3) AS integer)), 0) + 1
  FROM registrations
  WHERE id_pendaftaran LIKE 'RJ' || today_str || '%';
  
  -- If no records found, start with 1
  IF next_number IS NULL THEN
    next_number := 1;
  END IF;
  
  -- Format as RJ + YYYYMMDD + 3-digit number
  id_pendaftaran := 'RJ' || today_str || LPAD(next_number::text, 3, '0');
  
  RETURN id_pendaftaran;
END;
$$;

-- Function to generate nomor antrian
CREATE OR REPLACE FUNCTION generate_no_antrian()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  next_antrian integer;
BEGIN
  -- Get the next queue number for today
  SELECT COALESCE(MAX(no_antrian), 0) + 1
  INTO next_antrian
  FROM patient_visits
  WHERE tanggal = CURRENT_DATE
  
  UNION ALL
  
  SELECT COALESCE(MAX(no_antrian), 0) + 1
  FROM registrations
  WHERE tanggal = CURRENT_DATE;
  
  -- If no records found, start with 1
  IF next_antrian IS NULL THEN
    next_antrian := 1;
  END IF;
  
  RETURN next_antrian;
END;
$$;

-- Function to get remaining quota for a room on a specific date
CREATE OR REPLACE FUNCTION get_remaining_quota(room_id_param uuid, date_param date)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_quota integer;
  used_quota integer;
  remaining_quota integer;
BEGIN
  -- Get total quota for the room
  SELECT quota INTO total_quota
  FROM rooms
  WHERE id = room_id_param;
  
  -- If room not found, return 0
  IF total_quota IS NULL THEN
    RETURN 0;
  END IF;
  
  -- Count used quota for the date
  SELECT COUNT(*)
  INTO used_quota
  FROM patient_visits
  WHERE room_id = room_id_param 
    AND tanggal = date_param
    AND status IN ('Dalam Antrian', 'Dalam Pemeriksaan');
  
  -- Calculate remaining quota
  remaining_quota := total_quota - COALESCE(used_quota, 0);
  
  -- Ensure it's not negative
  IF remaining_quota < 0 THEN
    remaining_quota := 0;
  END IF;
  
  RETURN remaining_quota;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION generate_rekam_medik() TO authenticated;
GRANT EXECUTE ON FUNCTION generate_id_pendaftaran() TO authenticated;
GRANT EXECUTE ON FUNCTION generate_no_antrian() TO authenticated;
GRANT EXECUTE ON FUNCTION get_remaining_quota(uuid, date) TO authenticated;