## 🇧🇷 POC JMeter (Português)

Este projeto é uma **Prova de Conceito (POC)** criada para demonstrar habilidades práticas em testes de performance utilizando o **Apache JMeter**. O objetivo foi simular um cenário real de autenticação e consulta de transferências bancárias, validando o desempenho da API fornecida na mentoria do Júlio de Lima.

---

## 🚀 Cenário Testado

Fluxo testado no JMeter:

- Login na API (`POST /login`) usando o usuário `${API_USER}`
- Extração do token JWT da resposta
- Requisição autenticada em `GET /transferencias` usando o header `Authorization: Bearer <token>`
- Simulação de usuários simultâneos (configurável)
- Geração de dashboard HTML do JMeter
- Integração com New Relic via Metric API

```
- Simulação de **50 usuários simultâneos** (configurável no JMeter)
- Geração de relatório HTML com resultados da execução
```

---

## ⚙️ Configuração do Teste

- Ferramenta: Apache JMeter 5.4.1
- Execução: CLI (modo non-GUI)
- Usuários: 600 threads
- Ramp-up: 30 segundos
- Loops: 1
- Resultados: `results/result.jtl` e `results/dashboard/`

---

## ✅ Variáveis de Ambiente (.env)

Crie um arquivo `.env` na raiz do projeto com o seguinte conteúdo:

```
API_PROTOCOL=http
API_HOST=localhost
API_PORT=3000
API_USER=seu_usuario_aqui
API_PASS=sua_senha_aqui

NEWRELIC_API_KEY=sua_api_key_aqui
```

### ✅ Rodando o JMeter

#### Windows (CMD)

```cmd
set API_PROTOCOL=http
set API_HOST=localhost
set API_PORT=3000
set API_USER=seu_usuario_aqui
set API_PASS=sua_senha_aqui

jmeter.bat -n -t test-plan\poc_transferencias.jmx -l results
esult.jtl -e -o results\dashboard -JAPI_PROTOCOL=%API_PROTOCOL% -JAPI_HOST=%API_HOST% -JAPI_PORT=%API_PORT% -JAPI_USER=%API_USER% -JAPI_PASS=%API_PASSWORD%
```

#### PowerShell

```powershell
$env:API_PROTOCOL = "http"
$env:API_HOST = "localhost"
$env:API_PORT = "3000"
$env:API_USER = "seu_usuario_aqui"
$env:API_PASS = "sua_senha_aqui"

& "C:\apache-jmeter-5.4.1\bin\jmeter.bat" -n -t test-plan\poc_transferencias.jmx -l results\result.jtl -e -o results\dashboard `
  -JAPI_PROTOCOL=$env:API_PROTOCOL `
  -JAPI_HOST=$env:API_HOST `
  -JAPI_PORT=$env:API_PORT `
  -JAPI_USER=$env:API_USER `
  -JAPI_PASS=$env:API_PASS
```

---

### ✅ Rodando integração com New Relic

Após a execução do teste no JMeter, você pode enviar as métricas para o New Relic.

#### 📦 Instale as dependências necessárias:

```bash
npm install dotenv axios csv-parser
```

#### 🔐 Certifique-se de configurar sua chave no arquivo `.env`:

```
NEWRELIC_API_KEY=sua_api_key_aqui
```

#### ▶️ Execute o script:

```powershell
node scripts/upload-to-newrelic.js
```

Esse script:

- Lê o arquivo `result.jtl`
- Agrupa os resultados por `label` (ex: `/login`, `/transferencias`)
- Calcula o tempo médio de resposta por endpoint
- Envia a métrica `JMeter.response_time.avg` para o New Relic via Telemetry API

💡 Funciona inclusive com contas do plano gratuito (Free Tier) da New Relic.

---

## 🤖 CI/CD Manual com GitHub Actions

Esta POC pode ser executada manualmente pela interface do GitHub Actions usando workflow_dispatch. O relatório é salvo localmente em results/dashboard e incluído como artefato para download.

📄 Pipeline de exemplo (.github/workflows/jmeter-test.yml)

```
name: Run JMeter Performance Test

on:
  workflow_dispatch:

