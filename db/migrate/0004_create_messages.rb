class CreateMessages < ActiveRecord::Migration
  def up
    execute %q{
      CREATE EXTENSION hstore;
      DO $$BEGIN CREATE SCHEMA cforum; EXCEPTION WHEN duplicate_schema THEN RAISE NOTICE 'already exists'; END;$$;

      CREATE TABLE cforum.messages (
        message_id BIGSERIAL NOT NULL PRIMARY KEY,
        thread_id BIGINT NOT NULL REFERENCES cforum.threads(thread_id) ON DELETE CASCADE ON UPDATE CASCADE,
        forum_id BIGINT NOT NULL REFERENCES cforum.forums(forum_id) ON DELETE CASCADE ON UPDATE CASCADE,

        upvotes INTEGER NOT NULL DEFAULT 0,
        downvotes INTEGER NOT NULL DEFAULT 0,
        deleted BOOLEAN NOT NULL DEFAULT false,

        created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,

        mid BIGINT,

        user_id BIGINT REFERENCES cforum.users (user_id) ON DELETE SET NULL ON UPDATE CASCADE,
        parent_id BIGINT REFERENCES cforum.messages (message_id) ON DELETE SET NULL ON UPDATE CASCADE,

        author CHARACTER VARYING NOT NULL,
        email CHARACTER VARYING,
        homepage CHARACTER VARYING,

        subject CHARACTER VARYING NOT NULL,
        content CHARACTER VARYING NOT NULL,

        flags HSTORE
      );

      ALTER TABLE cforum.threads ADD COLUMN message_id BIGINT REFERENCES cforum.messages (message_id) ON DELETE SET NULL ON UPDATE CASCADE;
      CREATE INDEX threads_message_id_idx on cforum.threads (message_id); -- used for the FKs

      CREATE INDEX messages_thread_id_idx ON cforum.messages (thread_id);
      CREATE INDEX messages_mid_idx ON cforum.messages (mid);

      CREATE INDEX messages_parent_id_idx ON cforum.messages (parent_id); -- FK index

      CREATE INDEX messages_forum_id_updated_at_idx ON cforum.messages (forum_id, updated_at);
      CREATE INDEX messages_user_id_idx on cforum.messages (user_id);
    }
  end

  def down
    remove_column 'cforum.threads', :message_id
    drop_table 'cforum.messages'
    execute "DO $$BEGIN DROP SCHEMA system; EXCEPTION WHEN dependent_objects_still_exist THEN RAISE NOTICE 'not removing schema system'; END;$$;"
  end
end