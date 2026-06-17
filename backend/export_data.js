const pool = require('./db/db');
const fs = require('fs');

const tables = [
  'person', 'tournament', 'company', 'sponsors', 'sponsorstournament', 
  'sports', 'sporttype', 'equipments', 'coach', 'venue', 'referee', 'organizer', 
  'player', 'spectatorpass', 'team', 'match', 'sportrules', 'accommodation', 
  'organizetournament', 'spectatorviewmatch', 'playerplaysmatch', 'sportequipments', 
  'playersport', 'playerteam', 'teamplaysmatch', 'teamcoach', 'playerstatistics', 
  'teamstatistics', 'result'
];

async function run() {
  let out = '';
  for (let table of tables) {
    try {
        const { rows } = await pool.query(`SELECT * FROM "${table}"`);
        if (rows.length > 0) {
            for (let row of rows) {
                const keys = Object.keys(row).map(k => `"${k}"`).join(', ');
                const values = Object.values(row).map(v => {
                    if (v === null) return 'NULL';
                    if (typeof v === 'string') return `'${v.replace(/'/g, "''")}'`;
                    if (v instanceof Date) return `'${v.toISOString()}'`;
                    return v;
                }).join(', ');
                out += `INSERT INTO "${table}" (${keys}) VALUES (${values});\n`;
            }
        }
    } catch(e) { 
        // silently ignore tables that might literally have upper case locally vs here, or just not exist
        // actually Postgres folds lower case unless quoted, our script quotes so let's retry lowercase
        if (e.message.includes('does not exist')) {
            try {
                const { rows } = await pool.query(`SELECT * FROM ${table}`);
                if (rows.length > 0) {
                    for (let row of rows) {
                        const keys = Object.keys(row).map(k => `"${k}"`).join(', ');
                        const values = Object.values(row).map(v => {
                            if (v === null) return 'NULL';
                            if (typeof v === 'string') return `'${v.replace(/'/g, "''")}'`;
                            if (v instanceof Date) return `'${v.toISOString()}'`;
                            return v;
                        }).join(', ');
                        out += `INSERT INTO "${table}" (${keys}) VALUES (${values});\n`;
                    }
                }
            } catch(e2) {
                console.error(`Failed on ${table}: ${e2.message}`);
            }
        } else {
             console.error(`Error on ${table}: ${e.message}`);
        }
    }
  }
  fs.writeFileSync('mock_data.sql', out);
  console.log("SUCCESS");
  process.exit(0);
}
run();
