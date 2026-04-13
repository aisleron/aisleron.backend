# Aisleron Backend

Cloud synchronization and database management for the Aisleron Android application. This repository contains the Supabase configuration, PostgreSQL migrations, and Edge Functions.

## Installation
1. npx supabase init

## Using Podman instead of Docker
1. Install podman docker  
   
    `sudo dnf install podman-docker`

2. Export the podman host  

    `export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"`

## Management Commands

|Action|Command|Description|
|---|---|---|
| Start	    | npx supabase start            | Spins up Postgres, Auth, and the local Dashboard. |
| Stop	    | npx supabase stop	            | Shuts down containers but preserves local data. |
| Reset	    | npx supabase stop --no-backup	| Shuts down containers and wipes all local data. |
| Status	| npx supabase status	        | Displays local API keys, DB credentials, and URLs. |
| Generate Migration | npx supabase db diff -f {{migration_file_name}} | Generate a migration file by diffing against the declared schema. |

## Local Dashboard

Once the services are started, you can manage the local database and view internal Auth emails via the Supabase Studio UI:

URL: http://localhost:54323

## Project Structure

    supabase/migrations/: SQL files defining the database schema (Tables, RLS Policies).

    supabase/config.toml: Main configuration for local and remote services.

    supabase/seed.sql: Sample data used to populate the local database on start.


## Development & Deployment
* Use [Declarative Database Schemas](https://supabase.com/docs/guides/local-development/declarative-database-schemas). Do *not* use Imperative migrations.
* To evaluate schema files in a specific order, add the files to the schema_paths section in `config.toml`.
