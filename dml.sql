# display database size
SELECT pg_size_pretty(pg_database_size('mgd'));

# average row-based
select avg(length) from seq_sequence;

# average column-based
select avg(length) from seq_sequence_column;

# average below 1200 row-based
select avg(length) from seq_sequence where length<1200;

# average below 1200 column-based
select avg(length) from seq_sequence_column where length<1200;

# average between 100 and 500 row-based
select avg(length) from seq_sequence where length between 100 and 500;

# average between 100 and 500 column-based
select avg(length) from seq_sequence_column where length between 100 and 500;

# select json normal
select * from sf limit 1;

# select format json
select jsonb_pretty(data) as data from sf limit 1;

# select * where element properties has street jefferson
select * from sf where data #> '{properties,STREET}' = '"JEFFERSON"';

# same with above but pretty
select jsonb_pretty(data) from sf where data #> '{properties,STREET}' = '"JEFFERSON"';

# select nested key
select data->'properties'->'STREET' from sf;

# count group street
select data->'properties'->'STREET' as data, count(data) from sf group by data->'properties'->'STREET';
