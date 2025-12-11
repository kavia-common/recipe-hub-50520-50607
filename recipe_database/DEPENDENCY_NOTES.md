# recipe_database dependency updates

Date: 2025-12-11

Updated Node.js dependencies for db_visualizer to latest compatible stable versions:
- express ^4.21.2
- pg ^8.13.1
- mysql2 ^3.11.3
- sqlite3 ^5.1.7
- mongodb ^6.12.0
- nodemon ^3.1.7 (dev)

Notes:
- Added engines.node >= 18 to align with current mongodb and sqlite3 requirements.
- No changes required for shell scripts (backup/restore/startup) as they invoke system binaries.
- To refresh lockfiles in environments using npm: run `npm install --package-lock-only` inside recipe_database/db_visualizer.