jobs:
  performance-test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup JMeter
      run: |
        sudo apt-get update
        sudo apt-get install -y openjdk-11-jre-headless
        wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.4.1.tgz
        tar -xzf apache-jmeter-5.4.1.tgz
        export PATH=$PATH:$PWD/apache-jmeter-5.4.1/bin

    - name: Run JMeter Test
      run: |
        ./apache-jmeter-5.4.1/bin/jmeter -n -t test-plan/poc_transferencias.jmx \
        -l results/result.jtl -e -o results/dashboard \
        -JAPI_PROTOCOL=${{ secrets.API_PROTOCOL }} \
        -JAPI_HOST=${{ secrets.API_HOST }} \
        -JAPI_PORT=${{ secrets.API_PORT }} \
        -JAPI_USER=${{ secrets.API_USER }} \
        -JAPI_PASSWORD=${{ secrets.API_PASSWORD }}

    - name: Upload Test Report
      uses: actions/upload-artifact@v3
      with:
        name: JMeter-Report
        path: results/dashboard

```

🔐 Variáveis deverão ser definidas em Settings > Secrets and variables > Actions no seu repositório do GitHub.

## 📂 Estrutura do Projeto

```
poc-jmeter/
├── .github/
│   └── workflows/
│        └── jmeter-test.yml
├── test-plan/
│   └── poc_transferencias.jmx
├── results/
│   ├── result.jtl
│   ├── dashboard/
│   ├── jmeter-dashboard.png
│   └── newrelic-dashboard.png
├── scripts/
│   └── upload-to-newrelic.js
├── .env.example
└── README.md
```

---

## 📊 Relatório de Performance

### ✅ Dashboard JMeter

![Dashboard JMeter](results/jmeter-dashboard.png)

### ✅ Dashboard New Relic

![Dashboard New Relic](results/newrelic-dashboard.png)

> 💡 Todos os requests foram executados com sucesso (100% de acerto), com tempos de resposta abaixo de 40ms no pior cenário (Login).

---

## 📌 Observações Técnicas

- Extração do token feita com **JSON Extractor**
- Header `Authorization: Bearer <token>` configurado dinamicamente
- Os listeners do tipo **View Results Tree** foram usados apenas para depuração local no JMeter GUI
- Integração com New Relic feita com Node.js + Axios via Metric API v1
- Leitura de variáveis de ambiente com o pacote **dotenv**

---

👤 Autora

Ana Cláudia Coelho

QA Engineer | Performance Testing | CI/CD

---

## 🇺🇸 JMeter POC (English)

This project is a Proof of Concept (POC) created to demonstrate practical skills in performance testing using Apache JMeter. The goal was to simulate a real scenario of authentication and querying banking transfers, validating the performance of an API provided in Júlio de Lima’s mentorship.


---

## 🚀 Test Scenario

Test flow in JMeter:

- Login to the API (POST /login) using `${API_USER}`
- Extract JWT token from the response
- Authenticated request to `GET /transferencias` using Authorization: `Authorization: Bearer <token>`
- Simulation of concurrent users (configurable)
- Generation of HTML dashboard from JMeter
- Integration with New Relic via Metric API

```
- Simulation of **50 concurrent users** (configurable in JMeter)
- Generation of HTML report with execution results
```

---

## ⚙️ Test Configuration

- Tool: Apache JMeter 5.4.1
- Execution: CLI (non-GUI mode)
- Users: 600 threads
- Ramp-up: 30 seconds
- Loops: 1
- Results: `results/result.jtl` and `results/dashboard/`

---

## ✅ Environment Variables (.env)

Create a `.env` file in the root directory with the following content:

```
API_PROTOCOL=http
API_HOST=localhost
API_PORT=3000
API_USER=your_username_here
API_PASS=your_password_here

NEWRELIC_API_KEY=your_api_key_here
```

### ✅ Running JMeter

#### Windows (CMD)

```cmd
set API_PROTOCOL=http
set API_HOST=localhost
set API_PORT=3000
set API_USER=your_username_here
set API_PASS=your_password_here

