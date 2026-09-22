// Simple Express API untuk Carhartt Shop
// Endpoints:
//   GET /api/products
//   GET /api/products?category=T-Shirt
//   GET /api/products/:id

const express = require('express');
const cors = require('cors');
const products = require('./data/products');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/', (req, res) => {
  res.json({ success: true, message: 'Carhartt Shop API running', endpoints: ['/api/products', '/api/products/:id'] });
});

// GET /api/products  + filter ?category=
app.get('/api/products', (req, res) => {
  try {
    const { category } = req.query;
    let result = products;

    if (category) {
      const cat = category.trim().toLowerCase();
      result = products.filter((p) => p.category.toLowerCase() === cat);
    }

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// GET /api/products/:id
app.get('/api/products/:id', (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    const product = products.find((p) => p.id === id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product tidak ditemukan',
      });
    }

    res.status(200).json({
      success: true,
      data: product,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// 404 untuk route lain
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route tidak ditemukan' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Carhartt Shop API running at http://localhost:${PORT} and http://0.0.0.0:${PORT}`);
  console.log(`GET http://localhost:${PORT}/api/products`);
  console.log(`GET http://localhost:${PORT}/api/products/1`);
  console.log(`GET http://localhost:${PORT}/api/products?category=T-Shirt`);
  console.log('Listening on 0.0.0.0 for Android emulator (10.0.2.2) and physical device');
});
