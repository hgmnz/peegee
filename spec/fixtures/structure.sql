DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS users;

-- Table: users
CREATE TABLE users
(
  id serial NOT NULL,
  "name" character varying(100),
  email character varying(255) NOT NULL,
  "login" character varying(40) NOT NULL DEFAULT ''::character varying,
  "password" character varying(40),
  "admin" boolean NOT NULL DEFAULT false,
  notes text,
  lock_version integer DEFAULT 0,
  salt character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT users_pkey PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
ALTER TABLE users OWNER TO peegee;

-- Index: "login"
DROP INDEX IF EXISTS "login";

CREATE UNIQUE INDEX "login"
  ON users
  USING btree
  (login);

-- Table: posts


CREATE TABLE posts
(
  id serial NOT NULL,
  title character varying(255),
  body text,
  status_id integer NOT NULL DEFAULT 1,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  published_at timestamp without time zone,
  created_by_id integer NOT NULL,
  updated_by_id integer NOT NULL,
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT fk_posts_created_by_id FOREIGN KEY (created_by_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_posts_updated_by_id FOREIGN KEY (updated_by_id)
      REFERENCES users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (OIDS=FALSE);

ALTER TABLE posts OWNER TO peegee;

-- Index: ix_posts_on_status_id

CREATE INDEX ix_posts_on_status_id
  ON posts
  USING btree
  (status_id);
