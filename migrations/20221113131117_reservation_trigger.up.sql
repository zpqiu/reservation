-- Add up migration script here
CREATE TABLE rsvp.reservation_changes (
    id SERIAL NOT NULL,
    reservation_id uuid NOT NULL,
    op rsvp.reservation_update_type NOT NULL
);

CREATE OR REPLACE FUNCTION rsvp.reservations_trigger() RETURNS TRIGGER
AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- update reservation_changes
        INSERT INTO rsvp.reservation_changes (reservation_id, op) VALUES
        (NEW.id, 'create');
        -- check if the reservation conflicts with existing reservations
        -- send notification to the reservation service
    ELSIF TG_OP = 'UPDATE' THEN
        -- check if the reservation is valid
        IF OLD.status <> NEW.status THEN
            INSERT INTO rsvp.reservation_changes (reservation_id, op) VALUES
            (NEW.id, 'update');
        END IF;
        -- check if the reservation conflicts with existing reservations
        -- send notification to the reservation service
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO rsvp.reservation_changes (reservation_id, op) VALUES
        (NEW.id, 'delete');
        -- send notification to the reservation service
    END IF;
    -- notify a channel called reservation_update
    NOTIFY reservation_update;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reservations_trigger
    AFTER INSERT OR UPDATE OR DELETE ON rsvp.reservations
    FOR EACH ROW EXECUTE PROCEDURE rsvp.reservations_trigger();
