// mock-api/server.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.post('/login', (req, res) => {
  const { username, senha } = req.body;
  if (username === 'julio.lima' && senha === '123456') {
    return res.json({
      token: 'mocked-jwt-token-123'
    });
  }
  res.status(401).json({ error: 'Unauthorized' });
});

app.get('/transferencias', (req, res) => {
  const authHeader = req.headers['authorization'];
  if (authHeader === 'Bearer mocked-jwt-token-123') {
    return res.json([
      { id: 1, valor: 100 },
      { id: 2, valor: 200 }
    ]);
  }
  res.status(403).json({ error: 'Forbidden' });
});

app.listen(port, () => {
  console.log(`Mock API rodando na porta ${port}`);
});
