#!/bin/bash

# Script de teste local para verificar se tudo está funcionando
# Execute este script antes de fazer push para o GitHub

set -e  # Para o script se houver erro

echo "🚀 Iniciando teste local da POC JMeter..."

# Verifica se o Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não está instalado!"
    exit 1
fi

echo "✅ Node.js encontrado: $(node --version)"

# Verifica se o npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm não está instalado!"
    exit 1
fi

echo "✅ npm encontrado: $(npm --version)"

# Instala dependências
echo "📦 Instalando dependências..."
npm install

# Verifica se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado!"
    echo "📝 Crie um arquivo .env baseado no ENV_SETUP.md"
    exit 1
fi

echo "✅ Arquivo .env encontrado"

# Verifica se o JMeter está disponível
if [ ! -d "apache-jmeter-5.4.1" ]; then
    echo "📥 Baixando Apache JMeter..."
    powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.1.tgz' -OutFile 'apache-jmeter-5.4.1.tgz'"
    tar -xzf apache-jmeter-5.4.1.tgz
    rm apache-jmeter-5.4.1.tgz
fi

echo "✅ Apache JMeter encontrado"

# Cria diretório de resultados
mkdir -p results

# Inicia a API mock
echo "🔧 Iniciando API mock..."
nohup node mock-api/server.js > mock-api.log 2>&1 &
MOCK_PID=$!

# Aguarda a API inicializar
echo "⏳ Aguardando API mock inicializar..."
sleep 5

# Verifica se a API está funcionando
echo "🔍 Verificando se a API mock está funcionando..."
for i in {1..10}; do
    if curl -s http://localhost:3000/login > /dev/null 2>&1; then
        echo "✅ API mock está funcionando!"
        break
    fi
    echo "Tentativa $i: API ainda não está pronta..."
    sleep 2
done

if ! curl -s http://localhost:3000/login > /dev/null 2>&1; then
    echo "❌ API mock não está respondendo!"
    kill $MOCK_PID 2>/dev/null || true
    exit 1
fi

# Executa o teste do JMeter
echo "🧪 Executando teste do JMeter..."
./apache-jmeter-5.4.1/bin/jmeter \
    -n \
    -t test-plan/poc_transferencias.jmx \
    -l results/result.jtl \
    -Jjmeter.save.saveservice.output_format=csv \
    -Jjmeter.save.saveservice.assertion_results=none \
    -Jjmeter.save.saveservice.bytes=true \
    -Jjmeter.save.saveservice.label=true \
    -Jjmeter.save.saveservice.latency=true \
    -Jjmeter.save.saveservice.response_code=true \
    -Jjmeter.save.saveservice.response_message=true \
    -Jjmeter.save.saveservice.successful=true \
    -Jjmeter.save.saveservice.thread_counts=true \
    -Jjmeter.save.saveservice.thread_name=true \
    -Jjmeter.save.saveservice.time=true \
    -Jjmeter.save.saveservice.connect_time=true \
    -Jjmeter.save.saveservice.samplerData=false \
    -Jjmeter.save.saveservice.responseData=false \
    -Jjmeter.save.saveservice.responseHeaders=false \
    -Jjmeter.save.saveservice.requestHeaders=false \
    -Jjmeter.save.saveservice.encoding=false \
    -Jjmeter.save.saveservice.url=true \
    -Jjmeter.save.saveservice.sent_bytes=true \
    -Jjmeter.save.saveservice.idle_time=true \
    -Jjmeter.save.saveservice.csv.separator=, \
    -JAPI_PROTOCOL=http \
    -JAPI_HOST=localhost \
    -JAPI_PORT=3000 \
    -JAPI_USER=julio.lima \
    -JAPI_PASS=123456

# Verifica se o arquivo result.jtl foi gerado
if [ ! -f "results/result.jtl" ]; then
    echo "❌ Arquivo result.jtl não foi gerado!"
    kill $MOCK_PID 2>/dev/null || true
    exit 1
fi

echo "✅ Arquivo result.jtl gerado com sucesso!"

echo "🔍 Verificando dados do arquivo result.jtl..."
if [ ! -s "results/result.jtl" ]; then
    echo "❌ Arquivo result.jtl está vazio!"
    kill $MOCK_PID 2>/dev/null || true
    exit 1
fi

echo "✅ Arquivo result.jtl contém dados válidos!"

# Testa o upload para New Relic
echo "📤 Testando upload para New Relic..."
if npm run upload-nr; then
    echo "✅ Upload para New Relic funcionando!"
else
    echo "⚠️  Upload para New Relic falhou (verifique a API key)"
fi

# Para a API mock
echo "🛑 Parando API mock..."
kill $MOCK_PID 2>/dev/null || true

echo ""
echo "🎉 Teste local concluído com sucesso!"
echo "📁 Resultados disponíveis em:"
echo "   - results/result.jtl"
echo ""
echo "🚀 Agora você pode fazer push para o GitHub e executar a pipeline!" 