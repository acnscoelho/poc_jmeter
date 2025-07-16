require('dotenv').config();
const fs = require("fs");
const csv = require("csv-parser");
const axios = require("axios");

const NEWRELIC_API_KEY = process.env.NEWRELIC_API_KEY;
const JTL_FILE = "./results/result_clean.jtl";

async function main() {
  console.log("Iniciando upload de métricas para o New Relic...");
  
  // Verifica se a API key está disponível
  if (!NEWRELIC_API_KEY || NEWRELIC_API_KEY === 'dummy') {
    console.log("⚠️  AVISO: NEWRELIC_API_KEY não está configurada ou é inválida!");
    console.log("📝 Para configurar, vá em Settings > Secrets and variables > Actions");
    console.log("🔑 Adicione o secret 'NEWRELIC_API_KEY' com sua chave da API do New Relic");
    console.log("⏭️  Pulando upload para o New Relic...");
    process.exit(0); // Sai com sucesso, não com erro
  }

  // Verifica se o arquivo JTL existe
  let jtlFile = JTL_FILE;
  if (!fs.existsSync(jtlFile)) {
    // Tenta usar o arquivo original se o limpo não existir
    jtlFile = "./results/result.jtl";
    if (!fs.existsSync(jtlFile)) {
      console.error(`ERRO: Arquivo ${JTL_FILE} ou ./results/result.jtl não encontrado!`);
      process.exit(1);
    }
    console.log(`Usando arquivo original: ${jtlFile}`);
  } else {
    console.log(`Usando arquivo limpo: ${jtlFile}`);
  }

  console.log(`Lendo arquivo: ${jtlFile}`);
  const metricsMap = {};

  fs.createReadStream(jtlFile)
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
      console.log("Arquivo JTL lido com sucesso!");
      console.log(`Métricas encontradas: ${Object.keys(metricsMap).length}`);

      if (Object.keys(metricsMap).length === 0) {
        console.error("ERRO: Nenhuma métrica encontrada no arquivo JTL!");
        process.exit(1);
      }

      const timestamp = Math.floor(Date.now() / 1000);
      const metricsPayload = [];

      for (const label in metricsMap) {
        const avgTime = metricsMap[label].totalTime / metricsMap[label].count;

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
        console.log("Enviando métricas para o New Relic...");
        const response = await axios.post(
          "https://metric-api.newrelic.com/metric/v1",
          payload,
          {
            headers: {
              "Api-Key": NEWRELIC_API_KEY,
              "Content-Type": "application/json",
            },
            timeout: 30000, // 30 segundos de timeout
          }
        );

        console.log(`✅ Métricas enviadas para o New Relic com sucesso! Status: ${response.status}`);
        console.log(`📊 Total de métricas enviadas: ${metricsPayload.length}`);
      } catch (error) {
        console.error("❌ Erro ao enviar métricas para o New Relic:");
        if (error.response) {
          console.error(`Status: ${error.response.status}`);
          console.error(`Dados: ${JSON.stringify(error.response.data, null, 2)}`);
        } else if (error.request) {
          console.error("Erro de rede:", error.message);
        } else {
          console.error("Erro:", error.message);
        }
        process.exit(1);
      }
    })
    .on("error", (error) => {
      console.error("❌ Erro ao ler arquivo JTL:", error.message);
      process.exit(1);
    });
}

main();
