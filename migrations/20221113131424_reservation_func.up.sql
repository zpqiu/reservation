-- Add up migration script here
CREATE OR REPLACE FUNCTION rsvp.query(uid text, rid text, during tstzrange)
RETURNS TABLE (LIKE rsvp.reservations) AS $$
BEGIN
    IF uid is NULL AND rid is NULL THEN
        RETURN QUERY SELECT * FROM rsvp.reservations WHERE timespan && during;
    ELSIF uid IS NULL THEN
        RETURN QUERY SELECT * FROM rsvp.reservations WHERE resource_id = rid AND during @> timespan;
    ELSIF rid IS NULL THEN
        RETURN QUERY SELECT * FROM rsvp.reservations WHERE user_id = uid AND during @> timespan;
    ELSE
        RETURN QUERY SELECT * FROM rsvp.reservations WHERE resource_id = rid AND user_id = uid AND during @> timespan;
    END IF;
END;
$$ LANGUAGE plpgsql;
