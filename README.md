# POC JMeter - Teste de Performance com New Relic

Este projeto demonstra como executar testes de performance com Apache JMeter e integrar os resultados com o New Relic através de uma pipeline automatizada no GitHub Actions.

## 🚀 Funcionalidades

- ✅ Teste de login e transferências com JMeter
- ✅ API mock para testes locais e em CI/CD
- ✅ Geração automática de dashboard do JMeter
- ✅ Integração com New Relic para monitoramento
- ✅ Pipeline automatizada no GitHub Actions
- ✅ Upload de artefatos (dashboard e resultados)

## 📋 Pré-requisitos

- Node.js 18+
- Apache JMeter 5.4.1
- Conta no New Relic (para integração)

## 🛠️ Configuração Local

### 1. Instalação de Dependências

```bash
npm install
```

### 2. Configuração das Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
NEWRELIC_API_KEY=sua_api_key_do_new_relic
API_USER=julio.lima
API_PASS=123456
```

### 3. Execução Local

#### Iniciar a API Mock

```bash
npm run start:mock-api
```

#### Executar Testes com JMeter

```bash
# Baixar JMeter (se necessário)
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.1.tgz
tar -xzf apache-jmeter-5.4.1.tgz

# Executar testes
./apache-jmeter-5.4.1/bin/jmeter \
  -n \
  -t test-plan/poc_transferencias.jmx \
  -l results/result.jtl \
  -JAPI_PROTOCOL=http \
  -JAPI_HOST=localhost \
  -JAPI_PORT=3000 \
  -JAPI_USER=julio.lima \
  -JAPI_PASS=123456

# Gerar dashboard
./apache-jmeter-5.4.1/bin/jmeter \
  -g results/result.jtl \
  -o results/dashboard
```

#### Enviar Dados para New Relic

```bash
npm run upload-nr
```

## 🔧 Configuração do GitHub Actions

### Secrets Necessários

Configure os seguintes secrets no seu repositório GitHub:

1. **NEWRELIC_API_KEY**: Sua API key do New Relic
2. **API_USER**: Usuário para autenticação (ex: julio.lima)
3. **API_PASS**: Senha para autenticação (ex: 123456)

### Como Configurar Secrets

1. Vá para seu repositório no GitHub
2. Clique em **Settings** → **Secrets and variables** → **Actions**
3. Clique em **New repository secret**
4. Adicione cada secret com o nome e valor correspondente

### Executar a Pipeline

1. Vá para a aba **Actions** no seu repositório
2. Selecione o workflow **"Teste de Performance com JMeter e New Relic"**
3. Clique em **Run workflow**
4. Aguarde a execução completa

## 📊 Resultados

### Artefatos Gerados

A pipeline gera os seguintes artefatos:

- **jmeter-dashboard**: Dashboard HTML completo do JMeter
- **jmeter-results**: Arquivo result.jtl com dados brutos dos testes

### Métricas Enviadas para New Relic

- Tempo médio de resposta por endpoint
- Contagem de requisições
- Labels dos testes executados

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. API Mock não inicia

**Sintoma**: Pipeline falha na verificação da API
**Solução**: Verifique os logs da API mock no final da execução

#### 2. Arquivo result.jtl não gerado

**Sintoma**: Erro "Arquivo result.jtl não foi gerado!"
**Possíveis causas**:
- API mock não está respondendo
- Problemas de conectividade
- Configuração incorreta do JMeter

#### 3. Dashboard não gerado

**Sintoma**: Erro "Dashboard não foi gerado!"
**Solução**: Verifique se o arquivo result.jtl foi criado corretamente

#### 4. Falha no upload para New Relic

**Sintoma**: Erro ao enviar métricas
**Verificações**:
- API key do New Relic está correta
- Arquivo result.jtl existe e tem dados
- Conectividade com a API do New Relic

### Logs de Debug

A pipeline inclui logs detalhados para debug:

- Status da API mock
- Verificação de arquivos gerados
- Logs do script de upload para New Relic
- Logs da API mock (ao final da execução)

## 📁 Estrutura do Projeto

```
poc-jmeter/
├── .github/workflows/
│   └── jmeter-test.yml          # Pipeline do GitHub Actions
├── mock-api/
│   └── server.js                # API mock para testes
├── scripts/
│   └── upload-to-newrelic.js    # Script de upload para New Relic
├── test-plan/
│   └── poc_transferencias.jmx   # Plano de teste do JMeter
├── results/                     # Resultados dos testes
├── package.json
└── README.md
```

## 🔄 Melhorias Implementadas

### Pipeline do GitHub Actions

- ✅ Setup adequado do Node.js com cache
- ✅ Verificação robusta da API mock
- ✅ Validação de arquivos gerados
- ✅ Tratamento de erros melhorado
- ✅ Logs detalhados para debug
- ✅ Upload de múltiplos artefatos

### Script de Upload para New Relic

- ✅ Validação de API key
- ✅ Verificação de arquivo JTL
- ✅ Tratamento de erros robusto
- ✅ Logs detalhados
- ✅ Timeout configurado

### Plano de Teste JMeter

- ✅ Uso de variáveis de ambiente
- ✅ Configuração flexível para diferentes ambientes

## 📈 Próximos Passos

1. **Adicionar mais cenários de teste**
2. **Implementar testes de carga**
3. **Adicionar métricas customizadas**
4. **Integrar com outros sistemas de monitoramento**
5. **Implementar alertas baseados em thresholds**

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença ISC.
# trigger workflow
