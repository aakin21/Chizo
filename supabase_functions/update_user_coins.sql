  -- ✅ SECURITY FIX: Atomic coin update function to prevent race conditions
  -- This function ensures that coin updates are atomic and prevent concurrent modification issues

  CREATE OR REPLACE FUNCTION update_user_coins(
    p_user_id UUID,
    p_amount INTEGER,
    p_transaction_type TEXT,
    p_description TEXT
  )
  RETURNS BOOLEAN
  LANGUAGE plpgsql
  SECURITY DEFINER
  AS $$
  DECLARE
    v_current_coins INTEGER;
    v_new_coins INTEGER;
  BEGIN
    -- Lock the user row for update to prevent race conditions
    SELECT coins INTO v_current_coins
    FROM users
    WHERE id = p_user_id
    FOR UPDATE;

    -- Check if user exists
    IF v_current_coins IS NULL THEN
      RAISE EXCEPTION 'User not found: %', p_user_id;
    END IF;

    -- Calculate new coin balance
    v_new_coins := v_current_coins + p_amount;

    -- Prevent negative coins
    IF v_new_coins < 0 THEN
      RAISE EXCEPTION 'Insufficient coins. Current: %, Required: %', v_current_coins, ABS(p_amount);
    END IF;

    -- Update user coins atomically
    UPDATE users
    SET
      coins = v_new_coins,
      updated_at = NOW()
    WHERE id = p_user_id;

    -- Record transaction (using 'type' column name to match database schema)
    INSERT INTO coin_transactions (
      user_id,
      amount,
      type,
      description,
      created_at
    ) VALUES (
      p_user_id,
      p_amount,
      p_transaction_type,
      p_description,
      NOW()
    );

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      -- Log error and re-raise
      RAISE WARNING 'Error updating coins for user %: %', p_user_id, SQLERRM;
      RETURN FALSE;
  END;
  $$;

  -- Grant execute permission to authenticated users
  GRANT EXECUTE ON FUNCTION update_user_coins(UUID, INTEGER, TEXT, TEXT) TO authenticated;

  -- Example usage:
  -- SELECT update_user_coins('user-uuid', 50, 'earned', 'Daily login bonus');
  -- SELECT update_user_coins('user-uuid', -100, 'spent', 'Photo upload slot 2');
