# SportSync: Tournament Database Manager

A PostgreSQL database designed to administer, query, and analyze sports tournaments, teams, matches, and participant schedules.

LIVE DEMO: https://sportsync.salonii.me
---

## 📸 Application Showcase

### 1. Main Dashboard Canvas
The landing screen groups features logically into operations, analytical reports, and stored functions. It features a real-time blinking PostgreSQL database health banner.
![Dashboard Layout](screenshots/homepage_dashboard.png)

### 2. Multi-Step Form with Progress Stepper
The registration form utilizes a custom visual progress stepper. Choosing "Player" vs "Spectator" changes the layout conditionally to gather role-specific physical attributes or ticket pass tiers.
![Stepper and Form](screenshots/register_person_step1.png)

### 3. Borderless Report Tables & Status Badges
Complex analytical reports are displayed in a borderless tabular format with zebra striping. Data fields like seasons (`spring`/`fall`), outcome states, and ticket tiers are converted into dynamic colored pill badges.
![Report Table Showcase](screenshots/tournament_participants_report.png)

---

## 📐 Entity-Relationship (ER) Diagram & Conceptual Model

### Conceptual ER Diagram
The system's schema is based on the following ER model, which maps sports tournaments, participants, logistics, and matches:

![Entity-Relationship Diagram](sportER.png)

### 1. Specialization & Generalization (Subclassing)
* **The `Person` Superclass**: General entities like players and spectators share common attributes. To avoid redundancy and enforce clean design, `Person` serves as the superclass with attributes: `person_id` (PK), `person_name`, `gender`, `dob`, `contact_no`, `college_name`, and `roles`.
* **Subclasses (`Player` and `Spectator`)**:
  * **`Player` IS-A `Person`**: Inherits the primary key (`player_id` references `Person(person_id)`) and extends the profile with physical attributes: `height`, `weight`, `bloodgroup`, and `joining_year`.
  * **`Spectator` IS-A `Person`**: Inherits the primary key (`spectator_id` references `Person(person_id)`) and is specialized for spectators purchasing ticket passes.
* **Design Rationale**: Minimizes null values in the database, ensures schema reusability, and models real-world participant roles cleanly.

### 2. Aggregation & Match Statistics
Certain relationships contain statistics that depend on the combination of entities and matches rather than any single table.
* **Player Performance Aggregation**: A player's performance (e.g., score, goals) in a specific match cannot reside in `Player` (a player plays multiple matches) or `Match` (a match has multiple players). Therefore, the `PlayerPlaysMatch` relationship is aggregated into **`PlayerStatistics`** with attributes `score` and `status_name` (PK is `(player_id, match_id, status_name)`).
* **Team Performance Aggregation**: Similarly, a team's outcomes and statistics in a match are modeled by aggregating `TeamPlaysMatch` into **`TeamStatistics`** and the **`Result`** (outcome: win, loss, draw) table.
* **Design Rationale**: Captures performance data at both player and team levels for each match, enabling historical analytics.

### 3. Relationship Mappings & Participation Constraints
* **`Person - Player / Spectator`**: 1:1 Specialization. Total participation from `Player` and `Spectator` to `Person` (every player/spectator must be a person), partial participation from `Person` (not all persons are players or spectators; some are organizers, coaches, etc.).
* **`Player - Team`**: M:N Relationship via `PlayerTeam` junction table, tracking `joining_date` and `end_date` to support temporal player transfers.
* **`Team - Sport`**: Many-to-1 relationship. Each team plays exactly one sport; a sport can have multiple teams.
* **`Match - Venue / Referee`**: Many-to-1 relationships. Multiple matches can happen at the same venue or be conducted by the same referee. Partial participation (a venue or referee might not be assigned to any match yet).

---

## 🛠️ Database Building, Constraints & BCNF Normalization

The database is built on **PostgreSQL** with strict adherence to Relational Model principles, normalization, and semantic data integrity.

### 1. BCNF Normalization (Boyce-Codd Normal Form)
During the normalization phase, potential anomalies were analyzed and resolved to achieve BCNF across all relations:

