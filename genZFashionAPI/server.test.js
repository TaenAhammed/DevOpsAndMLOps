const request = require('supertest');
const mongoose = require('mongoose');
const app = require('./server');
const User = require('./models/User');

describe('User CRUD API', () => {
  beforeAll(async () => {
    await mongoose.connect('mongodb://localhost:27017/genZFashionDB_test');
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    await User.deleteMany({});
  });

  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
        age: 25
      };

      const response = await request(app)
        .post('/api/users')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('_id');
      expect(response.body.name).toBe(userData.name);
      expect(response.body.email).toBe(userData.email);
      expect(response.body.age).toBe(userData.age);
    });

    it('should return error for invalid user data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({ name: 'John' })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('GET /api/users', () => {
    it('should get all users', async () => {
      await User.create([
        { name: 'User 1', email: 'user1@example.com', age: 20 },
        { name: 'User 2', email: 'user2@example.com', age: 30 }
      ]);

      const response = await request(app)
        .get('/api/users')
        .expect(200);

      expect(response.body).toHaveLength(2);
    });
  });

  describe('GET /api/users/:id', () => {
    it('should get a user by ID', async () => {
      const user = await User.create({
        name: 'Jane Doe',
        email: 'jane@example.com',
        age: 28
      });

      const response = await request(app)
        .get(`/api/users/${user._id}`)
        .expect(200);

      expect(response.body.name).toBe(user.name);
      expect(response.body.email).toBe(user.email);
    });

    it('should return 404 for non-existent user', async () => {
      const fakeId = new mongoose.Types.ObjectId();
      await request(app)
        .get(`/api/users/${fakeId}`)
        .expect(404);
    });
  });

  describe('PUT /api/users/:id', () => {
    it('should update a user', async () => {
      const user = await User.create({
        name: 'Old Name',
        email: 'old@example.com',
        age: 25
      });

      const updatedData = {
        name: 'New Name',
        age: 30
      };

      const response = await request(app)
        .put(`/api/users/${user._id}`)
        .send(updatedData)
        .expect(200);

      expect(response.body.name).toBe(updatedData.name);
      expect(response.body.age).toBe(updatedData.age);
    });

    it('should return 404 for non-existent user', async () => {
      const fakeId = new mongoose.Types.ObjectId();
      await request(app)
        .put(`/api/users/${fakeId}`)
        .send({ name: 'Test' })
        .expect(404);
    });
  });

  describe('DELETE /api/users/:id', () => {
    it('should delete a user', async () => {
      const user = await User.create({
        name: 'To Delete',
        email: 'delete@example.com',
        age: 25
      });

      const response = await request(app)
        .delete(`/api/users/${user._id}`)
        .expect(200);

      expect(response.body.message).toBe('User deleted successfully');

      const deletedUser = await User.findById(user._id);
      expect(deletedUser).toBeNull();
    });

    it('should return 404 for non-existent user', async () => {
      const fakeId = new mongoose.Types.ObjectId();
      await request(app)
        .delete(`/api/users/${fakeId}`)
        .expect(404);
    });
  });
});
