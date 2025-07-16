# Configuração de Variáveis de Ambiente

## Arquivo .env

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```env
# Configurações da API
API_PROTOCOL=http
API_HOST=localhost
API_PORT=3000
API_USER=julio.lima
API_PASS=123456

# New Relic API Key
NEWRELIC_API_KEY=sua_api_key_do_new_relic_aqui
```

## GitHub Secrets

Para a pipeline do GitHub Actions, configure os seguintes secrets:

1. **NEWRELIC_API_KEY**: Sua API key do New Relic
2. **API_USER**: Usuário para autenticação (ex: julio.lima)
3. **API_PASS**: Senha para autenticação (ex: 123456)

### Como obter a API Key do New Relic

1. Acesse sua conta do New Relic
2. Vá para **Account settings** → **API keys**
3. Clique em **Create a key**
4. Selecione **Ingest - License** ou **Ingest - Insert**
5. Copie a chave gerada

### Como configurar secrets no GitHub

1. Vá para seu repositório no GitHub
2. Clique em **Settings** → **Secrets and variables** → **Actions**
3. Clique em **New repository secret**
4. Adicione cada secret com o nome e valor correspondente

## Variáveis de Ambiente no JMeter

O plano de teste do JMeter usa as seguintes variáveis:

- `${__P(API_PROTOCOL,http)}`: Protocolo da API (padrão: http)
- `${__P(API_HOST,localhost)}`: Host da API (padrão: localhost)
- `${__P(API_PORT,3000)}`: Porta da API (padrão: 3000)
- `${__P(API_USER,julio.lima)}`: Usuário para autenticação
- `${__P(API_PASS,123456)}`: Senha para autenticação

## Exemplo de Uso

### Local
```bash
# Definir variáveis de ambiente
export API_PROTOCOL=http
export API_HOST=localhost
export API_PORT=3000
export API_USER=julio.lima
export API_PASS=123456
export NEWRELIC_API_KEY=sua_chave_aqui

# Executar testes
npm run start:mock-api &
sleep 5
./apache-jmeter-5.4.1/bin/jmeter -n -t test-plan/poc_transferencias.jmx -l results/result.jtl
npm run upload-nr
```

### GitHub Actions
As variáveis são automaticamente configuradas através dos secrets do repositório. 