jmeter.bat -n -t test-plan\poc_transferencias.jmx -l results
esult.jtl -e -o results\dashboard -JAPI_PROTOCOL=%API_PROTOCOL% -JAPI_HOST=%API_HOST% -JAPI_PORT=%API_PORT% -JAPI_USER=%API_USER% -JAPI_PASSWORD=%API_PASSWORD%
```

#### PowerShell

```powershell
$env:API_PROTOCOL = "http"
$env:API_HOST = "localhost"
$env:API_PORT = "3000"
$env:API_USER = "your_username_here"
$env:API_PASS = "your_password_here"

& "C:\apache-jmeter-5.4.1\bin\jmeter.bat" -n -t test-plan\poc_transferencias.jmx -l results\result.jtl -e -o results\dashboard `
  -JAPI_PROTOCOL=$env:API_PROTOCOL `
  -JAPI_HOST=$env:API_HOST `
  -JAPI_PORT=$env:API_PORT `
  -JAPI_USER=$env:API_USER `
  -JAPI_PASSWORD=$env:API_PASS
```

---

### ✅ Running New Relic Integration

After executing the JMeter test, you can send metrics to New Relic.

#### 📦 Install dependencies:

```bash
npm install dotenv axios csv-parser
```

#### 🔐 Make sure your key is set in the  `.env` file:

```
NEWRELIC_API_KEY=sua_api_key_aqui
```

#### ▶️ Run the script:

```powershell
node scripts/upload-to-newrelic.js
```

This script:

- Reads the `result.jtl` file
- Groups results by `label` (e.g., `/login`, `/transferencias`)
- Calculates average response time per endpoint
- Sends the metric `JMeter.response_time.avg` to New Relic via Telemetry API

💡 Works even with New Relic Free Tier accounts.

---

## 🤖 Manual CI/CD with GitHub Actions

This POC can be executed manually through GitHub Actions UI using workflow_dispatch. The report is saved locally under results/dashboard and included as an artifact for download.

📄 Example pipeline (.github/workflows/jmeter-test.yml)


```
name: Run JMeter Performance Test

on:
  workflow_dispatch:

jobs:
  performance-test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup JMeter
      run: |
        sudo apt-get update
        sudo apt-get install -y openjdk-11-jre-headless
        wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.4.1.tgz
        tar -xzf apache-jmeter-5.4.1.tgz
        export PATH=$PATH:$PWD/apache-jmeter-5.4.1/bin

    - name: Run JMeter Test
      run: |
        ./apache-jmeter-5.4.1/bin/jmeter -n -t test-plan/poc_transferencias.jmx \
        -l results/result.jtl -e -o results/dashboard \
        -JAPI_PROTOCOL=${{ secrets.API_PROTOCOL }} \
        -JAPI_HOST=${{ secrets.API_HOST }} \
        -JAPI_PORT=${{ secrets.API_PORT }} \
        -JAPI_USER=${{ secrets.API_USER }} \
        -JAPI_PASSWORD=${{ secrets.API_PASSWORD }}

    - name: Upload Test Report
      uses: actions/upload-artifact@v3
      with:
        name: JMeter-Report
        path: results/dashboard
```
🔐 Variables must be defined in Settings > Secrets and variables > Actions in your GitHub repository.

## 📂 Estrutura do Projeto

```
poc-jmeter/
├── .github/
│   └── workflows/
│        └── jmeter-test.yml
├── test-plan/
│   └── poc_transferencias.jmx
├── results/
│   ├── result.jtl
│   ├── dashboard/
│   ├── jmeter-dashboard.png
│   └── newrelic-dashboard.png
├── scripts/
│   └── upload-to-newrelic.js
├── .env.example
└── README.md
```

---

## 📊 Performance Report

### ✅ JMeter Dashboard

![Dashboard JMeter](results/jmeter-dashboard.png)

### ✅ New Relic Dashboard

![Dashboard New Relic](results/newrelic-dashboard.png)

> 💡 All requests were successfully executed (100% success rate), with response times under 40ms in the worst-case scenario (Login).

---

## 📌 Technical Notes

- Token extracted with **JSON Extractor**
- `Authorization: Bearer <token>` header dynamically configured
- **View Results Tree** listeners were used only for local debugging in JMeter GUI
- New Relic integration built with Node.js + Axios via Metric API v1
- Environment variables handled using **dotenv** package

---

👤 Autora

Ana Cláudia Coelho

QA Engineer | Performance Testing | CI/CD

---
