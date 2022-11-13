-- Add up migration script here
CREATE TYPE rsvp.reservation_status AS ENUM
('unknown', 'pending', 'confirmed', 'blocked');
CREATE TYPE rsvp.reservation_update_type as ENUM
('unknown', 'create', 'update', 'delete');

CREATE TABLE rsvp.reservations (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    user_id varchar(64) NOT NULL,
    status rsvp.reservation_status NOT NULL DEFAULT 'pending',
    resource_id varchar(64) NOT NULL,
    timespan tstzrange NOT NULL,
    note text,

    CONSTRAINT reservation_pkey PRIMARY KEY (id),
    CONSTRAINT reservation_conflict EXCLUDE
    USING gist (resource_id WITH =, timespan WITH &&)
);

CREATE INDEX reservations_resource_id_idx ON rsvp.reservations (resource_id);
CREATE INDEX reservations_user_id_idx ON rsvp.reservations (user_id);