* **Sponsors & Company Split**:
  * *Original Relation*: `Sponsors(sponsor_id, name, contact_no, address, company)`
  * *Violation*: The functional dependency `company -> address` existed. Since `company` was not a superkey in `Sponsors`, this violated BCNF and caused update/deletion anomalies.
  * *Decomposition*: Split into:
    1. **`Company`** (`company` [PK], `address` [NOT NULL])
    2. **`Sponsors`** (`sponsor_id` [PK], `name`, `contact_no`, `company` [FK references `Company(company)`])
* **Sports & SportType Split**:
  * *Original Relation*: `Sports(sport_id, sport_name, type)`
  * *Violation*: The candidate key dependency `sport_name -> type` existed. Since `sport_name` was not a superkey in `Sports` (where `sport_id` is the primary key), this violated BCNF.
  * *Decomposition*: Split into:
    1. **`Sports`** (`sport_id` [PK], `sport_name` [UNIQUE, NOT NULL])
    2. **`SportType`** (`sport_name` [PK, FK references `Sports(sport_name)`], `type` [NOT NULL])

### 2. Referential Integrity & Cascading Actions
To maintain strict foreign key integrity, the schema implements custom referential actions:
* **`ON DELETE CASCADE` / `ON UPDATE CASCADE`**: Applied to dependency tables (`Player`, `SpectatorPass`, `PlayerPlaysMatch`, `PlayerTeam`, `Result`, etc.) to clean up linked records when a parent `Person`, `Match`, or `Team` is deleted.
* **`ON DELETE SET NULL`**: Used for fields like `captain_id` in `Team` or `referee_id`/`venue_id` in `Match` so that deleting a player or referee doesn't break the team or match record.
* **`ON DELETE RESTRICT`**: Applied to `Company` in the `Sponsors` table to prevent deleting a company while it still has active sponsor profiles.

### 3. Semantic CHECK Constraints & Domain Integrity
* **Regex Contact Validation**: `contact_no ~ '^[0-9]{10}$'` enforces a strict 10-digit number constraint on `Sponsors`, `Coach`, `Referee`, and `Organizer` tables.
* **Temporal Date Constraints**:
  * `chk_dates CHECK (end_date >= start_date)` in `Tournament` ensures no backwards tournament schedules.
  * `check_out_date >= check_in_date` in `Accommodation` validates lodging stays.
  * Match date check verifies that matches occur between year 2000 and one year in the future.
* **Domain Limitations**:
  * `gender`: Checked to be `'male'`, `'female'`, or `'other'` (case-insensitive).
  * `pass_type`: Checked to be `'gold'`, `'silver'`, or `'regular'` (case-insensitive).
  * `outcome`: Restricted to `'win'`, `'loss'`, or `'draw'`.
  * `role` and `department` (Logistics, Operations, Marketing, Finance, Refereeing, Medical, Hospitality, Technical, Volunteers) in tournament organization.
  * `level`: Restricted to `'beginner'`, `'intermediate'`, `'advanced'`, `'professional'`.

---

## ⚡ Stored Procedures & Advanced Database Logic

