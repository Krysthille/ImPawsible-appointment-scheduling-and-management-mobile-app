-- Set up cron job only if the cron extension is available
DO $$
BEGIN
  -- Check if cron extension exists
  IF EXISTS (
    SELECT 1 FROM pg_extension WHERE extname = 'cron'
  ) THEN
    -- Create a cron job to run the auto message function every hour
    PERFORM cron.schedule(
      'auto-send-messages',
      '0 * * * *', -- Every hour
      'SELECT auto_send_messages();'
    );
    
    RAISE NOTICE 'Cron job scheduled successfully';
  ELSE
    RAISE NOTICE 'Cron extension not available. Auto messages will need to be triggered manually.';
  END IF;
END $$; 