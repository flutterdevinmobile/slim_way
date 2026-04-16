BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "daily_logs" ADD COLUMN "protein" double precision;
ALTER TABLE "daily_logs" ADD COLUMN "fat" double precision;
ALTER TABLE "daily_logs" ADD COLUMN "carbs" double precision;
ALTER TABLE "daily_logs" ADD COLUMN "waterMl" bigint;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "foods" ADD COLUMN "protein" double precision;
ALTER TABLE "foods" ADD COLUMN "fat" double precision;
ALTER TABLE "foods" ADD COLUMN "carbs" double precision;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "users" ADD COLUMN "waterGlassSize" bigint;

--
-- MIGRATION VERSION FOR slim_way
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('slim_way', '20260416080554840', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416080554840', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20250825102351908-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250825102351908-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