### 1. Active Player Team Information (`get_player_current_team_info`)
This PL/pgSQL function retrieves the active team and college affiliations of a player:
```sql
CREATE OR REPLACE FUNCTION get_player_current_team_info(p_player_id VARCHAR)
RETURNS TABLE (
    team_name VARCHAR,
    college_name VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        T.team_name,
        T.college_id AS college_name
    FROM
        PlayerTeam PT
    INNER JOIN
        Team T ON PT.team_id = T.team_id
    WHERE
        PT.player_id = p_player_id
        AND (PT.end_date IS NULL OR PT.end_date > CURRENT_DATE)
        AND PT.joining_date <= CURRENT_DATE
    ORDER BY PT.joining_date DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

### 2. Department Organizers (`get_organizers_by_department`)
Aggregates organizers who worked in a specific department and consolidates their roles:
```sql
CREATE OR REPLACE FUNCTION get_organizers_by_department(dept_name VARCHAR)
RETURNS TABLE (
    member_id VARCHAR(10),
    member_name VARCHAR(100),
    contact_no VARCHAR(10),
    role TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.member_id, org.member_name, org.contact_no, STRING_AGG(DISTINCT o.role, ', ')
    FROM OrganizeTournament o
    JOIN Organizer org ON o.member_id = org.member_id
    WHERE LOWER(o.department) = LOWER(dept_name)
    GROUP BY o.member_id, org.member_name, org.contact_no;
END;
$$ LANGUAGE plpgsql;
```

### 3. Complex Subqueries & Analytical Reports
* **Fall Undefeated Teams**: Queries teams that did not lose or draw in any matches played during Autumn tournaments using `NOT EXISTS` and `EXISTS` subqueries.
* **Top Scoring Players**: Queries player statistics to display the top 10 highest scorers across all matches.

---

## 🛠️ Architecture & Tech Stack

```
sportsync/
├── backend/              # Node.js & Express.js REST API
│   ├── db/
│   │   └── db.js         # PostgreSQL pool connection
│   ├── routes/           # API Route handlers (Players, Tournaments, Reports, Functions)
│   └── server.js         # Express server setup
├── frontend/             # React & TypeScript Client SPA
│   ├── src/
│   │   ├── components/   # Reusable UI components (ReportTable)
│   │   ├── pages/        # Dashboard, CRUD Forms, Reports
│   │   └── App.tsx       # React router settings
│   └── tailwind.config.js
├── DDL.sql               # Core Database schema and constraints
├── DATASET.sql           # Initial dataset load script
├── FUNCTION_FIX.sql      # Stored procedures and PL/pgSQL database functions
└── CREATE_FUNCTION_INSTRUCTIONS.md # Detailed setup guide for database functions
```

### Technologies Used:
* **Frontend**: React (v18), TypeScript, Tailwind CSS, React Router (v6), Axios.
* **Backend**: Node.js, Express.js.
* **Database**: PostgreSQL (v12+), `pg` connection pool.

---

## ⚙️ Installation & Configuration

### Prerequisites
* **Node.js** (v16 or higher)
* **PostgreSQL** (v12 or higher)

### 1. Database Setup
1. Open your PostgreSQL console and create the database:
   ```sql
   CREATE DATABASE sporttournament;
   ```
2. Populate the tables, data, and functions using the SQL scripts:
   ```bash
   # Load tables schema
   psql -U postgres -d sporttournament -f DDL.sql

   # Populate dataset
   psql -U postgres -d sporttournament -f DATASET.sql

   # Create the custom stored functions
   psql -U postgres -d sporttournament -f FUNCTION_FIX.sql
   ```

### 2. Backend Setup
1. Navigate to the backend directory and install dependencies:
   ```bash
   cd backend
   npm install
   ```
2. Create a `.env` file in `backend/` and configure database connection parameters:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=sporttournament
   DB_USER=postgres
   DB_PASSWORD=your_postgres_password
   PORT=5000
   NODE_ENV=development
   ```
3. Start the Express server:
   ```bash
   npm start
   ```

### 3. Frontend Setup
1. Navigate to the frontend directory and install dependencies:
   ```bash
   cd ../frontend
   npm install
   ```
2. Launch the Vite dev server:
   ```bash
   npm run dev
   ```
3. Open `http://localhost:3000` in your web browser.

---

## 📡 API Reference Endpoints

### Operations & CRUD
* `POST /api/person/player` — Register a person and athlete profile.
* `POST /api/person/spectator` — Register a spectator with tournament tickets.
* `POST /api/tournament` — Add a new tournament schedule.
* `GET /api/player/:id` — Load single player profile.
* `PUT /api/player/:id` — Update contact data and measurements.
* `DELETE /api/player/:id` — Delete a player.

### Reporting & Views
* `GET /api/report/tournament-participants` — Roster of players grouped by tournament.
* `GET /api/report/top-scoring` — Top 10 high-scoring players list.
* `GET /api/report/team-stats` — General win/loss statistics.
* `GET /api/report/multidept-organizers` — Organizers working across multiple departments.
* `GET /api/report/fall-undefeated` — Unbeaten Autumn teams list.

### Database Functions
* `GET /api/function/player-team-college/:id` — Returns `get_player_current_team_info` results.
