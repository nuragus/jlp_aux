create foreign table seq_sequence_column (
    _sequence_key integer NOT NULL,
    _sequencetype_key integer NOT NULL,
    _sequencequality_key integer NOT NULL,
    _sequencestatus_key integer NOT NULL,
    _sequenceprovider_key integer NOT NULL,
    _organism_key integer NOT NULL,
    length integer,
    description text,
    version character varying(15),
    division character(3),
    virtual smallint NOT NULL,
    numberoforganisms integer,
    seqrecord_date timestamp without time zone DEFAULT now() NOT NULL,
    sequence_date timestamp without time zone DEFAULT now() NOT NULL,
    _createdby_key integer DEFAULT 1001 NOT NULL,
    _modifiedby_key integer DEFAULT 1001 NOT NULL,
    creation_date timestamp without time zone DEFAULT now() NOT NULL,
    modification_date timestamp without time zone DEFAULT now() NOT NULL
)
server cstore_server
options(compression 'pglz');
