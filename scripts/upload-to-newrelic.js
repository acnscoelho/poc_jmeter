require('dotenv').config();
const fs = require("fs");
const csv = require("csv-parser");
const axios = require("axios");

const NEW_RELIC_API_KEY = process.env.NEW_RELIC_API_KEY;

const JTL_FILE = "./results/result.jtl";

async function main() {
  const metricsMap = {};

  fs.createReadStream(JTL_FILE)
    .pipe(csv())
    .on("data", (row) => {
      const label = row.label;
      const elapsed = parseFloat(row.elapsed);

      if (!metricsMap[label]) {
        metricsMap[label] = {
          totalTime: 0,
          count: 0,
        };
      }

      metricsMap[label].totalTime += elapsed;
      metricsMap[label].count += 1;
    })
    .on("end", async () => {
      console.log("Finished reading JTL file!");

      const timestamp = Math.floor(Date.now() / 1000);
      const metricsPayload = [];

      for (const label in metricsMap) {
        const avgTime =
          metricsMap[label].totalTime / metricsMap[label].count;

        metricsPayload.push({
          name: "JMeter.response_time.avg",
          type: "gauge",
          value: avgTime,
          timestamp,
          attributes: {
            label: label,
          },
        });

        console.log(
          `Label: ${label}, Average Response Time: ${avgTime.toFixed(2)} ms`
        );
      }

      const payload = [
        {
          common: {
            attributes: {
              instrumentation_provider: "jmeter",
              test_name: "teste-carga-v1"
            }
          },
          metrics: metricsPayload
        }
      ];

      try {
        const response = await axios.post(
          "https://metric-api.newrelic.com/metric/v1",
          payload,
          {
            headers: {
              "Api-Key": NEW_RELIC_API_KEY,
              "Content-Type": "application/json",
            },
          }
        );

        console.log("Metrics sent to New Relic:", response.status);
      } catch (error) {
        console.error("Error sending metrics:", error.response?.data || error);
      }
    });
}

main();
