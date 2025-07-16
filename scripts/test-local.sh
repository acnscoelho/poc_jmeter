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
mkdir -p results/dashboard

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
    -p jmeter-dashboard.properties \
    -Jjmeter.save.saveservice.assertion_results=none \
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

# Limpa a pasta do dashboard antes de gerar um novo
echo "🧹 Limpando pasta results/dashboard..."
rm -rf results/dashboard
mkdir -p results/dashboard

# Gera o dashboard
echo "📊 Gerando dashboard do JMeter..."
./apache-jmeter-5.4.1/bin/jmeter \
    -g results/result.jtl \
    -o results/dashboard

# Verifica se o dashboard foi gerado
if [ ! -d "results/dashboard" ] || [ -z "$(ls -A results/dashboard)" ]; then
    echo "❌ Dashboard não foi gerado!"
    kill $MOCK_PID 2>/dev/null || true
    exit 1
fi

echo "✅ Dashboard gerado com sucesso!"

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
echo "   - results/dashboard/"
echo ""
echo "🚀 Agora você pode fazer push para o GitHub e executar a pipeline!" 