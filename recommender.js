require('dotenv').config();
const fs = require('fs');
const pg = require('pg');
require('@tensorflow/tfjs-node');
const use = require('@tensorflow-models/universal-sentence-encoder');

const config = {
    user: process.env.PG_USER,
    password: process.env.PG_PASSWORD,
    host: process.env.PG_HOST,
    port: process.env.PG_PORT,
    database: process.env.PG_NAME,
};

use.load().then(async model => {
    const embeddings = await model.embed("a lot of plot twist");
    const embeddingArray = embeddings.arraySync()[0];

    const client = new pg.Client(config);
    await client.connect();
    try {
        const pgResponse = await client.query(`SELECT * FROM movie_plots ORDER BY embedding <-> '${JSON.stringify(embeddingArray)}' LIMIT 5;`);
        console.log(pgResponse.rows);
    } catch (err) {
        console.error(err);
    } finally {
        await client.end()
    }
});