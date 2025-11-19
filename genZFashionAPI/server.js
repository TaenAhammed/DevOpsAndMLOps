const express = require('express');
const mongoose = require('mongoose');
const userRoutes = require('./routes/users');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Database connection
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/genZFashionDB');
    console.log('MongoDB connected...');
  } catch (err) {
    console.log(err);
  }
};

// Only connect if not in test mode
if (process.env.NODE_ENV !== 'test') {
  connectDB();
}

// Routes
app.get('/', (req, res) => {
  res.send('GenZ Fashion API!');
});

app.use('/api/users', userRoutes);

// Start server only if not in test mode
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
  });
}

module.exports = app;

