# About

## Service interface

```proto
enum ReservationStatus {
    UNKNOWN = 0;
    PENDING = 1;
    CONFIRMED = 2;
    BLOCKED = 3;
}

message Reservation {
    string id = 1;
    string user_id = 2;
    ReservationStatus status = 3;

    string resource_id = 4;
    google.protobuf.Timestamp start = 5;
    google.protobuf.Timestamp end = 6;

    string note = 7;
}

message ReserveRequest {
    Reservation reservation = 1;
}

message ReserveResponse {
    Reservation reservation = 1;
}

message UpdateRequest {
    string note = 1;
}

message UpdateResponse {
    Reservation reservation = 1;
}

message ConfirmRequest {
    string id = 1;
}

message ConfirmResponse {
    Reservation reservation = 1;
}

message CancelRequest {
    string id = 1;
}

message CancelResponse {
    Reservation reservation = 1;
}

message GetRequest {
    string id = 1;
}

message GetResponse {
    Reservation reservation = 1;
}

message QueryRequest {
    string resource_id = 1;
    string user_id = 2;
    // use status to filter
    ReservationStatus status = 3;
    google.protobuf.Timestamp start = 4;
    google.protobuf.Timestamp end = 5;
}

message ListenRequest {
    repeated
}

service ReservationService {
    rpc reserve(ReserveRequest) returns (ReserveResponse);
    rpc update(UpdateRequest) returns (UpdateResponse);
    rpc cancel(CancelRequest) returns (CancelResponse);
    rpc get(GetRequest) returns (GetResponse);
    rpc query(QueryRequest) returns (stream Reservation);
    rpc listen(ListenRequest) returns (stream Reservation);
}
```

## Database Schema

```sql
CREATE SCHEMA rsvp;
CREATE TYPE rsvp.reservation_status AS ENUM
('unknown', 'pending', 'confirmed', 'blocked');

CREATE TABLE rsvp.reservations (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    user_id varchar(64) NOT NULL,
    status reservation_status NOT NULL DEFAULT 'pending',
    resource_id varchar(64) NOT NULL,
    timespan tstzrange NOT NULL,
    not text,

    CONSTRAINT reservation_pkey PRIMARY KEY (id),
    CONSTRAINT reservation_conflict EXCLUDE
    USING gist (resource_id WITH =, timespan WITH &&)
);

CREATE INDEX reservations_resource_id_idx ON rsvp.reservation (resource_id);
CREATE INDEX reservations_user_id_idx ON rsvp.reservation (user_id);

CREATE OR REPLACE FUNCTION rsvp.query(uid text, rid text, during: tstzrange)
RETURNS TABLE rsvp.reservations AS $$ $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rsvp.reservations_trigger() RETURNS TRIGGER
AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER reservations_trigger
    AFTER INSERT OR UPDATE OR DELETE ON rsvp.reservations
    FOR EACH ROW EXECUTE PROCEDURE
```
